/* We download the dataset previously, so local file will be used
   We use UTF-8 to encode the dataset
   Otherwise, [ERROR: Invalid characters were present in the data.] will be showed
   We use SAS® OnDemand for Academics for this project
   For dealing with column name with space, use "<varname>"n
   Some preproduction features cannot be used on SAS 9.4 1M4 Desktop version */

/* Set file reference */
FILENAME DATAUTF "/home/u49784411/ttemp/top10s_utf8.csv" ENCODING='utf-8';


/* Stop creating previous title */
TITLE;


/* Import the csv data */
PROC IMPORT DATAFILE=DATAUTF
    OUT=AMS
    DBMS=CSV
    REPLACE;
    GUESSINGROWS=1000;
    DELIMITER=",";    
RUN;


/* Drop id column and subset variables into 3 categories */
DATA AMS;
    SET AMS;
    DROP VAR1;
    IF bpm<144 AND bpm>=103 THEN bpmsub="Medium";
        ELSE IF bpm<103 THEN bpmsub="Slow";
        ELSE IF bpm>=144 THEN bpmsub="Fast";
    IF nrgy<78 AND nrgy>=49 THEN nrgysub="Medium";
        ELSE IF nrgy<49 THEN nrgysub="Low";
        ELSE IF nrgy>=78 THEN nrgysub="High";
    IF dnce<77 AND dnce>=48 THEN dncesub="Medium";
        ELSE IF dnce<48 THEN dncesub="Low";
        ELSE IF dnce>=77 THEN dncesub="High";
RUN;


/* PDF print output start here */
ODS PDF FILE = "/home/u49784411/ttemp/AMS2640_Output_35.pdf" STARTPAGE=NO;
ODS NOPROCTITLE;


/* Info and statistics for variables */
PROC CONTENTS DATA=AMS;
RUN;


/* Compute summary statistics for numeric variables except year */
PROC UNIVARIATE DATA=AMS;
    VAR bpm nrgy dnce dB live val dur acous spch pop;
RUN;


/* Correlation matrix between variables with scatter Matrix for variables */
PROC CORR DATA=AMS PEARSON 
    PLOTS=MATRIX(HISTOGRAM NVAR=ALL)
    PLOTS(MAXPOINTS=1000000);
    VAR bpm nrgy dnce dB live val dur acous spch pop;
RUN;


/* -----Graph----- */
/* Show pie chart with top 20 different genre (including others) */
PROC SGPIE DATA=AMS;
    PIE "top genre"n / MAXSLICES=20 SLICEORDER=RESPASC OTHERLABEL="Others";
    TITLE "Top 20 genre of songs";
RUN;


/* Barchart for year and subsetted variables */
PROC SGPLOT DATA=AMS;
    VBAR year / COLORSTAT=FREQ;
    YAXIS LABEL="Count";
    TITLE "Bar chart by year";
    	
RUN;

PROC SGPLOT DATA=AMS;
    VBAR bpmsub;
    YAXIS LABEL="Count";
    TITLE "Bar chart of bpm by category";
RUN;

PROC SGPLOT DATA=AMS;
    VBAR nrgysub;
    YAXIS LABEL="Count";
    TITLE "Bar chart of nrgy by category";
RUN;

PROC SGPLOT DATA=AMS;
    VBAR dncesub;
    YAXIS LABEL="Count";
    TITLE "Bar chart of dnce by category";
RUN;


/* Show pie chart for subsetted variables */
PROC SGPIE DATA=AMS;
    PIE bpmsub / SLICEORDER=RESPASC DATALABELDISPLAY=ALL;
    TITLE "Pie chart of bpm by category";
RUN;

PROC SGPIE DATA=AMS;
    PIE nrgysub / SLICEORDER=RESPASC DATALABELDISPLAY=ALL;
    TITLE "Pie chart of nrgy by category";
RUN;

PROC SGPIE DATA=AMS;
    PIE dncesub / SLICEORDER=RESPASC DATALABELDISPLAY=ALL;
    TITLE "Pie chart of dnce by category";
RUN;


/* Box plot for subsetted variables with category */
PROC SGPLOT DATA=AMS;
    HBOX bpm / CATEGORY=bpmsub;
    TITLE "Box plot of bpm with category";
RUN;

PROC SGPLOT DATA=AMS;
    HBOX nrgy / CATEGORY=nrgysub;
    TITLE "Box plot of nrgy with category";
RUN;

PROC SGPLOT DATA=AMS;
    HBOX dnce / CATEGORY=dncesub;
    TITLE "Box plot of dnce with category";
RUN;


/* Histogram for bpm and val */
PROC SGPLOT DATA=AMS;
    HISTOGRAM bpm / SHOWBINS;
    DENSITY bpm / TYPE=NORMAL;
    DENSITY bpm / TYPE=KERNEL;
    TITLE "Histogram of bpm";
    YAXIS LABEL="Percentage";
RUN;

PROC SGPLOT DATA=AMS;
    HISTOGRAM val / SHOWBINS;
    DENSITY val / TYPE=NORMAL;
    DENSITY val / TYPE=KERNEL;
    TITLE "Histogram of val";
    YAXIS LABEL="Percentage";
RUN;



/* Histogram of dance pop genre with bpm, nrgy, dnce with category */
PROC SGPLOT DATA=AMS;
    HISTOGRAM bpm / GROUP=bpmsub;
    WHERE "top genre"n="dance pop";
    DENSITY bpm / TYPE=KERNEL;
    TITLE "Histogram of bpm with category in dance pop genre";
    YAXIS LABEL="Percentage";
RUN;

PROC SGPLOT DATA=AMS;
    HISTOGRAM nrgy / GROUP=nrgysub;
    WHERE "top genre"n="dance pop";
    DENSITY nrgy / TYPE=KERNEL;
    TITLE "Histogram of nrgy with category in dance pop genre";
    YAXIS LABEL="Percentage";
RUN;

PROC SGPLOT DATA=AMS;
    HISTOGRAM dnce / GROUP=dncesub;
    WHERE "top genre"n="dance pop";
    DENSITY dnce / TYPE=KERNEL;
    TITLE "Histogram of dnce with category in dance pop genre";
    YAXIS LABEL="Percentage";
RUN;

PROC SGPLOT DATA=AMS;
    HISTOGRAM db;
    WHERE "top genre"n="dance pop";
    DENSITY db / TYPE=KERNEL;
    TITLE "Histogram of db in dance pop genre";
    YAXIS LABEL="Percentage";
RUN;


/* Show bar chart of top genre in 2015 */
PROC SGPLOT DATA=AMS;
    VBAR "top genre"n;
    WHERE year=2015;
    TITLE "Bar chart of top genre in 2015";
RUN;


/* Count frequency group by artist and year, then delete duplicate records if any */
PROC SQL;
    CREATE TABLE acount AS
    (SELECT artist, year, COUNT(artist) AS Count
     FROM AMS
     GROUP BY year, artist);
QUIT;

PROC SORT DATA=acount NODUPKEY;
    BY _ALL_;
RUN;


/* Show trend of frequency of artist from data above */
PROC SGPLOT DATA=acount;
    SERIES X=year Y=count / GROUP=artist DATALABEL=artist;
    XAXIS VALUES=(2010 TO 2019 BY 1);
    TITLE "Trend of frequency of artist from 2010 to 2019";
RUN;


/* Find all songs of of selected artists in every year */
PROC PRINT DATA=AMS;
    VAR artist title "top genre"n year;
    WHERE artist="Justin Bieber" OR artist="Lady Gaga" OR artist="Ed Sheeran";
    BY year;
RUN;


/* Correlation matrix for variables of selected artists */
PROC CORR DATA=AMS PEARSON 
    PLOTS=MATRIX(HISTOGRAM NVAR=ALL)
    PLOTS(MAXPOINTS=1000000);
	WHERE artist="Justin Bieber" OR artist="Lady Gaga" OR artist="Ed Sheeran";
    VAR bpm nrgy dnce dB live val dur acous spch pop;
	TITLE "Correlation matrix for variables of selected artists";
RUN;


/* Conduct one-way ANOVA for numeric variables of selected artists */
PROC ANOVA DATA=AMS;
    WHERE artist="Justin Bieber" OR artist="Lady Gaga" OR artist="Ed Sheeran";
	CLASS artist;
	MODEL bpm nrgy dnce dB live val dur acous spch pop=artist;
    TITLE "ANOVA for variables of selected artists";
RUN;


/* PDF print output till here */
ODS PDF CLOSE;


/* Export sas dataset to sas7bdat */
DATA "/home/u49784411/ttemp";
   SET AMS;
RUN;

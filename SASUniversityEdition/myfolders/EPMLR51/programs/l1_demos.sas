/* Code for the Lesson 1 Demonstrations in the SAS e-Course 
   "Predictive Modeling Using Logistic Regression" */

/* The demonstrations in this SAS e-course build on each 
other. This file contains the code for all demonstrations in 
Lesson 1. 

If you started a new SAS session since you ran the previous
demonstration(s), you need to set up access to the course 
files (see the Course Overview and Data Setup) and then and 
re-run the code for all previous demonstrations. The title of 
each demonstration and the corresponding program file name 
appear in a comment above the code for that demo. 

Before you submit the code, make any necessary modifications to 
the code, if indicated in comments. 
Note: Most of the code requires no modifications.

Submit the code and check the log to verify that it ran without errors.

After performing the steps above, you are ready to proceed with the 
current demonstration!
*/

/* ===================================================== */
/* Lesson 1, Section 1: l1d1.sas
   Demonstration: Examining the Code for Generating 
   Descriptive Statistics and Frequency Tables
   [m641_1_i; derived from pmlr01d01.sas]               */
/* ===================================================== */

data work.develop;
   set pmlr.develop;
run;

%global inputs;
%let inputs=ACCTAGE DDA DDABAL DEP DEPAMT CASHBK 
            CHECKS DIRDEP NSF NSFAMT PHONE TELLER 
            SAV SAVBAL ATM ATMAMT POS POSAMT CD 
            CDBAL IRA IRABAL LOC LOCBAL INV 
            INVBAL ILS ILSBAL MM MMBAL MMCRED MTG 
            MTGBAL CC CCBAL CCPURC SDB INCOME 
            HMOWN LORES HMVAL AGE CRSCORE MOVED 
            INAREA;

proc means data=work.develop n nmiss mean min max;
   var &inputs;
run;

proc freq data=work.develop;
   tables ins branch res;
run;

/* ===================================================== */
/* Lesson 1, Section 2: l1d2.sas
   Demonstration: Splitting the Data
   [m641_2_h; derived from pmlr01d02.sas]               */
/* ===================================================== */


/* Sort the data by the target in preparation for stratified sampling. */

proc sort data=work.develop out=work.develop_sort; 
   by ins; 
run;

/* The SURVEYSELECT procedure will perform stratified sampling 
   on any variable in the STRATA statement. The OUTALL option 
   specifies that you want a flag appended to the file to 
   indicate selected records, not simply a file comprised 
   of the selected records. */

proc surveyselect noprint data=work.develop_sort 
                  samprate=.6667 stratumseed=restore
                  out=work.develop_sample
                  seed=44444 outall;
   strata ins;
run;

/* Verify stratification. */

proc freq data=work.develop_sample;
   tables ins*selected;
run;

/* Create training and validation data sets. */

data work.train(drop=selected SelectionProb SamplingWeight) 
     work.valid(drop=selected SelectionProb SamplingWeight);
   set work.develop_sample;
   if selected then output work.train;
   else output work.valid;
run;

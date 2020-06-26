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

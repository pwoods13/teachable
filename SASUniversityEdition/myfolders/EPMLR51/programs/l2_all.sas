/* Code for the Practices in Lessons 1 and 2 of the SAS
   e-Course "Predictive Modeling Using Logistic Regression" */


/* The practices in this SAS e-course build on each 
other. If you started a new SAS session since you
ran the previous practice(s), you need to set up access
to the course files (see the Course Overview and Data Setup)
and then re-run the code from the previous practices before 
you perform the current practice. 

This file contains the code for all practices in 
Lessons 1 and 2. The title of each practice and
the corresponding program file name appear
in a comment above the code for that practice.

Before you submit the code, make any necessary
modifications, if indicated in comments.
Note: Most of the code requires no modifications.

Submit the code and check the log to verify that it
ran without errors.

After performing the steps above, you are ready to proceed 
with the current practice!
*/

/* ===================================================== */
/* Lesson 1, Practice 1: l1s1.sas
   Practice: Exploring the Veterans' Organization Data 
   Used in the Practices
   [m641_1_p2; derived from pmlr00e01.sas]               */
/* ===================================================== */

data pmlr.pva(drop=control_number 
                   MONTHS_SINCE_LAST_PROM_RESP 
                   FILE_AVG_GIFT 
                   FILE_CARD_GIFT);
   set pmlr.pva_raw_data;
   STATUS_FL=RECENCY_STATUS_96NK in("F","L");
   STATUS_ES=RECENCY_STATUS_96NK in("E","S");
   home01=(HOME_OWNER="H");
   nses1=(SES="1");
   nses3=(SES="3");
   nses4=(SES="4");
   nses_=(SES="?");
   nurbr=(URBANICITY="R");
   nurbu=(URBANICITY="U");
   nurbs=(URBANICITY="S");
   nurbt=(URBANICITY="T");
   nurb_=(URBANICITY="?");
run;

proc contents data=pmlr.pva;
run;

proc means data=pmlr.pva mean nmiss max min;
   var _numeric_;
run;

proc freq data=pmlr.pva nlevels;
   tables _character_;
run;


/* ===================================================== */
/* Lesson 1, Practice 2: l1s2.sas
   Practice: Splitting the Data
   [m641_2_p; derived from pmlr01s01.sas]                */
/* ===================================================== */

proc sort data=pmlr.pva out=work.pva_sort;
   by target_b;
run;

proc surveyselect noprint data=work.pva_sort 
                  samprate=0.5 out=pva_sample seed=27513 
                  outall stratumseed=restore;
   strata target_b;
run;

data pmlr.pva_train(drop=selected SelectionProb SamplingWeight)
     pmlr.pva_valid(drop=selected SelectionProb SamplingWeight);
   set work.pva_sample;
   if selected then output pmlr.pva_train;
   else output pmlr.pva_valid;
run;


/* ===================================================== */
/* Lesson 2, Practice 1: l2s1.sas
   Practice: Fitting a Logistic Regression Model
   [m642_2_p; derived from pmlr02s01.sas]                */
/* ===================================================== */

/* Modifications for your SAS software:
   ------------------------------------------------------
   (Optional) To avoid a warning in the log about the 
   suppression of plots that have more than 5000 
   observations, you can add the MAXPOINTS= option 
   to the PROC LOGISTIC statement like this: 
   plots(maxpoints=none only). Omitting the 
   MAXPOINTS= option does not affect the results 
   of the practices in this course. 
*/

%global ex_pi1;
%let ex_pi1=0.05;

title1 "Logistic Regression Model of the Veterans' Organization Data";
proc logistic data=pmlr.pva_train plots(only)=
              (effect(clband x=(pep_star recent_avg_gift_amt
              frequency_status_97nk)) oddsratio (type=horizontalstat));
   class pep_star (param=ref ref='0');
   model target_b(event='1')=pep_star recent_avg_gift_amt
                  frequency_status_97nk / clodds=pl;
   effectplot slicefit(sliceby=pep_star x=recent_avg_gift_amt) / noobs; 
   effectplot slicefit(sliceby=pep_star x=frequency_status_97nk) / noobs; 
   score data=pmlr.pva_train out=work.scopva_train priorevent=&ex_pi1;
run;

title1 "Adjusted Predicted Probabilities of the Veteran's Organization Data";
proc print data=work.scopva_train(obs=10);
   var p_1 pep_star recent_avg_gift_amt frequency_status_97nk;
   
run;
title;


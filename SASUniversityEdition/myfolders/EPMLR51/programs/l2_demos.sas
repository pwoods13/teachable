/* Code for the Lesson 1 and 2 Demonstrations in the SAS e-Course 
   "Predictive Modeling Using Logistic Regression" */

/* The demonstrations in this SAS e-course build on each 
other. This file contains the code for all demonstrations in 
Lesson 1 and 2. 

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



/* ===================================================== */
/* Lesson 2, Section 1: l2d1.sas
   Demonstration: Fitting a Basic Logistic Regression Model,
   Parts 1 and 2                                             
   [m642_1_k1, m642_1_k2; derived from pmlr02d01.sas]    */
/* ===================================================== */

title1 "Logistic Regression Model for the Variable Annuity Data Set";
proc logistic data=work.train 
              plots(only maxpoints=none)=(effect(clband x=(ddabal depamt checks res))
              oddsratio (type=horizontalstat));
   class res (param=ref ref='S') dda (param=ref ref='0');
   model ins(event='1')=dda ddabal dep depamt 
               cashbk checks res / stb clodds=pl;
   units ddabal=1000 depamt=1000 / default=1;
   oddsratio 'Comparisons of Residential Classification' res / diff=all cl=pl;
   effectplot slicefit(sliceby=dda x=ddabal) / noobs;
   effectplot slicefit(sliceby=dda x=depamt) / noobs;   
run;
title1;


/* ===================================================== */
/* Lesson 2, Section 1: l2d2.sas
   Demonstration: Scoring New Cases                               
   [m642_1_n; derived from pmlr02d02.sas]                */
/* ===================================================== */

/* Score a new data set with one run of the LOGISTIC procedure with the 
   SCORE statement.  */
 
proc logistic data=work.train noprint;
   class res (param=ref ref='S');
   model ins(event='1')= res dda ddabal dep depamt cashbk checks;
   score data = pmlr.new out=work.scored1;
run;

title1 "Predicted Probabilities from Scored Data Set";
proc print data=work.scored1(obs=10);
   var p_1 dda ddabal dep depamt cashbk checks res;
run;

title1 "Mean of Predicted Probabilities from Scored Data Set";
proc means data=work.scored1 mean nolabels;
   var p_1;
run;

/* Score a new data set with the OUTMODEL= amd INMODEL= options */ 

proc logistic data=work.train outmodel=work.scoredata noprint;
   class res (param=ref ref='S');
   model ins(event='1')= res dda ddabal dep depamt cashbk checks;
run;

proc logistic inmodel=work.scoredata noprint;
   score data = pmlr.new out=work.scored2;
run;

title1 "Predicted Probabilities from Scored Data Set";
proc print data=work.scored2(obs=10);
   var p_1 dda ddabal dep depamt cashbk checks res;
run;

/* Score a new data set with the CODE Statement  */

proc logistic data=work.train noprint;
   class res (param=ref ref='S');
   model ins(event='1')= res dda ddabal dep depamt cashbk checks;
   code file="&PMLRfolder/pmlr_score.txt";
run;

data work.scored3;
   set pmlr.new;
   %include "&PMLRfolder/pmlr_score.txt";
run;

title1 "Predicted Probabilities from Scored Data Set";
proc print data=work.scored3(obs=10);
   var p_ins1 dda ddabal dep depamt cashbk checks res;
run;
title1 ;


/* ===================================================== */
/* Lesson 2, Section 2: l2d3.sas
   Demonstration: Correcting for Oversampling                               
   [m642_2_f; derived from pmlr02d03.sas]                */
/* ===================================================== */

/* Specify the prior probability to correct for oversampling.  */
%global pi1;
%let pi1=.02;       

/* Correct predicted probabilities */

proc logistic data=work.train noprint;
   class res (param=ref ref='S');
   model ins(event='1')=dda ddabal dep depamt cashbk checks res;
   score data=pmlr.new out=work.scored4 priorevent=&pi1;
run;

title1 "Adjusted Predicted Probabilities from Scored Data Set";
proc print data=work.scored4(obs=10);
   var p_1 dda ddabal dep depamt cashbk checks res;
run;

title1 "Mean of Adjusted Predicted Probabilities from Scored Data Set";
proc means data=work.scored4 mean nolabels;
   var p_1;
run;
title1 ;

/* Correct probabilities in the Score Code */ 

proc logistic data=work.train noprint;
   class res (param=ref ref='S');
   model ins(event='1')=dda ddabal dep depamt cashbk checks res;
   /* File suffix "txt" is used so you can view the file */
   /* with a native text editor. SAS prefers "sas", but  */
   /* when specified as a filename, SAS does not care.   */
   code file="&PMLRfolder/pmlr_score_adj.txt";
run;

%global rho1;
proc SQL noprint;
   select mean(INS) into :rho1 
   from work.train;
quit;

data new;
   set pmlr.new;
   off=log(((1-&pi1)*&rho1)/(&pi1*(1-&rho1)));
run;

data work.scored5;
   set work.new;
   %include "&PMLRfolder/pmlr_score_adj.txt";
   eta=log(p_ins1/p_ins0) - off;
   prob=1/(1+exp(-eta));
run;

title1 "Adjusted Predicted Probabilities from Scored Data Set";
proc print data=scored5(obs=10);
   var prob dda ddabal dep depamt cashbk checks res;
run;
title1 ;



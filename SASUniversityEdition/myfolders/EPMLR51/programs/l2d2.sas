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

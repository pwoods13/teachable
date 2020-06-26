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



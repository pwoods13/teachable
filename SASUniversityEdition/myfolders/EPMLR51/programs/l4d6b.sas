/* ===================================================== */
/* Lesson 4, Section 5: l4d6b.sas
   Demonstration: Comparing and Evaluating Many Models, Part 2
   [m644_5_g3; derived from pmlr04d06.sas]               */
/* ===================================================== */

title1 "Model Performance Measures for Training and Validation Data Sets";
proc print data=work.results(obs=24);
run;

title1 "C Statistics by Model";
proc sgplot data=work.results;
   where index > 18;
   series y=c x=index / group=datarole markerattrs=(symbol=circle) markers;
   yaxis label="C Statistic" Values=(0.770 to 0.790 by 0.01);
   xaxis label="Model Number" Values=(20 to 80 by 5);
run;

title1 "Overall Average Profit by Model";
proc sgplot data=work.results;
   where index > 18;
   series y=overall_avg_profit x=index / 
           group=datarole markerattrs=(symbol=plus) markers;
   yaxis label="Overall Average Profit" Values=(1.21 to 1.26 by 0.010);
   xaxis label="Model Number" Values=(20 to 80 by 5);
run;

title1 "Model Number with Highest Profit";
%global index;
proc sql;
   select index into :index
   from work.results
   where datarole='valid' 
   having overall_avg_profit=max(overall_avg_profit);
quit;

/* Remove all blanks from index */
%let index=%cmpres(&index);
title1 "Logistic Model with Highest Profit";
proc logistic data=work.train_imputed_swoe_bins;
   model ins(event='1')=&&inputs&index;
   score data=work.valid_imputed_swoe_bins out=work.scoval2 fitstat; 
run;



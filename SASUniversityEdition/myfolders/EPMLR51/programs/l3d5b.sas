/* ===================================================== */
/* Lesson 3, Section 4: l3d5b.sas
   Demonstration: Performing Variable Screening, Part 2
   [m643_4_e2; derived from pmlr03d05.sas]               */
/* ===================================================== */

/* Find values for reference lines */
%global vref href;
proc sql noprint;
   select min(ranksp) into :vref 
   from (select ranksp 
   from work.correlations1 
   having spvalue > .5);

   select min(rankho) into :href 
   from (select rankho
   from work.correlations1
   having hpvalue > .5);
quit;

/* Plot variable names, Hoeffding ranks, and Spearman ranks. */

title1 "Scatter Plot of the Ranks of Spearman vs. Hoeffding";
proc sgplot data=work.correlations1;
   refline &vref / axis=y;
   refline &href / axis=x;
   scatter y=ranksp x=rankho / datalabel=variable;
   yaxis label="Rank of Spearman";
   xaxis label="Rank of Hoeffding";
run;
title1 ;

%global screened;
%let screened=SavBal Dep DDA CD Sav CC ATM MM branch_swoe Phone IRA IRABal 
              DDABal ATMAmt ILS POS NSF CCPurc SDB DepAmt CCBal Inv InArea   
              Age CashBk MICRScor Income;


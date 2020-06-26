/* ===================================================== */
/* Lesson 3, Section 4:  l3d5a.sas
   Demonstration: Performing Variable Screening, Part 1
   [m643_4_e1; derived from pmlr03d05.sas]               */
/* ===================================================== */

ods select none;
ods output spearmancorr=work.spearman
           hoeffdingcorr=work.hoeffding;

proc corr data=work.train_imputed_swoe spearman hoeffding;
   var ins;
   with &reduced;
run;

ods select all;

proc sort data=work.spearman;
    by variable;
run;

proc sort data=work.hoeffding;
    by variable;
run;

data work.correlations;
   merge work.spearman(rename=(ins=scorr pins=spvalue))
         work.hoeffding(rename=(ins=hcorr pins=hpvalue));
   by variable;
   scorr_abs=abs(scorr);
   hcorr_abs=abs(hcorr);
run;

proc rank data=work.correlations out=work.correlations1 descending;
    var scorr_abs hcorr_abs;
    ranks ranksp rankho;
run;

proc sort data=work.correlations1;
   by ranksp;
run;

title1 "Rank of Spearman Correlations and Hoeffding Correlations";
proc print data=work.correlations1 label split='*';
   var variable ranksp rankho scorr spvalue hcorr hpvalue;
   label ranksp ='Spearman rank*of variables'
         scorr  ='Spearman Correlation'
         spvalue='Spearman p-value'
         rankho ='Hoeffding rank*of variables'
         hcorr  ='Hoeffding Correlation'
         hpvalue='Hoeffding p-value';  
run;


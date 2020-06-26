/* ===================================================== */
/* Lesson 3, Section 3: l3d4.sas
   Demonstration: Reducing Redundancy by Clustering Variables
   [m643_3_i; derived from pmlr03d04.sas]                */
/* ===================================================== */

/* Use the ODS OUTPUT statement to generate data sets based on the variable 
   clustering results and the clustering summary. */

ods select none;
ods output clusterquality=work.summary
           rsquare=work.clusters;

proc varclus data=work.train_imputed_swoe maxeigen=.7 hi;
   var &inputs branch_swoe miacctag 
       miphone mipos miposamt miinv 
       miinvbal micc miccbal miccpurc
       miincome mihmown milores mihmval 
       miage micrscor;
run;
ods select all;

/* Use the CALL SYMPUT function to create a macro variable:&NVAR = 
   the number of of clusters. This is also the number of variables 
   in the analysis, going forward. */

%global nvar;
data _null_;
   set work.summary;
   call symput('nvar',compress(NumberOfClusters));
run;

title1 "Variables by Cluster";
proc print data=work.clusters noobs label split='*';
   where NumberOfClusters=&nvar;
   var Cluster Variable RSquareRatio VariableLabel;
   label RSquareRatio="1 - RSquare*Ratio";
run;
title1 ;

title1 "Variation Explained by Clusters";
proc print data=work.summary label;
run;

/* Choose a representative from each cluster.  */
%global reduced;
%let reduced=branch_swoe MIINCOME Dep CCBal MM Income ILS POS NSF CD 
             DDA LOC Age Inv InArea AcctAge Moved CRScore MICRScor
             IRABal MIAcctAg SavBal CashBk DDABal SDB InvBal CCPurc 
             ATMAmt Sav CC Phone HMOwn DepAmt IRA MTG ATM LORes;


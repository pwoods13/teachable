/* ===================================================== */
/* Lesson 3, Section 1: l3d1.sas
   Demonstration: Imputing Missing Values                               
   [m643_1_h; derived from pmlr03d01.sas]                */
/* ===================================================== */

title1 "Variables with Missing Values";
proc print data=work.train(obs=15);
   var ccbal ccpurc income hmown;
run;
title1 ;

/* Create missing indicators */
data work.train_mi(drop=i);
   set work.train;
   /* name the missing indicator variables */
   array mi{*} MIAcctAg MIPhone MIPOS MIPOSAmt 
               MIInv MIInvBal MICC MICCBal 
               MICCPurc MIIncome MIHMOwn MILORes
               MIHMVal MIAge MICRScor;
   /* select variables with missing values */
   array x{*} acctage phone pos posamt 
              inv invbal cc ccbal
              ccpurc income hmown lores 
              hmval age crscore;
   do i=1 to dim(mi);
      mi{i}=(x{i}=.);
      nummiss+mi{i};
   end;
run;

/* Impute missing values with the median */
proc stdize data=work.train_mi reponly method=median out=work.train_imputed;
   var &inputs;
run;

title1 "Imputed Values with Missing Indicators";
proc print data=work.train_imputed(obs=12);
   var ccbal miccbal ccpurc miccpurc income miincome hmown mihmown nummiss;
run;
title1 ;


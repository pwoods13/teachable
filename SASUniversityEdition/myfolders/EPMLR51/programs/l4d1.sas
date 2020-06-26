/* ===================================================== */
/* Lesson 4, Section 1: l4d1.sas
   Demonstration: Preparing the Validation Data
   [m644_1_g; derived from pmlr04d01.sas]               */
/* ===================================================== */

title1 "Variables with Missing Values on the Validation Data Set";
proc means data=work.valid nmiss;
   var SavBal DDA CD Sav MM IRA IRABal ATMAmt ILS NSF SDB CCBal Inv
       DepAmt Dep ATM CC;
run;

proc univariate data=work.train_imputed_swoe_bins noprint;
   var cc ccbal inv;
   output out=work.medians
          pctlpts=50
          pctlpre=cc ccbal inv;
run;

data work.valid_imputed_swoe_bins(drop=cc50 ccbal50 inv50 i);
   if _N_=1 then set work.medians;
   set work.valid;
   array x(*) cc ccbal inv;
   array med(*) cc50 ccbal50 inv50;
   do i=1 to dim(x);
      if x(i)=. then x(i)=med(i);
   end;
   %include brswoe;
   if not dda then ddabal=&mean;
   %include rank;
run;

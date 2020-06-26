/* ===================================================== */
/* Lesson 3, Section 4: l3d7b.sas
   Demonstration: Accommodating a Nonlinear Relationship, 
   Part 2
   [m643_4_m2; derived from pmlr03d07.sas]               */
/* ===================================================== */

/* Using the binned values of DDABal may make for a more linear 
   relationship between the input and the target. The following code 
   creates DATA step code to bin DDABal, yielding a new predictor, B_DDABal.  */

/* Rank the observations. */

proc rank data=work.train_imputed_swoe_dda groups=100 out=work.ranks;
   var ddabal;
   ranks bin;
run;

/* Save the endpoints of each bin */

proc means data=work.ranks noprint nway;
   class bin;
   var ddabal;
   output out=endpts max=max;
run;

title1 "Checking Account Balance Endpoints";
proc print data=work.endpts(obs=10);
run;

/* Write the code to assign individuals to bins according to the DDABal. */

filename rank "&PMLRfolder/rank.sas";

data _null_;
   file rank;
   set work.endpts end=last;
   if _n_=1 then put "select;";
   if not last then do;
      put "  when (ddabal <= " max ") B_DDABal =" bin ";";
   end;
   else if last then do;
      put "  otherwise B_DDABal =" bin ";" / "end;";
   end;
run;

/* Use the code. */

data work.train_imputed_swoe_bins;
   set work.train_imputed_swoe_dda;
   %include rank / source;
run;

title1 "Minimum and Maximum Checking Account Balance by Bin";
proc means data=work.train_imputed_swoe_bins min max;
   class B_DDABal;
   var DDABal;  
run;
title1 ;

/* Switch the binned DDABal (B_DDABal) for the originally scaled 
   DDABal input in the list of potential inputs. */
%global screened;
%let screened=SavBal Dep DDA CD Sav CC ATM MM branch_swoe Phone IRA
              IRABal B_DDABal ATMAmt ILS POS NSF CCPurc SDB DepAmt
              CCBal Inv InArea Age CashBk MICRScor Income;


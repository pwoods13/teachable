/* ===================================================== */
/* Lesson 3, Section 2: l3d3.sas
   Demonstration: Computing the Smoothed Weight of Evidence                         
   [m643_2_j; derived from pmlr03d03.sas]                */
/* ===================================================== */

/* Rho1 is the proportion of events in the training data set. */
%global rho1;
proc sql noprint;
   select mean(ins) into :rho1
   from work.train_imputed;
run; 

/* The output data set from PROC MEANS will have the number of
   observations and events for each level of branch. */

proc means data=work.train_imputed sum nway noprint;
   class branch;
   var ins;
   output out=work.counts sum=events;
run;

/* The DATA Step creates the scoring code that assigns each branch to
   a value of the smoothed weight of evidence. */


filename brswoe "&PMLRfolder/swoe_branch.sas";

data _null_;
   file brswoe;
   set work.counts end=last;
   logit=log((events + &rho1*24)/(_FREQ_ - events + (1-&rho1)*24));
   if _n_=1 then put "select (branch);" ;
   put "  when ('" branch +(-1) "') branch_swoe = " logit ";" ;
   if last then do;
   logit=log(&rho1/(1-&rho1));
   put "  otherwise branch_swoe = " logit ";" / "end;";
   end;
run;

data work.train_imputed_swoe;
   set work.train_imputed;
   %include brswoe / source2;
run;

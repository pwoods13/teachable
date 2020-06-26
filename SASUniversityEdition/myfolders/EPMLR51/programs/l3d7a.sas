/* ===================================================== */
/* Lesson 3, Section 4: l3d7a.sas
   Demonstration: Accommodating a Nonlinear Relationship, 
   Part 1
   [m643_4_m1; derived from pmlr03d07.sas]               */
/* ===================================================== */

title1 "Checking Account Balance and INS by Checking Account";
proc means data=work.train_imputed_swoe mean median min max;
   class dda;
   var ddabal ins;
run;

/* A possible remedy for that non-linearity is to replace the logical 
   imputation of 0 for non-DDA customers with the mean. */

%global mean;
proc sql noprint;
   select mean(ddabal) into :mean 
   from work.train_imputed_swoe where dda;
quit;

data work.train_imputed_swoe_dda;
   set work.train_imputed_swoe;
   if not dda then ddabal=&mean;
run;

/* Create new logit plots */
%global var;
%let var=DDABal;

proc rank data=work.train_imputed_swoe_dda groups=100 out=work.ranks;
   var &var;
   ranks bin;
run;

proc means data=work.ranks noprint nway;
   class bin;
   var ins &var;
   output out=work.bins sum(ins)=ins mean(&var)=&var;
run;

/* Calculate the empirical logit */ 
data work.bins;
   set work.bins;
   elogit=log((ins+(sqrt(_FREQ_ )/2))/
          ( _FREQ_ -ins+(sqrt(_FREQ_ )/2)));
run;

title1 "Empirical Logit against &var";
proc sgplot data=work.bins;
   reg y=elogit x=&var /
       curvelabel="Linear Relationship?"
      curvelabelloc=outside
      lineattrs=(color=ligr);
   series y=elogit x=&var;
run;

title1 "Empirical Logit against Binned &var";
proc sgplot data=work.bins;
   reg y=elogit x=bin /
       curvelabel="Linear Relationship?"
       curvelabelloc=outside
       lineattrs=(color=ligr);
   series y=elogit x=bin;  
run;

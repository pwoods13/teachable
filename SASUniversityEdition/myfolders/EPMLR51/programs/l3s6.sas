/* Solution: l3s6.sas step 1 */

%global var;
%let var=LAST_GIFT_AMT;

proc rank data=pmlr.pva_train_imputed_swoe 
          groups=20 out=work.ranks;
   var &var;
   ranks bin;
run;


/* Solution: l3s6.sas step 2 */

proc means data=work.ranks noprint nway;
   class bin;
   var target_b &var;
   output out=work.bins sum(target_b)=target_b 
          mean(&var)=&var;
run;

data work.bins;
   set work.bins;
   elogit=log((target_b+(sqrt(_FREQ_ )/2))/
          ( _FREQ_ -target_b+(sqrt(_FREQ_ )/2)));
run;


/* Solution: l3s6.sas step 3 */

title1 "Empirical Logit against &var";
proc sgplot data=work.bins;
   reg y=elogit x=&var /
       curvelabel="Linear Relationship?"
       curvelabelloc=outside
       lineattrs=(color=ligr);
   series y=elogit x=&var;
run;
title1;


/* Solution: l3s6.sas step 4 */

title1 "Empirical Logit against Binned &var";
proc sgplot data=work.bins;
   reg y=elogit x=bin /
       curvelabel="Linear Relationship?"
       curvelabelloc=outside
       lineattrs=(color=ligr);
   series y=elogit x=bin;
run;
title1;



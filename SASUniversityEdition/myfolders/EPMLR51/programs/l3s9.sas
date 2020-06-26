/* Solution: l3s9.sas step 1 */

%global ex_selected;

%macro fitstat(data=,target=,event=,inputs=,best=,priorevent=);

ods select none;
ods output bestsubsets=work.score;

proc logistic data=&data namelen=50;
   model &target(event="&event")=&inputs / 
         selection=score best=&best;
run;

proc sql noprint;
  select variablesinmodel into :inputs1 -  
  from work.score;
  select NumberOfVariables into :ic1 - 
  from work.score;
quit;

%let lastindx=&SQLOBS;

%do model_indx=1 %to &lastindx;

%let im=&&inputs&model_indx;
%let ic=&&ic&model_indx;

ods output scorefitstat=work.stat&ic ;
proc logistic data=&data namelen=50;
  model &target(event="&event")=&im;
  score data=&data out=work.scored fitstat
        priorevent=&priorevent;
run;

proc datasets
   library=work
   nodetails
   nolist;
   delete scored;
run;
quit;

%end;

data work.modelfit;
   set work.stat1 - work.stat&lastindx;
   model=_n_;
run;

%mend fitstat;


/* Solution: l3s9.sas step 2 */

%fitstat(data=pmlr.pva_train_imputed_swoe,target=target_b,event=1,
         inputs=&ex_screened LAST_GIFT_AMT*LIFETIME_AVG_GIFT_AMT
         LIFETIME_AVG_GIFT_AMT*RECENT_STAR_STATUS 
         LIFETIME_GIFT_COUNT*MONTHS_SINCE_LAST_GIFT,best=1,
         priorevent=0.05);

proc sort data=work.modelfit;
   by bic;
run;

title1 "Fit Statistics from Models selected from Best-Subsets";
ods select all;
proc print data=work.modelfit;
   var model auc aic bic misclass adjrsquare brierscore;
run;
title1;


/* Solution: l3s9.sas step 3 */

proc sql;
   select VariablesInModel into :ex_selected
   from work.score
   where numberofvariables=9;
quit;


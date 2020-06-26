/* ===================================================== */
/* Lesson 3, Section 5: l3d8d.sas
   Demonstration: Creating an Interaction Plot
   [m643_5_r; derived from pmlr03d08.sas]               */
/* ===================================================== */

/*----  MACRO INTERACT  ----*\
Reserved data set names: work.percentiles
                         work.plot
\*--------------------------*/
%macro interact(data=,target=,event=,inputs=,var1=,var2=,mean_inputs=);

proc logistic data=&data noprint;
   model &target(event="&event")= &inputs; 
   code file="&PMLRfolder/interaction.txt";
run;

proc univariate data=&data noprint;
   var &var1 &var2;
   output out=work.percentiles pctlpts=5 25 50 75 95 pctlpre=&var1._p &var2._p;
run;

data _null_;
   set work.percentiles;
   call symput("&var1._p5",&var1._p5);
   call symput("&var1._p25",&var1._p25);
   call symput("&var1._p50",&var1._p50);
   call symput("&var1._p75",&var1._p75);
   call symput("&var1._p95",&var1._p95);
   call symput("&var2._p5",&var2._p5);
   call symput("&var2._p25",&var2._p25);
   call symput("&var2._p50",&var2._p50);
   call symput("&var2._p75",&var2._p75);
   call symput("&var2._p95",&var2._p95);
run;

proc means data=&data noprint;
   var &mean_inputs;
   output out=work.plot mean=;
run;

data work.plot(drop=_type_ _freq_);
   set work.plot;
   do &var2=&&&var2._p5,&&&var2._p25,&&&var2._p50,&&&var2._p75,&&&var2._p95;
      do &var1=&&&var1._p5,&&&var1._p25,&&&var1._p50,&&&var1._p75,&&&var1._p95;
        %include "&PMLRfolder/interaction.txt";
         output;
     end;
   end;
run;

title1 "Interaction Plot of &var2 by &var1";
proc sgplot data=work.plot;
   series y=p_&target&event x=&var2 / group=&var1;
   yaxis label="Probability of &target"; 
run;

%mend interact;

%interact(data=train_imputed_swoe_bins,target=ins,event=1,
               inputs=SavBal Dep DDA CD Sav CC ATM MM branch_swoe 
               IRA B_DDABal ATMAmt ILS NSF SDB DepAmt Inv 
               SavBal*B_DDABal MM*B_DDABal branch_swoe*ATMAmt Sav*B_DDABal 
               SavBal*SDB SavBal*DDA AtmAmt*DepAmt B_DDABAL*ATMAmt SavBal*IRA
               SavBal*MM SavBal*CC Sav*NSF DDA*ATMAmt Dep*ATM IRA*B_DDABal
               CD*MM CD*Sav Sav*CC,var1=SavBal,var2=B_DDABal,mean_inputs=SavBal Dep 
               DDA CD Sav CC ATM MM branch_swoe IRA B_DDABal ATMAmt ILS NSF SDB 
               DepAmt Inv);


/* ===================================================== */
/* Lesson 4, Section 3: l4d3.sas
   Demonstration: Using a Profit Matrix to Measure Model
   Performance
   [m644_3_i; derived from pmlr04d03.sas]               */
/* ===================================================== */

/* Add the decision variable    */
/* (based on the profit matrix) */
/* and calculate profit         */ 
%global rho1;
proc SQL noprint;
  select mean(INS) into :rho1 from pmlr.develop;
quit;

data work.scoval;
   set work.scoval;
   sampwt=(&pi1/&rho1)*(INS) 
            + ((1-&pi1)/(1-&rho1))*(1-INS);
   decision=(p_1 > 0.01);
   profit=decision*INS*99
            - decision*(1-INS)*1;
run;

/* Calculate total and average profit */

title1 "Total and Average Profit";
proc means data=work.scoval sum mean;
   weight sampwt;
   var profit;
run;

/* Investigate the true positive and */
/* false positive rates              */
data work.roc;
   set work.roc;
   AveProf=99*tp - 1*fp;
run;

title1 "Average Profit Against Depth";
proc sgplot data=work.roc;
   series y=aveProf x=depth;
   yaxis label="Average Profit";
run;

title1 "Average Profit Against Cutoff";
proc sgplot data=work.roc;
   where cutoff le 0.05;
   refline .01 / axis=x;
   series y=aveProf x=cutoff;
   yaxis label="Average Profit";
run;


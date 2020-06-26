/* Solution: l3s5.sas step 1 */

%let ex_reduced=
LIFETIME_GIFT_COUNT LAST_GIFT_AMT MEDIAN_HOME_VALUE 
FREQUENCY_STATUS_97NK MONTHS_SINCE_LAST_GIFT  nses_ 
mi_DONOR_AGE PCT_MALE_VETERANS PCT_MALE_MILITARY
PCT_WWII_VETERANS LIFETIME_AVG_GIFT_AMT cluster_swoe 
PEP_STAR nurbu nurbt home01 nurbr DONOR_AGE STATUS_FL 
MOR_HIT_RATE nses4 INCOME_GROUP RECENT_STAR_STATUS IN_HOUSE 
WEALTH_RATING PUBLISHED_PHONE PCT_OWNER_OCCUPIED nurbs;


/* Solution: l3s5.sas step 2 */

ods select none;
ods output spearmancorr=work.spearman
           hoeffdingcorr=work.hoeffding;

proc corr data=pmlr.pva_train_imputed_swoe 
          spearman hoeffding;
   var target_b;
   with &ex_reduced;
run;

ods select all;


/* Solution: l3s5.sas step 3 */

proc sort data=work.spearman;
    by variable;
run;

proc sort data=work.hoeffding;
    by variable;
run;

data work.correlations;
   attrib variable length=$32;
   merge work.spearman(rename=
         (target_b=scorr ptarget_b=spvalue))
         work.hoeffding
         (rename=(target_b=hcorr ptarget_b=hpvalue));
   by variable;
   scorr_abs=abs(scorr);
   hcorr_abs=abs(hcorr);
run;


/* Solution: l3s5.sas step 4 */

proc rank data=work.correlations 
          out=work.correlations1 descending;
    var scorr_abs hcorr_abs;
    ranks ranksp rankho;
run;


/* Solution: l3s5.sas step 5 */

proc sort data=work.correlations1;
   by ranksp;
run;

title1 "Rank of Spearman Correlations and Hoeffding Correlations";
proc print data=work.correlations1 label split='*';
   var variable ranksp rankho scorr spvalue hcorr hpvalue;
   label ranksp='Spearman rank*of variables'
         scorr='Spearman Correlation'
         spvalue='Spearman p-value'
         rankho='Hoeffding rank*of variables'
         hcorr='Hoeffding Correlation'
         hpvalue='Hoeffding p-value';
run;


/* Solution: l3s5.sas step 6 */

%global vref href;
proc sql noprint;
   select min(ranksp) into :vref 
   from (select ranksp 
         from work.correlations1 
         having spvalue > .5);
   select min(rankho) into :href 
   from (select rankho
         from work.correlations1
         having hpvalue > .5);
quit;

title1 "Scatter Plot of the Ranks of Spearman vs. Hoeffding";
proc sgplot data=work.correlations1;
   refline &vref / axis=y;
   refline &href / axis=x;
   scatter y=ranksp x=rankho / datalabel=variable;
   yaxis label="Rank of Spearman";
   xaxis label="Rank of Hoeffding";
run;



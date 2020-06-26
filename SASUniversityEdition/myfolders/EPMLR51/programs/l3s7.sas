/* Solution: l3s7.sas step 1 */

%global ex_screened;
%let ex_screened=LIFETIME_GIFT_COUNT LAST_GIFT_AMT MEDIAN_HOME_VALUE 
                 FREQUENCY_STATUS_97NK MONTHS_SINCE_LAST_GIFT  nses_ 
                 mi_DONOR_AGE PCT_MALE_VETERANS PCT_MALE_MILITARY 
                 PCT_WWII_VETERANS LIFETIME_AVG_GIFT_AMT cluster_swoe 
                 PEP_STAR nurbu nurbt home01 nurbr DONOR_AGE STATUS_FL 
                 MOR_HIT_RATE nses4 INCOME_GROUP RECENT_STAR_STATUS 
                 IN_HOUSE WEALTH_RATING nurbs;


/* Solution: l3s7.sas step 2 */

%global sl;

title1 "P-Value for Entry and Retention";
proc sql;
   select 1-probchi(log(sum(target_b ge 0)),1) into :sl
   from pmlr.pva_train_imputed_swoe;
quit;
title1;


/* Solution: l3s7.sas step 3 */

title1 "Interaction Detection using Forward Selection";
proc logistic data=pmlr.pva_train_imputed_swoe namelen=50;
   model target_b(event='1')= &ex_screened 
         LIFETIME_GIFT_COUNT|LAST_GIFT_AMT|MEDIAN_HOME_VALUE|
         FREQUENCY_STATUS_97NK|MONTHS_SINCE_LAST_GIFT|nses_|
         mi_DONOR_AGE|PCT_MALE_VETERANS|PCT_MALE_MILITARY|
         PCT_WWII_VETERANS|LIFETIME_AVG_GIFT_AMT|cluster_swoe|
         PEP_STAR|nurbu|nurbt|home01|nurbr|DONOR_AGE|STATUS_FL|
         MOR_HIT_RATE|nses4|INCOME_GROUP|RECENT_STAR_STATUS|
         IN_HOUSE|WEALTH_RATING|nurbs @2 / include=26 clodds=pl 
       selection=forward slentry=&sl;
run;
title1;

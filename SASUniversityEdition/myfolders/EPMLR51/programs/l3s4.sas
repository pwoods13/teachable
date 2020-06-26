/* Solution: l3s4.sas step 1 */

%let ex_inputs= MONTHS_SINCE_ORIGIN 
DONOR_AGE IN_HOUSE INCOME_GROUP PUBLISHED_PHONE
MOR_HIT_RATE WEALTH_RATING MEDIAN_HOME_VALUE
MEDIAN_HOUSEHOLD_INCOME PCT_OWNER_OCCUPIED
PER_CAPITA_INCOME PCT_MALE_MILITARY 
PCT_MALE_VETERANS PCT_VIETNAM_VETERANS 
PCT_WWII_VETERANS PEP_STAR RECENT_STAR_STATUS
FREQUENCY_STATUS_97NK RECENT_RESPONSE_PROP
RECENT_AVG_GIFT_AMT RECENT_CARD_RESPONSE_PROP
RECENT_AVG_CARD_GIFT_AMT RECENT_RESPONSE_COUNT
RECENT_CARD_RESPONSE_COUNT LIFETIME_CARD_PROM 
LIFETIME_PROM LIFETIME_GIFT_AMOUNT
LIFETIME_GIFT_COUNT LIFETIME_AVG_GIFT_AMT 
LIFETIME_GIFT_RANGE LIFETIME_MAX_GIFT_AMT
LIFETIME_MIN_GIFT_AMT LAST_GIFT_AMT
CARD_PROM_12 NUMBER_PROM_12 MONTHS_SINCE_LAST_GIFT
MONTHS_SINCE_FIRST_GIFT STATUS_FL STATUS_ES
home01 nses1 nses3 nses4 nses_ nurbr nurbu nurbs 
nurbt nurb_;


/* Solution: l3s4.sas step 2 */ 
       
ods select none;
ods output clusterquality=work.summary
           rsquare=work.clusters;

proc varclus data=pmlr.pva_train_imputed_swoe 
             hi maxeigen=0.70;
   var &ex_inputs mi_DONOR_AGE mi_INCOME_GROUP 
       mi_WEALTH_RATING cluster_swoe;
run;

ods select all;


/* Solution: l3s4.sas step 3 */ 

data _null_;
   set work.summary;
   call symput('nvar',compress(NumberOfClusters));
run;


/* Solution: l3s4.sas step 4 */ 

title1 "Variables by Cluster";
proc print data=work.clusters noobs label split='*';
   where NumberOfClusters=&nvar;
   var Cluster Variable RSquareRatio;
   label RSquareRatio="1 - RSquare*Ratio";
run;

title1 "Variation Explained by Clusters";
proc print data=work.summary label;
run;
title1;




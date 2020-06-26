/* Solution: l3s8.sas step 1 */

title1 "Backward Selection for Variable Annuity Data Set";
proc logistic data=pmlr.pva_train_imputed_swoe namelen=50;
   model target_b(event='1')= &ex_screened 
         LAST_GIFT_AMT*LIFETIME_AVG_GIFT_AMT 
         LIFETIME_AVG_GIFT_AMT*RECENT_STAR_STATUS 
         LIFETIME_GIFT_COUNT*MONTHS_SINCE_LAST_GIFT
         / clodds=pl selection=backward slstay=&sl hier=single 
         fast;
run;
title1;

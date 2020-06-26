/* Solution: l3s1.sas step 1 */

data pmlr.pva_train_mi(drop=i);
   set pmlr.pva_train;
   /* name the missing indicator variables */
   array mi{*} mi_DONOR_AGE mi_INCOME_GROUP 
               mi_WEALTH_RATING;
   /* select variables with missing values */
   array x{*} DONOR_AGE INCOME_GROUP WEALTH_RATING;
   do i=1 to dim(mi);
      mi{i}=(x{i}=.);
      nummiss+mi{i};
   end;
run;


/* Solution: l3s1.sas step 2 */

proc rank data=pmlr.pva_train_mi out=work.pva_train_rank groups=3;
   var recent_response_prop recent_avg_gift_amt;
   ranks grp_resp grp_amt;
run;


/* Solution: l3s1.sas step 3 */

proc sort data=work.pva_train_rank out=work.pva_train_rank_sort;
   by grp_resp grp_amt;
run;


/* Solution: l3s1.sas step 4 */

proc stdize data=work.pva_train_rank_sort method=median
            reponly out=pmlr.pva_train_imputed;
   by grp_resp grp_amt;
   var DONOR_AGE INCOME_GROUP WEALTH_RATING;
run;


/* Solution: l3s1.sas step 5 */

options nolabel;
proc means data=pmlr.pva_train_imputed median;
   class grp_resp grp_amt;
   var DONOR_AGE INCOME_GROUP WEALTH_RATING;
run;
options label;

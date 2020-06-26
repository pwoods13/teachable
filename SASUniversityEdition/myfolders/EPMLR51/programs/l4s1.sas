/* Solution: l4s1.sas step 1 */

title1 "Variables with Missing Values on the Validation Data Set";
proc means data=pmlr.pva_valid nmiss;
   var LIFETIME_GIFT_COUNT LAST_GIFT_AMT MEDIAN_HOME_VALUE 
       FREQUENCY_STATUS_97NK PEP_STAR INCOME_GROUP 
       LIFETIME_AVG_GIFT_AMT MONTHS_SINCE_LAST_GIFT;
run;


/* Solution: l4s1.sas step 2 */

proc univariate data=pmlr.pva_train_imputed_swoe noprint;
   var INCOME_GROUP;
   output out=work.medians
          pctlpts=50
          pctlpre=income_group;
run;

title1 "Medians for Variables with Missing Values";
proc print data=work.medians;
run;
title1;


/* Solution: l4s1.sas step 3 */

data pmlr.pva_valid_imputed_swoe(drop=income_group50 i);
   if _N_=1 then set work.medians;
   set pmlr.pva_valid;
   array x(*) income_group;
   array med(*) income_group50;
      do i=1 to dim(x);
         if x(i)=. then x(i)=med(i);
      end;
   %include clswoe;
run;


/* Solution: l4s1.sas step 4 */

title1 "Training Data Set Model";
proc logistic data= pmlr.pva_train_imputed_swoe;
   model target_b(event='1')=&ex_selected;
   score data= pmlr.pva_valid_imputed_swoe priorevent=&ex_pi1
         outroc=work.roc fitstat; 
run;
title1;


/* Solution: l4s1.sas step 5 */

data work.roc;
   set work.roc;
   cutoff=_PROB_;
   specif=1-_1MSPEC_;
   tp=&ex_pi1*_SENSIT_;
   fn=&ex_pi1*(1-_SENSIT_);
   tn=(1-&ex_pi1)*specif;
   fp=(1-&ex_pi1)*_1MSPEC_;
   depth=tp+fp;
   pospv=tp/depth;
   negpv=tn/(1-depth);
   acc=tp+tn;
   lift=pospv/&ex_pi1;
   keep cutoff tn fp fn tp 
        _SENSIT_ _1MSPEC_ specif depth
        pospv negpv acc lift;
run;
title1 "Lift Chart for Validation Data";
proc sgplot data=work.roc;
   where 0.005 <= depth <= 0.50;
   series y=lift x=depth;
   refline 1.0 / axis=y;
   yaxis values=(0 to 4 by 1);
run; 
quit;
title1;



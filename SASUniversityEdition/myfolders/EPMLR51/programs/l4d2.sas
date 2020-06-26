/* ===================================================== */
/* Lesson 4, Section 2: l4d2.sas
   Demonstration: Measuring Model Performance Based on
   Commonly-Used Metrics
   [m644_2_i; derived from pmlr04d02.sas]               */
/* ===================================================== */

ods select roccurve scorefitstat;
proc logistic data=work.train_imputed_swoe_bins;
   model ins(event='1')=&selected;
   score data=work.valid_imputed_swoe_bins out=work.scoval 
         priorevent=&pi1 outroc=work.roc fitstat;
run;

title1 "Statistics in the ROC Data Set";
proc print data=work.roc(obs=10);
   var _prob_ _sensit_ _1mspec_;
run;

data work.roc;
   set work.roc;
   cutoff=_PROB_;
   specif=1-_1MSPEC_;
   tp=&pi1*_SENSIT_;
   fn=&pi1*(1-_SENSIT_);
   tn=(1-&pi1)*specif;
   fp=(1-&pi1)*_1MSPEC_;
   depth=tp+fp;
   pospv=tp/depth;
   negpv=tn/(1-depth);
   acc=tp+tn;
   lift=pospv/&pi1;
   keep cutoff tn fp fn tp 
        _SENSIT_ _1MSPEC_ specif depth
        pospv negpv acc lift;
run;

/* Create a lift chart */
title1 "Lift Chart for Validation Data";
proc sgplot data=work.roc;
   where 0.005 <= depth <= 0.50;
   series y=lift x=depth;
   refline 1.0 / axis=y;
   yaxis values=(0 to 9 by 1);
run; quit;
title1 ;

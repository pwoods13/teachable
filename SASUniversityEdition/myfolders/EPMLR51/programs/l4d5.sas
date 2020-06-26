/* ===================================================== */
/* Lesson 4, Section 5: l4d5.sas
   Demonstration: Comparing ROC Curves to Measure Model
   Performance
   [m644_5_g1; derived from pmlr04d05.sas]               */
/* ===================================================== */

proc logistic data=work.train_imputed_swoe_bins noprint;
   class res;
   model ins(event='1')=dda ddabal dep depamt checks res;
   score data=work.valid_imputed_swoe_bins 
         out=work.sco_validate(rename=(p_1=p_ch2));         
run;

proc logistic data=work.train_imputed_swoe_bins noprint;
   model ins(event='1')=&selected;
   score data=work.sco_validate out=work.sco_validate(rename=(p_1=p_sel));         
run;

title1 "Validation Data Set Performance";
ods select ROCOverlay ROCAssociation ROCContrastTest;
proc logistic data=work.sco_validate;
   model ins(event='1')=p_ch2 p_sel / nofit;
   roc "Chapter 2 Model" p_ch2;
   roc "Chapter 4 Model" p_sel;
   roccontrast "Comparing the Two Models";
run;

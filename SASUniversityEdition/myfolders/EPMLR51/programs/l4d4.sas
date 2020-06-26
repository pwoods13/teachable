/* ===================================================== */
/* Lesson 4, Section 4: l4d4.sas
   Demonstration: Using the K-S Statistic to Measure Model
   Performance
   [m644_4_g; derived from pmlr04d04.sas]               */
/* ===================================================== */

title1 "K-S Statistic for the Validation Data Set";
proc npar1way edf data=work.scoval;
   class ins;
   var p_1;
run;

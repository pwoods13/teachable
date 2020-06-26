/* ===================================================== */
/* Lesson 3, Section 5: l3d8e.sas
   Demonstration: Using the Best-Subsets Selection Method
   [m643_5_s; derived from pmlr03d08.sas]               */
/* ===================================================== */

data work.train_imputed_swoe_bins;
  set work.train_imputed_swoe_bins;
  resr=(res='R');
  resu=(res='U');
run;

/* Run best subsets */
title1 "Models Selected by Best Subsets Selection";
proc logistic data=work.train_imputed_swoe_bins;
   model ins(event='1')=&screened resr resu SavBal*B_DDABal MM*B_DDABal
                branch_swoe*ATMAmt B_DDABal*Sav SavBal*SDB 
                SavBal*DDA ATMAmt*DepAmt B_DDABal*ATMAmt SavBal*ATMAmt
                SavBal*IRA SavBal*MM SavBal*CC Sav*NSF DDA*ATMAmt Dep*ATM
                IRA*B_DDABal CD*MM MM*IRABal CD*Sav B_DDABal*CashBk Sav*CC 
                / selection=score best=1;
   
run;

/* ===================================================== */
/* Lesson 3, Section 5: l3d8b.sas
   Demonstration: Using Backward Elimination to Subset the
   Variables
   [m643_5_n; derived from pmlr03d08.sas]               */
/* ===================================================== */

title1 "Backward Selection for Variable Annuity Data Set";
proc logistic data=work.train_imputed_swoe_bins;
   class res (param=ref ref='S');
   model ins(event='1')= &screened res SavBal*B_DDABal MM*B_DDABal
                branch_swoe*ATMAmt B_DDABal*Sav SavBal*SDB 
                SavBal*DDA ATMAmt*DepAmt B_DDABal*ATMAmt SavBal*ATMAmt
                SavBal*IRA SavBal*MM SavBal*CC Sav*NSF DDA*ATMAmt Dep*ATM
                IRA*B_DDABal CD*MM MM*IRABal CD*Sav B_DDABal*CashBk Sav*CC
               / clodds=pl 
         selection=backward slstay=&sl hier=single fast;
run;

/* ===================================================== */
/* Lesson 3, Section 5: l3d8c.sas
   Demonstration: Displaying Odds Ratios for Variables
   Involved in Interactions
   [m643_5_o; derived from pmlr03d08.sas]               */
/* ===================================================== */

title1 "Candidate Model for Variable Annuity Data Set";
ods select OddsRatiosPL;
proc logistic data=work.train_imputed_swoe_bins;
   model ins(event='1')= SavBal Dep DDA CD Sav CC ATM MM branch_swoe IRA B_DDABal 
                         ATMAmt ILS NSF SDB 
                         DepAmt Inv SavBal*B_DDABal MM*B_DDABal 
                         branch_swoe*ATMAmt Sav*B_DDABal 
                         SavBal*SDB SavBal*DDA AtmAmt*DepAmt B_DDABAL*ATMAmt SavBal*IRA
                         SavBal*MM SavBal*CC Sav*NSF DDA*ATMAmt Dep*ATM IRA*B_DDABal
                         CD*MM CD*Sav Sav*CC / clodds=pl; 
   oddsratio B_DDABAL / at(savbal=0, 1211, 52299) cl=pl;
run;

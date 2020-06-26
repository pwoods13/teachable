/* ===================================================== */
/* Lesson 3, Section 5: l3d8a.sas
   Demonstration: Detecting Interactions
   [m643_5_m; derived from pmlr03d08.sas]               */
/* ===================================================== */

title1 "P-Value for Entry and Retention";

%global sl;
proc sql;
   select 1-probchi(log(sum(ins ge 0)),1) into :sl
   from work.train_imputed_swoe_bins;
quit;

title1 "Interaction Detection using Forward Selection";
proc logistic data=work.train_imputed_swoe_bins;
   class res (param=ref ref='S');
   model ins(event='1')= &screened res
                SavBal|Dep|DDA|CD|Sav|CC|ATM|MM|branch_swoe|Phone|IRA|
                IRABal|B_DDABal|ATMAmt|ILS|POS|NSF|CCPurc|SDB|DepAmt|
                CCBal|Inv|InArea|Age|CashBk|MICRScor|Income|res @2 / include=28 clodds=pl 
       selection=forward slentry=&sl;
run;

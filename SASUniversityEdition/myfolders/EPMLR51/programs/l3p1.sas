/* Practice: l3p1.sas step 2 */

proc rank data=pmlr.pva_train_mi out=work.pva_train_rank groups=3;
   var recent_response_prop recent_avg_gift_amt;
   ranks grp_resp grp_amt;
run;

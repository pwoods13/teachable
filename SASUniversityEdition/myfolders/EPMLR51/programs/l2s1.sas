/* Solution: l2s1.sas step 1 */

%global ex_pi1;
%let ex_pi1=0.05;


/* Solution: l2s1.sas step 2 */

title1 "Logistic Regression Model of the Veterans' Organization Data";
proc logistic data=pmlr.pva_train plots(only)=
              (effect(clband x=(pep_star recent_avg_gift_amt
              frequency_status_97nk)) oddsratio (type=horizontalstat));
   class pep_star (param=ref ref='0');
   model target_b(event='1')=pep_star recent_avg_gift_amt
                  frequency_status_97nk / clodds=pl;
   effectplot slicefit(sliceby=pep_star x=recent_avg_gift_amt) / noobs; 
   effectplot slicefit(sliceby=pep_star x=frequency_status_97nk) / noobs; 
   score data=pmlr.pva_train out=work.scopva_train priorevent=&ex_pi1;
run;


/* Solution: l2s1.sas step 4 */

title1 "Adjusted Predicted Probabilities of the Veteran's Organization Data";
proc print data=work.scopva_train(obs=10);
   var p_1 pep_star recent_avg_gift_amt frequency_status_97nk;
run;
title;

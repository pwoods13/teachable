/* Solution l3s3.sas step 1 */

%global rho1_ex;

proc sql noprint;
   select mean(target_b) into :rho1_ex
   from pmlr.pva_train_imputed;
run; 

proc means data=pmlr.pva_train_imputed  
           sum nway noprint;
   class cluster_code;
   var target_b;
   output out=work.counts sum=events;
run;


/* Solution l3s3.sas step 2 */

filename clswoe "&PMLRfolder\swoe_cluster.sas";

data _null_;
   file clswoe;
   set work.counts end=last;
      logit=log((events + &rho1_ex*24)/
            (_FREQ_ - events + (1-&rho1_ex)*24));
   if _n_=1 then put "select (cluster_code);" ;
   put "  when ('" cluster_code +(-1) "') 
       cluster_swoe=" logit ";" ;
   if last then do;
      logit=log(&rho1_ex/(1-&rho1_ex));
      put "  otherwise cluster_swoe=" logit ";" / "end;";
   end;
run;

data pmlr.pva_train_imputed_swoe;
   set pmlr.pva_train_imputed;
   %include clswoe;
run;

title;

proc print data=pmlr.pva_train_imputed_swoe(obs=1);
   where cluster_code = "01";
   var cluster_code cluster_swoe;
run;

/* solution l3s2.sas step 1 */

proc means data=pmlr.pva_train_imputed noprint nway;
   class cluster_code;
   var target_b;
   output out=work.level mean=prop;
run;


/* solution l3s2.sas step 2 */

ods output clusterhistory=work.cluster;

proc cluster data=work.level method=ward 
             outtree=work.fortree
             plots=(dendrogram(horizontal height=rsq));
   freq _freq_;
   var prop;
   id cluster_code;
run;


/* solution l3s2.sas step 3 */

proc freq data=pmlr.pva_train_imputed noprint;
   tables cluster_code*target_b / chisq;
   output out=work.chi(keep=_pchi_) chisq;
run;

data work.cutoff;
   if _n_=1 then set work.chi;
   set work.cluster;
   chisquare=_pchi_*rsquared;
   degfree=numberofclusters-1;
   logpvalue=logsdf('CHISQ',chisquare,degfree);
run;

title1 "Plot of the Log of the P-Value by Number of Clusters";
proc sgplot data=work.cutoff;
   scatter y=logpvalue x=numberofclusters 
           / markerattrs=(color=blue symbol=circlefilled);
   xaxis label="Number of Clusters";
   yaxis label="Log of P-Value" min=-40 max=0;
run;
title1; 


/* solution l3s2.sas step 4 */

%global ncl;

proc sql;
   select NumberOfClusters into :ncl
   from work.cutoff
   having logpvalue=min(logpvalue);
quit;


/* solution l3s2.sas step 5 */

proc tree data=work.fortree nclusters=&ncl 
          out=work.clus noprint;
   id cluster_code;
run;

proc sort data=work.clus;
   by clusname;
run;

title1 "Cluster Assignments";
proc print data=work.clus;
   by clusname;
   id clusname;
run;


/* solution l3s2.sas step 6 */

filename clcode "&PMLRfolder/cluster_code.sas";

data _null_;
   file clcode;
   set work.clus end=last;
   if _n_=1 then put "select (cluster_code);";
   put "  when ('" cluster_code +(-1) "') cluster_clus='" cluster +(-1) "';";
   if last then do;
      put "  otherwise cluster_clus='U';" / "end;";
   end;
run;

data pmlr.pva_train_imputed_clus;
   set pmlr.pva_train_imputed;
   %include clcode;
run;

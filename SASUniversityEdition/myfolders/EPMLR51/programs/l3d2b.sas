/* ===================================================== */
/* Lesson 3, Section 2: l3d2b.sas
   Demonstration: Collapsing the Levels of a Nominal Input,
   Part 2                               
   [m643_2_g2; derived from pmlr03d02.sas]                */
/* ===================================================== */

/* Use the FREQ procedure to get the Pearson Chi^2 statistic of the 
   full BRANCH*INS table. */

proc freq data=work.train_imputed noprint;
   tables branch*ins / chisq;
   output out=work.chi(keep=_pchi_) chisq;
run;

/* Use a one-to-many merge to put the Chi^2 statistic onto the clustering
   results. Calculate a (log) p-value for each level of clustering. */

data work.cutoff;
   if _n_=1 then set work.chi;
   set work.cluster;
   chisquare=_pchi_*rsquared;
   degfree=numberofclusters-1;
   logpvalue=logsdf('CHISQ',chisquare,degfree);
run;

/* Plot the log p-values against number of clusters. */

title1 "Plot of the Log of the P-Value by Number of Clusters";
proc sgplot data=work.cutoff;
   scatter y=logpvalue x=numberofclusters 
           / markerattrs=(color=blue symbol=circlefilled);
   xaxis label="Number of Clusters";
   yaxis label="Log of P-Value" min=-120 max=-85;
run;
title1 ;

/* Create a macro variable (&ncl) that contains the number of clusters
   associated with the minimum log p-value. */

proc sql;
   select NumberOfClusters into :ncl
   from work.cutoff
   having logpvalue=min(logpvalue);
quit;

proc tree data=work.fortree nclusters=&ncl out=work.clus noprint;
   id branch;
run;

proc sort data=work.clus;
   by clusname;
run;

title1 "Levels of Branch by Cluster";
proc print data=work.clus;
   by clusname;
   id clusname;
run;
title1 ;

/* The DATA Step creates the scoring code to assign the branches to a cluster. */

filename brclus "&PMLRfolder/branch_clus.sas";

data _null_;
   file brclus;
   set work.clus end=last;
   if _n_=1 then put "select (branch);";
   put "  when ('" branch +(-1) "') branch_clus = '" cluster +(-1) "';";
   if last then do;
      put "  otherwise branch_clus = 'U';" / "end;";
   end;
run;

data work.train_imputed_greenacre;
   set work.train_imputed;
   %include brclus / source2;
run;


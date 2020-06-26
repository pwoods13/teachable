/* ===================================================== */
/* Lesson 3, Section 2: l3d2a.sas
   Demonstration: Collapsing the Levels of a Nominal Input,
   Part 1                               
   [m643_2_g1; derived from pmlr03d02.sas]                */
/* ===================================================== */

proc means data=work.train_imputed noprint nway;
   class branch;
   var ins;
   output out=work.level mean=prop;
run;

title1 "Proportion of Events by Level";
proc print data=work.level;
run;

/* Use ODS to output the ClusterHistory output object into a data set 
   named "cluster." */

ods output clusterhistory=work.cluster;

proc cluster data=work.level method=ward outtree=work.fortree
        plots=(dendrogram(vertical height=rsq));
   freq _freq_;
   var prop;
   id branch;
run;

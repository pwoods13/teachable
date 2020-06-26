/* ===================================================== */
/* Lesson 1, Section 1: l1d1.sas
   Demonstration: Examining the Code for Generating 
   Descriptive Statistics and Frequency Tables
   [m641_1_i; derived from pmlr01d01.sas]               */
/* ===================================================== */

data work.develop;
   set pmlr.develop;
run;

%global inputs;
%let inputs=ACCTAGE DDA DDABAL DEP DEPAMT CASHBK 
            CHECKS DIRDEP NSF NSFAMT PHONE TELLER 
            SAV SAVBAL ATM ATMAMT POS POSAMT CD 
            CDBAL IRA IRABAL LOC LOCBAL INV 
            INVBAL ILS ILSBAL MM MMBAL MMCRED MTG 
            MTGBAL CC CCBAL CCPURC SDB INCOME 
            HMOWN LORES HMVAL AGE CRSCORE MOVED 
            INAREA;

proc means data=work.develop n nmiss mean min max;
   var &inputs;
run;

proc freq data=work.develop;
   tables ins branch res;
run;

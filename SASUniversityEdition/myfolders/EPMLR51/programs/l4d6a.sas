/* ===================================================== */
/* Lesson 4, Section 5: l4d6a.sas
   Demonstration: Comparing and Evaluating Many Models, Part 1
   [m644_5_g2; derived from pmlr04d06.sas, pmlr04d06a.sas.,
   pmlr04d06b.sas]   
   Note: The code shown in the demonstration video uses
   %INCLUDE statements to include the SAS programs for the 
   Assess and Fitandscore macros, respectively. Instead,
   the code below includes all of the code for both macros.                        
                                                         */
/* ===================================================== */

%put &screened;

data work.valid_imputed_swoe_bins;
   set work.valid_imputed_swoe_bins;
   MICRScor=(crscore=.);
   resr=(res='R');
   resu=(res='U');
run;

title1 "Variables with Missing Values on the Validation Data Set";
proc means data=work.valid_imputed_swoe_bins nmiss;
   var &screened; 
run;

proc stdize data=work.train_imputed_swoe_bins method=median reponly
            OUTSTAT=med;
   var &screened;
run;

proc stdize data=work.valid_imputed_swoe_bins reponly method=in(med)
            out=work.valid_imputed_swoe_bins;
   var &screened;
run;

/* Assess macro code */
%macro assess(data=,inputcount=,inputsinmodel=,index=,pi1=,rho1=,target=,
              profit11=,profit01=,profit10=,profit00=);
    %let rho0 = %sysevalf(1-&rho1);
    %let pi0 = %sysevalf(1-&pi1);

    proc sort data=scored&data;
        by descending p_1;
    run;

    /* create assessment data set */
    data assess;
        attrib DATAROLE length=$5;
        retain sse 0 csum 0 DATAROLE "&data";

        /* 2 x 2 count array, or count matrix */
        array n[0:1,0:1] _temporary_ (0 0 0 0);

        /* sample weights array */
        array w[0:1] _temporary_ 
            (%sysevalf(&pi0/&rho0) %sysevalf(&pi1/&rho1));
        keep DATAROLE INPUT_COUNT INDEX 
            TOTAL_PROFIT OVERALL_AVG_PROFIT ASE C;
        set scored&data end=last;

        /* profit associated with each decision */
        d1=&Profit11*p_1+&Profit01*p_0;
        d0=&Profit10*p_1+&Profit00*p_0;

        /* T is a flag for response */
        t=(strip(&target)="1");

        /* D is the decision, based on profit. */
        d=(d1>d0);

        /* update the count matrix, sse, and c */
        n[t,d] + w[t];
        sse + (&target-p_1)**2;
        csum + ((n[1,1]+n[1,0])*(1-t)*w[0]);

        if last then
            do;
                INPUT_COUNT=&inputcount;
                TOTAL_PROFIT = sum(&Profit11*n[1,1],&Profit10*n[1,0],
                    &Profit01*n[0,1],&Profit00*n[0,0]);
                OVERALL_AVG_PROFIT = TOTAL_PROFIT/sum(n[0,0],n[1,0],n[0,1],n[1,1]);
                ASE = sse/sum(n[0,0],n[1,0],n[0,1],n[1,1]);
                C = csum/(sum(n[0,0],n[0,1])*sum(n[1,0],n[1,1]));
                index=&index;
                output;
            end;
    run;

    proc append base=results data=assess force;
    run;

%mend assess;


/* Fitandscore macro code */
/*Usage:*/
/*%fitandscore(data_train=,                             training data set*/
/*             data_validate=,                          validation data set*/
/*             target=,                                 target variable*/
/*             predictors=,                             predictor variable list*/
/*             best=,                                   # of best subset models to try*/
/*             profit00=,profit01=,profit10=,profit11=, values of the profit matrix*/
/*             pi1=);                                   actual population proportion*/

%macro fitandscore(data_train=,
                   data_validate=,
                   target=,
                   predictors=,
                   best=,
                   profit00=,profit01=,profit10=,profit11=,
                   pi1=);

    ods select none;

    ods output bestsubsets=score;

    proc logistic data=&data_train;
        model ins(event='1')=&predictors 
            / selection=SCORE best=&best;
    run;

    %global nmodels;

    proc sql;
        select count(*) into :nmodels from score;
    run;

    %global rho1;

    proc sql;
        select mean(INS) into :rho1 from &data_train;
    run;

    %do i=1 %to &nmodels;
        %global inputs&i;
        %global ic&i;
    %end;

    proc sql noprint;
        select variablesinmodel into :inputs1 -  
            from score;
        select NumberOfVariables into :ic1 - 
            from score;
    quit;

    proc datasets 
        library=work 
        nodetails 
        nolist;
        delete results;
    run;

    %do model_indx=1 %to &nmodels;

        %let im=&&inputs&model_indx;
        %let ic=&&ic&model_indx;

        proc logistic data=&data_train;
            model &target(event='1')=&im;
            score data=&data_train 
                out=scored&data_train(keep=ins p_1 p_0)
                priorevent=&pi1;
            score data=&data_validate 
                out=scored&data_validate(keep=ins p_1 p_0)
                priorevent=&pi1;
        run;

        %assess(data=&data_train,inputcount=&ic,inputsinmodel=&im,index=&model_indx,
            pi1=&pi1,rho1=&rho1,target=&target,profit11=&profit11,profit01=&profit01,
            profit10=&profit10,profit00=&profit00);
        %assess(data=&data_validate,inputcount=&ic,inputsinmodel=&im,index=&model_indx,
            pi1=&pi1,rho1=&rho1,target=&target,profit11=&profit11,profit01=&profit01,
            profit10=&profit10,profit00=&profit00);

    %end;

    ods select all;

%mend fitandscore;

/* End of macro code */

%fitandscore(data_train=train_imputed_swoe_bins,
             data_validate=valid_imputed_swoe_bins,
             target=ins,predictors=&screened resr resu SavBal*B_DDABal 
             MM*B_DDABal branch_swoe*ATMAmt B_DDABal*Sav SavBal*SDB 
             SavBal*DDA ATMAmt*DepAmt B_DDABal*ATMAmt SavBal*ATMAmt
             SavBal*IRA SavBal*MM SavBal*CC Sav*NSF DDA*ATMAmt Dep*ATM
             IRA*B_DDABal CD*MM MM*IRABal CD*Sav B_DDABal*CashBk Sav*CC,
             best=2,profit00=0,profit01=-1,profit10=0,profit11=99,pi1=0.02);


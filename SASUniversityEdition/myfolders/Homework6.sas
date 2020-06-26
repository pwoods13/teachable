data iout;
	infile "/folders/myfolders/Homework3/iout.csv" dlm="," dsd;
	input student Q Score;
run;

proc sort data=iout out=ioutSorted;
	by student;
run; 

proc means data=ioutSorted mean;
	by student;
	var Score;
run;
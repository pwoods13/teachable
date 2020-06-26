proc import datafile="/folders/myfolders/Final Project/A1_Ans_only.txt" out=AnswerKey(drop=VAR2) dbms=csv replace;
	getnames=no;
run;

proc import datafile="/folders/myfolders/Final Project/Form A1_only.csv" out=StudentResponses(drop=VAR2) dbms=csv replace; 
	getnames=no;
run;

data x;
	infile "/folders/myfolders/Final Project/Form A1_only.csv" dsd;
	input var1 varC;
	varC=put(var1, 4.);
run;
	
data all;
	merge AnswerKey StudentResponses;
run;


proc import datafile="/folders/myfolders/Final Project/Domains Form A1.csv" out=Domains_Form_A1 dbms=csv replace;
	getnames=no;
run;

proc append base=AnswerKey data=StudentResponses force;
	set 
run;
	

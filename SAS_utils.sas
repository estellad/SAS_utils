libname raw “\\folder\to\nowhere”;

/************************************ EXPORT ***************************************/
/* MACRO export SAS dataset as .csv or one sheet in .xlsx */
%macro export(dataset, name, sheet, type);
	PROC EXPORT DATA = &dataset.
		OUTFILE=“C://folder/to/nowhere/&name..&type”
		DBMS = &type. REPLACE;
		%if %sysfunc(lowcase(“&type.”)) = “xlsx” %then %do;
		sheet = “sheet.”;
	RUN;
 %mend;

%export(dataset = something, name = Something, sheet = tabA, type = csv);


%let output = \\folder\to\nowhere;

/* BASE export */
proc export data = something;
	outfield = “&output.\Somthing.csv”;
	dbms = csv
	replace;
run;


/************************* Batch CONVERT Character to Dates ********************/
%let vars = birth_date death_date graduate_date marry_date vacation_date
%macro chartodate;
	%do i=1 %to %sysfunc(countw(&vars.));
		%let var = %scan(&vars., &i.);
		format &var._ MMDDYY10.;
		if vtype(&var.) = ‘N’ then &var._ = &var.;
		if vtype(&var.) = ‘C’ then &var._ = input(&var., MMDDYY10.);

		drop &var.;
		rename &var._ = &var.;
	%end;
%mend;

%chartodate;


/************************* DROP Columns With All Missing ********************/
%macro dropmissing(in data, outdate); 
	proc content data = &indata. noprint out=cont; 
	run;

	proc sql noprint; 
		select name into:namelist separated by “ ” from cont where type=1; 
	quit;

	proc means noprint data=&indata.;
		var &namelist.;
		output out=maxout(drop_:) max=;
	run;

	proc transpose data=maxout out=max_col;
	run;

	proc sql noprint;
		select distinct _name_ into: del separated by “ ” from max_col where col1=.;
	quit;

	data &outdata.;
		set &indata. (drop = &del.);
	run;
%mend;

%dropmissing(dataset_messy, dataset_useful);


/************************* SAS loop through vars with same prefix ********************/
%let gene_list = kras pdl1 clb nras naf tet2 smcla asxl1 runx1;
/* One thing I really don't understand is SAS function takes variable directly from global environment! */
%macro flag_genes; 
data finished_flagging;
	set tobe_flagged;
	%do i=1 %to %sysfunc(countw(&gene_list.));
		%let _gene_var = %scan(&gene_list., &i.);
	
		fl_&_gene_var. = (&_gene_var.fl = "Y");
		fl_&_gene_var._miss = (&_gene_var.fl = "");
	%end;
	
	fl_tot_n = (fl_kras_miss = 0 and fl_kras_miss = 0 and fl_kras_miss = 0);
	fl_tot_miss = (fl_kras_miss = 1 or fl_kras_miss = 1 or fl_kras_miss = 1);
	
	keep fl_: ;
run;
%mend;
%flag_mutations;


/******************* SAS loop through vars with diff indexing -fix ********************/
%macro count_days;
	%do i = 1 to 20;
	/* Note this is not a double loop */
	%let j = %eval(i+1); 
	if a_day&i._num > 0 and a_day&i._cat = "A" then do;
		count_&i. = a_day&i._num;
		count_&j._new = a_day&j._num;
	end;
	%end;
%mend;

%count_days;

/******************************** SAS for-loop for vars *******************************/
array somevars var_high short_var tomorrow still not holiday;
do over somevars;
	if somevars ^= 1 then somevars = 0;
end;






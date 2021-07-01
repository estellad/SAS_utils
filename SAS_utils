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

%export(dataset = something, name = Something, sheet = tabA, type = csv)


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

%chartodate


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






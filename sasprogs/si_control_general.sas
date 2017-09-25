/*********************************************************************************************************
DESCRIPTION: Creates generic global variables required for creation of at-risk mothers & babies 
analysis datasets

INPUT:
si_sandpit_libname     = the libname you use to access IDI_Sandpit
si_proj_schema         = your project schema name
si_debug               = retain all the intermediate datasets {True | False} 
si_id_col              = name of the column that has the id most likely to be snz_uid

OUTPUT:
work.control_file = sas dataset specifying every variable needed to run the si data foundation
all of column names are also global macro variables that can be used throughout 
the code

AUTHOR: V Benny

DEPENDENCIES: 
NA

NOTES: 
The data foundation has 1 control file. The reason for having three here is we have one set of 
parameters to set up file locations and writing to the database. Once the population is written to the
database we have separate control files for the mother and child as we choose to summarise different 
variables for the mothers and the child. People external to the SIA wishing to replicate this work would
just modify si_control_general. Those wanting to do additional analysis may need to edit all three
control files.

HISTORY: 
10 Aug 2017 EW Bug fix to allow the variables to be specified and allow casting of dates
13 Jul 2017 VB 	v1
*********************************************************************************************************/
data work.control_file_long;
	attrib si_var_name  length=$32;
	attrib si_value     length=$32;
	input si_var_name $ si_value $;

	/* specify your variables after the comma do not put a space after the comma */
	/* do not leave spaces after variables specified */
	/* refer to completed files in the examples folder if you are unsure */
	infile datalines dlm="," dsd missover;
	datalines;
si_sandpit_libname,sand
si_proj_schema,DL-MAA2016-15
si_debug,False
si_id_col,snz_uid
si_asat_date,birth_date
start_cutoff_date,2010-07-01
end_cutoff_date,2011-06-30
idi_version,IDI_Clean
;
run;

/* we did it in long form first so it is easier on the eye and you are less likely to put the wrong argument in */
/* the wrong macro variable */
/* tip table on its side so each column can be mapped to a macro variable */
proc transpose data= work.control_file_long
	out = work.control_file_wide (drop=_name_);
	id si_var_name;
	var si_value;
run;

/* make sure these variables are available to all macros */
%global 
	si_sandpit_libname    si_proj_schema 
	si_debug
	si_id_col
	si_asat_date
	start_cutoff_date
	end_cutoff_date
	idi_version;

data _null_;
	set work.control_file_wide;

	/* populate the global variables */
	call symput('si_sandpit_libname',left(trim(si_sandpit_libname)));
	call symput('si_proj_schema',left(trim(si_proj_schema)));
	call symput('si_debug',left(trim(si_debug)));
	call symput('si_id_col',left(trim(si_id_col)));
	call symput('si_asat_date',left(trim(si_asat_date)));
	/* the two dates require quotes around them */
	call symput('start_cutoff_date',left(trim(start_cutoff_date)));
	call symput('end_cutoff_date',left(trim(end_cutoff_date)));
	call symput('idi_version',left(trim(idi_version)));
run;

%put _user_;

/* libname to write to db via implicit passthrough */
libname &si_sandpit_libname ODBC dsn= idi_sandpit_srvprd schema="&si_proj_schema" bulkload=yes;

/* software information */
%global si_version si_license;
%let si_version = 1.0.0;
%let si_license = GNU GPLv3;
%global si_bigdate;


data _null_;
	call symput('si_bigdate', "31Dec9999"D);
run;


/* additional processing required so we can cast the dates */
/* so messy maybe a call symputx with catted single quotes would have been neater */
%global start_cutoff_date_quote end_cutoff_date_quote;
%let start_cutoff_date_quote = %unquote(%str(%')&start_cutoff_date.%str(%'));
%let end_cutoff_date_quote = %unquote(%str(%')&end_cutoff_date.%str(%'));

%put ********************************************************************;
%put --------------------------------------------------------------------;
%put ----------------------SI Data Foundation----------------------------;
%put ............si_version: &si_version;
%put ............si_license: &si_license;
%put ............si_runtime: %sysfunc(datetime(),datetime20.);

/* general info */
%put --------------------------------------------------------------------;
%put -------------si_control_general: General info-----------------------;
%put ....si_sandpit_libname: &si_sandpit_libname;
%put ........si_proj_schema: &si_proj_schema;
%put ..............si_debug: &si_debug;
%put .............si_id_col: &si_id_col;
%put ..........si_asat_date: &si_asat_date;

/* get cohort info */
%put --------------------------------------------------------------------;
%put -------------si_control_general: General info-----------------------;
%put ......start_cutoff_date: &start_cutoff_date;
%put ........end_cutoff_date: &end_cutoff_date;
%put start_cutoff_date_quote: &start_cutoff_date_quote;
%put ..end_cutoff_date_quote: &end_cutoff_date_quote;
%put ............idi_version: &idi_version;
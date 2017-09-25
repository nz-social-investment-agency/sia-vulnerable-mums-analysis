/*********************************************************************************************************
DESCRIPTION: File where you can specify arguments needed to build the social investment data foundation
	for the mothers cohort

INPUT:
si_debug               = retain all the intermediate datasets {True | False} 
si_pop_table_out       = name of the table you created that contains a list of ids and dates
si_id_col              = name of the column that has the id most likely to be snz_uid
si_asat_date           = date when the intervention or time point of interest
si_num_periods_before  = number of periods before hand to create service metrics for
si_num_periods_after   = number of periods after to create service metrics for
si_period_duration     = how long is a period {Year | Quarter | Month | Week | <integer>}
si_amount_type         = Specify if the amount type is (L)ump sum, (D)aily or NA if there is no amount {L, D, NA}
si_sial_amount_col     = name of the column that has the dollars in it {cost | revenue}
si_price_index_type    = type of inflation adjustment {CPI | PPI | QEX}
si_price_index_qtr     = reference Quarter to which Inflation adjustment is to be done
si_discount            = specify if discounting is to be done {True | False}
si_discount_rate       = specify discounting rate e.g. 3 means 3% (value is ignored if si_discount = False)
si_use_acc             = include ACC data {True | False} 
si_use_cor             = include Corrections data {True | False} 
si_use_hnz             = include Housing NZ data {True | False}   
si_use_ird             = include IRD data {True | False}
si_use_mix             = include MIX data {True | False}  
si_use_moe             = include MOE data {True | False} 
si_use_moh             = include MOH data {True | False} 
si_use_moj             = include MOJ data {True | False} 
si_use_msd             = include MSD data {True | False} 
si_use_pol             = include Police data {True | False} 
si_rollup_output_type  = type of rolled up table you would like{Long | Wide | Both}
si_rollup_agg_cols     = rollup level - currently not implemented rollup is harded coded at subject area level
si_rollup_cost         = produce cost service metrics {True | False}
si_rollup_duration     = produce duration service metrics {True | False}
si_rollup_count        = produce count of events based on period duration {True | False}
si_rollup_count_sdate  = produce count of events based on the start date of the event {True | False}
si_rollup_dayssince    = produce days since the last event in the profile window and days since the first 
event in the forecast window  {True | False}


OUTPUT:
work.control_file = sas dataset specifying every variable needed to run the si data foundation
                    all of column names are also global macro variables that can be used throughout the code

AUTHOR: E Walsh

DATE: 12 May 2017

DEPENDENCIES: 

NOTES: 
A complete example is shown in ../examples/XXXXX

HISTORY: 
12 May 2017 EW v1
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
si_debug,False
si_pop_table_out,si_mother_cohort
si_id_col,snz_uid
si_asat_date,birth_date
si_num_periods_before,-2
si_num_periods_after,6
si_period_duration,Year
si_amount_type,L
si_sial_amount_col,cost
si_price_index_type,CPI
si_price_index_qtr,2016Q2
si_discount,False
si_discount_rate,3
si_use_acc,True
si_use_cor,False
si_use_hnz,False
si_use_ird,False
si_use_mix,True
si_use_moe,True
si_use_moh,True
si_use_moj,True
si_use_msd,False
si_use_pol,True
si_rollup_output_type,Wide
si_rollup_cost,True
si_rollup_duration,False
si_rollup_count,False
si_rollup_count_sdate,False
si_rollup_dayssince,False
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
	si_debug
	si_id_col             si_asat_date     
	si_num_periods_before si_num_periods_after si_period_duration
	si_amount_type        si_sial_amount_col
	si_price_index_type   si_price_index_qtr 
	si_discount           si_discount_rate
	si_use_acc            si_use_cor           si_use_hnz     
    si_use_ird            si_use_mix
	si_use_moe            si_use_moh           si_use_msd 
	si_use_moj            si_use_pol
	si_rollup_output_type
	si_rollup_cost        si_rollup_duration   si_rollup_count
	si_rollup_count_sdate si_rollup_dayssince;

data _null_;
	set work.control_file_wide;

	/* populate the global variables */
	call symput('si_debug',left(trim(si_debug)));
	call symput('si_pop_table_out',left(trim(si_pop_table_out)));
	call symput('si_id_col',left(trim(si_id_col)));
	call symput('si_asat_date',left(trim(si_asat_date)));
	call symput('si_num_periods_before',left(trim(si_num_periods_before)));
	call symput('si_num_periods_after',left(trim(si_num_periods_after)));
	call symput('si_period_duration',left(trim(si_period_duration)));
	call symput('si_amount_type',left(trim(si_amount_type)));
	call symput('si_sial_amount_col',left(trim(si_sial_amount_col)));
	call symput('si_price_index_type',left(trim(si_price_index_type)));
	call symput('si_price_index_qtr',left(trim(si_price_index_qtr)));
	call symput('si_discount',left(trim(si_discount)));
	call symput('si_discount_rate',left(trim(si_discount_rate)));
	call symput('si_use_acc',left(trim(si_use_acc)));
	call symput('si_use_cor',left(trim(si_use_cor)));
	call symput('si_use_hnz',left(trim(si_use_hnz)));
	call symput('si_use_ird',left(trim(si_use_ird)));
    call symput('si_use_mix',left(trim(si_use_mix)));
	call symput('si_use_moe',left(trim(si_use_moe)));
	call symput('si_use_moh',left(trim(si_use_moh)));
	call symput('si_use_moj',left(trim(si_use_moj)));
	call symput('si_use_msd',left(trim(si_use_msd)));
	call symput('si_use_pol',left(trim(si_use_pol)));
	call symput('si_rollup_output_type',left(trim(si_rollup_output_type)));
	call symput('si_rollup_cost',left(trim(si_rollup_cost)));
	call symput('si_rollup_duration',left(trim(si_rollup_duration)));
	call symput('si_rollup_count',left(trim(si_rollup_count)));
	call symput('si_rollup_count_sdate',left(trim(si_rollup_count_sdate)));
	call symput('si_rollup_dayssince',left(trim(si_rollup_dayssince)));
run;

/* we no longer require the long version */
proc sql;
	drop table control_file_long;
quit;

/************************************************************************/
/* do not modify below here */

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

%put ********************************************************************;
%put --------------------------------------------------------------------;
%put ----------------------SI Data Foundation----------------------------;
%put ............si_version: &si_version;
%put ............si_license: &si_license;
%put ............si_runtime: %sysfunc(datetime(),datetime20.);

/* general info */
%put --------------------------------------------------------------------;
%put -------------si_control: General info-------------------------------;
%put ....si_sandpit_libname: &si_sandpit_libname;
%put ........si_proj_schema: &si_proj_schema;
%put ..............si_debug: &si_debug;

/* population cohort info */
%put ---------------------------------------------------------------------;
%put ------------si_control: Population cohort parameters-----------------;
%put ......si_pop_table_out: &si_pop_table_out;
%put .............si_id_col: &si_id_col;
%put ..........si_asat_date: &si_asat_date;

/* windowing parameters */
%put ----------------------------------------------------------------------;
%put ------------si_control: Windowing parameters--------------------------;
%put .si_num_periods_before: &si_num_periods_before;
%put ..si_num_periods_after: &si_num_periods_after;
%put ....si_period_duration: &si_period_duration;
%put ----------------------------------------------------------------------;

/* cost related parameters */
%put ---------------------------------------------------------------------;
%put ------------si_control: Cost Related Parameters----------------------;
%put ........si_amount_type: &si_amount_type;
%put ....si_sial_amount_col: &si_sial_amount_col;
%put ...si_price_index_type: &si_price_index_type;
%put ....si_price_index_qtr: &si_price_index_qtr;
%put ...........si_discount: &si_discount;
%put ......si_discount_rate: &si_discount_rate;

/* agency data use flags */
%put ----------------------------------------------------------------------;
%put ------------si_control: Agency data use flags-------------------------;
%put ............si_use_acc: &si_use_acc;
%put ............si_use_cor: &si_use_cor;
%put ............si_use_hnz: &si_use_hnz;
%put ............si_use_ird: &si_use_ird;
%put ............si_use_mix: &si_use_mix;
%put ............si_use_moe: &si_use_moe;
%put ............si_use_moh: &si_use_moh;
%put ............si_use_moj: &si_use_moj;
%put ............si_use_msd: &si_use_msd;
%put ............si_use_pol: &si_use_pol;

/* rollup flags */
%put ----------------------------------------------------------------------;
%put ------------si_control: Rollup flags ---------------------------------;
%put ........si_rollup_cost: &si_rollup_cost;
%put ....si_rollup_duration: &si_rollup_duration;
%put .......si_rollup_count: &si_rollup_count;
%put .si_rollup_count_sdate: &si_rollup_count_sdate;
%put ...si_rollup_dayssince: &si_rollup_dayssince;
%put ********************************************************************;
/*********************************************************************************************************
DESCRIPTION: Main script that creates the vulnerable mothers datasets ready for analysis.

INPUT:
si_control_general.sas = builds dataset with generic list of parameters
si_control_mother.sas = builds dataset with list of parameters for mothers
si_control_child.sas = builds dataset with list of parameters for children
si_source_path = full path to the folder location

OUTPUT:
IDI_Sandpit.<project_schema>.si_mothers_birth_events
IDI_Sandpit.<project_schema>.si_mothers_cohort_char_ext
IDI_Sandpit.<project_schema>.si_child_cohort_char_ext
IDI_Sandpit.<project_schema>.rlpm_<agency-specific>_events (Roll-up tables for mothers)
IDI_Sandpit.<project_schema>.rlpc_<agency-specific>_events (Roll-up tables for children)
IDI_Sandpit.<project_schema>.si_mother_cohort_modelling (Modelling dataset for mothers)
IDI_Sandpit.<project_schema>.si_child_cohort_modelling (Modelling dataset for children)


AUTHOR: V Benny

DEPENDENCIES:
Social Investment Analytical Layer must be installed and available for use
Mental Health/Addictions Data Definition must be installed and available for use.
Social Investment Data Foundation macros must be available for use.
All of these are available as Git submodules under the lib folder.

NOTES:
1. People external to the SIA wishing to replicate this work would need modify si_control_general.sas
	before running main so that the work is written to their own schemas.
2. This SAS code takes approximately 3 hours to run.

HISTORY: 
07 Sep 2017 VB Integration testing completed.
10 Aug 2017 EW Integrated submodules and performed integration testing
13 Jul 2017	VB Version 1

*********************************************************************************************************/

/*********************************************************************************************************/
/* Set up */
/*********************************************************************************************************/

/* switch off when testing is complete */
options mlogic mprint;

/* Paraemterise location where the folders are stored */
%let si_source_path = \\wprdfs08\MAA2016-15 Supporting the Social Investment Unit\github_vulnerable_mothers;

/* Time the run to help plan for future re-runs if necessary */
%global si_main_start_time;
%let si_main_start_time = %sysfunc(time());

/* Load any macros specific to the vulnerable mothers work */
/* Load the data foundation macros */
options obs=MAX mvarsize=max pagesize=132
        append=(sasautos=("&si_source_path.\sasautos" 
"&si_source_path.\lib\social_investment_data_foundation\sasautos"));

/* Specify libnames required by project */
%include "&si_source_path.\include\libnames.sas";

/* Specify generic global variables */
%include "&si_source_path.\sasprogs\si_control_general.sas";
libname &si_sandpit_libname. ODBC dsn= idi_sandpit_srvprd schema="&si_proj_schema." bulkload=yes;

/* Load Formats required by macros */
%include "&si_source_path.\include\si_moe_formats.sas";

/*********************************************************************************************************/
/* Build population */
/*********************************************************************************************************/

/* Generate the population - This consists of 2 cohorts. The first is for all mothers who have given 
birth in the defined period, and are linked to the SNZ ERP in the year following the birth. The dataset 
will have one record for each mother - with multiple date columns for each birth event in the defined 
period. A second population is for children from these birth events and are also linked to the SNZ ERP in 
the year following birth.*/

%include "&si_source_path.\sasprogs\si_get_cohort.sas";

/*********************************************************************************************************/
/* Add static or slow changing characteristics */
/*********************************************************************************************************/

/* Generate static variables related to demographics and identification for mothers and the children */
%si_get_characteristics(
	si_char_proj_schema=&si_proj_schema., 
	si_char_table_in=si_mother_cohort, 
	si_as_at_date=&si_asat_date., 
	si_char_table_out=work.si_mother_cohort_char
	);
%si_get_characteristics(
	si_char_proj_schema=&si_proj_schema., 
	si_char_table_in=si_child_cohort, 
	si_as_at_date=&si_asat_date., 
	si_char_table_out=work.si_child_cohort_char
	);

/* add the custom characteristics */
%include "&si_source_path.\sasprogs\si_mother_child_char_ext.sas";

/* push both datasets into the database so that master characteristics can run an explicit pass through*/
%si_write_to_db(
	si_write_table_in=si_mother_cohort_char_ext, 
	si_write_table_out=&si_sandpit_libname..si_mother_cohort_char_ext,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col., &si_asat_date.)
);
%si_write_to_db(
	si_write_table_in=si_child_cohort_char_ext, 
	si_write_table_out=&si_sandpit_libname..si_child_cohort_char_ext,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col., &si_asat_date.)
);

/*********************************************************************************************************/
/* Build SIAL metrics and outcomes */
/*********************************************************************************************************/

/* Creation of cohorts end here. Now we start rolling up SIAL for generating additional variables*/
/* Time required: 3 hours*/

/* Specify global variables for mother variables rollup */
%include "&si_source_path.\sasprogs\si_control_mother.sas";

/* Create rollup tables with additional variables for mothers */
%include "&si_source_path.\sasprogs\si_mother_variables.sas";

/* Specify global variables for child variables rollup */
%include "&si_source_path.\sasprogs\si_control_child.sas";

/* Create rollup tables with additional variables for mothers */
%include "&si_source_path.\sasprogs\si_child_variables.sas";

/* Create the modelling tables */
%si_run_sqlscript(filepath = &si_source_path.\sql\create_modelling_dataset_mother.sql, db_odbc = idi_sandpit_srvprd, 
	db_schema = "&si_proj_schema.", replace_string = "{schema_name}" );
%si_run_sqlscript(filepath = &si_source_path.\sql\create_modelling_dataset_child.sql, db_odbc = idi_sandpit_srvprd, 
	db_schema = "&si_proj_schema.", replace_string = "{schema_name}"  );




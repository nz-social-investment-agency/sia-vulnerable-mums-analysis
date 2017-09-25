/*********************************************************************************************************
DESCRIPTION: Creates rolled up variables for all children in the cohort

INPUT: 
IDI_Sandpit.<project_schema>.si_child_cohort

OUTPUT:
Rollup tables across all agencies will be created in the IDI_Sandpit.<project_schema>, with the
prefix "rlpm_"

AUTHOR: Vinay Benny

DEPENDENCIES: 
Social Investment Analytical layer must be installed and available for use
Social investment Data Foundation macros must be available for use.
Both of these are available as Git submodules under the lib folder
si_control_child must be populated and si_main must be run

NOTES: 

HISTORY:
15 Jul 2017 EW QA and tidy up
14 Jul 2017 WJ v1.1
14 Jul 2017 VB v1 

*********************************************************************************************************/

/* Create generic rollup tables for the child population*/
/* we have chosen to look at MOH, MIX using the generic rollup */
%si_wrapper_sial_rollup(si_wrapper_proj_schema = &si_proj_schema.);
%si_write_to_db(
	si_write_table_in=MIX_mortality_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MIX_mortality_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MIX_selfharm_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MIX_selfharm_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_cancer_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_cancer_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_chronic_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_chronic_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_gms_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_gms_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_labtest_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_labtest_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_nir_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_nir_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_nnpac_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_nnpac_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_pfhd_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_pfhd_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_pharm_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_pharm_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_primhd_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_MOH_primhd_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Custom rollups */
/*************************************CYF ABUSE*********************************************************/
/* requires the control file to have been run */
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_CYF_abuse_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = NA,  
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = CYF_abuse_events_aln,	
	period_aligned_to_calendar = False );

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = CYF_abuse_events_aln,	
	si_out_table = CYF_abuse_events_rlp,		
	si_agg_cols= %str(department datamart subject_area event_type),	
	si_id_col = &si_id_col. ,
	si_amount_col = NA,
	si_as_at_date = &si_asat_date. ,
	cost = False, 
	duration = True, 
	count = True, 
	count_startdate = True, 
	dayssince = True,
	si_rollup_ouput_type = &si_rollup_output_type.
	);
%si_write_to_db(
	si_write_table_in=CYF_abuse_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpc_CYF_abuse_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/*************************************IMMUNISATIONS*********************************************************/
proc sort data= sand.si_child_cohort out= work.si_child_cohort;
	by snz_uid;
run;

proc sort data=moh.nir out=work.nir;
	by snz_uid;
run;

data SIAL_MOH_nir_events_rlpw;
	merge work.si_child_cohort(keep=snz_uid in=a ) work.nir (keep=snz_uid  moh_nir_imm_stat_6_month_ind
		moh_nir_imm_stat_8_month_ind
		moh_nir_imm_stat_12_month_ind
		moh_nir_imm_stat_18_month_ind
		moh_nir_imm_stat_24_month_ind
		moh_nir_imm_stat_60_month_ind);
	by snz_uid;

	if a;
run;

proc sort data= SIAL_MOH_nir_events_rlpw out=SIAL_MOH_nir_events_rlpw1 nodupkey;
	by snz_uid;
run;

%si_write_to_db(
	si_write_table_in=SIAL_MOH_nir_events_rlpw1, 
	si_write_table_out=&si_sandpit_libname..rlpc_SIAL_MOH_nir_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/*************************************INDICATORS FROM SIDF********************************************************/

/* before school check outcomes currently has the general outcome, SDQ for parent and teaching
extend the code if you want dental, hearing outcomes */

/* Create a dataset with an as-at date 5 years from birth event*/
proc sql;
	drop table sand.&si_pop_table_out._5yrs;
	create table sand.&si_pop_table_out._5yrs as 
		select 
			snz_uid, 
			intnx('DTYEAR', birth_date, 5, 'SAME') as birth_date_5yrs format = datetime20.
		from &si_sandpit_libname..&si_pop_table_out._char_ext;
quit;

/* also update the where clause so that it accepts a window date using similar notation to the sial align events macro */
%si_get_b4s_outcomes( si_b4s_dsn = &idi_version., si_b4s_proj_schema = &si_proj_schema. ,
	si_b4s_table_in = &si_pop_table_out._5yrs ,si_b4s_id_col = snz_uid,
	si_b4s_asat_date =birth_date_5yrs, si_b4s_table_out = rlpc_b4sc_events);
%si_write_to_db(
	si_write_table_in=rlpc_b4sc_events, 
	si_write_table_out=&si_sandpit_libname..rlpc_b4sc_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* ECE outcomes */
%si_get_ece_participation(si_ece_table_in =&si_pop_table_out._5yrs ,
	si_ece_type = Any, si_ece_proj_schema =&si_proj_schema., si_ece_id_col = snz_uid,
	si_ece_asat_date = birth_date_5yrs, si_ece_table_out = rlpc_ece_any_events);
%si_write_to_db(
	si_write_table_in=rlpc_ece_any_events, 
	si_write_table_out=&si_sandpit_libname..rlpc_ece_any_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* and a Kohanga specific breakdown */
%si_get_ece_participation(si_ece_table_in =&si_pop_table_out._5yrs , si_ece_type = Kohanga, 
	si_ece_proj_schema =&si_proj_schema., si_ece_id_col =snz_uid,
	si_ece_asat_date =birth_date_5yrs, si_ece_table_out =rlpc_ece_koh_events);
%si_write_to_db(
	si_write_table_in=rlpc_ece_koh_events, 
	si_write_table_out=&si_sandpit_libname..rlpc_ece_koh_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* CYF contact records and police fv */
%si_get_cr_outcomes( si_crd_dsn = &idi_version., si_crd_proj_schema =&si_proj_schema. , si_crd_table_in =&si_pop_table_out._5yrs, 
	si_crd_id_col = snz_uid, si_crd_asat_date =birth_date_5yrs, si_crd_table_out =rlpc_cr_events);

/* Removing duplicates in the data */
proc sort data=rlpc_cr_events out=rlpc_cr_events1 nodupkey;
	by snz_uid;
run;

%si_write_to_db(
	si_write_table_in=rlpc_cr_events1, 
	si_write_table_out=&si_sandpit_libname..rlpc_cr_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* SOCRATES support need */
/* no need for date windowing here - assume they were born with disability and the support need */
%si_get_disability_needs(si_din_dsn = &idi_version., si_din_proj_schema =&si_proj_schema., si_din_table_in =&si_pop_table_out._5yrs,
	si_din_id_col =&si_id_col., si_din_table_out =rlpc_disability_events);
%si_write_to_db(
	si_write_table_in=rlpc_disability_events, 
	si_write_table_out=&si_sandpit_libname..rlpc_disability_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* potentially avoidable hospitalisations */
%si_get_pah(si_pah_dsn= &idi_version., si_pah_proj_schema =&si_proj_schema., si_pah_table_in =&si_pop_table_out._5yrs , si_pah_id_col = &si_id_col.,
	si_pah_date = birth_date_5yrs, 
	si_pah_table_out = rlpc_pah_events);

%si_write_to_db(
	si_write_table_in=rlpc_pah_events, 
	si_write_table_out=&si_sandpit_libname..rlpc_pah_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);


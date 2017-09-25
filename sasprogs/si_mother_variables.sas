/*********************************************************************************************************
DESCRIPTION: Creates rolled up variables for all mothers

INPUT: 
IDI_Sandpit.<project_schema>.si_mother_cohort

OUTPUT:
Rollup tables across all agencies will be created in the IDI_Sandpit.<project_schema>, with the
prefix "rlpm_"

AUTHOR: Vinay Benny

DEPENDENCIES: 
Social Investment Analytical layer must be installed and available for use
Social investment Data Foundation macros must be available for use.
Both of these are available as Git submodules under the lib folder
si_control_mother must be populated and si_main must be run


NOTES: 
NA

HISTORY:
11 Aug 2017 EW tidy up
13 Jul 2017 VB v1 

*********************************************************************************************************/

/* Create generic rollup tables at subject_area level for the mothers population*/
%si_wrapper_sial_rollup(si_wrapper_proj_schema = &si_proj_schema.);
%si_write_to_db(
	si_write_table_in=MIX_mortality_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MIX_mortality_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MIX_selfharm_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MIX_selfharm_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOE_intervention_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_intervention_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOE_ITL_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_ITL_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOE_school_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_school_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOE_tertiary_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_tertiary_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_cancer_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_cancer_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_chronic_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_chronic_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_gms_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_gms_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_labtest_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_labtest_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_nir_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_nir_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_nnpac_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_nnpac_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_pfhd_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_pfhd_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_pharm_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_pharm_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOH_primhd_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOH_primhd_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=MOJ_courtcase_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOJ_courtcase_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=POL_offender_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_POL_offender_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
%si_write_to_db(
	si_write_table_in=POL_victim_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_POL_victim_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
/*%si_write_to_db(
	si_write_table_in=IRD_income_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_IRD_income_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);*/

/* Custom rollups */

/*************************************T1 BENEFITS*********************************************************/
/**** Variables for MSD Tier 1 benefit durations ****/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_MSD_T1_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = NA,  
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = MSD_T1_events_aln,	
	period_aligned_to_calendar = False );

proc sql;
	create table MSD_T1_events_aln as 
		select *, upcase( substr(event_type_3, 1, 4) ) as event_type_5 
			from MSD_T1_events_aln;
quit;

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = MSD_T1_events_aln,	
	si_out_table = MSD_T1_events_rlp,		
	si_agg_cols= %str(department datamart subject_area event_type_5),	
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

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=MSD_T1_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MSD_T1_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete MSD_T1_events_aln	MSD_T1_events_rlpw;
run;

/*************************************T2 BENEFITS*********************************************************/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_MSD_T2_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = &si_amount_type. , 
	si_amount_col = &si_sial_amount_col. , 
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = MSD_T2_events_aln,
	period_aligned_to_calendar = False, 
	si_pi_type = &si_price_index_type. , 
	si_pi_qtr = &si_price_index_qtr. );

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = MSD_T2_events_aln,	
	si_out_table = MSD_T2_events_rlp,		
	si_agg_cols= %str(department datamart subject_area),	
	si_id_col = &si_id_col. ,
	si_amount_col = &si_sial_amount_col._&si_price_index_type._&si_price_index_qtr.,
	si_as_at_date = &si_asat_date. ,
	cost = True, 
	duration = True, 
	count = True, 
	count_startdate = True, 
	dayssince = True,
	si_rollup_ouput_type = &si_rollup_output_type.
	);

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=MSD_T2_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MSD_T2_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete MSD_T2_events_aln	MSD_T2_events_rlpw;
run;

/*************************************T3 BENEFITS*********************************************************/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_MSD_T3_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = &si_amount_type. , 
	si_amount_col = &si_sial_amount_col. , 
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = MSD_T3_events_aln,
	period_aligned_to_calendar = False, 
	si_pi_type = &si_price_index_type. , 
	si_pi_qtr = &si_price_index_qtr. );

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = MSD_T3_events_aln,	
	si_out_table = MSD_T3_events_rlp,		
	si_agg_cols= %str(department datamart subject_area),	
	si_id_col = &si_id_col. ,
	si_amount_col = &si_sial_amount_col._&si_price_index_type._&si_price_index_qtr.,
	si_as_at_date = &si_asat_date. ,
	cost = True, 
	duration = True, 
	count = True, 
	count_startdate = True, 
	dayssince = True,
	si_rollup_ouput_type = &si_rollup_output_type.
	);

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=MSD_T3_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_MSD_T3_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete MSD_T3_events_aln	MSD_T3_events_rlpw;
run;

/*************************************CORRECTIONS*********************************************************/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_COR_sentence_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = &si_amount_type. , 
	si_amount_col = &si_sial_amount_col. , 
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = COR_sentence_events_aln,
	period_aligned_to_calendar = False, 
	si_pi_type = &si_price_index_type. , 
	si_pi_qtr = &si_price_index_qtr. );

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = COR_sentence_events_aln,	
	si_out_table = COR_sentence_events_rlp,		
	si_agg_cols= %str(department datamart subject_area event_type),	
	si_id_col = &si_id_col. ,
	si_amount_col = &si_sial_amount_col._&si_price_index_type._&si_price_index_qtr.,
	si_as_at_date = &si_asat_date. ,
	cost = True, 
	duration = True, 
	count = True, 
	count_startdate = True, 
	dayssince = True,
	si_rollup_ouput_type = &si_rollup_output_type.
	);

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=COR_sentence_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_COR_sentence_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete COR_sentence_events_aln	COR_sentence_events_rlpw;
run;

/*************************************MENTAL HEALTH*********************************************************/
/**** Variables for maternal alcohol use, drug use, depression, and general MH issues ****/
/* Align the moh_events*/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].moh_diagnosis , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = NA,  
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = moh_diagnosis_aln,	
	period_aligned_to_calendar = False );

/* Create a classification of MH disorders we have a special interest in, and filter out Potential MH related records*/
proc sql;
	create table moh_diagnosis_aln as 
		select *
			, 
		case 
			when event_type in ('Mood', 'Mood anxiety', 'Anxiety') then 'DEP' /* define a rough indicator for depression*/
	when event_type in ('Substance use') then 'SUB'
	else 'OTH' end as event_type_4
	from moh_diagnosis_aln
		where event_type <> 'Potential MH';
quit;

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = moh_diagnosis_aln,	
	si_out_table =moh_diagnosis_rlp,		
	si_agg_cols= %str(department datamart subject_area event_type_4),	
	si_id_col = &si_id_col. ,
	si_amount_col = NA,
	si_as_at_date = &si_asat_date. ,
	cost = False, 
	duration = True, 
	count = True, 
	count_startdate = True, 
	dayssince = True,
	si_rollup_ouput_type = Long
	);

/* A bit of variable selection here- we don't need durations for PHARM related variables*/
proc sql;
	create table moh_diagnosis_rlpl as 
		select * from moh_diagnosis_rlpl where vartype not like '%PHARM_MHA%DUR';
quit;

proc transpose data=moh_diagnosis_rlpl delim=_ out=moh_diagnosis_rlpw (drop=_NAME_); /*Suffix "w" for Wide table format*/
	by snz_uid;
	id vartype;
	var value;
run;

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=moh_diagnosis_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_moh_diagnosis,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete moh_diagnosis_aln	moh_diagnosis_rlpw	moh_diagnosis_rlpl;
run;

/*************************************IRD EVENTS*********************************************************/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table=[IDI_Sandpit].[&si_proj_schema.].SIAL_IRD_income_events , /* SIAL table in the current loop iteration */
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = &si_amount_type. , 
	si_amount_col = &si_sial_amount_col. , 
	noofperiodsbefore = &si_num_periods_before. , 
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = IRD_income_events_aln,
	period_aligned_to_calendar = False, 
	si_pi_type = &si_price_index_type. , 
	si_pi_qtr = &si_price_index_qtr. );

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = IRD_income_events_aln,	
	si_out_table = IRD_income_events_rlp,		
	si_agg_cols= %str(department datamart subject_area),	
	si_id_col = &si_id_col. ,
	si_amount_col = &si_sial_amount_col._&si_price_index_type._&si_price_index_qtr.,
	si_as_at_date = &si_asat_date. ,
	cost = True, 
	duration = True, 
	count = False, 
	count_startdate = False, 
	dayssince = True,
	si_rollup_ouput_type = &si_rollup_output_type.
	);

/* Write these datasets into the database for future use*/
%si_write_to_db(
	si_write_table_in=IRD_income_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_IRD_income_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=work;
	delete IRD_income_events_aln	IRD_income_events_rlpw;
run;

/*********************************HIGHEST QUAL - AT BIRTH, 5 YEARS FROM BIRTH *****************************************************/
/* Highest qualification as on date of giving birth*/
%si_get_highest_qualifications( 
	si_table_in = &si_pop_table_out._char_ext
	,si_id_col = &si_id_col.
	,si_as_at_date = &si_asat_date. 
	,si_IDI_refresh_date = 
	,si_target_schema = &si_proj_schema.
	,si_out_table = rlpw_MOE_qual
	);
%si_write_to_db(
	si_write_table_in=rlpw_MOE_qual, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_qual,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Create a dataset with an as-at date 5 years from birth event*/
proc sql;
	drop table sand.&si_pop_table_out._5yrs;
	create table sand.&si_pop_table_out._5yrs as 
		select 
			*, 
			intnx('DTYEAR', birth_date, 5, 'SAME') as birth_date_5yrs format = datetime20.
		from &si_sandpit_libname..&si_pop_table_out._char_ext;
quit;

/* Highest qualification 5 years from date of giving birth*/
%si_get_highest_qualifications( 
	si_table_in = &si_pop_table_out._5yrs
	,si_id_col = &si_id_col.
	,si_as_at_date = birth_date_5yrs
	,si_IDI_refresh_date = 
	,si_target_schema = &si_proj_schema.
	,si_out_table = rlpw_MOE_qual_5yrs
	);
%si_write_to_db(
	si_write_table_in=rlpw_MOE_qual_5yrs, 
	si_write_table_out=&si_sandpit_libname..rlpm_MOE_qual_5yrs,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/* Clean up intermediate datasets*/
proc datasets lib=sand;
	delete &si_pop_table_out._5yrs;
run;

proc datasets lib=work;
	delete rlpw_MOE_qual_5yrs	rlpw_MOE_qual;
run;

/*************************************ADDRESS NOTIFICATION*********************************************************/
%si_align_sialevents_to_periods(
	si_table_in=[IDI_Sandpit].[&si_proj_schema.].&si_pop_table_out._char_ext, /* Output from get_characteristics_ext */
	si_sial_table= (select 
	addr.snz_uid, 
	'ADDR' as department,'ADDR' as datamart,'ADDR' as subject_area,
	cast(ant_notification_date as datetime) as start_date, 
	cast(ant_replacement_date as datetime) as end_date,
	ant_meshblock_code as event_type
	from [IDI_Clean].[data].address_notification addr 
	where exists 
	(select 1 from IDI_Sandpit.[&si_proj_schema.].[si_mother_cohort_char_ext] cohort
	where cohort.snz_uid = addr.snz_uid	)) , /* Workaround for address as a SIAL table*/
	si_id_col = &si_id_col. , 
	si_as_at_date = &si_asat_date. ,
	si_amount_type = NA , 
	noofperiodsbefore = -5 , /* 5 years before birth is the risk factor, unlike other rollups*/
	noofperiodsafter = &si_num_periods_after. , 
	period_duration = &si_period_duration. , 
	si_out_table = ADDR_events_aln,
	period_aligned_to_calendar = False);

/* Create the roll-up variables */
%si_create_rollup_vars(
	si_table_in = &si_sandpit_libname..&si_pop_table_out._char_ext , 
	si_sial_table = ADDR_events_aln,	
	si_out_table =ADDR_events_rlp,		
	si_agg_cols= %str(department datamart subject_area ),	
	si_id_col = &si_id_col. ,
	si_amount_col = NA,
	si_as_at_date = &si_asat_date. ,
	cost = False, 
	duration = False, 
	count = False, 
	count_startdate = True, 
	dayssince = False,
	si_rollup_ouput_type = Wide
	);
%si_write_to_db(
	si_write_table_in=ADDR_events_rlpw, 
	si_write_table_out=&si_sandpit_libname..rlpm_ADDR_events,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/*************************************MATERNAL SMOKING*********************************************************/
proc sql;
	connect to odbc (dsn=&idi_version._archive_srvprd);

	/* Smoking during pregnancy*/
	create table _temp_antenatal_smoking as 
		select snz_uid 
			from connection to odbc(
				select 
					distinct cohort.snz_uid
						from 
							IDI_Sandpit.[&si_proj_schema.].[&si_pop_table_out._char_ext] cohort
						inner join IDI_Clean.moh_clean.pub_fund_hosp_discharges_event pfh 
							on (cohort.snz_uid = pfh.snz_uid 
							and pfh.moh_evt_evst_date between dateadd(dd, -1*cohort.gestation_in_days, cohort.&si_asat_date.)
							and cohort.&si_asat_date.)
						inner join IDI_Clean.moh_clean.pub_fund_hosp_discharges_diag diag  
							on (pfh.moh_evt_event_id_nbr=diag.moh_dia_event_id_nbr 
							and left(diag.moh_dia_clinical_code, 4) = 'Z720' )
							);

	/* Smoking for 2 years after childbirth*/
	create table _temp_postnatal_smoking as 
		select snz_uid 
			from connection to odbc(
				select 
					distinct cohort.snz_uid
						from 
							IDI_Sandpit.[&si_proj_schema.].[&si_pop_table_out._char_ext] cohort
						inner join IDI_Clean.moh_clean.pub_fund_hosp_discharges_event pfh 
							on (cohort.snz_uid = pfh.snz_uid 
							and pfh.moh_evt_evst_date between cohort.&si_asat_date. and dateadd(yyyy, 2, cohort.&si_asat_date.) )
						inner join IDI_Clean.moh_clean.pub_fund_hosp_discharges_diag diag  
							on (pfh.moh_evt_event_id_nbr=diag.moh_dia_event_id_nbr 
							and left(diag.moh_dia_clinical_code, 4) = 'Z720' )
							);
	disconnect from odbc;
quit;

/************************************MESHBLOCK(AS ON CHILDBIRTH DATE) DEPRIVATION INDEX**************************************/
/* and some flags for smoking */
proc sql;
	create table _temp_cohort as
		select 
			cohort.*,
		case 
			when ante.snz_uid is null then 0 
			else 1 
		end 
	as antenatal_smk_flg,
		case 
			when post.snz_uid is null then 0 
			else 1 
		end 
	as postnatal_smk_flg,
		depdata.dep_index as meshblock_dep_index
	from 
		&si_sandpit_libname..&si_pop_table_out._char_ext cohort
	left join _temp_antenatal_smoking ante on (cohort.snz_uid = ante.snz_uid)
	left join _temp_postnatal_smoking post on (cohort.snz_uid = post.snz_uid)
	left join (select meshblock.meshblock_code, meshblock.MB2013_code, dep.DepIndex2013 as dep_index
		from class.meshblock_concordance meshblock
			left join class.DepIndex2013 dep on (meshblock.MB2013_code = dep.Meshblock2013) ) depdata
				on cohort.ant_meshblock_code = depdata.meshblock_code;
quit;

%si_write_to_db(
	si_write_table_in=_temp_cohort, 
	si_write_table_out=&si_sandpit_libname..&si_pop_table_out._char_ext,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);

/***********************************LIVED IN SOCIAL HOUSING IN THE 2 YRS BEFORE BIRTH EVENT*************************************/
proc sql;
	connect to odbc (dsn=&idi_version._archive_srvprd);
	create table mothers_in_social_housing as 
		select snz_uid from 
			connection to odbc (
		select mothers.snz_uid
			from 
				IDI_Sandpit.[&si_proj_schema.].[&si_pop_table_out._char_ext] mothers
			inner join &idi_version..security.concordance concord on (mothers.snz_uid = concord.snz_uid)
				where 
					concord.snz_msd_uid is not null
					and exists (
				select 1 
					from 
						IDI_Sandpit.clean_read_HNZ.adhoc_clean_tenancy_h_snapshot sh
					where concord.snz_msd_uid = sh.snz_msd_uid 
						and hnz_ths_snapshot_date between dateadd(yyyy, -2, mothers.birth_date) and mothers.birth_date
						)
						);
	disconnect from odbc;
quit;

%si_write_to_db(
	si_write_table_in=mothers_in_social_housing, 
	si_write_table_out=&si_sandpit_libname..rlpm_social_housing,
	si_cluster_index_flag=True, 
	si_index_cols=%bquote(&si_id_col.)
	);
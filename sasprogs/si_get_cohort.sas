/*********************************************************************************************************
TITLE: si_get_cohort.sas

DESCRIPTION: Creates 2 distinct population datasets, one for mothers who gave birth during a specified
period, and one for the children from all those birth events in that period. 
Also creates a dataset of all mother-child pair birth events in the specified time period.
These datasets are written into the IDI_Sandpit database

INPUT: 
dia_clean.births
data.personal_detail
data.snz_res_pop

OUTPUT:
IDI_Sandpit.<project_schema>.si_mother_birth_events
IDI_Sandpit.<project_schema>.si_mother_cohort
IDI_Sandpit.<project_schema>.si_child_cohort

AUTHOR: Vinay Benny

DEPENDENCIES:
si_control_general must be run

NOTES: 
Only the first birth is considered in this time period

HISTORY:
11 Aug 2017 EW QA and tidy up
13 Jul 2017 VB v1 

*********************************************************************************************************/



/* List of all mother-child birth pairs between the listed time period where at least one of the parents is identfied as female.
In case both parents are listed as female, we pick parent 1 as this is the column that usually lists mothers.
*/
proc sql;
	connect to odbc (dsn=&idi_version._archive_srvprd);
	create table _temp_births as 
		select * 
			from connection to odbc(
				select 
					bir.snz_uid as child_snz_uid,
					cast(datefromparts(dia_bir_birth_year_nbr , dia_bir_birth_month_nbr, 15) as datetime) as date_of_childbirth,
					bir.parent1_snz_uid,
					per1.snz_sex_code as parent1_sex_code,
					bir.parent2_snz_uid,
					per2.snz_sex_code as parent2_sex_code,
					bir.dia_bir_still_birth_code,
					dia_bir_birth_gestation_nbr as gestation_in_weeks,
					dia_bir_birth_weight_nbr as birth_weight,
				case 
					when per1.snz_sex_code = 2 then parent1_snz_uid 
					when per2.snz_sex_code = 2 then parent2_snz_uid 
				end 
			as mother_snz_uid
				from 
					&idi_version..dia_clean.births bir
				left join &idi_version..data.personal_detail per1 on (per1.snz_uid = bir.parent1_snz_uid)
				left join &idi_version..data.personal_detail per2 on (per2.snz_uid = bir.parent2_snz_uid)
					where
						case 
							when per1.snz_sex_code = 2 then parent1_snz_uid 
							when per2.snz_sex_code = 2 then parent2_snz_uid 
							else NULL 
						end 
						is not null
						and	datefromparts(dia_bir_birth_year_nbr , dia_bir_birth_month_nbr, 15) between cast(&start_cutoff_date_quote as date) 
						and cast(&end_cutoff_date_quote as date)
						);
quit;

/* Get ERP linkage indicators for all mother-child pairs as on the date of childbirth*/
proc sql;
	create table si_mother_birth_events as 
		select 
			mothers.mother_snz_uid as snz_uid
			, mothers.date_of_childbirth
			, mothers.dia_bir_still_birth_code
			, mothers.parent1_snz_uid
			, mothers.parent2_snz_uid
			, mothers.child_snz_uid
			, mothers.gestation_in_weeks
			, mothers.birth_weight
			, 
		case 
			when pop.snz_uid is null then 0 
			else 1 
		end 
	as mother_linked_flg
		, 
	case 
		when childpop.snz_uid is null then 0 
		else 1 
	end 
as child_linked_flg 
	from _temp_births mothers
		left join data.snz_res_pop pop 
			on (mothers.mother_snz_uid = pop.snz_uid 
			and mothers.date_of_childbirth >=  dhms( intnx('YEAR',input(pop.srp_ref_date,yymmdd10.), -1, 'SAME'), 0, 0, 0) )
			and mothers.date_of_childbirth < dhms(input(pop.srp_ref_date,yymmdd10.), 0, 0, 0)
		left join data.snz_res_pop childpop 
			on (mothers.child_snz_uid = childpop.snz_uid
			and mothers.date_of_childbirth >=  dhms( intnx('YEAR',input(childpop.srp_ref_date,yymmdd10.), -1, 'SAME'), 0, 0, 0) )
			and mothers.date_of_childbirth < dhms(input(childpop.srp_ref_date,yymmdd10.), 0, 0, 0);
quit;

/* Create a few summary counts to check the dataset.*/
proc sql;
	/* Total number of mothers giving birth*/
	select year(datepart(date_of_childbirth)) as year, count(distinct snz_uid) as nbr_of_mothers from si_mother_birth_events 
		group by calculated year order by year;

	/* Total number of mothers*/
	select count(distinct snz_uid) as total_mothers from si_mother_birth_events;

	/* Total number of children born for each calendar year*/
	select year(datepart(date_of_childbirth)) as year, count(*) as nbr_of_children from si_mother_birth_events
		group by calculated year order by year;

	/* Total number of children */
	select count(*) as total_children from si_mother_birth_events;

	/* ERP linked mothers by calendar year*/
	select year(datepart(date_of_childbirth)) as year, count(distinct snz_uid) as ERPlinkedmothers from si_mother_birth_events 
		where mother_linked_flg = 1
			group by calculated year order by year;

	/* Total births with ERP linked mothers by calendar year*/
	select count(distinct snz_uid) as total_ERPlinkedmothers from si_mother_birth_events where  mother_linked_flg = 1;

	/* ERP linked children by calendar year*/
	select year(datepart(date_of_childbirth)) as year, count(distinct child_snz_uid) as ERPlinkedchildren from si_mother_birth_events 
		where child_linked_flg = 1
			group by calculated year order by year;

	/* Total count ERP linked children by calendar year */
	select count(distinct child_snz_uid) as total_ERPlinkedchildren from si_mother_birth_events where child_linked_flg = 1;
quit;

/* We write this dataset into the database for easier processing*/
%si_write_to_db(si_write_table_in=si_mother_birth_events,
	si_write_table_out=&si_sandpit_libname..si_mother_birth_events
	,si_cluster_index_flag=True,si_index_cols=%bquote(snz_uid, date_of_childbirth)
	);

/* Creating a dataset to handle multiple birth events for the same mother (a birth event can have multiple children)
This creates a dataset at the mother snz_uid level, with multiple date columns for each birth event. We leave provision 
for at least 5 birth events in the specified period.
*/
proc sql;
	connect to odbc (dsn=&idi_version._archive_srvprd);
	create table si_mother_cohort as
		select * 
			from connection to odbc(
				select 
					snz_uid
					,[bir1] as birth_date
					,[bir2] as birth2_date
					,[bir3] as birth3_date
					,[bir4] as birth4_date
					,[bir5] as birth5_date
					,mother_linked_flg
				from 
					(
				select 
					births.snz_uid
					, 'bir' + cast(row_number() over (partition by births.snz_uid order by births.date_of_childbirth asc) as varchar(1) ) as birthnum
					, births.mother_linked_flg
					, births.date_of_childbirth
				from 
					(
				select 
					snz_uid,
					mother_linked_flg,
					date_of_childbirth
				from 
					[IDI_Sandpit].[&si_proj_schema.].[si_mother_birth_events]
				group by
					snz_uid,
					mother_linked_flg,
					date_of_childbirth
					)births
					) mainquery
					pivot ( max(mainquery.date_of_childbirth) for birthnum in ([bir1], [bir2], [bir3], [bir4], [bir5]) ) as pvt

					);
quit;

/* Creating a dataset for the children from the birth events.*/
proc sql;
	connect to odbc (dsn=&idi_version._archive_srvprd);
	create table si_child_cohort as
		select * 
			from connection to odbc(
				select 
					child_snz_uid as snz_uid,
					date_of_childbirth as birth_date,
					child_linked_flg
				from 
					[IDI_Sandpit].[&si_proj_schema.].[si_mother_birth_events]
				group by
					child_snz_uid,
					date_of_childbirth,
					child_linked_flg
					);
quit;

/* Push the mothers cohort to the database  */
%si_write_to_db(si_write_table_in=si_mother_cohort,
	si_write_table_out=&si_sandpit_libname..si_mother_cohort
	,si_cluster_index_flag=True,si_index_cols=%bquote(&si_id_col., birth_date)
	);

/* Push the mothers cohort to the database  */
%si_write_to_db(si_write_table_in=si_child_cohort,
	si_write_table_out=&si_sandpit_libname..si_child_cohort
	,si_cluster_index_flag=True,si_index_cols=%bquote(&si_id_col., birth_date)
	);
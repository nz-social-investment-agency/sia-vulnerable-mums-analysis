/*********************************************************************************************************
DESCRIPTION: Add custom characteristics for the mothers and the children

INPUT:
si_mother_cohort_char = stock standard characteristics for the mother from the data foundation
si_child_cohort_char = stock standard characteristics for the child from the data foundation

OUTPUT:
work.si_mother_cohort_char_ext = extra characteristics for the mother
work.si_child_cohort_char_ext = extra characteristics for the child

AUTHOR: 
V Benny

DEPENDENCIES:
Social Investment Analytical layer must be installed and available for use
Social investment Data Foundation macros must be available for use.
Both of these are available as Git submodules under the lib folder

NOTES:
The data foundation has a characteristics extension macro but this cannot be used here because
we have custom characteristics that only apply to the mother and custom characteristics that
only apply to the child. The data foundation macro is currently structured to accept a single
input table and a single output table. Modifying it would require 2 input tables, two output 
tables, two as at dates and the sandpit name
   

HISTORY: 
10 Aug 2017 EW V1 based on work by VB

*********************************************************************************************************/


/* Add ad-hoc variables to both cohorts */
proc sql;
		create table si_mother_cohort_char_ext as
			select cohort.*,
			case when cohort.as_at_age <=19 then 1 else 0 end as teen_preg_flg, /* Teen pregnancy indicator*/
			case when cohort.as_at_age between 45 and 60 then 1 else 0 end as late_preg_flg, /* Late pregnancy indicator*/
			birth.gestation,
			floor(birth.gestation)*7 + 10*( birth.gestation - floor(birth.gestation) ) as gestation_in_days
		from si_mother_cohort_char cohort
			inner join 
			/*Get maximum gestation in case of twins/triplets */
				(select snz_uid, date_of_childbirth, max(gestation_in_weeks) as gestation 
				from &si_sandpit_libname..si_mother_birth_events birth
				group by snz_uid, date_of_childbirth) birth
				on (cohort.snz_uid = birth.snz_uid and cohort.&si_asat_date. = date_of_childbirth );
quit;

proc sql;
		create table si_child_cohort_char_ext as
			select cohort.*,
			birth.gestation,
			floor(birth.gestation)*7 + 10*( birth.gestation - floor(birth.gestation) ) as gestation_in_days
		from si_child_cohort_char cohort
			inner join 
			/*Get maximum gestation in case of twins/triplets */
				(select child_snz_uid, date_of_childbirth, max(gestation_in_weeks) as gestation 
				from &si_sandpit_libname..si_mother_birth_events birth
				group by child_snz_uid, date_of_childbirth) birth
				on (cohort.snz_uid = birth.child_snz_uid and cohort.&si_asat_date. = birth.date_of_childbirth );
quit;
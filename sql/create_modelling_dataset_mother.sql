/*********************************************************************************************************
DESCRIPTION: Combine the mothers cohort dataset and roll-up tables to create a single table for analysis

INPUT:
[{schema_name}].[si_mother_cohort_char_ext]
Roll-up tables rlpm_<agency_specific>_events

OUTPUT:
[{schema_name}].[si_mother_cohort_modelling] 


AUTHOR: V Benny

DEPENDENCIES:
NA

NOTES:
See SIAL data dictionary for business rules applied

Expect warning about null values being eliminated by an aggregate 

HISTORY: 
14 Aug 2017 EW Added drop table to prevent errors
13 Jul 2017	VB Version 1
*********************************************************************************************************/
if object_id ('[{schema_name}].[si_mother_cohort_modelling]', 'U') is not null
  drop table [{schema_name}].[si_mother_cohort_modelling];

select 
	mothers.[snz_uid]
	,mothers.[birth_date] as birth_date
	,mothers.[mother_linked_flg]
	,mothers.[as_at_age]
	,mothers.[snz_sex_code] 
	,mothers.[prioritised_eth]
	,mothers.snz_ethnicity_grp1_nbr
	,mothers.snz_ethnicity_grp2_nbr
	,mothers.snz_ethnicity_grp3_nbr
	,mothers.snz_ethnicity_grp4_nbr
	,mothers.snz_ethnicity_grp5_nbr
	,mothers.snz_ethnicity_grp6_nbr
	,mothers.[ant_region_code]
	,mothers.[ant_ta_code]
	,mothers.[ant_meshblock_code]
	,mothers.[uid_miss_ind_cnt]
	,mothers.[gestation]
	,mothers.[gestation_in_days]
	,mothers.[teen_preg_flg]
	,mothers.[late_preg_flg]
	,mothers.[antenatal_smk_flg]
	,mothers.[postnatal_smk_flg]
	,mothers.[meshblock_dep_index]
	,coalesce(addr.p_addr_addr_addr_ct2,0) as p_addr_change_ct
	,case when coalesce(mha.p_moh_nmds_mha_dep_ct2,0) + coalesce(mha.p_moh_pharm_mha_dep_ct2,0) + 
	  coalesce(mha.p_moh_lab_mha_dep_ct2 ,0) > 0 then 1 else 0 end as p_mha_dep_flg
	,case when coalesce(mha.f_moh_nmds_mha_dep_ct2,0) + coalesce(mha.f_moh_pharm_mha_dep_ct2,0) + 
	  coalesce(mha.f_moh_lab_mha_dep_ct2 ,0) > 0 then 1 else 0 end as f_mha_dep_flg
	,case when coalesce(mha.p_moh_nmds_mha_sub_ct2,0) + coalesce(mha.p_moh_pharm_mha_sub_ct2,0) + 
	  coalesce(mha.p_moh_primhd_mha_sub_ct2,0) + coalesce(mha.p_msd_icp_mha_sub_ct2,0) > 0 then 1
	    else 0 end as p_subabuse_flg
	,case when coalesce(mha.f_moh_nmds_mha_sub_ct2,0) + coalesce(mha.f_moh_pharm_mha_sub_ct2,0) + 
	  coalesce(mha.f_moh_primhd_mha_sub_ct2,0) + coalesce(mha.f_msd_icp_mha_sub_ct2,0) > 0 then 1
	    else 0 end as f_subabuse_flg
	,case when coalesce(mha.p_moh_nmds_mha_oth_ct2,0) + coalesce(mha.p_moh_pharm_mha_oth_ct2,0) + 
	  coalesce(mha.p_moh_primhd_mha_oth_ct2,0) + coalesce(mha.p_msd_icp_mha_oth_ct2,0) + 
	    coalesce(mha.p_moh_lab_mha_dep_ct2,0) > 0 then 1 else 0 end as p_othermh_flg
	,qual.nqflevel as mother_nqflevel
	,case when coalesce(ben.p_ird_ins_ben_cst,0) > 0 then 1 else 0 end  as p_t1_ben_flg
	,case when sh.snz_uid is not null then 1 else 0 end as p_sh_flg
	,case when (single.parent1_snz_uid is null or single.parent2_snz_uid is null) then 1 else 0 end as single_parent_flg
	,coalesce(moeint.[p_moe_stu_int_dur],0) as p_moe_intervention_dur
	,coalesce(selfharm.[p_mix_hrm_slf_ct2],0) as p_selfharm_event_ct
	,coalesce(enr.p_moe_stu_enr_dur, 0) as p_school_enr_days	
	,case when chronic.p_moh_tkr_ccc_cnt is not null then 1 else 0 end as p_chronic_diag_flg
	,case when cancer.p_moh_can_reg_cnt is not null then 1 else 0 end as p_cancer_diag_flg
	,mothers.as_at_age - datediff(yyyy, firstbirths.date_of_first_childbirth, mothers.birth_date) as age_at_first_birth
	,children.ct_of_children_before
	,children.ct_of_children_after
	,case when (coalesce(cor.p_cor_mmp_sar_rc_cst ,0) + coalesce(cor.p_cor_mmp_sar_ps_cst ,0)) > 0 then 1 else 0 end as p_cor_prison_remand_flg
	,case when (coalesce(cor.p_cor_mmp_sar_cs_cst ,0) + coalesce(cor.p_cor_mmp_sar_rp_cst ,0)) > 0 then 1 else 0 end as p_cor_comm_release_flg
	,coalesce(gms.[p_moh_gms_gms_ct2] , 0) as p_gms_ct

	/* past cost variables*/

	,coalesce(ben.p_ird_ins_ben_cst,0) / 2.0 as p_avg_yearly_t1ben_inc 
	,coalesce(t2.p_msd_ben_t2_cst, 0) / 2.0 as p_avg_yearly_t2ben_inc
	,coalesce(t3.p_msd_ben_t3_cst, 0) / 2.0 as p_avg_yearly_t3ben_inc
	,( coalesce(ben.p_ird_emp_was_cst,0) + 
	coalesce(ben.p_ird_emp_c00_cst,0) + coalesce(ben.p_ird_emp_p00_cst,0) + coalesce(ben.p_ird_emp_s00_cst,0) + 
	coalesce(ben.p_ird_emp_c01_cst,0) + coalesce(ben.p_ird_emp_p01_cst,0) + coalesce(ben.p_ird_emp_s01_cst,0) +
	coalesce(ben.p_ird_emp_c02_cst,0) + coalesce(ben.p_ird_emp_p02_cst,0) + coalesce(ben.p_ird_emp_s02_cst,0) + 
	coalesce(ben.p_ird_emp_ppl_cst,0) ) / 2.0 as p_avg_yearly_emp_inc
	,(coalesce(cor.p_cor_mmp_sar_cs_cst ,0) + coalesce(cor.p_cor_mmp_sar_rc_cst ,0) + coalesce(cor.p_cor_mmp_sar_ps_cst ,0) 
	  + coalesce(cor.p_cor_mmp_sar_rp_cst ,0)) / 2.0 as p_avg_yearly_cor_cost
	,coalesce(lab.[p_moh_lab_lab_cst] , 0) / 2.0 as p_avg_yearly_lab_cost
	,coalesce(nnp.[p_moh_nnp_nnp_cst] , 0) / 2.0 as p_avg_yearly_nnp_cost
	,coalesce(pfh.[p_moh_pfh_pfh_cst] , 0) / 2.0 as p_avg_yearly_pfhd_cost
	,coalesce(pha.[p_moh_pha_pha_cst] , 0) / 2.0 as p_avg_yearly_pharm_cost
	,coalesce(prm.[p_moh_prm_prm_cst] , 0) / 2.0 as p_avg_yearly_primhd_cost
	,coalesce(ter.[p_moe_ter_enr_cst] , 0) / 2.0 as p_avg_yearly_moetertiary_cost

	/* future variables*/

	,case when coalesce( [f_mix_mor_mor_dffe], [p_mix_mor_mor_dsle] ) is null then 0 else 1 end as mortality_evt_flg
	,coalesce([f_mix_hrm_slf_ct2],0) as f_selfharm_event_ct
	,qual5yrs.nqflevel as f_nqf_level_5yrs
	,case when chronic.f_moh_tkr_ccc_cnt is not null then 1 else 0 end as f_chronic_diag_flg
	,case when cancer.f_moh_can_reg_cnt is not null then 1 else 0 end as f_cancer_diag_flg	
	,case when (coalesce(cor.f_cor_mmp_sar_rc_cst ,0) + coalesce(cor.f_cor_mmp_sar_ps_cst ,0)) > 0 then 1
	  else 0 end as f_cor_prison_remand_flg
	,case when (coalesce(cor.f_cor_mmp_sar_cs_cst ,0) + coalesce(cor.f_cor_mmp_sar_rp_cst ,0)) > 0 then 1
	  else 0 end as f_cor_comm_release_flg
	,coalesce(gms.[f_moh_gms_gms_ct2] , 0) as f_gms_ct

	/* future cost variables*/

	,coalesce(ben.f_ird_ins_ben_cst,0) / 5.0 as f_avg_yearly_t1ben_inc 
	,coalesce(t2.f_msd_ben_t2_cst, 0) / 5.0 as f_avg_yearly_t2ben_inc
	,coalesce(t3.f_msd_ben_t3_cst, 0) / 5.0 as f_avg_yearly_t3ben_inc
	,( coalesce(ben.f_ird_emp_was_cst,0) + 
	coalesce(ben.f_ird_emp_c00_cst,0) + coalesce(ben.f_ird_emp_p00_cst,0) + coalesce(ben.f_ird_emp_s00_cst,0) + 
	coalesce(ben.f_ird_emp_c01_cst,0) + coalesce(ben.f_ird_emp_p01_cst,0) + coalesce(ben.f_ird_emp_s01_cst,0) +
	coalesce(ben.f_ird_emp_c02_cst,0) + coalesce(ben.f_ird_emp_p02_cst,0) + coalesce(ben.f_ird_emp_s02_cst,0) + 
	coalesce(ben.f_ird_emp_ppl_cst,0) ) / 5.0 as f_avg_yearly_emp_inc
	,(coalesce(cor.f_cor_mmp_sar_cs_cst ,0) + coalesce(cor.f_cor_mmp_sar_rc_cst ,0) + coalesce(cor.f_cor_mmp_sar_ps_cst ,0) 
	  + coalesce(cor.f_cor_mmp_sar_rp_cst ,0)) / 5.0 as f_avg_yearly_cor_cost
	,coalesce(lab.[f_moh_lab_lab_cst] , 0) / 5.0 as f_avg_yearly_lab_cost
	,coalesce(nnp.[f_moh_nnp_nnp_cst] , 0) / 5.0 as f_avg_yearly_nnp_cost
	,coalesce(pfh.[f_moh_pfh_pfh_cst] , 0) / 5.0 as f_avg_yearly_pfhd_cost
	,coalesce(pha.[f_moh_pha_pha_cst] , 0) / 5.0 as f_avg_yearly_pharm_cost
	,coalesce(prm.[f_moh_prm_prm_cst] , 0) / 5.0 as f_avg_yearly_primhd_cost
	,coalesce(ter.[f_moe_ter_enr_cst] , 0) / 5.0 as f_avg_yearly_moetertiary_cost
into [{schema_name}].[si_mother_cohort_modelling] 
from 
[{schema_name}].[si_mother_cohort_char_ext] mothers
left join [{schema_name}].[rlpm_ADDR_events] addr on (mothers.snz_uid = addr.snz_uid)
left join [{schema_name}].[rlpm_moh_diagnosis] mha on (mothers.snz_uid = mha.snz_uid)
left join [{schema_name}].[rlpm_MOE_qual] qual on (mothers.snz_uid = qual.snz_uid)
left join [{schema_name}].[rlpm_IRD_income_events] ben on (mothers.snz_uid = ben.snz_uid)
left join [{schema_name}].[rlpm_social_housing] sh on (mothers.snz_uid = sh.snz_uid)
inner join (select 
				snz_uid, 
				date_of_childbirth, 
				max(parent1_snz_uid) as parent1_snz_uid, 
				max(parent2_snz_uid) as parent2_snz_uid 
			from [{schema_name}].[si_mother_birth_events]
			group by 
				snz_uid, 
				date_of_childbirth) single on (mothers.snz_uid = single.snz_uid and mothers.birth_date = single.date_of_childbirth)
left join [{schema_name}].[rlpm_COR_sentence_events] cor on (mothers.snz_uid = cor.snz_uid)
left join [{schema_name}].[rlpm_MSD_T2_events] t2 on (mothers.snz_uid = t2.snz_uid)
left join [{schema_name}].[rlpm_MSD_T3_events] t3 on (mothers.snz_uid = t3.snz_uid)
left join [{schema_name}].[rlpm_MOE_intervention_events] moeint on (mothers.snz_uid = moeint.snz_uid)
left join [{schema_name}].[rlpm_MOH_gms_events] gms on (mothers.snz_uid = gms.snz_uid)
left join [{schema_name}].[rlpm_MOH_labtest_events] lab on (mothers.snz_uid = lab.snz_uid)
left join [{schema_name}].[rlpm_MOH_nnpac_events] nnp on (mothers.snz_uid = nnp.snz_uid)
left join [{schema_name}].[rlpm_MOH_pfhd_events] pfh on (mothers.snz_uid = pfh.snz_uid)
left join [{schema_name}].[rlpm_MOH_pharm_events] pha on (mothers.snz_uid = pha.snz_uid)
left join [{schema_name}].[rlpm_MOH_primhd_events] prm on (mothers.snz_uid = prm.snz_uid)
left join [{schema_name}].[rlpm_MIX_mortality_events] death on (mothers.snz_uid = death.snz_uid)
left join [{schema_name}].[rlpm_MIX_selfharm_events] selfharm on (mothers.snz_uid = selfharm.snz_uid)
left join [{schema_name}].[rlpm_MOE_qual_5yrs] qual5yrs on (mothers.snz_uid = qual5yrs.snz_uid)
left join [{schema_name}].[rlpm_MOE_school_events] enr on (mothers.snz_uid = enr.snz_uid)
left join [{schema_name}].[rlpm_MOE_tertiary_events] ter on (mothers.snz_uid = ter.snz_uid)
left join [{schema_name}].[rlpm_MOH_chronic_events] chronic on (mothers.snz_uid = chronic.snz_uid)
left join [{schema_name}].[rlpm_MOH_cancer_events] cancer on (mothers.snz_uid = cancer.snz_uid)
inner join (
	select parent_snz_uid, min(birthdate) as date_of_first_childbirth
	from
		(
			select parent1_snz_uid as parent_snz_uid, datefromparts(dia_bir_birth_year_nbr, dia_bir_birth_month_nbr, 15) as birthdate 
			  from IDI_Clean_20170420.dia_clean.births
			union all
			select parent2_snz_uid as parent_snz_uid, datefromparts(dia_bir_birth_year_nbr, dia_bir_birth_month_nbr, 15) as birthdate
			  from IDI_Clean_20170420.dia_clean.births
		)x
	group by parent_snz_uid
	) firstbirths on (mothers.snz_uid = firstbirths.parent_snz_uid)
inner join (
		select  snz_uid, 
			count(*) as ct_of_children, 
			sum(case when b.birthdate < a.birth_date then 1 else 0 end) as ct_of_children_before, 
			sum(case when b.birthdate <= a.birth_date then 1 else 0 end) as ct_of_children_after
		from [{schema_name}].[si_mother_cohort_char_ext] a
		inner join (
			select parent1_snz_uid as parent_snz_uid, datefromparts(dia_bir_birth_year_nbr, dia_bir_birth_month_nbr, 15) as birthdate 
			  from IDI_Clean_20170420.dia_clean.births
			union all
			select parent2_snz_uid as parent_snz_uid, datefromparts(dia_bir_birth_year_nbr, dia_bir_birth_month_nbr, 15) as birthdate
			  from IDI_Clean_20170420.dia_clean.births
			)b on (a.snz_uid = b.parent_snz_uid and b.birthdate <= a.birth_date )
		group by snz_uid
		) children on (mothers.snz_uid = children.snz_uid);
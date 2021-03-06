/*********************************************************************************************************
DESCRIPTION: Combine the childs cohort dataset and roll-up tables to create a single table for analysis

INPUT:
[{schema_name}].[si_child_cohort_char_ext]
Roll-up tables rlpc_<agency_specific>_events

OUTPUT:
[DL-MAA2016-15].[si_child_cohort_modelling] 

AUTHOR: WJ Lee

DEPENDENCIES:
NA

NOTES:
See SIAL data dictionary for business rules applied

HISTORY: 
15 Aug 2017 VB Changed variable names to make it consistent with mothers dataset
14 Aug 2017 EW Added drop table to prevent errors and tidied up code
13 Jul 2017	WL Version 1
*********************************************************************************************************/
if object_id ('[{schema_name}].[si_child_cohort_modelling]', 'U') is not null
  drop table [{schema_name}].[si_child_cohort_modelling];

select 
	a.[snz_uid]
	,mum_id
	,[snz_sex_code]
	,[prioritised_eth]
	,[iwi1_desc]
	,[uid_miss_ind_cnt]
	,child_linked_flg
	,coalesce([contact_record],0) as contact_record_cyf
	,coalesce([police_fv],0) as police_fv
	,coalesce([pah_wgt],0)as pah_flg
	,case when [pah] is null then '00 none' else [pah] end as pah_description
	,coalesce([disability_needs_flag],0)as disability_flg
	,coalesce([f_mix_mor_mor_cnt],0) as mortality_flg
	,case when coalesce([f_moh_can_reg_cnt],0) > 0 then 1 else 0 end as cancer_flg
	,case when coalesce([f_moh_tkr_ccc_cnt],0) > 0 then 1 else 0 end as chronic_flg
	,coalesce([f_msd_cyf_abe_neg_cnt],0) as neglect_abuse_ct
	,coalesce([f_msd_cyf_abe_ntf_cnt],0) as not_found_abuse_ct
	,coalesce([f_msd_cyf_abe_emo_cnt],0) as emotional_abuse_ct
	,coalesce([f_msd_cyf_abe_brd_cnt],0) as behaviour_abuse_ct
	,coalesce([f_msd_cyf_abe_phy_cnt],0) as physical_abuse_ct
	,coalesce([f_msd_cyf_abe_sex_cnt],0) as sexual_abuse_ct
	/*,coalesce([f_moh_gms_gms_cnt],0) as gms_ct*/
	,coalesce([f_moh_gms_gms_cst],0) as gms_cost
	,coalesce([f_moh_gms_gms_dffe],0) as gms_dffe
	,coalesce([f_moh_gms_gms_ct2],0) as gms_ct2
	,coalesce([f1_moh_gms_gms_cnt],0) as [f1_moh_gms_gms_cnt]
	,coalesce([f1_moh_gms_gms_cst],0) as [f1_moh_gms_gms_cst]
	,coalesce([f1_moh_gms_gms_ct2],0) as [f1_moh_gms_gms_ct2]
	,coalesce([moh_nir_imm_stat_6_month_ind],0) as imm_6mth_complete_flg
	,coalesce([moh_nir_imm_stat_8_month_ind],0) as imm_8mth_complete_flg
	,coalesce([moh_nir_imm_stat_12_month_ind],0) as imm_12mth_complete_flg
	,coalesce([moh_nir_imm_stat_18_month_ind],0) as imm_18mth_complete_flg
	,coalesce([moh_nir_imm_stat_24_month_ind],0) as imm_24mth_complete_flg
	,coalesce([moh_nir_imm_stat_60_month_ind],0) as imm_60mth_complete_flg
	,coalesce([ece_any_flag],0) as ece_any_flg
	,coalesce([ece_kohanga_flag],0) as ece_kohanga_flg
	,[b4sc_outcome]
	,[b4sc_sdqp_outcome]
	,[b4sc_sdqt_outcome]
	,[b4sc_vision_outcome]
	,[b4sc_hearing_outcome]
	,[b4sc_growth_outcome]
	,[b4sc_dental_outcome]
	,[b4sc_peds_outcome]
	,coalesce([f_moh_pha_pha_cnt],0) as [f_moh_pha_pha_cnt]
	,coalesce([f_moh_pha_pha_cst],0) as [f_moh_pha_pha_cst]
	,coalesce([f_moh_lab_lab_cst],0) as [f_moh_lab_lab_cst]
	,coalesce([f_moh_nnp_nnp_cnt],0)as [f_moh_nnp_nnp_cnt]
	,coalesce([f_moh_nnp_nnp_cst],0)as [f_moh_nnp_nnp_cst]
	,coalesce([f_moh_pfh_pfh_cst],0)as [f_moh_pfh_pfh_cst]
	,siblings_ct
	,mother_teen_preg_flg
	,mother_late_preg_flg
	,mother_single_parent_flg
	,mother_nqlf_level
	,mother_t1ben_flg
	,mother_socialhousing_flg
	,mother_mesh_dep_index
	,mother_avg_income
	,mother_antenatal_smoking_flg
	,mother_postnatal_smoking_flg
	,mother_p_subabuse_flg
	,mother_f_subabuse_flg
	,mother_p_depression_flg
	,mother_f_depression_flg
	,mother_address_change_ct
	,case when u.gestation < 37 then 1 else 0 end as premature_birth_flg
	,coalesce(a.ant_region_code,region_m) as region
into [{schema_name}].[si_child_cohort_modelling] 
from [{schema_name}].[si_child_cohort_char_ext] a
	left join [DL-MAA2016-15].[rlpc_cr_events] b on a.snz_uid=b.snz_uid
	left join [DL-MAA2016-15].[rlpc_pah_events] c on a.snz_uid=c.snz_uid
	left join[DL-MAA2016-15].[rlpc_disability_events] e	on a.snz_uid=e.snz_uid
	left join [DL-MAA2016-15].[rlpc_MIX_mortality_events] f	on a.snz_uid=f.snz_uid
	left join [DL-MAA2016-15].[rlpc_MOH_cancer_events] g on a.snz_uid=g.snz_uid
	left join [DL-MAA2016-15].[rlpc_MOH_chronic_events] h on a.snz_uid=h.snz_uid
	left join [DL-MAA2016-15].[rlpc_CYF_abuse_events] i	on a.snz_uid=i.snz_uid
	left join [DL-MAA2016-15].[rlpc_MOH_gms_events] j on a.snz_uid=j.snz_uid
	left join [DL-MAA2016-15].[rlpc_SIAL_MOH_nir_events] k on a.snz_uid=k.snz_uid
	left join[DL-MAA2016-15].[rlpc_ece_any_events] l on a.snz_uid=l.snz_uid
	left join[DL-MAA2016-15].[rlpc_ece_koh_events] m on a.snz_uid=m.snz_uid
	left join[DL-MAA2016-15].[rlpc_b4sc_events] n on a.snz_uid=n.snz_uid
	left join[DL-MAA2016-15].[rlpc_MOH_primhd_events] o on a.snz_uid=o.snz_uid
	left join[DL-MAA2016-15].[rlpc_MOH_pharm_events] p on a.snz_uid=p.snz_uid
	left join[DL-MAA2016-15].[rlpc_MOH_pfhd_events] q on a.snz_uid=q.snz_uid
	left join[DL-MAA2016-15].[rlpc_MOH_labtest_events] r on a.snz_uid=r.snz_uid
	left join[DL-MAA2016-15].[rlpc_MOH_nnpac_events] s on a.snz_uid=s.snz_uid
	left join (select snz_uid as mother_snz_uid, child_snz_uid from [{schema_name}].[si_mother_birth_events]) t
		on a.snz_uid=t.child_snz_uid
	left join (select 
					snz_uid as mum_id
					,teen_preg_flg as mother_teen_preg_flg 
					,late_preg_flg as mother_late_preg_flg
					,p_subabuse_flg as mother_p_subabuse_flg
					,f_subabuse_flg as mother_f_subabuse_flg
					,single_parent_flg as mother_single_parent_flg
					,mother_nqflevel as mother_nqlf_level
					,p_t1_ben_flg as mother_t1ben_flg
					,p_sh_flg as mother_socialhousing_flg
					,meshblock_dep_index as mother_mesh_dep_index
					,P_avg_yearly_emp_inc as mother_avg_income
					,antenatal_smk_flg as mother_antenatal_smoking_flg
					,[postnatal_smk_flg] as mother_postnatal_smoking_flg
					,p_mha_dep_flg as mother_p_depression_flg
					,f_mha_dep_flg as mother_f_depression_flg
					,p_addr_change_ct as mother_address_change_ct
					,ant_region_code as region_m
					,gestation
					,[ct_of_children_after] -1 as siblings_ct
			from [{schema_name}].[si_mother_cohort_modelling]) u 
		on t.mother_snz_uid=u.mum_id;
# ================================================================================================ #
# Description: Code for reading the at-risk mums dataset in from the database, and adding a few
# transformed variables that may be of interest.
#
# Input: 
# <schema>.[si_mother_cohort_modelling] = one dataset with all the mother variables
#
# Output: 
# mothers = dataframe with variables used to analyse the mothers that has some tidy up done
# catcols_mum = names of all the categorical variables in mothers
# intcols_mum = names of all the integer variables in mothers
# numcols_mum = names of all the numerical variables in mothers
#
# Author: V Benny
#
# Dependencies:
# SIAtoolbox = to read in the table from the database
#
# Notes:
# NA
#
# History (reverse order): 
# 17 Aug 2017 EW Test and tidy up
# 11 Aug 2017 VB v1
# ================================================================================================ #


################################ Load datasets for analysis into memory ################################
paste0("select * from ", "[DL-MAA2016-15].[si_mother_cohort_modelling]")
# Read in SQL table and create the dataset for analysis
dataset <- SIAtoolbox::read_sql_table(paste0("select * from ", mother_modelling_tab), connstr, string = TRUE) %>%
  mutate(snz_uid = factor(snz_uid),
         prioritised_eth = factor(prioritised_eth),
         ant_region_code = factor(ant_region_code),
         ant_ta_code = factor(ant_ta_code),
         ant_meshblock_code = factor(ant_meshblock_code),
         single_parent_flg = as.integer(single_parent_flg),
         age_at_first_birth = as.integer(age_at_first_birth),
         ct_of_children_before = as.integer(ct_of_children_before),
         ct_of_children_after = as.integer(ct_of_children_after),
         # Pregnancy
         gestation = gestation_in_days / 7.0,  # Derive gestation in weeks
         premature_birth_flg = as.integer(ifelse(gestation < 37, 1, 0)),
         teen_preg_flg = as.integer(teen_preg_flg),
         late_preg_flg = as.integer(late_preg_flg),
         antenatal_smk_flg = as.integer(antenatal_smk_flg),
         postnatal_smk_flg = as.integer(postnatal_smk_flg),
         # Deprivation and mobility
         meshblock_dep_index = as.integer(meshblock_dep_index),
         p_addr_change_ct = as.integer(p_addr_change_ct),
         f_gms_ct = as.integer(f_gms_ct),
         p_gms_ct = as.integer(p_gms_ct),
         # Psychological health
         p_mha_dep_flg = as.integer(p_mha_dep_flg),
         p_subabuse_flg = as.integer(p_subabuse_flg),
         p_othermh_flg = as.integer(p_othermh_flg),
         selfharm_flg = as.integer( ifelse(p_selfharm_event_ct + f_selfharm_event_ct > 0, 1, 0) ),
         # Physical Health
         p_chronic_diag_flg = as.integer(p_chronic_diag_flg),
         p_cancer_diag_flg = as.integer(p_cancer_diag_flg),
         f_chronic_diag_flg = as.integer(f_chronic_diag_flg),
         f_cancer_diag_flg = as.integer(f_cancer_diag_flg),
         p_health_costs = p_avg_yearly_primhd_cost + p_avg_yearly_pharm_cost + p_avg_yearly_pfhd_cost + p_avg_yearly_nnp_cost
           + p_avg_yearly_lab_cost,
         f_health_costs = f_avg_yearly_primhd_cost + f_avg_yearly_pharm_cost + f_avg_yearly_pfhd_cost + f_avg_yearly_nnp_cost
         + f_avg_yearly_lab_cost,
         # Education
         mother_nqflevel = as.integer(mother_nqflevel),
         f_nqf_level_5yrs = as.integer(f_nqf_level_5yrs),
         p_ter_student_flg = as.integer(ifelse(p_avg_yearly_moetertiary_cost > 0, 1, 0) ),
         # p_sec_student_flg = as.integer(ifelse(p_school_enr_days > 0, 1, 0) ),
         # Benefits
         p_t1_ben_flg = as.integer(p_t1_ben_flg),
         p_sh_flg = as.integer(p_sh_flg),
         p_avg_yearly_ben = p_avg_yearly_t1ben_inc + p_avg_yearly_t2ben_inc + p_avg_yearly_t3ben_inc,
         f_avg_yearly_ben = f_avg_yearly_t1ben_inc + f_avg_yearly_t2ben_inc + f_avg_yearly_t3ben_inc,
         # Corrections
         p_cor_prison_remand_flg = as.integer(p_cor_prison_remand_flg),
         p_cor_comm_release_flg = as.integer(p_cor_comm_release_flg),
         f_cor_prison_remand_flg = as.integer(f_cor_prison_remand_flg),
         f_cor_comm_release_flg = as.integer(f_cor_comm_release_flg),
         # Mortality
         mortality_evt_flg = as.integer(mortality_evt_flg),
         # Employment
         p_emp_status_flg = as.integer(ifelse(p_avg_yearly_emp_inc > 0, 1, 0) ),
         # Create new variables for incremental difference in costs before and after birth of child
         # This would enable looking at differences in the lives of the mothers before and after giving birth.
         # Diff variables (difference between after-birth and before-birth)
         # NQF level cleanup- a person's qualifications cannot go down in time
         emp_inc_diff_std = (f_avg_yearly_emp_inc / (1+ct_of_children_after)) - (p_avg_yearly_emp_inc/1+ct_of_children_before),
         ben_cost_diff = f_avg_yearly_ben - p_avg_yearly_ben,
         health_cost_diff = f_health_costs - p_health_costs,
         # lab_cost_diff = f_avg_yearly_lab_cost - p_avg_yearly_lab_cost,
         # nnp_cost_diff = f_avg_yearly_nnp_cost - p_avg_yearly_nnp_cost,
         # pfhd_cost_diff = f_avg_yearly_pfhd_cost - p_avg_yearly_pfhd_cost,
         # pharm_cost_diff = f_avg_yearly_pharm_cost - p_avg_yearly_pharm_cost,
         # primhd_cost_diff = f_avg_yearly_primhd_cost - p_avg_yearly_primhd_cost,
         gms_ct_diff = f_gms_ct/5.0 - p_gms_ct/2.0,
         cancer_or_chronic_flg = as.integer(
           ifelse( (f_chronic_diag_flg == 1 | p_cancer_diag_flg == 1 | f_cancer_diag_flg == 1), 1, 0)),
         p_cor_flg = as.integer(ifelse(p_cor_prison_remand_flg == 1 | p_cor_comm_release_flg == 1, 1, 0)),
         f_cor_flg = as.integer(ifelse(f_cor_prison_remand_flg == 1 | f_cor_comm_release_flg == 1, 1, 0))
         # f_nqf_level_5yrs = ifelse( !is.na(f_nqf_level_5yrs) & 
         #                            !is.na(mother_nqflevel) & 
         #                            (f_nqf_level_5yrs - mother_nqflevel) < 0,
         #                           mother_nqflevel, f_nqf_level_5yrs)
         
  ) %>% # Removing unnecessary variables from the dataset
  # 6- level ethnicity has been removed, but can be added back in the future if required
  # School enrollment days have been excluded because it does not apply to everyone in the population
  # Corrections costs have been removed because it is heavily skewed, and replaced with binary flags instead
  # Health and benefit related costs have been removed as we have added the difference in forecast and profile
  #   window costs in this case.
  # Cancer/Chronic Diagnosis have been collapsed into a single flag variable.
  # Profile and forecast corrections hsitory collpsed to single flag variable
  select(-gestation,-gestation_in_days, -birth_date, -uid_miss_ind_cnt
         ,-ant_meshblock_code,-ant_ta_code
         ,-p_school_enr_days
         ,-snz_sex_code
         ,-snz_ethnicity_grp1_nbr,-snz_ethnicity_grp2_nbr,-snz_ethnicity_grp3_nbr
         ,-snz_ethnicity_grp4_nbr,-snz_ethnicity_grp5_nbr,-snz_ethnicity_grp6_nbr
         ,-f_avg_yearly_cor_cost,-p_avg_yearly_cor_cost
         ,-f_avg_yearly_emp_inc
         ,-f_avg_yearly_t1ben_inc, -p_avg_yearly_t1ben_inc
         ,-f_avg_yearly_t2ben_inc, -p_avg_yearly_t2ben_inc
         ,-f_avg_yearly_t3ben_inc, -p_avg_yearly_t3ben_inc
         ,-f_avg_yearly_ben
         ,-f_avg_yearly_lab_cost, -p_avg_yearly_lab_cost
         ,-f_avg_yearly_nnp_cost, -p_avg_yearly_nnp_cost
         ,-f_avg_yearly_pfhd_cost, -p_avg_yearly_pfhd_cost
         ,-f_avg_yearly_pharm_cost, -p_avg_yearly_pharm_cost
         ,-f_avg_yearly_primhd_cost, -p_avg_yearly_primhd_cost
         ,-f_health_costs
         ,-f_avg_yearly_moetertiary_cost, -p_avg_yearly_moetertiary_cost
         ,-p_moe_intervention_dur
         ,-ct_of_children_after
         ,-f_gms_ct, -p_gms_ct
         ,-p_cancer_diag_flg,-f_cancer_diag_flg
         ,-p_chronic_diag_flg,-f_chronic_diag_flg
         ,-p_cor_prison_remand_flg,-p_cor_comm_release_flg,-f_cor_prison_remand_flg,-f_cor_comm_release_flg
         ,-p_selfharm_event_ct, -f_selfharm_event_ct
         ,-p_t1_ben_flg
         )

# Get mothers who are linked to the ERP
mothers <- dataset %>%
  filter(mother_linked_flg == 1) %>% 
  select(-mother_linked_flg) 

# Set the ID column name for mothers dataset
idcol_mum <- "snz_uid"

# Create lists of numeric, integer and categorical variables
catcols_mum <- names( mothers[ , sapply( mothers , is.factor) ] %>% 
                        select(-one_of(idcol_mum)))
# To keep the code consistent with the catcols_mum code suppress the warning about the snz_uid - it is not integer
suppressWarnings(intcols_mum <- names( mothers[ , sapply( mothers , is.integer) ] %>% 
                                         select(-one_of(idcol_mum))))
numcols_mum <- names( mothers[ , !names(mothers) %in% c(catcols_mum, intcols_mum, idcol_mum)] )


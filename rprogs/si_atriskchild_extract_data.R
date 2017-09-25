# ================================================================================================ #
# Description: Code for reading the at-risk child dataset in from the database,
# and adding a few transformed variables that may be of interest.
#
# Input: 
# <schema>.[si_child_cohort_modelling]
#
# Output: 
# children = dataframe with child information
# catcols_child = names of all the categorical variables in mothers
# intcols_child = names of all the integer variables in mothers
# numcols_child = names of all the numerical variables in mothers
#
# Author: W Lee
#
# Dependencies:
# SIAtoolbox = to read in the table from the database
# mothers_imputed =  required for inheriting imputed values from mothers dataset
#
# Notes:
# NA
#
# History (reverse order): 
# 17 Aug 2017 EW  Test and tidy up
# 15 Aug 2017 VB  Added new variables and set appropriate datatypes, inherited imputed values from
#                 the mothers's dataset
# 11 Aug 2017 EW  V1 based on the original script for mothers by VB
# ================================================================================================ #


################################ Load datasets for analysis into memory ################################

# Read in SQL table and create the dataset for analysis
#TODO do we want to add birth weight
dataset <- SIAtoolbox::read_sql_table(paste0("select * from ", child_modelling_tab), connstr, string = TRUE) %>%
  mutate(snz_uid = factor(snz_uid),
         mum_id = factor(mum_id),
         # Demographics
         snz_sex_code = as.integer(ifelse(snz_sex_code == "1", 0, 1)), # 0 - Male, 1 - Female
         prioritised_eth = factor(prioritised_eth),
         region = factor(region),
         iwi1_desc = factor(iwi1_desc),
         siblings_ct = as.integer(siblings_ct),
         premature_birth_flg = as.integer(premature_birth_flg),
         # CYF
         contact_record_cyf = as.integer(contact_record_cyf),
         police_fv = as.integer(police_fv),
         neglect_abuse_ct = as.integer(neglect_abuse_ct),
         not_found_abuse_ct = as.integer(not_found_abuse_ct),
         emotional_abuse_ct = as.integer(emotional_abuse_ct),
         behaviour_abuse_ct = as.integer(behaviour_abuse_ct),
         physical_abuse_ct = as.integer(physical_abuse_ct),
         sexual_abuse_ct = as.integer(sexual_abuse_ct),
         # Health
         pah_flg = as.integer(pah_flg),
         pah_description = as.factor(pah_description),
         disability_flg = as.integer(disability_flg),
         mortality_flg = as.integer(mortality_flg),
         cancer_flg = as.integer(cancer_flg),
         chronic_flg = as.integer(chronic_flg),
         gms_cost = as.numeric(gms_cost),
         gms_dffe = as.integer(gms_dffe),
         gms_ct2 = as.integer(gms_ct2),
         f1_moh_gms_gms_cnt = as.integer(f1_moh_gms_gms_cnt),
         f1_moh_gms_gms_cst = as.numeric(f1_moh_gms_gms_cst),
         f1_moh_gms_gms_ct2 = as.integer(f1_moh_gms_gms_ct2),
         imm_6mth_complete_flg = as.integer(imm_6mth_complete_flg),
         imm_8mth_complete_flg = as.integer(imm_8mth_complete_flg),
         imm_12mth_complete_flg = as.integer(imm_12mth_complete_flg),
         imm_18mth_complete_flg = as.integer(imm_18mth_complete_flg),
         imm_24mth_complete_flg = as.integer(imm_24mth_complete_flg),
         imm_60mth_complete_flg = as.integer(imm_60mth_complete_flg),
         b4sc_outcome = relevel(as.factor(ifelse(is.na(b4sc_outcome), 'Unknown',
                                                 as.character(b4sc_outcome))), ref = "Not Referred") ,
         b4sc_sdqp_outcome = relevel(as.factor(ifelse(is.na(b4sc_sdqp_outcome), 'Unknown',
                                                      as.character(b4sc_sdqp_outcome))), ref = "Not Referred"),
         b4sc_sdqt_outcome = relevel(as.factor(ifelse(is.na(b4sc_sdqt_outcome), 'Unknown',
                                                      as.character(b4sc_sdqt_outcome))), ref = "Not Referred"),
         b4sc_vision_outcome = relevel(as.factor(ifelse(is.na(b4sc_vision_outcome), 'Unknown',
                                                        as.character(b4sc_vision_outcome))), ref = "Pass Bilaterally"),
         b4sc_hearing_outcome = relevel(as.factor(ifelse(is.na(b4sc_hearing_outcome), 'Unknown',
                                                         as.character(b4sc_hearing_outcome))), ref = "Pass Bilaterally"),
         b4sc_growth_outcome = relevel(as.factor(ifelse(is.na(b4sc_growth_outcome), 'Unknown',
                                                        as.character(b4sc_growth_outcome))), ref = "Not Referred"),
         b4sc_dental_outcome = relevel(as.factor(ifelse(is.na(b4sc_dental_outcome), 'Unknown',
                                                        as.character(b4sc_dental_outcome))), ref = "Not Referred"),
         b4sc_peds_outcome = relevel(as.factor(ifelse(is.na(b4sc_peds_outcome), 'Unknown',
                                                      as.character(b4sc_peds_outcome))), ref = "Not Referred"),
         f_moh_pha_pha_cnt = as.integer(f_moh_pha_pha_cnt),
         f_moh_pha_pha_cst = as.numeric(f_moh_pha_pha_cst),
         f_moh_lab_lab_cst = as.numeric(f_moh_lab_lab_cst),
         f_moh_nnp_nnp_cnt = as.integer(f_moh_nnp_nnp_cnt),
         f_moh_nnp_nnp_cst = as.numeric(f_moh_nnp_nnp_cst),
         f_moh_pfh_pfh_cst = as.numeric(f_moh_pfh_pfh_cst),
         # Education
         ece_any_flg = as.integer(ece_any_flg),
         ece_kohanga_flg = as.integer(ece_kohanga_flg),
         # Mother related
         mother_teen_preg_flg = as.integer(mother_teen_preg_flg),
         mother_late_preg_flg = as.integer(mother_late_preg_flg),
         mother_single_parent_flg = as.integer(mother_single_parent_flg),
         mother_nqlf_level = as.integer(mother_nqlf_level),
         mother_t1ben_flg = as.integer(mother_t1ben_flg),
         mother_socialhousing_flg = as.integer(mother_socialhousing_flg),
         mother_mesh_dep_index = as.integer(mother_mesh_dep_index),
         mother_antenatal_smoking_flg = as.integer(mother_antenatal_smoking_flg),
         mother_postnatal_smoking_flg = as.integer(mother_postnatal_smoking_flg),
         mother_p_depression_flg = as.integer(mother_p_depression_flg),
         mother_f_depression_flg = as.integer(mother_f_depression_flg),
         mother_p_subabuse_flg = as.integer(mother_p_subabuse_flg),
         mother_f_subabuse_flg = as.integer(mother_f_subabuse_flg),
         mother_address_change_ct = as.integer(mother_address_change_ct),
         mother_avg_income = as.numeric(mother_avg_income),
         # Create new variables here
         f_health_costs = f_moh_pfh_pfh_cst + f_moh_nnp_nnp_cst + f_moh_lab_lab_cst + f_moh_pha_pha_cst + gms_cost,
         imm_on_time_ct = imm_6mth_complete_flg + imm_8mth_complete_flg +imm_12mth_complete_flg + imm_18mth_complete_flg + 
           imm_24mth_complete_flg + imm_60mth_complete_flg
         
  ) %>% 
  # Removing unnecessary variables from the dataset
  # 6- level ethnicity has been removed, but can be added back in the future if required
  # Health costs have been consildated into one variable
  # Health counts are removed (except gms)
  # Immunisations have been collapsed into a single variable that counts number of times immunisations happened on schedule
  # Retain only b4sc_outcome and B4SC growth outcome and remove other B4SC outcomes for parsimony reasons
  select(-uid_miss_ind_cnt
         ,-iwi1_desc
         ,-f1_moh_gms_gms_cnt,-f1_moh_gms_gms_cst,-f1_moh_gms_gms_ct2,-gms_dffe
         ,-f_moh_pha_pha_cnt
         ,-f_moh_nnp_nnp_cnt
         ,-f_moh_pfh_pfh_cst, -f_moh_nnp_nnp_cst, -f_moh_lab_lab_cst,-f_moh_pha_pha_cst, -gms_cost
         ,-imm_6mth_complete_flg,-imm_8mth_complete_flg,-imm_12mth_complete_flg
         ,-imm_18mth_complete_flg,-imm_24mth_complete_flg,-imm_60mth_complete_flg
         ,-b4sc_sdqp_outcome,-b4sc_sdqt_outcome,-b4sc_vision_outcome,-b4sc_hearing_outcome
         ,-b4sc_dental_outcome,-b4sc_peds_outcome,-b4sc_growth_outcome
  )

# For Mother's NQF level and region, extract the imputed variables from the mothers dataset.
# Also filter on only those children who are from mothers linked to the ERP (because it may otherwise bias the variables 
# inherited from mothers)
dataset <- dataset %>% 
  inner_join(mothers_imputed %>% 
               select(snz_uid, ant_region_code, mother_nqflevel, meshblock_dep_index), by= c("mum_id" = "snz_uid") ) %>% 
  select(one_of(names(dataset), "ant_region_code", "mother_nqflevel", "meshblock_dep_index")) %>%
  mutate(
    region = ant_region_code,
    mother_nqlf_level = mother_nqflevel,
    mother_mesh_dep_index = meshblock_dep_index
  ) %>%
  select(-ant_region_code, -mother_nqflevel, -mum_id  # not required for this analysis
         ,-pah_description # Too many levels for this variable.
         ,-meshblock_dep_index
         )

children <- dataset %>% 
  #filter(child_linked_flg == 1) %>% 
  select(-child_linked_flg)

# Set the ID column name for child dataset
idcol_child <- "snz_uid"

# Create lists of numeric and categorical variables
catcols_child <- names( children[ , sapply( children , is.factor) ] %>% select(-one_of(idcol_child)) )
suppressWarnings(intcols_child <- names( children[ , sapply( children , is.integer) ] %>% select(-one_of(idcol_child)) ) )
numcols_child <- names( children[ , !names(children) %in% c(catcols_child, intcols_child, idcol_child)] )


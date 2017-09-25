# ================================================================================================ #
# Description: Apply premodelling data transformations, imputations and exploratory analysis.
#
# Input: 
# mothers = dataframe with variables used to analyse the mothers that has some tidy up done
# catcols_mum = names of all the categorical variables in mothers
# intcols_mum = names of all the integer variables in mothers
# numcols_mum = names of all the numerical variables in mothers
#
# Output: 
# mothers_imputed = Imputed dataset with all NAs imputed
# mothers_imputed_scaled = Imputed and variable-standardised dataset
# Descriptive stats on pre-imputation and post-imputation datasets
#
# Author: V Benny
#
# Dependencies:
# TBA
#
# Notes:
# NA
#
# History (reverse order): 
# 17 Aug 2017 EW Test and tidy up
# 11 Aug 2017 VB v1
# ================================================================================================ #

################################ Descriptive Stats on Full population ################################


# Look at missing values
missing_values <- mothers %>% 
  summarise_all( funs(sum(is.na(.)) / n() ) ) %>% 
  gather(key = "feature", value = "missing_pct") %>%
  arrange(missing_pct)
ggplot(data = missing_values, aes(x = reorder(feature, -missing_pct), y = missing_pct )) + 
  geom_bar(stat="identity", fill="red") + coord_flip()
# Region, Meshblock Deprivation Index, NQF Level have missing values

# For all numerics, get the distribution histograms before imputation and preprocessing
mothers %>% select_if(is.numeric) %>% 
  gather() %>% 
  filter(!is.na(value)) %>%
  ggplot( aes(value) ) + facet_wrap(~ key, scales = "free") + geom_histogram()
ggsave("../output/plots/mothers_data_before_imputation.png", device = "png", width = 16, height = 8, units = "in")



################################ Imputation and Preprocessing ################################

# Perform multiple imputation for missing values in the dataset. This section takes ~50 minutes to execute.
predictor_matrix <- 1- diag(1, ncol(mothers)) # Create a predictor matrix for the imputation that excludes the ID column
predictor_matrix[, grep(idcol_mum, names(mothers)) ] <- 0 
imputation <- mice( data = mothers, m = 5, predictorMatrix = predictor_matrix )
mothers_imputed <- mice::complete(imputation, "long", inc= FALSE)

# The mice function will give us m=5 datasets with imputed values in a long form meaning each snz_uid will appear m=5 times
# with .imp indicating which of the 5 datasets the observation belongs to so take the mean imputed value for numeric 
# variables, round them if they are integer and the most commonly imputed value for categorical variables
imputed_num <- mothers_imputed %>% 
  group_by(snz_uid) %>% 
  select(snz_uid, numcols_mum) %>% 
  summarise_all(funs(mean))

imputed_int <- mothers_imputed %>% 
  group_by(snz_uid) %>% 
  select(snz_uid, intcols_mum) %>% 
  summarise_all(funs(mean)) %>%
  group_by(snz_uid) %>% 
  summarise_all(funs(round))

imputed_cat <- mothers_imputed %>% 
  group_by(snz_uid)%>% 
  select(snz_uid, catcols_mum) %>% 
  summarise_all(funs(names(table(.))[which.max(table(.))])) %>%
  mutate(prioritised_eth = relevel(factor(prioritised_eth), ref = "E"),
         ant_region_code = relevel(factor(ant_region_code), ref = "2")
  )

mothers_imputed <- imputed_num %>% 
  inner_join(imputed_int, by = idcol_mum) %>% 
  inner_join( imputed_cat, by = idcol_mum )

# In case of extreme outliers for variables ( <1% or >99% ), replace with 1st or 99th percentile value.
# Also apply transformations for skewed variables if any.
mothers_imputed <- mothers_imputed %>% 
  mutate(
    # gestation = trim_outliers(gestation, 0.001, 0.999)
    #  these were left here for experimenting
    # ,p_moe_intervention_dur = trim_outliers(p_moe_intervention_dur, 0.001, 0.999)
    # ,P_avg_yearly_emp_inc = trim_outliers(P_avg_yearly_emp_inc, 0.01, 0.99)
    # ,P_avg_yearly_t1ben_inc = trim_outliers(P_avg_yearly_t1ben_inc, 0.01, 0.99)
    # ,P_avg_yearly_t2ben_inc = trim_outliers(P_avg_yearly_t2ben_inc, 0.01, 0.99)
    # ,P_avg_yearly_t3ben_inc = trim_outliers(P_avg_yearly_t3ben_inc, 0.01, 0.99)
    # ,P_avg_yearly_lab_cost = trim_outliers(P_avg_yearly_lab_cost, 0.01, 0.99)
    # ,P_avg_yearly_nnp_cost = trim_outliers(P_avg_yearly_nnp_cost, 0.01, 0.99)
    # ,P_avg_yearly_pfhd_cost = trim_outliers(P_avg_yearly_pfhd_cost, 0.01, 0.99)
    # ,P_avg_yearly_pharm_cost = trim_outliers(P_avg_yearly_pharm_cost, 0.01, 0.99)
    # ,P_avg_yearly_primhd_cost = trim_outliers(P_avg_yearly_primhd_cost, 0.01, 0.99)
    # ,p_health_costs = log( 1 + p_health_costs )
    # ,P_avg_yearly_emp_inc = log( 1 + P_avg_yearly_emp_inc )
    # ,P_avg_yearly_t1ben_inc = log( 1 + P_avg_yearly_t1ben_inc )
    # ,P_avg_yearly_t2ben_inc = log( 1 + P_avg_yearly_t2ben_inc )
    # ,P_avg_yearly_t3ben_inc = log( 1 + P_avg_yearly_t3ben_inc )
  )


# Clean up memory by removing objects that are no longer required
rm(dataset, mothers, imputed_num, imputed_cat, imputed_int, imputation, predictor_matrix, missing_values)

# Apply centering and scaling to numeric variables such that mean = 0 and sd = 1
scalemodel <- caret::preProcess(mothers_imputed[, c(numcols_mum, intcols_mum)], method=c("center", "scale"))
mothers_imputed_scaled <- cbind(predict(scalemodel, 
                                        mothers_imputed[,c(numcols_mum, intcols_mum)]), 
                                mothers_imputed[, !names(mothers_imputed) %in% c(numcols_mum, intcols_mum)] )



################################ Exploratory Analysis ################################
# Post-imputation descriptive stats on the dataset
mothers_imputed %>% 
  select_if(is.numeric) %>% 
  gather() %>% 
  ggplot( aes(value) ) + facet_wrap(~ key, scales = "free") + geom_histogram()
ggsave("../output/plots/mothers_data_after_imputation.png", device = "png", width = 16, height = 8, units = "in")

# Perform an exploratory factor analysis on the dataset
res.famd <- FAMD(base = mothers_imputed_scaled[, !names(mothers_imputed_scaled) %in% c(idcol_mum) ], ncp = 30 )
plot(res.famd)

# Describe the relationship between the variables and the first 2 principal axes to determine the variable importance and 
# behaviour
write.xlsx(res.famd$eig, file = "../output/mothers_pca.xlsx", sheetName = "FAMD_Eigen")

write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.1$quanti, 
           file = "../output/mothers_pca.xlsx", 
           sheetName = "Dim1_Num",
           append=TRUE)

write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.1$category, 
           file = "../output/mothers_pca.xlsx", 
           sheetName = "Dim1_Cat",
           append=TRUE)

write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.2$quanti, 
           file = "../output/mothers_pca.xlsx", 
           sheetName = "Dim2_Num",
           append=TRUE)

write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.2$category, 
           file = "../output/mothers_pca.xlsx", 
           sheetName = "Dim2_Cat",
           append=TRUE)



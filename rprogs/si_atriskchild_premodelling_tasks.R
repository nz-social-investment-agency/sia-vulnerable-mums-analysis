# ================================================================================================ #
# Description: Apply premodelling data transformations, imputations and exploratory analysis.
#
# Input: 
# children = dataframe with variables used to analyse the mothers that has some tidy up done
# catcols_child = names of all the categorical variables in mothers
# intcols_child= names of all the integer variables in mothers
# numcols_child = names of all the numerical variables in mothers
#
# Output: 
# children_imputed = Imputed dataset with all NAs imputed
# children_imputed_scaled = Imputed and variable-standardised dataset
# Descriptive stats on pre-imputation and post-imputation datasets
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
# 16 Aug 2017 VB  V1
# ================================================================================================ #



################################ Descriptive Stats on Full population ################################


# Look at missing values
missing_values <- children %>% summarise_all( funs(sum(is.na(.)) / n() ) ) %>% 
  gather(key = "feature", value = "missing_pct") %>%
  arrange(missing_pct)
ggplot(data = missing_values, aes(x = reorder(feature, -missing_pct), y = missing_pct )) + 
  geom_bar(stat="identity", fill="red") + coord_flip()
# Region, B4SC data, Meshblock Deprivation Index, NQF Level have missing values

# For all numerics, get the distribution histograms before imputation and preprocessing
children %>% select_if(is.numeric) %>% gather() %>% filter(!is.na(value)) %>%
  ggplot( aes(value) ) + facet_wrap(~ key, scales = "free") + geom_histogram()
ggsave("../output/plots/children_data_before_imputation.png", device = "png", width = 16, height = 8, units = "in")



################################ Imputation and Preprocessing ################################

# Children dataset has only 3 missing values for ethnicity and sex. Hence no imputation will be performed
# We will assume the mode values for the missing data.
children_imputed <- children
children_imputed$prioritised_eth[which(is.na(children_imputed$prioritised_eth))] <- 
  names(sort(-table(children_imputed$prioritised_eth)))[1]
children_imputed$snz_sex_code[which(is.na(children_imputed$snz_sex_code))] <- 
  as.integer(names(sort(-table(children_imputed$snz_sex_code)))[1])

# In case of extreme outliers for variables ( <1% or >99% ), replace with 1st or 99th percentile value.
# Also apply transformations for skewed variables if any.
children_imputed <- children_imputed %>% 
  mutate(
    # gestation = trim_outliers(gestation, 0.001, 0.999)
    # f_health_costs = log(1 + f_health_costs)
  )


# Clean up memory by removing objects that are no longer required
rm(dataset, children, missing_values)

# Apply centering and scaling to numeric variables such that mean = 0 and sd = 1
scalemodel <- caret::preProcess(children_imputed[, c(numcols_child, intcols_child )], 
                                method=c("center", "scale") )
children_imputed_scaled <- cbind(predict(scalemodel, children_imputed[,c(numcols_child, intcols_child )]), 
                                children_imputed[, !names(children_imputed) %in% c(numcols_child, intcols_child)] )



################################ Exploratory Analysis ################################
# Post-imputation descriptive stats on the dataset
children_imputed %>% select_if(is.numeric) %>% gather() %>% 
  ggplot( aes(value) ) + facet_wrap(~ key, scales = "free") + geom_histogram()
ggsave("../output/plots/children_data_after_imputation.png", device = "png", width = 16, height = 8, units = "in")

# Perform an exploratory factor analysis on the dataset
res.famd <- FAMD(base = children_imputed_scaled[, !names(children_imputed_scaled) %in% c(idcol_child) ], ncp = 30 )
plot(res.famd)

# Describe the relationship between the variables and the first 2 principal axes to determine the variable 
# importance and behaviour
write.xlsx(res.famd$eig, file = "../output/children_pca.xlsx", sheetName = "FAMD_Eigen")
write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.1$quanti, file = "../output/children_pca.xlsx", sheetName = "Dim1_Num", append = TRUE)
write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.1$category, file = "../output/children_pca.xlsx", sheetName = "Dim1_Cat", append=TRUE)
write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.2$quanti, file = "../output/children_pca.xlsx", sheetName = "Dim2_Num", append=TRUE)
write.xlsx(dimdesc(res.famd, axes=1:2)$Dim.2$category, file = "../output/children_pca.xlsx", sheetName = "Dim2_Cat", append=TRUE)



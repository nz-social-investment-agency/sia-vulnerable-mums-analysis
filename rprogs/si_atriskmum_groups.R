## ===================================================================== ##
##
## Purpose: Based on the clusters to which mums have been allocated, 
##  this script attempts to describe the cluster groupings in terms of
##  the variables that strongly characterise each cluster. These variables
##  describe how we can define natural groupings among mothers, for better
##  service/intervention design that cater to each natural groupings.
##  
##  Also, clusters that exhibit larger coefficients for the variables that
##  are associated with risk (based on "Growing Up in New Zealand" study) 
##  indicate groups that may be at risk of bad outcomes, thereby giving us
##  a way to prioritise services for groups with certain characteristics. 
##
## Input: 
## analysis_dataset = dataset with all the cluster ids
##
## Output: 
## Descriptive stats on significant variables in each cluster
##
## Author: V Benny
## Date: 11/08/2017
## Modified:     
## Review: 
## Version History
##  11 Aug 2017 VB  v1
## ===================================================================== ##




########################## Create final dataset for analysis################################
analysis_data_y <- analysis_data$target_grp
analysis_data_x <- model.matrix(~., data=analysis_data %>% select(-one_of("target_grp")) ) [, -1]

# Apply a generalised linear model with penalised maximum likelihood for variable selection (with Lasso penalty)
# for each clusters.
# First we do a grouped analysis, retaining same set of variables for all clusters
# Parallel execution of cross validation.
cl <- makeCluster(10)
registerDoParallel(cl)
# This is to retain the same set of variables for all multinomial levels
cv.glmnetout.grouped <- cv.glmnet(x = analysis_data_x, 
                          y = analysis_data_y, 
                          family = "multinomial", 
                          type.multinomial = "grouped", 
                          maxit = 1000000,
                          parallel = TRUE)

# This is to retain only those variables that are relevant for each multinomial level
cv.glmnetout.ungrouped <- cv.glmnet(x = analysis_data_x, 
                                    y = analysis_data_y, 
                                    family = "multinomial",  
                                    maxit = 1000000,
                                    parallel = TRUE)
stopCluster(cl)

# Save coefficient outputs
coeffvals_grouped_mum <- coef(cv.glmnetout.grouped, s = "lambda.min")
coeffvals_ungrouped_mum <- coef(cv.glmnetout.ungrouped, s = "lambda.min")
plot(cv.glmnetout.grouped)
plot(cv.glmnetout.ungrouped)

df1 <- data.frame(matrix(NA, 1 + ncol(analysis_data_x), 1))
df2 <- data.frame(matrix(NA, 1 + ncol(analysis_data_x), 1))

for( i in names(coeffvals_grouped_mum) ){
  df1[,1] <- coeffvals_grouped_mum[[1]]@Dimnames[1]
  df1[[i]] <- as.matrix(coeffvals_grouped_mum[[i]])
  df2[,1] <- coeffvals_ungrouped_mum[[1]]@Dimnames[1]
  df2[[i]] <- as.matrix(coeffvals_ungrouped_mum[[i]])
}
names(df1) <- c("cols", names(coeffvals_grouped_mum))
names(df2) <- c("cols", names(coeffvals_ungrouped_mum))
write.xlsx(df1, file="../output/mums_lassoglm_output.xlsx", sheetName="grouped_lasso")
write.xlsx(df2, file="../output/mums_lassoglm_output.xlsx", sheetName="ungrouped_lasso", append = TRUE)

rm(df1, df2)





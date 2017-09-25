## ===================================================================== ##
##
## Purpose: Based on the clusters to which children have been allocated, this 
##  script analyses which variables are important in characterising
##  the clusters based on their characteristics
##
##
## Input: 
## analysis_dataset = dataset with all the cluster ids
##
## Output: 
## Descriptive stats on significant variables in each cluster
##
## Author: W Lee
## Date: 11/08/2017
## Modified:     
## Review: 
## Version History
##  11 Aug 2017 VB  v1
## ===================================================================== ##



########################## Create final dataset for analysis################################

analysis_data_y <- analysis_data$target_grp
analysis_data_x <- model.matrix(~., data=analysis_data %>% select(-one_of("target_grp")) ) [, -1]



# Apply a generalised linear model with penalised maximum likelihood for variable selection
# for each clusters.

# Parallel execution of cross validation.
cl <- makeCluster(10)
registerDoParallel(cl)

cv.glmout <- cv.glmnet(x = analysis_data_x, y = analysis_data_y, family = "multinomial" , type.multinomial = "grouped",
                      maxit = 1000000,
                       parallel = TRUE)
# This is to retain only those variables that are relevant for each multinomial level
# cv.glmnetout <- cv.glmnet(x = analysis_data_x, y = analysis_data_y, family = "multinomial", parallel = TRUE)
stopCluster(cl)

# Save coefficient outputs
coeffvals_grouped_child <- coef(cv.glmout, s = "lambda.min")

plot(cv.glmout)

df1 <- data.frame(matrix(NA, 1 + ncol(analysis_data_x), 1))

for( i in names(coeffvals_grouped_child) ){
  df1[,1] <- coeffvals_grouped_child [[1]]@Dimnames[1]
  df1[[i]] <- as.matrix(coeffvals_grouped_child[[i]])

}
names(df1) <- c("cols", names(coeffvals_grouped_child))
write.xlsx(df1, file="../output/child_lassoglm_output.xlsx", sheetName="grouped_lasso")


rm(df1)


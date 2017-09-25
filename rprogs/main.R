# ================================================================================================ #
# Description: Script that runs data cleaning, clustering and statistical tests for the mothers
# and the children 
#
# Input: 
# NA
#
# Output: 
# TBA
#
# Author: E Walsh
#
# Dependencies:
# NA
#
# Notes:
# NA
#
# History (reverse order): 
# 13 Aug 2017 EW v1
# ================================================================================================ #

############################################# Setup ################################################

# Set the working directory
setwd("~/Network-Shares/Datalab-MA/MAA2016-15 Supporting the Social Investment Unit/github_vulnerable_mothers/rprogs")


# Load libraries
library(RODBC)       # interface for MS SQL server
library(dplyr)       # data manipulation
library(tidyr)       # used for data tidying in conjunction with dplyr
library(devtools)    # used to install non CRAN packages such as SIAtoolbox
library(SIAtoolbox)  # common functions and templates for the SIA
library(ggplot2)     # nice plots
library(FactoMineR)  # multivariate exploratory data analysis and data mining
library(mice)        # multivariate imputation has nice visualiasions too
library(caret)       # classification and regression training
library(cluster)     # various clustering algorithms use clustMixType if we have loads of categorical vars
library(clustMixType)# for kproto clustering algorithm
library(doParallel)  # parallel execution of clustering
library(foreach)     # used in conjunction with parallel execution
library(doRNG)       # for setting seed for each parallel execution
library(xlsx)        # reading and writing into xlsx
library(reshape2)    # Used for the melt() function
library(glmnet)      # Fit a lasso to identify the subset of variables describing each cluster

# Set seed for replicability
seedval <- 12345
set.seed(seedval)

# Connection to the database
connstr <- set_conn_string(db = "IDI_Sandpit")

# Since we only have two short functions put it here
trim_outliers <- function(col, lower_cutoff, upper_cutoff) {
  limit_lower <- quantile(col, c(lower_cutoff) )
  limit_upper <- quantile(col, c(upper_cutoff) )
  col[which(col > limit_upper)] <- limit_upper
  col[which(col < limit_lower)] <- limit_lower
  return(col)
}

clusterStats <- function(dataset, clustcolvector, numcolvector, outputfile, silhouettematrix){
  
  write.xlsx( c("Description"), file=outputfile, sheetName="Note to Stats", row.names=FALSE, col.names = FALSE )
  for(clustcol in clustcolvector){
    results_mean <- t(cbind(goodness_measure = silhouettematrix[which(!is.na(silhouettematrix[,clustcol])), clustcol] ,
                       (dataset %>% group_by_(clustcol) %>% summarise(ct = n() ))[2],
                      dataset %>% select( one_of(numcolvector, clustcol) ) %>% group_by_(clustcol) %>% summarise_all(funs(mean))
                 ))
    results_sd <- t(cbind(goodness_measure = silhouettematrix[which(!is.na(silhouettematrix[,clustcol])), clustcol] ,
                       (dataset %>% group_by_(clustcol) %>% summarise(ct = n() ))[2],
                       dataset %>% select( one_of(numcolvector, clustcol) ) %>% group_by_(clustcol) %>% summarise_all(funs(sd))
    ))
    
    write.xlsx( cbind(results_mean, results_sd), file=outputfile, sheetName=clustcol, append = TRUE, col.names = FALSE)
    
    # Create a boxplot for all variables
    dataset %>% select( one_of(numcolvector, clustcol) ) %>% melt(id = clustcol) %>% 
      ggplot(aes_string(y="value", x = clustcol, group = clustcol) ) + facet_wrap(~ variable, scales = "free") + 
      geom_boxplot(outlier.alpha = 0)
    ggsave(file = paste0(substr(outputfile, 1, nchar(outputfile) - 4), clustcol,"_boxplot.png"), 
           device = "png", width = 16, height = 8, units = "in")
  }
}


################################### Data prep: 1 hour #############################################

mother_modelling_tab <- "[DL-MAA2016-15].[si_mother_cohort_modelling]"
child_modelling_tab <- "[DL-MAA2016-15].[si_child_cohort_modelling]"

# Load data and identify mums who are linked to the ERP
source("si_atriskmum_extract_data.R")

# Explore, impute, scale the variables to create an analysis-ready mums dataset 
source("si_atriskmum_premodelling_tasks.R")

# Load data for children 
# Note: Children are not linked to ERP because they may be too young to link properly
source("si_atriskchild_extract_data.R")

# Explore, impute, scale the variables to create an analysis-ready child dataset
# Note: This step has a dependency on the mothers dataset
source("si_atriskchild_premodelling_tasks.R")

############ Identifying natural groupings for mothers based on characteristics: 2 hours #########

# load clustering
source("si_atriskmum_clustering.R")

# perform statistical tests
source("si_atriskmum_groups.R")


######### Identifying  natural groupings for children based on characteristics: 1 hour ############
# load clustering
source("si_atriskchild_clustering.R")

# perform statistical tests
source("si_atriskchild_groups.R")

# Create a child variables dataset with both children and mother cluster IDs
source("si_create_atriskchild_atriskmum_groups.R")

# ================================================================================================ #
# Description: Creates datasets with children's data along with the mothers' cluster IDs
#
# Input: 
# <schema>.[si_child_cohort_modelling]
# res.kmeans.mum
# res.kmeans.child
#
# Output: 
# final_child_dataset = dataframe with child information and mum's cluster ids
# final_mums_dataset = dataframe with mum's information and children's cluster ids
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
# 11 Aug 2017 VB  V1 
# ================================================================================================ #

dataset <- SIAtoolbox::read_sql_table("select snz_uid, mum_id from [DL-MAA2016-15].[si_child_cohort_modelling] ", 
                                      connstr, string = TRUE)
dataset <- dataset %>% mutate(snz_uid = factor(snz_uid), mum_id = factor(mum_id)) 

final_child_dataset <- res.kmeans.child %>% inner_join(dataset, by = "snz_uid") %>% 
  inner_join(res.kmeans.mum %>% 
               select(one_of("snz_uid", names(res.kmeans.mum[, grepl("X", names(res.kmeans.mum))]) )) , 
             by = c("mum_id" = "snz_uid"), suffix = c(".child", ".mum") )

final_mums_dataset <- res.kmeans.mum %>% 
  inner_join(dataset, by = c("snz_uid" = "mum_id"), suffix = c(".mum", ".child") ) %>% 
  inner_join(res.kmeans.child %>% 
               select(one_of("snz_uid", names(res.kmeans.child[, grepl("X", names(res.kmeans.child))]) )) , 
             by = c("snz_uid.child" = "snz_uid"), suffix = c(".mum", ".child") )

rm(dataset)

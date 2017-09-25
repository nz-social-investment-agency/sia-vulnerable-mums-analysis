## ===================================================================== ##
##
## Purpose: Apply clustering on the dataset to identify natural groupings 
##  in the mothers dataset. This will enable us to look at groups that
##  seem to be at risk of bad outcomes resulting from birth event, and 
##  design services that cater to each homogeneous group.
##
##  Here we will try non-hierarchical algorithms for clustering:
##  1. K-medoids using Manhattan distance (given non-Euclidean nature of 
##    binary variables)
##  2. K-means with Euclidean distance (treating binary variables as numeric)
##
##  Then we will try different algorithms for agglomerative clustering:
##  1. Fast clustering with scaled data, using Eucildean distance with Ward for 
##    agglomeration(ignoring factors and treating binaries as numeric)
##
## Input: 
## mothers_imputed, mothers_imputed_scaled
##
## Output: 
## analysis_dataset = dataset with cluster ids.
## Descriptive stats on clusters
##
## Author: V Benny
## Date: 11/08/2017
## Modified:     
## Review: 
## Version History
##  11 Aug 2017 VB  v1
## ===================================================================== ##


################################ K-Medoids Clustering ################################

# Clustering on randomly drawn samples (with replacement) with manhattan distance and K-medoids
# Parallel execution, with number of clusters from 2 to 15

# Convert factors into binary variables
mothers_imputed_bin <- as.data.frame( model.matrix(~., data=mothers_imputed %>% select(-one_of(idcol_mum)) ) )[, -1]

# Set up clustering parameters
numclust <- c(2:15)
cl <- makeCluster(10) # Use judiciously
silavgwidth_mum <- c(NA)
clustervals <- data.frame(matrix(NA, nrow(mothers_imputed), length(numclust) ))
silwidths <- data.frame(matrix(NA, max(numclust), length(numclust) ))

# Run clustering
registerDoParallel(cl)
res.clara <- foreach(i = numclust, .packages= c('cluster', 'dplyr'), .options.RNG = seedval) %dorng% {
  clara.fit <- clara( mothers_imputed_bin, 
                      k = i, metric = "manhattan", samples = 10, sampsize = 10000, stand = TRUE, 
                      trace = 3, pamLike= TRUE)
  
  templist <- list(clara.fit$clustering, clara.fit$silinfo$clus.avg.widths,clara.fit$silinfo$avg.width)
}
stopCluster(cl)

# Gather and save results
for(i in seq_along(numclust)){
  clustervals[, i] <- data.frame(res.clara[[i]][[1]])[1]
  silwidths[1:numclust[i], i] <- data.frame(res.clara[[i]][[2]])
  silavgwidth_mum[i] <- res.clara[[i]][[3]]
}

# Get the cluster IDs into the dataset for analysis and write summaries into the database
res.kmedoids.mum <- cbind(mothers_imputed, clustervals)
clusterStats(res.kmedoids.mum, names(clustervals), c(numcols_mum, intcols_mum), 
             "../output/kmedoids_mum_clustering_output.xlsx", silwidths)

# Remove unwanted objects
rm(mothers_imputed_bin)

################################ K-Means Clustering ################################
# Kmeans clustering using kproto
# Number of clusters to try out
numclust <- c(2:15)

cl <- makeCluster(10)
tot_withinss <- c(NA)
clustervals <- data.frame(matrix(NA, nrow(mothers_imputed), length(numclust) ))
withinss <- data.frame(matrix(NA, max(numclust), length(numclust) ))
lambdaestval <- lambdaest(mothers_imputed_scaled %>% select(-snz_uid))

# Weight the important risk factor variables if required, to reorient the clustering around these variables

# Run parallel iterations for clustering
registerDoParallel(cl)
res.kmeans.mum <- foreach(i = seq_along(numclust), .combine=cbind, .packages= c('clustMixType', 'dplyr'), 
                          .options.RNG = seedval) %dorng% {
  kproto.fit <- kproto(x = mothers_imputed_scaled %>% select(-one_of(idcol_mum)), 
                       k=numclust[i], lambda=lambdaestval, iter.max=100, trace=TRUE, nstart = 2)
  templist <- list( data.frame(kproto.fit$cluster), data.frame(kproto.fit$withinss), data.frame(kproto.fit$tot.withinss ))
}
stopCluster(cl)

# Gather and save results
for(i in seq_along(numclust)){
  clustervals[, i] <- data.frame(res.kmeans.mum[1, i])
  withinss[1:numclust[i], i] <- data.frame(res.kmeans.mum[2, i])
  tot_withinss[i] <- data.frame( res.kmeans.mum[3, i] )[1,1]
}

# Get the cluster IDs into the dataset for analysis and write summaries into the database
res.kmeans.mum <- cbind(mothers_imputed_scaled, clustervals)
clusterStats(res.kmeans.mum, names(clustervals), c(numcols_mum, intcols_mum), 
             "../output/kmeans_mum_clustering_output.xlsx", withinss)


################################ Hierarchical Clustering ################################

# Try a Hierarchical clustering using fastcluster with Euclidean distance measure for distance and Ward.D2 for agglomeration
res.hclust.mum <- fastcluster::hclust( 
  d = dist(mothers_imputed_scaled[, names(mothers_imputed_scaled) %in% c(numcols_mum, intcols_mum)]), 
  method = "ward.D2")
plot(res.hclust.mum)

# Based on the output of hierarchical clustering, try out meaningful cluster numbers
hclust_dataset <- mothers_imputed_scaled
write.xlsx(c("Description"), file="../output/hclust_mum_clustering_output.xlsx", 
           sheetName="Note to Stats")
nbclust <- c(2:15)
for (nc in nbclust){
  clustercut <- cutree(res.hclust.mum, k = nc)
  hclust_dataset[, paste0("clustnum_",nc)] <- clustercut
  hclust_num_means <- hclust_dataset %>% select(one_of(numcols_mum, intcols_mum), paste0("clustnum_",nc) ) %>%
    group_by_(paste0("clustnum_",nc) ) %>% summarise_all(funs(mean)) %>% select_( .dots = c(numcols_mum, intcols_mum) )
  write.xlsx(hclust_num_means, file="../output/hclust_mum_clustering_output.xlsx", 
             sheetName=paste0("clustnum_",nc), append=TRUE)
}


################################ Cluster Output ################################
# After looking at clusters statistics and plots, output of Kmeans with Euclidean 
# distance with 6 clusters seem to be the ideal point, with a sharp drop in 
# within sum-of-squares and meaningful cluster groupings in terms of business rules.

# Create final dataset with cluster IDs for analysis
# The objective is to analyse how clusters 1, 4 and 5 differ from 2, 3 and 6
analysis_data <- res.kmeans.mum %>% 
  select(one_of(idcol_mum, intcols_mum, numcols_mum, catcols_mum, "X5") ) %>%
  mutate(
    # target_grp = ifelse(X5 %in% c(2,3,6), 0, 1),
    target_grp = relevel(as.factor(X5), ref = "6")
    ) %>%
  select(-one_of("X5", idcol_mum))



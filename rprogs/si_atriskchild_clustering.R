## ===================================================================== ##
##
## Purpose: Apply clustering on the dataset to identify natural groupings 
##  in the children dataset. This will enable us to look at groups that
##  seem to be at risk of bad outcomes.
##
##  Here we will try non-hierarchical algorithms for clustering:
##  1. K-medoids using Manhattan distance (given non-Euclidean nature of 
##    binary variables)
##  2. K-means with Euclidean distance (treating binary variables as numeric)
##
## Input: 
## children_imputed, children_imputed_scaled
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

# Convert factors into binary variables
children_imputed_bin <- as.data.frame( model.matrix(~., data=children_imputed %>% select(-one_of(idcol_child) ) ) )[, -1]

# Parallel execution, with number of clusters from 2 to 15
numclust <- c(2:15)
cl <- makeCluster(10) # Use judiciously
silavgwidth_child <- c(NA)
clustervals <- data.frame(matrix(NA, nrow(children_imputed), length(numclust) ))
silwidths <- data.frame(matrix(NA, max(numclust), length(numclust) ))

# Run clustering
registerDoParallel(cl)
res.clara <- foreach(i = numclust, .packages= c('cluster', 'dplyr'), .options.RNG = seedval) %dorng% {
  clara.fit <- clara( children_imputed_bin , 
                      k = i, metric = "manhattan", samples = 10, sampsize = 10000, stand = TRUE, 
                      trace = 3, pamLike= TRUE)
  
  templist <- list(clara.fit$clustering, clara.fit$silinfo$clus.avg.widths,clara.fit$silinfo$avg.width)
}
stopCluster(cl)

# Gather and save results
for(i in seq_along(numclust)){
  clustervals[, i] <- data.frame(res.clara[[i]][[1]])[1]
  silwidths[1:numclust[i], i] <- data.frame(res.clara[[i]][[2]])
  silavgwidth_child[i] <- res.clara[[i]][[3]]
}

# Get the cluster IDs into the dataset for analysis and write summaries into the database
res.kmedoids.child <- cbind(children_imputed, clustervals)
clusterStats(res.kmedoids.child, names(clustervals), c(numcols_child, intcols_child), 
             "../output/kmedoids_child_clustering_output.xlsx", silwidths)


# finding a way to select the best number of matrix based on the sum of squares
len_sil <- length(silavgwidth_child)+1
dat_sil <- data.frame(SS=silavgwidth_child, cluster=c(2:len_sil))
ggplot(data=dat_sil,aes(x=cluster,y=SS)) + geom_bar(stat="identity") + xlab("Cluster") + ylab("Avg Ridge Score")
ggsave("../output/plots/children_kmedoid.png", device = "png", width = 16, height = 8, units = "in")


# Remove unwanted objects
rm(children_imputed_bin, len_sil, dat_sil)

################################ K-Means Clustering ################################
# Kmeans clustering using kproto
# Number of clusters to try out
numclust <- c(2:15)

cl <- makeCluster(10)
tot_withinss <- c(NA)
clustervals <- data.frame(matrix(NA, nrow(children_imputed), length(numclust) ))
withinss <- data.frame(matrix(NA, max(numclust), length(numclust) ))

registerDoParallel(cl)
res.kmeans.child <- foreach(i = seq_along(numclust), .combine=cbind, .packages= c('clustMixType', 'dplyr'), 
                            .options.RNG = seedval) %dorng% {
  kproto.fit <- kproto(x = children_imputed_scaled %>% select(-one_of(idcol_child)), k=numclust[i], lambda=1, iter.max=100, 
                       trace=TRUE)
  templist <- list( data.frame(kproto.fit$cluster), data.frame(kproto.fit$withinss), data.frame(kproto.fit$tot.withinss ))
}
stopCluster(cl)

# Gather and save results
for(i in seq_along(numclust)){
  clustervals[, i] <- data.frame(res.kmeans.child[1, i])
  withinss[1:numclust[i], i] <- data.frame(res.kmeans.child[2, i])
  tot_withinss[i] <- data.frame( res.kmeans.child[3, i] )[1,1]
}

# Get the cluster IDs into the dataset for analysis and write summaries into the database
res.kmeans.child <- cbind(children_imputed_scaled, clustervals)
clusterStats(res.kmeans.child, names(clustervals), c(numcols_child, intcols_child), 
             "../output/kmeans_child_clustering_output.xlsx", withinss)


# finding a way to select the best number of clusters based on averages based on the sum of squares
len=length(tot_withinss)+1
dat=data.frame(SS=tot_withinss, cluster=c(2:len))
ggplot(data=dat,aes(x=cluster,y=SS)) + geom_bar(stat="identity") + xlab("Cluster") + ylab("Sum of Squares")
ggsave("../output/plots/children_kmeans_SS.png", device = "png", width = 16, height = 8, units = "in")




################################ Cluster Output ################################
# After looking at clusters statistics and plots, output of Kmeans with Euclidean 
# distance with 6 clusters seem to be the ideal point, with a sharp drop in 
# within sum-of-squares and meaningful cluster groupings in terms of business rules.

# Create final dataset with cluster IDs for analysis
analysis_data <- res.kmeans.child %>% 
  select(one_of(idcol_child, intcols_child,numcols_child, catcols_child, "X5") ) %>%
  mutate(target_grp = as.factor(X5) ) %>%
  select(-one_of("X5", idcol_child))





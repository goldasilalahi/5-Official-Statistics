# Load required libraries
library(psych)
library(stats)
library(mclust)
library(cluster)
library(factoextra)
library(readxl)
library(car)
library(clusterCrit)
library(clusterSim)
library(corrplot)
library(RColorBrewer)
library(dplyr)
library(reshape2)
library(pheatmap)

# Import data
data <- read_excel("/Users/Golda/College/sem 5/offstat/data offstat.xlsx")
data_numeric <- data[, -1]
data_scaled <- scale(data_numeric)

# Boxplot of Data
boxplot(data_scaled,
        col = brewer.pal(ncol(data_scaled), "Set3"),
        main = "Boxplot Indikator Ketahanan Pangan Indonesia Tahun 2021",
        las = 2)

# Heatmap Korelasi
cor_matrix <- cor(data_scaled)
cor_melted <- melt(cor_matrix)
ggplot(cor_melted, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.2f", value)), color = "white", size = 3) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(angle = 0)) +
  labs(title = "Heatmap Korelasi Variabel", x = "", y = "")

# KMO Test
kmo_result <- KMO(data_scaled)
print(kmo_result)

# Hierarchical Clustering
sil_hc <- fviz_nbclust(data_scaled, FUN = hcut, method = "silhouette", k.max = 10)
print(sil_hc)

d <- dist(data_scaled, method = "euclidean")
hc <- hclust(d, method = "ward.D2")
plot(hc, main = "Dendrogram untuk Hierarchical Clustering", xlab = "", sub = "")

k_hc <- 2
cutree_hc <- cutree(hc, k = k_hc)
data$cluster_hc <- cutree_hc

fviz_cluster(list(data = data_scaled, cluster = cutree_hc),
             ellipse.type = "convex",
             geom = "point",
             stand = FALSE,
             main = "Hierarchical Clustering Visualization",
             palette = "jco")

# Gaussian Mixture Model (GMM)
bic_gmm <- Mclust(data_scaled)
plot(bic_gmm, "BIC")
title(main = "Optimal Cluster Number (BIC Method for GMM)")

k_gmm <- bic_gmm$G
gmm_model <- Mclust(data_scaled, G = k_gmm)
data$cluster_gmm <- gmm_model$classification

fviz_cluster(list(data = data_scaled, cluster = gmm_model$classification),
             ellipse.type = "convex",
             geom = "point",
             stand = FALSE,
             main = "Gaussian Mixture Model (GMM) Clustering Visualization",
             palette = "jco")

# Evaluate Clustering
# Silhouette Plot
silhouette_hc <- silhouette(cutree_hc, d)
silhouette_gmm <- silhouette(as.numeric(gmm_model$classification), dist(data_scaled))

fviz_silhouette(silhouette_hc, main = "Silhouette Plot untuk Hierarchical Clustering")
fviz_silhouette(silhouette_gmm, main = "Silhouette Plot untuk Gaussian Mixture Model")

# Davies-Bouldin Index
db_index_hc <- intCriteria(as.matrix(data_scaled), as.integer(cutree_hc), "Davies_Bouldin")
db_index_gmm <- intCriteria(as.matrix(data_scaled), as.integer(gmm_model$classification), "Davies_Bouldin")

cat("Davies-Bouldin Index untuk Hierarchical Clustering:", db_index_hc$davies_bouldin, "\n")
cat("Davies-Bouldin Index untuk GMM:", db_index_gmm$davies_bouldin, "\n")

# Dunn Index
dunn_index_hc <- index.G1(data_scaled, cutree_hc, d)
dunn_index_gmm <- index.G1(data_scaled, gmm_model$classification, dist(data_scaled))

cat("Dunn Index untuk Hierarchical Clustering:", dunn_index_hc, "\n")
cat("Dunn Index untuk GMM:", dunn_index_gmm, "\n")

# Separation Index
calculate_separation_index <- function(data, clusters) {
  cluster_centers <- aggregate(data, by = list(clusters), FUN = mean)[-1]
  n_clusters <- nrow(cluster_centers)
  
  within_cluster_distances <- sapply(unique(clusters), function(cluster) {
    members <- data[clusters == cluster, ]
    cluster_center <- cluster_centers[cluster, ]
    mean(rowSums((members - cluster_center)^2))
  })
  
  between_cluster_distances <- combn(1:n_clusters, 2, function(pair) {
    sum((cluster_centers[pair[1], ] - cluster_centers[pair[2], ])^2)
  })
  
  mean(within_cluster_distances) / mean(between_cluster_distances)
}

sep_index_hc <- calculate_separation_index(data_scaled, cutree_hc)
sep_index_gmm <- calculate_separation_index(data_scaled, gmm_model$classification)

cat("Separation Index untuk Hierarchical Clustering:", sep_index_hc, "\n")
cat("Separation Index untuk GMM:", sep_index_gmm, "\n")

# SW/SB Ratio
calculate_sw_sb_ratio <- function(data, clusters) {
  cluster_centers <- aggregate(data, by = list(clusters), FUN = mean)[-1]
  global_center <- colMeans(data)
  
  sw <- sum(sapply(unique(clusters), function(cluster) {
    members <- data[clusters == cluster, ]
    sum(rowSums((members - cluster_centers[cluster, ])^2))
  }))
  
  sb <- sum(sapply(unique(clusters), function(cluster) {
    size <- sum(clusters == cluster)
    sum((cluster_centers[cluster, ] - global_center)^2) * size
  }))
  
  sw / sb
}

sw_sb_hc <- calculate_sw_sb_ratio(data_scaled, cutree_hc)
sw_sb_gmm <- calculate_sw_sb_ratio(data_scaled, gmm_model$classification)

cat("SW/SB Ratio untuk Hierarchical Clustering:", sw_sb_hc, "\n")
cat("SW/SB Ratio untuk GMM:", sw_sb_gmm, "\n")

# Average Silhouette Coefficient
avg_silhouette_hc <- mean(silhouette_hc[, 3])
avg_silhouette_gmm <- mean(silhouette_gmm[, 3])

cat("Rata-rata Silhouette Coefficient untuk Hierarchical Clustering:", avg_silhouette_hc, "\n")
cat("Rata-rata Silhouette Coefficient untuk Gaussian Mixture Model:", avg_silhouette_gmm, "\n")
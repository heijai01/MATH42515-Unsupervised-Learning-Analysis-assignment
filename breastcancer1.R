library(naniar)
library(visdat)
library(mice)
library(ggplot2)
library(reshape2)
library(corrplot)
library(factoextra)
library(dplyr)
library(mclust)
library(cluster)
df <- read.csv("C:/Users/cheng/Desktop/durham mds/data visualisation/breastcancer.csv")

# remove the X name column
df <- df[,-1]

str(df)
head(df)
summary(df)

# dealing with missing data
gg_miss_var(df, show_pct = TRUE) # about 50% of texture_mean and 13% of smoothness_mean missing
vis_dat(df) 
md.pattern(df)

df$texture_mean <- NULL # removing column texture_mean
df$smoothness_mean[is.na(df$smoothness_mean)] <- mean(df$smoothness_mean, na.rm = TRUE) # mean imputation
# Mean imputation is adopted. This approach is simple, preserves the overall distribution of the variable, and is appropriate for downstream techniques such as PCA and clustering. 
# More complex methods such as regression or multiple imputation were not considered necessary given the relatively small proportion of missing values.
# While mean imputation may reduce variance, this limitation is not critical in this context as the analysis focuses on structure rather than statistical inference.

# histogram
df_long <- melt(df)
ggplot(df_long, aes(x = value)) +
  geom_histogram(
    bins = 30,
    fill = "steelblue",
    color = "white",
    alpha = 0.9
  ) +
  facet_wrap(~variable, scales = "free", ncol = 3) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 8)
  ) +
  labs(
    title = "Distribution of Variables",
    x = "Value",
    y = "Frequency"
  )

# kde 
ggplot(df_long, aes(x = value)) +
  geom_histogram(aes(y = ..density..),
                 bins = 30,
                 fill = "steelblue",
                 color = "white",
                 alpha = 0.7) +
  geom_density(color = "red", size = 0.6) +
  facet_wrap(~variable, scales = "free", ncol = 3) +
  theme_minimal() +   theme(
    strip.text = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 8)
  ) +
  labs(
    title = "Distribution of Variables",
    x = "Value",
    y = "Frequency"
  )
# variables such as perimeter_mean, area_mean, compactness_mean, concavity_mean etc right skewed
# radius_mean(slight right skewed), symmetry, smoothness(might be due to mean imputation) more symmetric

# boxplot
ggplot(df_long, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot(alpha = 0.8, outlier.colour = "black") +
  scale_fill_brewer(palette = "Set2") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Boxplot of Variables",
    x = "",
    y = "Value"
  ) +
  guides(fill = "none")     # hard to see, might need standardisation

df_scaled <- scale(df)
df_scaled <- as.data.frame(df_scaled)
df_scaled_long <- melt(df_scaled)
ggplot(df_scaled_long, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Boxplot of Standardised Variables",
    x = "",
    y = "Scaled Values"
  ) +
  guides(fill = "none")  # outliers present in all variables

# correlation
pairs(df) # messy to look it, not used

round(cor(df),3)
corrplot(cor(df), cl.cex=0.8, tl.col="black", tl.cex=0.9, tl.srt=45)

S
# pca

# before coding, mean imputation before might slightly reduce variance and weaken correlation. but since its only 13% it should be fine

pca <-prcomp(df_scaled)
summary(pca)
fviz_eig(pca, addlabels = TRUE) # scree plot
fviz_pca_ind(pca, label = "none") # spread mainly along pc1, no clear cluster, dense central region, some extreme points
pca$rotation
# PC1 is mainly driven by radius_mean, perimeter_mean, area_mean, concavity_mean, and concave_points_mean 
# → represents overall nuclear size and boundary irregularity
# PC2 is influenced by smoothness_mean, symmetry_mean, and fractal_dimension_mean
# → represents variation in nuclear texture and structural complexity

fviz_pca_biplot(pca,
                label = "var",
                col.var = "red",
                col.ind = "grey80",
                alpha.ind = 0.3,
                pointsize = 1,
                repel = TRUE)
# Biplot shows that radius, perimeter, and area are strongly aligned,
# indicating high correlation and contribution to overall nuclear size (PC1).
# Concavity and concave_points follow a similar direction (boundary irregularity),
# while smoothness, symmetry, and fractal_dimension relate more to PC2(texture/complexity).


# k-mean

df_pca <- pca$x[,1:2]
fviz_nbclust(df_pca, kmeans, method = "wss") +
  ggtitle("Elbow Method for Optimal k")
fviz_nbclust(df_pca, kmeans, method = "silhouette")
# pick k = 2
set.seed(123)
km2 <- kmeans(df_pca, centers = 2, nstart = 25)
fviz_cluster(km2, data = df_pca, geom = "point", ellipse.type = "convex", palette="jco")
km2

# Add cluster labels back to original data
df$km_cluster <- km2$cluster

# Examine cluster characteristics
aggregate(df, by = list(cluster = df$km_cluster), mean)

# gmm
gmm_res <-Mclust(df_pca)
summary(gmm_res)

gmm_cluster <- gmm_res$classification
table(gmm_cluster)

fviz_cluster(list(data = df_pca, cluster = gmm_cluster),
             geom = "point",
             ellipse.type = "norm",
             palette = "jco",
             main = "GMM clustering")

plot(gmm_res, what = "uncertainty")
summary(gmm_res$uncertainty)
plot(gmm_res, what="classification")
plot(gmm_res, what = "density")
plot(gmm_res, what = "BIC")
gmm_res$BIC

df$gmm_cluster <- gmm_cluster
aggregate(df, by = list(cluster = df$gmm_cluster), mean)


# silhouette comparison of 2 model
sil_km <- silhouette(km2$cluster, dist(df_pca))
mean(sil_km[,3])
sil_gmm <- silhouette(gmm_cluster, dist(df_pca))
mean(sil_gmm[,3])

# Cluster sizes comparison
table(km2$cluster)
table(gmm_cluster)



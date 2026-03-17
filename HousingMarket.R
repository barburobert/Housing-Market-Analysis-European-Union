# Project: Housing Market Analysis across NUTS 2 Regions (2022)
# Author: Robert Barbu

# This project examines regional differences in the housing market
# Variables included in the analysis:

# X1  Population density                         Persons per square kilometre
# X2  At-risk-of-poverty rate                   Percent
# X3  Mortgage credit interest rate             Percent
# X4  Housing cost overburden rate              Percent
# X5  Arrears                                   Percent
# X6  Employment rates                          Percent
# X7  Income of households net of taxes         Euro
# X8  Heating degree days                       Days
# X9  Cooling degree days                       Days
# X10 SBS data                                  Number of local units constructed

### 1. Set path -----
setwd("D:/aplicatii robert/Analiza Datelor - CIBE")

### 2. Data import----

X <- read.table(
  file = "ALLDATA.txt",
  sep = "\t",
  header = TRUE,
  dec = ".",
  row.names = 1
)

str(X)
dim(X)
names(X)
head(X)
summary(X)

### 3. Outlier removal----
# Outliers are removed using the IQR rule.

remove_outliers <- function(df) {
  df_num <- df[, sapply(df, is.numeric)]
  for (col in names(df_num)) {
    Q1 <- quantile(df_num[[col]], 0.25, na.rm = TRUE)
    Q3 <- quantile(df_num[[col]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    lower <- Q1 - 1.5 * IQR
    upper <- Q3 + 1.5 * IQR
    df <- df[df[[col]] >= lower & df[[col]] <= upper, ]
  }
  return(df)
}

X_clean <- remove_outliers(X)
X <- X_clean


### 4. Descriptive statistics ----

# coefficient of variation function
cv <- function(x) {
  return(sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE) * 100)
}

# Select only numeric variables
X_numeric <- X_clean[, sapply(X, is.numeric), drop = FALSE]

# Compute descriptive measures
means <- apply(X_numeric, 2, mean, na.rm = TRUE)
sds <- apply(X_numeric, 2, sd, na.rm = TRUE)
quantiles <- apply(X_numeric, 2, quantile, na.rm = TRUE)
coeff_var <- apply(X_numeric, 2, cv)

# Combine main descriptive statistics into one table
descriptive_stats <- data.frame(
  Variable = names(X_numeric),
  Mean = means,
  Standard_Deviation = sds,
  Coefficient_of_Variation = coeff_var,
  row.names = NULL
)

print(descriptive_stats)
print(quantiles)

#the dataset reveals strong regional heterogeneity, especially in cooling degree days, housing construction activity, population density, and arrears, all of which show very high dispersion across NUTS 2 regions. In contrast, employment rates, household income, and mortgage interest rates appear relatively more stable, suggesting that regional housing market differences are driven mainly by urban concentration, climate-related conditions, and financial stress rather than by labor market variation alone.



### 5. Correlation analysis and graphical representation ----

# Correlation matrix

Corr <- cor(X)
round(Corr, 2)

#install.packages("corrplot")
library(corrplot)

corrplot(Corr, method = "number", type = "upper")
#The strongest patterns are a strong negative correlation between heating and cooling degree days (X8–X9, -0.75), a strong negative link between employment and cooling degree days (X6–X9, -0.68), and a strong negative association between poverty risk and employment (X2–X6, -0.61). At the same time, population density is moderately positively related to household income (X1–X7, 0.54), suggesting that more urbanized regions also tend to be more affluent.

# Graphical representation of 3 variables (X1, X7, X10)

# install.packages("ggplot2")
library(ggplot2)

ggplot(
  data = data.frame(X, Region = rownames(X)),
  aes(x = X1, y = X7, size = X10, label = Region)
) +
  geom_point(shape = 17, color = "black", alpha = 0.8) +
  geom_text(size = 3, vjust = -0.5) +
  labs(
    title = "Simultaneous Representation of Three Variables",
    x = "X1",
    y = "X2",
    size = "X3"
  ) +
  theme_minimal(base_size = 13)
#The chart suggests that denser regions tend to have higher household incomes, while the largest housing construction volumes are concentrated in a limited number of relatively urban and more affluent regions.

# Graphical representation of 4 variables (X1, X7, X10, X4)

ggplot(
  data = data.frame(X, Region = rownames(X)),
  aes(x = X1, y = X7, color = X10, size = X4, label = Region)
) +
  geom_point(alpha = 0.9) +
  geom_text(size = 3, vjust = -0.5, color = "darkred") +
  scale_color_gradient(low = "red", high = "blue") +
  labs(
    title = "Simultaneous Representation of Four Variables",
    x = "X1",
    y = "X2",
    color = "X5 (color)",
    size = "X3 (size)"
  ) +
  theme_minimal(base_size = 13)
#The plot shows that high-income, densely populated regions cluster toward the upper-right area, while higher values of X5 appear scattered rather than concentrated in one clear regional profile.

### 6. Principal Component Analysis (PCA) ----

# PCA is applied to reduce the dimensionality of the dataset and to identify
# the main differences between NUTS 2 regions in the housing market.

# install.packages("FactoMineR")
# install.packages("factoextra")
library(FactoMineR)
library(factoextra)


### 6.1 PCA estimation 
acp <- PCA(X, scale.unit = TRUE, graph = FALSE)

# Eigenvalues and explained variance
acp$eig

# Variable coordinates in the new factor space
round(acp$var$coord, 3)

# Regional coordinates (scores)
round(acp$ind$coord[1:5, ], 3)

### 6.2 Selection of the number of components

#Criterion 1: Kaiser rule - Components with eigenvalues greater than 1 are retained,so k=3
acp$eig

# Criterion 2: Cumulative explained variance, a satisfactory solution usually explains around 70%–80% of total variance,so k=4
acp$eig[, 3]

# Criterion 3: Scree plot, The number of components is also assessed visually, based on the point, where the slope of the eigenvalue curve becomes flatter, so k=4.
fviz_eig(acp)


### 6.3 Interpretation of variables and component naming

# Correlations between original variables and principal components
round(acp$var$coord[, 1], 3)
# DIM1 - Socio-economic well-being
# X2 At-risk-of-poverty rate (-)
# X5 Arrears (-)
# X6 Employment rates (+)
# X7 Income of households (+)
# X8 Heating degree days (+)
# X9 Cooling degree days (-)

round(acp$var$coord[, 2], 3)
# DIM2 - Urban pressure on the housing market
# X1 Population density (+)
# X3 Mortgage interest rate (-)
# X4 Housing cost overburden rate (+)
# X7 Income of households (+)

round(acp$var$coord[, 3], 3)
# DIM3 - Household financial stress
# X4 Housing cost overburden rate (+)
# X5 Arrears (+)
# X10 Housing units constructed (-)

round(acp$var$coord[, 4], 3)
# DIM4 - Housing market dynamics and credit conditions
# X3 Mortgage interest rate (-)
# X5 Arrears (+)
# X10 Housing units constructed (+)

### 6.4 Graphical representation of variables 

# Correlation circle
fviz_pca_var(acp, col.var = "contrib")

# Interpretation:Dim1 mainly contrasts more prosperous regions, with higher income, employment and density, against regions with higher poverty risk, arrears and cooling needs, while Dim2 separates regions under stronger urban and housing-cost pressure from those characterized more by credit conditions and construction activity.


### 6.5 Graphical representation of regions 

# Projection of NUTS 2 regions in the principal component space
fviz_pca_ind(acp)

# Interpretation:The PCA map suggests that several German regions such as DE11, DE12, DE21, DEA3 and DEA5 display the most favorable housing market profiles, combining stronger socio-economic conditions with higher urban pressure, while regions such as ES62, ITG4, ITF4, HR02, HR03, BG34 and BG42 appear more vulnerable, being positioned on the negative side of the first principal component. Czech regions such as CZ02, CZ03, CZ04, CZ05, CZ07 and CZ08 form a distinct group, indicating a different regional housing market structure rather than a purely favorable or unfavorable profile.
### 7. Factor Analysis (FA) ----

# Factor analysis is applied to identify latent dimensions that summarize the main regional differences in housing market conditions across NUTS 2 regions.

X_fa <- X

#install.packages("psych")
#install.packages("nFactors")
library(psych)
library(nFactors)

R <- cor(X_fa)

### 7.1 Testing data suitability for factor analysis 

KMO(R)
# A KMO value around 0.60–0.70 indicates a mediocre but acceptable level
# Based on the KMO results, X3 and X4 are excluded because they show lower sampling adequacy and may weaken the factor structure.
X_fa <- X[, c("X1", "X2", "X5", "X6", "X7", "X8", "X9", "X10")]
R <- cor(X_fa)

cortest.bartlett(R)
# Bartlett’s test is highly significant (p < 0.001), which means that the correlation matrix is not an identity matrix and the variables are sufficiently intercorrelated to justify factor analysis.

### 7.2 Selection of the number of factors 

parallel_analysis <- fa.parallel(X_fa, fm = "pa", fa = "fa")
parallel_analysis

# Interpretation:Parallel analysis suggests retaining three common factors, since only the first three factor eigenvalues from the actual data exceed those obtained from the simulated data. This supports a three-factor solution as the most appropriate structure for summarizing the main regional differences in the housing market.

### 7.3 Initial factor extraction

af <- fa(R, nfactors = 3, n.obs = nrow(X_fa), rotate = "none", fm = "pa")
af
summary(af)

fa.diagram(af)

# Interpretation:The unrotated solution confirms the presence of three common factors, but the structure is still too diffuse for clear economic interpretation. The first factor dominates the model, while the overall fit remains weak, which justifies applying rotation to obtain a more interpretable factor structure.

### 7.4 Rotated factor solution 

af2 <- fa(R, nfactors = 3, n.obs = nrow(X_fa), rotate = "varimax", fm = "pa")
af2
summary(af2)

fa.diagram(af2)
#The rotated three-factor solution is more interpretable, as it separates the common variance into distinct regional dimensions: PA1 is mainly linked to climatic and labour-market conditions, PA2 captures income and urban-economic strength, and PA3 reflects socio-economic vulnerability, especially through poverty risk. Together, the three factors explain about 62% of total variance, confirming that regional housing market differences can be summarized by a limited number of latent structural dimensions.

# Factor loadings
print(af2$loadings, cutoff = 0.3)

# Factor scores
fs <- factor.scores(X_fa, af2)
scores <- fs$scores

### 7.5 Interpretation of the retained factors 

#The rotated factor solution identifies three main latent dimensions of regional housing market differences. 
#PA1 captures climatic and labour-market conditions, 
#PA2 reflects income and urban-economic strength, 
#PA3 measures socio-economic vulnerability through poverty risk and arrears.


### 7.6 Conclusion of the factor analysis 

# Top 10 regions for each factor
head(sort(scores[, "PA1"], decreasing = TRUE), 10)
head(sort(scores[, "PA2"], decreasing = TRUE), 10)
head(sort(scores[, "PA3"], decreasing = TRUE), 10)

# Bottom 10 regions for each factor
head(sort(scores[, "PA1"], decreasing = FALSE), 10)
head(sort(scores[, "PA2"], decreasing = FALSE), 10)
head(sort(scores[, "PA3"], decreasing = FALSE), 10)

#The factor scores are broadly consistent with the PCA results. Regions with the highest PA2 scores, such as DE21, DE11 and DE12, also appeared in the PCA as stronger and more urbanized regional profiles, while regions with high PA3 scores, such as ITF1, BG42 and HR02, confirm the existence of a more vulnerable group characterized by greater socio-economic pressure. Therefore, factor analysis does not contradict PCA, but refines it by separating regional differences into more clearly interpretable latent dimensions.

### 8. Cluster Analysis ----

# Cluster analysis is applied to group NUTS 2 regions with similar housing market profiles, using the factor scores obtained previously.

# Factor scores used in clustering
scores <- fs$scores

### 8.1 Distance matrix 

# Euclidean distance between regions in the factor-score space
d <- dist(scores, method = "euclidean")

### 8.2 Hierarchical clustering 

# Ward method
hc_ward <- hclust(d, method = "ward.D2")
plot(hc_ward, hang = -1, main = "Dendrogram - Ward Method")

rect.hclust(hc_ward, k = 3, border = c("blue", "yellow", "red"))

# Interpretation:The Ward dendrogram indicates a three-cluster structure, with a clearer and more compact separation than the alternative hierarchical methods, supporting the idea that NUTS 2 regions can be grouped into three distinct housing market profiles.

# Centroid method
hc_centroid <- hclust(d, method = "centroid")
plot(hc_centroid, hang = -1, main = "Dendrogram - Centroid Method")

# Interpretation:The centroid method produces a less distinct hierarchical structure, with more gradual merging and weaker visual separation between groups, making it less suitable than Ward’s method for identifying clear regional housing market clusters.

# Single linkage method
hc_single <- hclust(d, method = "single")
plot(hc_single, hang = -1, main = "Dendrogram - Single Linkage")

# Interpretation:The single-linkage dendrogram shows a chaining effect, where regions are added progressively rather than forming compact groups, so it provides the weakest evidence of clearly separated housing market clusters.

### 8.3 Selection of the number of clusters 

#install.packages("NbClust")
library(NbClust)

nc <- NbClust(
  scores,
  distance = "euclidean",
  min.nc = 2,
  max.nc = 7,
  method = "ward.D2",
  index = "all"
)

# Interpretation: The index plot supports a three-cluster solution, as the main break appears at k = 3 and the gain from adding further clusters becomes much smaller afterward.

### 8.4 Hierarchical clustering solution with 3 clusters 

solutie3 <- cutree(hc_ward, k = 3)

table(solutie3)
aggregate(scores, list(solutie3), mean)

# Interpretation:The three-cluster solution is moderately balanced and reveals three distinct regional profiles: Cluster 1 groups relatively stronger regions with positive income and urban-economic scores, Cluster 2 captures weaker regions with clearly negative scores on that same dimension, while Cluster 3 is defined mainly by a very strong PA1 profile, indicating a distinct climatic and labour-market pattern rather than a purely favorable or unfavorable housing market position.

### 8.5 Cluster quality assessment 

#install.packages("cluster")
library(cluster)

sil <- silhouette(solutie3, d)
plot(sil, main = "Silhouette Plot")

mean(sil[, 3])

# Interpretation:The average silhouette width indicates a moderate clustering quality, meaning that the three-cluster solution is acceptable but not very sharp. Cluster 1 is the best defined, Cluster 2 is reasonably separated, while Cluster 3 is the weakest and appears more heterogeneous or closer to neighboring groups.

### 8.6 K-means clustering ----

set.seed(123)

km <- kmeans(scores, 3)
km
km$size
km$centers

# Interpretation:The k-means solution also supports a three-cluster structure

### 8.7 Decomposition of variability ----

km$totss
km$withinss
km$betweenss
sum(km$withinss)

# Interpretation:The k-means decomposition shows that about 47.7% of total variance is explained by differences between clusters, indicating a moderate but meaningful degree of separation. The remaining variation is still within clusters, so the regional groups are distinct, but not sharply homogeneous.

### 8.8 Distances between clusters ----

centers <- km$centers
dist_centroids <- dist(centers, method = "euclidean")
dist_centroids

# Interpretation:The centroid distances confirm that Cluster 2 is the most distinct group, especially relative to Cluster 3, while Clusters 1 and 3 are closer to each other.


### 8.9 Conclusion of the cluster analysis ----

#The cluster analysis shows that NUTS 2 regions can be grouped into three broad housing market profiles.
#The first cluster includes stronger urban-economic regions. 
#the second captures weaker and more peripheral regions.
#third reflects a distinct climatic and labour-market profile rather than a purely favorable or unfavorable economic position.

cluster_regions <- data.frame(
  Region = names(solutie3),
  Cluster = solutie3
)

cluster_regions[cluster_regions$Cluster == 1, ]
cluster_regions[cluster_regions$Cluster == 2, ]
cluster_regions[cluster_regions$Cluster == 3, ]

#The cluster analysis identifies three distinct regional housing market profiles. Cluster 1 includes mainly German, Belgian and Scandinavian regions and reflects the most favorable urban-economic profile. Cluster 2 groups relatively weaker or more peripheral regions, especially from Eastern and Central Europe. Cluster 3 is composed primarily of Southern European regions from Spain, Italy and Portugal, and stands out through a distinct climatic and labour-market structure rather than a purely stronger or weaker economic position.

### Main conclusion ----
#Overall, the analysis shows that NUTS 2 regions do not share a single housing market pattern. A first broad group consists mainly of German, Belgian and Scandinavian regions, which appear more economically robust and urbanly stronger, a second group includes more peripheral and less advantaged regions from Eastern and parts of Central Europe, while a third group is formed largely by Southern European regions, especially from Spain, Italy and Portugal, whose housing market profile is shaped more strongly by climatic and labour-market conditions. The main idea is that regional housing market differences in 2022 were structural and persistent, reflecting broader territorial inequalities in income, urban development, vulnerability, and local economic context.
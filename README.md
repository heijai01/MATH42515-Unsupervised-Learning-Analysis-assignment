#  Breast Cancer Clustering Analysis 

##  Overview
This project applies unsupervised learning techniques to explore patterns in breast cancer data. The aim is to identify natural groupings of tumour characteristics without using class labels.
This project was completed an assignment of the MATH42515 Data Exploration, Visualization, and Unsupervised Learning at Durham University.

The analysis includes:
- Exploratory Data Analysis (EDA)
- Missing data handling
- Principal Component Analysis (PCA)
- Clustering using K-means and Gaussian Mixture Models (GMM)

---



##  Dataset
The dataset contains features describing characteristics of cell nuclei, including:
- Size-related features (radius, perimeter, area)
- Texture features (smoothness, symmetry)
- Shape irregularity (concavity, concave points)

Missing data was handled by:
- Removing variables with high missingness
- Applying mean imputation for low levels of missing data

---

##  Methodology

### 1. Exploratory Data Analysis
- Distribution analysis using histograms and density plots  
- Correlation analysis to identify redundancy  
- Identification of skewness and outliers  

### 2. Dimension Reduction (PCA)
- Data standardised prior to PCA  
- Scree plot used to determine number of components  
- First two principal components retained for clustering  
- Interpretation:
  - **PC1** → tumour size and boundary irregularity  
  - **PC2** → texture and structural complexity  

### 3. Clustering

#### K-means
- Distance-based clustering  
- Optimal number of clusters determined using elbow and silhouette methods  

#### Gaussian Mixture Model (GMM)
- Probabilistic clustering approach  
- Allows elliptical cluster shapes and soft assignments  
- Model selection based on BIC  

---

##  Results
- Both methods identify a consistent two-cluster structure 
- K-means achieves a higher silhouette score (stronger separation)  
- GMM captures more flexible cluster shapes and overlapping structure  




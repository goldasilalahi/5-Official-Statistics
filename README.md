# 5-Official-Statistics

## Clustering Food Security Indicators in Indonesia Using Hierarchical and Gaussian Mixture Models
This project analyzes food security indicators across 34 provinces in Indonesia for 2021. Clustering methods such as Hierarchical Clustering and Gaussian Mixture Models (GMM) are applied to group provinces based on key dimensions of food security: availability, access, and utilization. The findings aim to inform targeted policy interventions for improving food security.

## Key Methods
1. **Data Preprocessing**:
   - Standardization of variables (e.g., calorie consumption, stunting prevalence).
   - Correlation analysis to check multicollinearity.
2. **Clustering Techniques**:
   - **Hierarchical Clustering**:
     - Optimal number of clusters determined by silhouette scores.
     - Dendrograms to visualize clustering results.
   - **Gaussian Mixture Models (GMM)**:
     - Optimal clusters identified using Bayesian Information Criterion (BIC).
3. **Cluster Evaluation**:
   - Metrics: Silhouette Coefficient, Davies-Bouldin Index, and Dunn Index.
   - Separation Index and SW/SB Ratios to assess cluster validity.

## Output/Insights
- Hierarchical Clustering identified 2 clusters, highlighting disparities between regions with higher and lower food security.
- GMM identified 4 clusters:
  1. **High Food Security**: Provinces like DKI Jakarta and Bali.
  2. **Vulnerable**: Regions such as Papua Barat and Nusa Tenggara Timur.
  3. **Moderate Security**: Java provinces with significant agricultural output.
  4. **Unique Case**: Papua, with distinct challenges due to geography and infrastructure.
- Results highlight urban-rural disparities and regional gaps in food availability and access.

## Data Source
- Food security indicators from [Badan Pusat Statistik (BPS)](https://www.bps.go.id/) and related publications.

## Tools
- R

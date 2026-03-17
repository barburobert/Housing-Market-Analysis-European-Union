# Housing-Market-Analysis-European-Union, 
## NUTS 2 Regions

## Overview

This project examines regional differences in the housing market across NUTS 2 regions in 2022. The analysis combines descriptive statistics, Principal Component Analysis (PCA), factor analysis, and cluster analysis in order to identify the main structural dimensions of regional housing market variation and to group regions with similar profiles.

The results show that the regional housing market is strongly heterogeneous. Some regions display stronger urban-economic profiles, others are more peripheral and less advantaged, while a distinct Southern European group stands out through climatic and labour-market characteristics.

## Objective

The main objective of the project is to highlight regional disparities in the 2022 data housing market and to determine whether these differences can be summarized into a smaller number of structural dimensions and regional profiles.

More specifically, the analysis aims to:

- describe the statistical variation of the selected indicators across NUTS 2 regions
- identify the main dimensions underlying regional housing market differences
- detect latent factors shaping the regional structure of the housing market
- group regions into clusters with similar socio-economic and housing-related characteristics

## Dataset

The dataset was compiled using regional indicators collected from Eurostat for the year 2022, at the NUTS 2 level. The selected variables describe housing market conditions, socio-economic performance, and climatic context across European regions.

Initial variables and measurement units:

- `X1` – Population density (persons per square kilometre)
- `X2` – At-risk-of-poverty rate (%)
- `X3` – Mortgage credit interest rate (%)
- `X4` – Housing cost overburden rate (%)
- `X5` – Arrears (mortgage/rent, utility bills or hire purchase) (%)
- `X6` – Employment rates (%)
- `X7` – Income of households net of taxes (euro)
- `X8` – Heating degree days (days)
- `X9` – Cooling degree days (days)
- `X10` – Local units constructed (number)

## Methods

### 1. Descriptive statistics
The first stage of the analysis summarizes the main characteristics of the dataset using:
- means
- standard deviations
- coefficients of variation
- quantiles
- correlation analysis
- graphical representations of multiple variables

This stage shows substantial regional heterogeneity, especially in population density, arrears, cooling degree days, and housing construction activity.

### 2. Principal Component Analysis (PCA)
PCA is used to reduce dimensionality and identify the main directions of regional differentiation.

The retained principal components highlight:
- socio-economic well-being
- urban pressure on the housing market
- household financial stress
- housing market dynamics and credit conditions

PCA confirms that regional housing market differences are structured and persistent rather than random.

### 3. Factor analysis
Factor analysis complements PCA by identifying latent dimensions behind the observed indicators.

After testing data suitability with the KMO measure and Bartlett’s test, a three-factor solution was retained. The rotated solution suggests three broad latent dimensions:
- climatic and labour-market conditions
- income and urban-economic strength
- socio-economic vulnerability

### 4. Cluster analysis
Cluster analysis is applied to the factor scores in order to classify NUTS 2 regions into homogeneous groups.

Using hierarchical clustering and k-means, the analysis supports a three-cluster solution:
- stronger urban-economic regions
- weaker and more peripheral regions
- a distinct Southern European group shaped mainly by climatic and labour-market conditions

## Main findings

The three analytical approaches lead to a consistent conclusion: the 2022 housing market across NUTS 2 regions was strongly heterogeneous.

Three broad regional profiles emerge:

1. Stronger urban-economic regions  
   These are dominated by many German, Belgian and Scandinavian regions and tend to display higher income, stronger urban-economic conditions, and more favorable housing market profiles.

2. Weaker peripheral regions  
   These include several Eastern and Central European regions and are characterized by weaker economic and urban strength.

3. Distinct Southern European regions  
   Mainly from Spain, Italy and Portugal, these regions are differentiated less by pure economic strength and more by climatic and labour-market conditions.

Overall, the results suggest that regional housing market differences in 2022 reflected deeper territorial inequalities in economic development, vulnerability, urban structure, and local context.

## Repository structure

- ALLDATA.xlsx
- ALLDATA.txt
- HousingMarket.R
- HousingMarket.html
- README.md

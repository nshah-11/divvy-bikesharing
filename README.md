# Divvy Ridership Analysis 2023 - Trip Demand Prediction 
Cycle Squad Members - Neha Shah, Isha Hameed, Helen Cunningham, Amber Wang, Natania Christopher  

## Introduction 
Bikesharing demands are soaring in Chicago, yet there is currently no way to identify demand. Since its introduction to the cityin 2013, Chicago has spent over $30 million on implementing a sustainable bike-sharing system. For this project, the team leveraged bike-share demand data from Divvy to forecast precise daily and hourly requirements, aiming to boost Divvy user satisfaction and refine operational strategies. By addressing these issues, we can create a more seamless, accessible, and enjoyable mode of urban transportation, ultimately contributing to improved quality of life and sustainable growth within the Chicago community. Insights from this study can be used by Divvy to optimize their bike-sharing station planning and business strategies.

## Modeling 
Our approach to modeling included two scenarios: 1) Prediction of trip demand to forecast bike usage (ARIMA, Random Forest–Regression, Gradient Boosting, Generalized Additive Model, Neural Network) and 2) prediction of member type using classification models (Random Forest–Classification, Support Vector Machine, Neural Network). These models were chosen as they are widely known, easy to understand and effective for both prediction and classification tasks. What is novel to our approach is that we added several variables through feature engineering, such as season, which have not been previously explored, and analyzed a range of models to ensure optimal performance. This would provide insights into the impact of these variables on bike-sharing demand.

## Models Evaluation 
We used 5-fold cross validation and performance metrics such as accuracy, MSE, R^2, and MAE to ensure model robustness and ability to comparemodels. R^2 scores and MSE for trip demand models can be seen below.

| Model: Trips               | R^2                                    | MSE |
| -------------------------------- | ------------------------------------------------------------------------ |-----|
| Random Forest                | 85%           | 8.10|
| XGBoost              |85%      |8.58|
| GAM            | 49%     | 29.05|

All models predicting membershiptype yielded around a 68% accuracy.

Best Trip Demand Model: Random Forest (regression)

Best Membership Model: Random Forest (classification)

## Dashboards & Visualizations

The team created 2 dashboards with the objective of assisting a Divvy operational decision maker. Each dashboard addresses a different goal a decisionmaker may have:

1. Data Overview Dashboard which helps to visualize overall trends in the data
2. Trip Prediction Dashboard which helps predict daily trips based on Random Forest Regression model

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/fc7018e6-bf46-455a-9faf-bf169a195ed4)

![Trip Pred RF](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/b355865b-8d68-4113-8f63-9206d149ba29)

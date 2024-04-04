#clear history
rm(list = ls())

# for tableau viz
library(Rserve)
Rserve()

library(dplyr)
library(lubridate)
library(caret)
library(ggcorrplot)
library(cowplot)
library(ggplot2)
library(e1071)
library(ROSE)

data <- read.table(file = "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project//modelingdata.csv", sep = ",", header = TRUE)

#convert character variables to factor 
data$member_casual <- as.factor(ifelse(data$member_casual == "casual", 0, 1))
data$day_of_week <- as.factor(data$day_of_week)
data$month <- as.factor(data$month)
data$season <- as.factor(data$season)
data$rideable_type <- as.factor(data$rideable_type)

############################# ARIMA #################################
library(forecast)
library(tseries)
library(xts)

#convert date column to date 
data$date <- as.Date(data$date, format="%Y-%m-%d")
# group data by time 
time_data <- data %>%
  group_by(date) %>%
  summarise(trips = sum(trips))

# Create a line chart
ggplot(time_data, aes(x = date, y = trips)) + 
  geom_line(color = "blue", size = 1) + 
  geom_point(color = "black", size = 2) + 
  labs(title = "Daily Trips Over Time",
       x = "Date",
       y = "Number of Trips") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

# convert date to xts object for time series 
time_series <- ts(time_data$trips, frequency=365)

# building model 
arima_model <- auto.arima(time_series)
summary(arima_model)
checkresiduals(arima_model)

forecasts2 <- forecast(arima_model, h=30)

print(forecasts2)
plot(forecasts2)

#Check for stationarity through Augmented Dickey-Fuller (ADF) test
adf.test(time_series, alternative = "stationary")
# data:  time_series
# Dickey-Fuller = -1.0775, Lag order = 7, p-value = 0.9253
# alternative hypothesis: stationary

#with p-value of 0.9253 indicates data is non stationary so we need to make it stationary 

# Differencing the series can remove trends and seasonality
# First order difference
diff_series <- diff(time_series, differences = 1)

# Check stationarity again
adf.test(diff_series, alternative = "stationary")
# data:  diff_series
# Dickey-Fuller = -9.4858, Lag order = 7, p-value = 0.01
# alternative hypothesis: stationary
# 
# Warning message:
#   In adf.test(diff_series, alternative = "stationary") :
#   p-value smaller than printed p-value

# we now have stationary data!!! 

# build arima model accounting for stationary data
arima_model1 <- auto.arima(diff_series)
summary(arima_model1)
# Series: diff_series 
# ARIMA(1,0,1) with zero mean 

# Coefficients:
#   ar1      ma1
# 0.3211  -0.8665
# s.e.  0.0626   0.0310
# 
# sigma^2 = 14294240:  log likelihood = -3514.43
# AIC=7034.86   AICc=7034.93   BIC=7046.55
# 
# Training set error measures:
#   ME     RMSE      MAE      MPE     MAPE MASE        ACF1
# Training set -7.294209 3770.371 2672.997 321.3743 506.4321  NaN 0.001871055

checkresiduals(arima_model1)

forecasts <- forecast(arima_model1, h=30)

print(forecasts1)
plot(forecasts1)

#ARIMA is not the best model since we are only working with 2023 data. 
#Forecasts are only made for the first few days of Jan 2024 and then plateaus. 

############### Split data for other models ######################
#Convert date column to days 
data <- data %>%
  mutate(day_of_month = day(date))

#take sample of data since there are a lot of observations 20% sample
smp_size <- floor(0.2 * nrow(data))
set.seed(123)
smp <- sample(seq_len(nrow(data)), size = smp_size)
smp_data <- data[smp, ]

#visualize sample data if it follows the same trend 
time_data <- smp_data %>%
  group_by(date) %>%
  summarise(trips = sum(trips))

# Create a line chart
ggplot(time_data, aes(x = date, y = trips)) + 
  geom_line(color = "blue", size = 1) +  # Adds a blue line to the plot
  geom_point(color = "black", size = 2) +  # Optionally adds red points to each data point
  labs(title = "Daily Trips Over Time",
       x = "Date",
       y = "Number of Trips") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotates the x-axis labels for better readability

#sample dataset does follow a similar trend to full dataset!!!

#remove date column for models 
smp_data <- smp_data[,-3]

#Split into train and test datasets 
set.seed(42)
index<-createDataPartition(smp_data$trips,p=0.7,list=FALSE)
train<-smp_data[index,]
test<-smp_data[-index,]

#test for imbalance in membmer_casual data for train and test data 
train_tgt_imb <- table(train$member_casual)
print(train_tgt_imb)

test_tgt_imb <- table(test$member_casual)
print(test_tgt_imb)

################################ Correlation Matrix ###########################
 
model.matrix(~+., data=smp_data) %>% 
  cor(use="pairwise.complete.obs") %>% 
  ggcorrplot(show.diag=FALSE, type="lower", lab=TRUE, lab_size=2)
#little to no correlation less than .5 

################################ Random Forest Model ############################
library(randomForest)
library(Metrics)

start_time <- Sys.time()
rf_model <- randomForest(trips ~ ., data=train, ntree=100)
end_time <- Sys.time()
time.elapse <- (end_time - start_time)
print(time.elapse)
# Time difference of 1.424069 hours
predictions <- predict(rf_model, test[, -8])

mse <- mean((predictions - test$trips)^2)
#11.921534
mae(test$trips, predictions)
#the average absolute difference between the observed values and the predicted values is
#the lower the MAE the better a model is able to fit a datset 
#2.09935

#RSME
sqrt(mean((predictions - test$trips)^2))
#3.452757

print(rf_model)
# Call:
#   randomForest(formula = trips ~ ., data = train, ntree = 100) 
# Type of random forest: regression
# Number of trees: 100
# No. of variables tried at each split: 2
# 
# Mean of squared residuals: 12.08385
# % Var explained: 78.53
  
#################################### TUning ############################## 
#tuning ntree 
result <- data.frame(ntree = integer(), mse = numeric())
start_time <- Sys.time()
for (trees in seq(501, 1001, by = 100)) {
  model <- randomForest(trips ~ ., data = train, ntree = trees)
  pred <- predict(model, test[, -8])
  mse <- mean((pred - test$trips)^2)
  
  result <- rbind(result, data.frame(ntree = trees, mse = mse))
}
end_time <- Sys.time()
time.elapse <- (end_time - start_time)
print(time.elapse)
#Time difference of 20.21817 hours for testing ntree of 100 to 500
print(result)
# ntree      mse
# 1   100 11.92153
# 2   200 11.75151
# 3   300 11.80116
# 4   400 11.96939
# 5   500 11.79165

# tuning of mtry
# w/o tuning mtry of 2 was used, however for regression models sqrt(p) is = to mtry
# since there are about 24 predictors that is approximately equal to 4 rounded down
param_grid <- expand.grid(.mtry = c(2,4,6,8))

# Set up cross-validation
control <- trainControl(method = "cv", number = 5)  # 10-fold cross-validation

# Perform grid search with cross-validation
set.seed(42)
start_time <- Sys.time()
mtry <- train(trips ~ .,data = train, method = "rf", metric="RMSE",
              trControl = control, tuneGrid = param_grid, ntree=200)
end_time <- Sys.time()
time.elapse <- (end_time - start_time)
print(time.elapse)
#Time difference of 6.63637 hours

# Print the best parameters
print(mtry)
# 138457 samples
# 8 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 110765, 110766, 110766, 110766, 110765 
# Resampling results across tuning parameters:
#   
#   mtry  RMSE      Rsquared   MAE     
# 2    6.090808  0.5535300  3.882747
# 4    4.470850  0.7165623  2.728598
# 6    3.487761  0.8036919  2.108276
# 8    3.080030  0.8369834  1.873619
# 
# RMSE was used to select the optimal model using the smallest value.
# The final value used for the model was mtry = 8.

# However we will use mtry = 6 so we don't use all predictor variables and cause bias.

# # further tuning for nodesize
# nodesize_values <- c(1, 5, 10)
# results <- data.frame(nodesize = integer(), MSE = numeric())
# 
# for (size in nodesize_values) {
#   model <- randomForest(trips ~ ., data = train, nodesize = size, ntree = 200, mtry=6)
#   predictions <- predict(model, test[, -8])
#   
#   mse <- mean((predictions - test$trips)^2)
#   results <- rbind(results, data.frame(nodesize = size, MSE = mse))
# }

# print(results)

#tuning for nodesize was attemped but computationally expensive

################################ Random Forest w/ Tuning ntree,mtry ################

start_time <- Sys.time()
rf_model2 <- randomForest(trips ~ ., data=train, ntree=200, mtry=6)
end_time <- Sys.time()
time.elapse <- (end_time - start_time)
print(time.elapse)
# Time difference of 12.15723 hours - ntree=100 mtry=6
# Time difference of 17.93908 hours - ntree =200 mtry=6
predictions2 <- predict(rf_model2, test)

mse <- mean((predictions2 - test$trips)^2)
#8.3314
#8.1016

mae(test$trips, predictions2)
#the average absolute difference between the observed values and the predicted values is
#the lower the MAE the better a model is able to fit a datset 
#1.767349
# 1.744874

#RSME
sqrt(mean((predictions2 - test$trips)^2))
# 2.886419
# 2.846333

print(rf_model2)
# Call:
#   randomForest(formula = trips ~ ., data = train, ntree = 100,      mtry = 10) 
# Type of random forest: regression
# Number of trees: 100
# No. of variables tried at each split: 8
# 
# Mean of squared residuals: 8.61887
# % Var explained: 84.69

# Call:
#   randomForest(formula = trips ~ ., data = train, ntree = 200,      mtry = 6) 
# Type of random forest: regression
# Number of trees: 200
# No. of variables tried at each split: 6
# 
# Mean of squared residuals: 8.275262
# % Var explained: 85.3

############################### SVM Model ####################################### 
#WITHOUT TUNING
start_time <- Sys.time()
svm_model <- svm(member_casual ~ ., data=train, method="C-classification", kernel="radial")
end_time <- Sys.time()
time.elapse <- (end_time - start_time)
print(time.elapse)
# 1.066593 hours
summary(svm_model)
# Call:
#   svm(formula = member_casual ~ ., data = train, method = "C-classification", kernel = "radial")
# 
# 
# Parameters:
#   SVM-Type:  C-classification 
# SVM-Kernel:  radial 
# cost:  1 
# 
# Number of Support Vectors:  109517
# 
# ( 54751 54766 )
# 
# 
# Number of Classes:  2 
# 
# Levels: 
#   0 1
predictions <- predict(svm_model, test)

# Evaluate the model
confusion_matrix <- table(predictions, test$member_casual)
print(confusion_matrix)
# predictions     0     1
# 0 21506 12543
# 1  8326 16962                                                                   
accuracy <- sum(predictions == test$member_casual) / nrow(test)
print(paste("Accuracy:", accuracy))
# "Accuracy: 0.648297015352984"   



#note: this code for tuning is commented out as it takes hours to run, however results are shown below after based on the tune model below
#tuning the model to find the best parameters for cost and gamma
# start_time <- Sys.time()
# tune_out=tune(svm, member_casual ~ . ,data=train,
#               type = "C-classification",
#               kernel = "radial",
#               ranges = list( cost = c(0.1,1,10,100) , gamma = c(0.001,0.01,0.1,0.90)))
# end_time <- Sys.time()
# time.elapse <- (end_time - start_time)
# print(time.elapse)
# summary(tune_out)

#tunning is computationally expensive
                                  

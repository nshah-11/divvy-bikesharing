rm(list = ls())

library(dplyr)
library(lubridate)
library(caret)

data <- read.table(file = "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project//clean_data.csv", sep = ",", header = TRUE)

data$month <- factor(data$month, levels = c("January", "February", "March", "April", "May", "June", 
                                            "July", "August", "September", "October", "November", "December"))
data$day_of_week <- factor(data$day_of_week, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", 
                                                        "Saturday"))
data$season <- factor(data$season, levels = c("Spring", "Summer", "Fall", "Winter"))
data$date <- as.Date(data$date, format="%m/%d/%Y")
data$member_casual <- as.factor(data$member_casual)
data$rideable_type <- as.factor(data$rideable_type)

# Convert time_of_start to a POSIXct object
data$hour <- as.POSIXct(data$time_of_start, format="%I:%M:%S %p")

# convert hour to reflect 0-23 hours 
data <- data %>%
  mutate(hour = hour(hour))

#group by relevate attributes to get number of trips to be able to predict demand 
modeldata <- data %>%
  group_by(rideable_type, member_casual, date, day_of_week, month, season, trip_duration_mins, hour) %>%
  summarise(
    'trips' = n(),
    .groups = 'drop'
  )

summary(modeldata$trips)

# file_path <- "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project"
# output_file <- file.path(file_path, "modelingdata.csv")
# write.csv(modeldata, output_file, row.names = FALSE)

#Code for splitting modeling data 
set.seed(123)
index<-createDataPartition(modeldata$trips,p=0.7,list=FALSE)
train<-modeldata[index,]
test<-modeldata[-index,]

# file_path <- "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project"
# output_file <- file.path(file_path, "traindata.csv")
# write.csv(train, output_file, row.names = FALSE)
rm(list = ls())

library(dplyr)
# library(readr)

## merged all csv files
# file_path <- "C://Users//nehas//Desktop//data"
# df <- list.files(path = file_path, full.names = TRUE, pattern = "\\.csv$") %>%
#   lapply(read_csv) %>%
#   bind_rows()
# output_file <- file.path(file_path, "data2023.csv")
# write.csv(df, output_file, row.names = FALSE)

## reading merged dataset for 2023
tripdata <- read.table(file = "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project//data2023.csv", sep = ",", header = TRUE)
length(unique(tripdata$ride_id)) #no duplicate rides 
## check for missing/null values
colSums(is.na(tripdata))
# cols start_station_name , sstart_station_id, end_station_name, end_station_id end_lat and end_lng have missing values
# remove id related columns since they don't provide useful info 
tripdata <- tripdata[ , -c(1, 6,8)]

prop.table(table(tripdata$rideable_type))*100
# classic_bike   docked_bike electric_bike 
# 47.134073      1.368683     51.497244 

#there are three types but per the website there should only be two options classic and ebikes
#https://divvybikes.com/how-it-works/meet-the-bikes
#since electric bikes can be either docked or locked (not both at once) and classic bikes must be docked at a station to end the ride
#assume docked-bikes are the same as classic bikes since 

tripdata <- tripdata %>%
  mutate(rideable_type = if_else(rideable_type == 'docked_bike', 'classic_bike', rideable_type))
prop.table(table(tripdata$rideable_type))*100
# classic_bike electric_bike 
# 48.50276      51.49724 

#unique start station names
length(unique(tripdata$start_station_name)) # 1593
start_stations <- tripdata %>%
  distinct(start_station_name) %>%
  arrange(start_station_name)

#unique end station names 
length(unique(tripdata$end_station_name)) #1598
end_stations <- tripdata %>%
  distinct(end_station_name) %>%
  arrange(end_station_name)

#unique latitude and longitude 
length(unique(tripdata$start_lat)) #783955
length(unique(tripdata$start_lng)) #730634
length(unique(tripdata$end_lat)) #13877
length(unique(tripdata$end_lng)) #13985

# member vs casual 
prop.table(table(tripdata$member_casual))*100
# casual   member 
# 36.00041 63.99959 

## filter for rows with missing data 
missing_data = tripdata[!complete.cases(tripdata),]
#colSums(is.na(missing_data))
prop.table(table(missing_data$rideable_type))*100
# classic_bike electric_bike 
# 0.5248846    99.4751154 
prop.table(table(missing_data$member_casual))*100
# casual   member 
# 37.99405 62.00595 

### NOTE: A MAJORITY OF RIDES WITH MISSING DATA INVOLVE ELECTRIC BIKES 99%

### OPTION 1
## filtered out missing data
cleaned_data = tripdata[complete.cases(tripdata),] # ~ 25% data removed 
colSums(is.na(cleaned_data))
prop.table(table(cleaned_data$rideable_type))*100
# classic_bike electric_bike 
# 63.87449      36.12551 
length(unique(missing_data$start_station_name)) #1526
length(unique(missing_data$end_station_name))#1468
prop.table(table(cleaned_data$member_casual))*100
# casual   member 
# 35.36151 64.63849 

head(table(cleaned_data$end_station_name),10)
analyze = subset(cleaned_data, end_station_name == "Adler Planetarium")
unique(analyze$end_lat)
unique(analyze$end_lng)
#end station seem to have the same long and lat coordinates based on end station name 
# (can use this info to impute station names using lat and log data)
#but opposite for start_station does not hold true

#filter data for rows where only end_station_name has missing values
trip_filtered_end_station <- tripdata %>%
  filter(is.na(end_station_name),
         !is.na(start_station_name), !is.na(rideable_type),
         !is.na(start_lat), !is.na(start_lng),
         !is.na(end_lat), !is.na(end_lng),
         !is.na(started_at), !is.na(ended_at),
         !is.na(member_casual))
prop.table(table(trip_filtered_end_station$rideable_type))*100
# classic_bike electric_bike 
# 0.05166087   99.94833913 
prop.table(table(trip_filtered_end_station$member_casual))*100
# casual   member 
# 38.66707 61.33293 

# most have missing end_station names for electric_bikes 
# this would make sense if ebikes do not need to be 'docked' at a station
# and so for at least ebikes it makes sense data is missing
# similar logic would then apply for start_station_name
# for classic_bike those with missing station names could mean bikes were lost or stolen


#filter data for rows where only start_station_name has missing values
trip_filtered_start_station <- tripdata %>%
  filter(is.na(start_station_name),
         !is.na(end_station_name), !is.na(rideable_type),
         !is.na(started_at), !is.na(ended_at),
         !is.na(start_lat), !is.na(start_lng),
         !is.na(end_lat), !is.na(end_lng),
         !is.na(member_casual))
prop.table(table(trip_filtered_start_station$rideable_type))*100
# classic_bike electric_bike 
# 0.001308313  99.998691687
prop.table(table(trip_filtered_start_station$member_casual))*100
# casual   member 
# 31.68188 68.31812 

# attempt to imput end_station_name

# lookup table of unique end_lat and end_lng pairings with end_station_name mappings
lookup_table <- tripdata %>%
  filter(!is.na(end_station_name)) %>%
  distinct(end_lat, end_lng, end_station_name)

# Use the lookup table to impute missing end_station_name in tripdata
tripdata1 <- tripdata %>%
  left_join(lookup_table, by = c("end_lat", "end_lng")) %>%
  mutate(end_station_name = coalesce(end_station_name.x, end_station_name.y)) %>%
  select(-ends_with(".x"), -ends_with(".y"))

#results in more observations because of many to many relationship, this will not work 

# long and lat pairs associated with multiple end station names
multiple_station_names <- tripdata %>%
  filter(!is.na(end_station_name)) %>%
  group_by(end_lat, end_lng) %>%
  summarise(station_names = paste(unique(end_station_name), collapse = ", ")) %>%
  filter(nchar(station_names) - nchar(gsub(",", "", station_names)) >= 1) %>%
  ungroup()

## OPTION 2
# remove all rows with missing lat and long 
cleaned_data1 =  tripdata[complete.cases(tripdata$end_lat, tripdata$end_lng), ]
colSums(is.na(cleaned_data1))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(start_station_name) & rideable_type == 'classic_bike'))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(end_station_name) & rideable_type == 'classic_bike'))

# # check
# finalclean <- cleaned_data1 %>%
#   filter(is.na(start_station_name),
#          !is.na(end_station_name), !is.na(rideable_type),
#          !is.na(started_at), !is.na(ended_at),
#          !is.na(start_lat), !is.na(start_lng),
#          !is.na(end_lat), !is.na(end_lng),
#          !is.na(member_casual))
# prop.table(table(finalclean$rideable_type))*100
# # electric_bike 
# # 100 
# finalclean1 <- cleaned_data1 %>%
#   filter(is.na(end_station_name),
#          !is.na(start_station_name), !is.na(rideable_type),
#          !is.na(started_at), !is.na(ended_at),
#          !is.na(start_lat), !is.na(start_lng),
#          !is.na(end_lat), !is.na(end_lng),
#          !is.na(member_casual))
# prop.table(table(finalclean1$rideable_type))*100
# # electric_bike 
# # 100 

#impute 'unknown'values under start_station_name and end_station
cleaned_data1$start_station_name[is.na(cleaned_data1$start_station_name)] <- 'unknown'
cleaned_data1$end_station_name[is.na(cleaned_data1$end_station_name)] <- 'unknown'
colSums(is.na(cleaned_data1)) # no longer any missing values 
prop.table(table(cleaned_data1$rideable_type))*100 #approx 50-50 split
# classic_bike electric_bike 
# 48.43708      51.56292 




### 2 OPTIONS: 

### 1. use cleaned_dataset where all rows with missing/NA values are removed
### HOWEVER the distribution for classic vs electric bikes are skewed 

### 2. use cleaned_dataset1 where all rows with missing lat and long are removed,
### and missing values for start_station_name and end_station_name are imputed with unknown to prevent bias

### PICK FINAL CLEANED DATASET  
### depends on what we want to answer and as long as we are able to justify why it was cleaned that way


### may also need to clean station names, some have additional characters or (TEST)

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

# length(unique(tripdata$ride_id)) #no duplicate rides 
# ## check for missing/null values
# colSums(is.na(tripdata))
# cols start_station_name , sstart_station_id, end_station_name, end_station_id end_lat and end_lng have missing values
# remove id related columns since they don't provide useful info 
tripdata <- tripdata[ , -c(1, 6,8)]

# prop.table(table(tripdata$rideable_type))*100
# classic_bike   docked_bike electric_bike 
# 47.134073      1.368683     51.497244 

# dockbikes <- tripdata[tripdata$rideable_type == "docked_bike" ,]
### docked bikes only appear from Jan to August...after August there are no records of docked_bikes at all
### it appears that docked bikes are the same as classic bikes then -> reached out to owner of data to explain 

#there are three types but per the website there should only be two options classic and ebikes
#https://divvybikes.com/how-it-works/meet-the-bikes
#since electric bikes can be either docked or locked (not both at once) and classic bikes must be docked at a station to end the ride
#assume docked-bikes are the same as classic bikes since 

#converted all docked_bikes to classic_bikes 
tripdata <- tripdata %>%
  mutate(rideable_type = if_else(rideable_type == 'docked_bike', 'classic_bike', rideable_type))
# prop.table(table(tripdata$rideable_type))*100
# classic_bike electric_bike 
# 48.50276      51.49724 

#additional analysis of other columns 
#unique start station names
# length(unique(tripdata$start_station_name)) # 1593
# start_stations <- tripdata %>%
#   distinct(start_station_name) %>%
#   arrange(start_station_name)
# 
# #unique end station names 
# length(unique(tripdata$end_station_name)) #1598
# end_stations <- tripdata %>%
#   distinct(end_station_name) %>%
#   arrange(end_station_name)
# 
# #unique latitude and longitude 
# length(unique(tripdata$start_lat)) #783955
# length(unique(tripdata$start_lng)) #730634
# length(unique(tripdata$end_lat)) #13877
# length(unique(tripdata$end_lng)) #13985
# 
# # member vs casual 
# prop.table(table(tripdata$member_casual))*100
# casual   member 
# 36.00041 63.99959 

# ## filter for rows with missing data
# missing_data = tripdata[!complete.cases(tripdata),]
# #colSums(is.na(missing_data))
# prop.table(table(missing_data$rideable_type))*100
# # classic_bike electric_bike
# # 0.5248846    99.4751154
# prop.table(table(missing_data$member_casual))*100
# # casual   member
# # 37.99405 62.00595
# 
# #filter missing data where start_station_name is NA 
# filtered_data <- missing_data %>% 
#   filter(is.na(start_station_name))
# colSums(is.na(filtered_data))
# prop.table(table(filtered_data$rideable_type))*100
# # classic_bike electric_bike 
# # 0.003882537  99.996117463 
# 
# #filter missing data where ONLY start station name is missing 
# filtered_data <- missing_data %>% 
#   filter(is.na(start_station_name) & !is.na(end_station_name))
# colSums(is.na(filtered_data))
# prop.table(table(filtered_data$rideable_type))*100
# # classic_bike electric_bike 
# # 0.001308313  99.998691687 
# 
# #filter missing data where end_station_name is NA 
# filtered_data <- missing_data %>% 
#   filter(is.na(end_station_name))
# colSums(is.na(filtered_data))
# prop.table(table(filtered_data$rideable_type))*100
# # classic_bike electric_bike 
# # 0.03133376   99.96866624 
# 
# #filter missing data where ONLY end_station_name is missing
# filtered_data <- missing_data %>% 
#   filter(is.na(end_station_name) & !is.na(start_station_name))
# colSums(is.na(filtered_data)) #shows end_lat and end_lng is missing as well 
# missing_data =  missing_data[complete.cases(missing_data$end_lat, missing_data$end_lng), ]
# prop.table(table(filtered_data$rideable_type))*100
# # classic_bike electric_bike 
# # 0.05166087   99.94833913 

### NOTE: A MAJORITY OF RIDES WITH MISSING DATA INVOLVE ELECTRIC BIKES 99%
# most have missing end_station names for electric_bikes
# this would make sense if ebikes do not need to be 'docked' at a station
# and so for at least ebikes it makes sense data is missing
# similar logic would then apply for start_station_name
# for classic_bike those with missing station names could mean bikes were lost or stolen


# ### OPTION 1
# ## filtered out missing data
# cleaned_data = tripdata[complete.cases(tripdata),] # ~ 25% data removed 
# colSums(is.na(cleaned_data))
# prop.table(table(cleaned_data$rideable_type))*100
# # classic_bike electric_bike 
# # 63.87449      36.12551 
# length(unique(missing_data$start_station_name)) #1526
# length(unique(missing_data$end_station_name))#1468
# prop.table(table(cleaned_data$member_casual))*100
# # casual   member 
# # 35.36151 64.63849 
# 
# head(table(cleaned_data$end_station_name),10)
# analyze = subset(cleaned_data, end_station_name == "Adler Planetarium")
# unique(analyze$end_lat)
# unique(analyze$end_lng)
# #end station seem to have the same long and lat coordinates based on end station name 
# # (can use this info to impute station names using lat and log data)
# #but opposite for start_station does not hold true
# 
# #filter data for rows where only end_station_name has missing values
# trip_filtered_end_station <- tripdata %>%
#   filter(is.na(end_station_name),
#          !is.na(start_station_name), !is.na(rideable_type),
#          !is.na(start_lat), !is.na(start_lng),
#          !is.na(end_lat), !is.na(end_lng),
#          !is.na(started_at), !is.na(ended_at),
#          !is.na(member_casual))
# prop.table(table(trip_filtered_end_station$rideable_type))*100
# # classic_bike electric_bike 
# # 0.05166087   99.94833913 
# prop.table(table(trip_filtered_end_station$member_casual))*100
# # casual   member 
# # 38.66707 61.33293 
# 
# #filter data for rows where only start_station_name has missing values
# trip_filtered_start_station <- tripdata %>%
#   filter(is.na(start_station_name),
#          !is.na(end_station_name), !is.na(rideable_type),
#          !is.na(started_at), !is.na(ended_at),
#          !is.na(start_lat), !is.na(start_lng),
#          !is.na(end_lat), !is.na(end_lng),
#          !is.na(member_casual))
# prop.table(table(trip_filtered_start_station$rideable_type))*100
# # classic_bike electric_bike 
# # 0.001308313  99.998691687
# prop.table(table(trip_filtered_start_station$member_casual))*100
# # casual   member 
# # 31.68188 68.31812 
# 
# # attempt to imput end_station_name
# 
# # lookup table of unique end_lat and end_lng pairings with end_station_name mappings
# lookup_table <- tripdata %>%
#   filter(!is.na(end_station_name)) %>%
#   distinct(end_lat, end_lng, end_station_name) %>%
#   arrange(end_station_name)
# 
# # Use the lookup table to impute missing end_station_name in tripdata
# tripdata1 <- tripdata %>%
#   left_join(lookup_table, by = c("end_lat", "end_lng")) %>%
#   mutate(end_station_name = coalesce(end_station_name.x, end_station_name.y)) %>%
#   select(-ends_with(".x"), -ends_with(".y"))
# 
# #results in more observations because of many to many relationship, this will not work 
# 
# # long and lat pairs associated with multiple end station names
# multiple_station_names <- tripdata %>%
#   filter(!is.na(end_station_name)) %>%
#   group_by(end_lat, end_lng) %>%
#   summarise(station_names = paste(unique(end_station_name), collapse = ", ")) %>%
#   filter(nchar(station_names) - nchar(gsub(",", "", station_names)) >= 1) %>%
#   ungroup()

## OPTION 2
# remove all rows with missing lat and long 
cleaned_data1 =  tripdata[complete.cases(tripdata$end_lat, tripdata$end_lng), ]
colSums(is.na(cleaned_data1))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike (since they need to be docked at a station to end trip)
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(start_station_name) & rideable_type == 'classic_bike'))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(end_station_name) & rideable_type == 'classic_bike'))
# colSums(is.na(cleaned_data1))

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


#impute 'Locked' values under start_station_name and end_station from missing values
# this is because to park ebikes, it can either be docked or locked (but not both)
# per website  Dock at any Divvy station, or use the cable to lock at any e-station or at the 500+ Divvy approved public bike racks for no additional cost. 
cleaned_data1$start_station_name[is.na(cleaned_data1$start_station_name)] <- 'Locked at e-station/public rack'
cleaned_data1$end_station_name[is.na(cleaned_data1$end_station_name)] <- 'Locked at e-station/public rack'
# colSums(is.na(cleaned_data1)) # no longer any missing values 
# prop.table(table(cleaned_data1$rideable_type))*100 #approx 50-50 split
# classic_bike electric_bike 
# 48.43708      51.56292 

### may also need to clean station names, some have additional characters or (TEST)

##these are a list of all stations with their respective lat and long as of 2-8-24
stations <- read.table(file = "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project//Divvy_Bicycle_Stations_20240208.csv", sep = ",", header = TRUE)
# length(unique(stations$Latitude)) #898 
# length(unique(stations$Longitude)) #897
# length(unique(stations$Station.Name)) #901 vs. 1598 (end) and 1593(start)

stations <- stations %>%
  arrange(Station.Name)

stations <- stations[ , -c(1, 3,4,5,6)]

# CLEANING END STATION NAMES 
# some have extra characters, TEMP or test

df <- data.frame(table(cleaned_data1$end_station_name))

# need to remove 410 - only one observation 
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != '410', ]
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Bissell St & Armitage Ave*'] <- 'Bissell St & Armitage Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Buckingham - Fountain'] <- 'Buckingham Fountain'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Buckingham Fountain (Columbus/Balbo)'] <- 'Buckingham Fountain'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Buckingham Fountain (Temp)'] <- 'Buckingham Fountain'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'California Ave & Francis Pl (Temp)'] <- 'California Ave & Francis Pl'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Campbell Ave & Montrose Ave (Temp)'] <- 'Campbell Ave & Montrose Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Fort Dearborn Dr & 31st St*'] <- 'Fort Dearborn Dr & 31st St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Kedzie Ave & 24th St (Temp)'] <- 'Kedzie Ave & 24th St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lincoln Ave & Roscoe St*'] <- 'Lincoln Ave & Roscoe St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Morgan St & Lake St*'] <- 'Morgan St & Lake St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Noble St & Milwaukee Ave (Temp)'] <- 'Noble St & Milwaukee Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Pulaski Rd & Eddy St (Temp)'] <- 'Pulaski Rd & Eddy St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Racine Ave & Fullerton Ave (Temp)'] <- 'Racine Ave & Fullerton Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Wentworth Ave & 24th St (Temp)'] <- 'Wentworth Ave & 24th St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Wentworth Ave & Cermak Rd*'] <- 'Wentworth Ave & Cermak Rd'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Wilton Ave & Diversey Pkwy*'] <- 'Wilton Ave & Diversey Pkwy'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Woodlawn & 103rd - Olive Harvey Vaccination Site'] <- 'Woodlawn & 103rd'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lincoln Ave & Belmont Ave (Temp)'] <- 'Lincoln Ave & Belmont Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Rainbow Beach'] <- 'Rainbow - Beach'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Bissell St & Armitage Ave'] <- 'Bissell St & Armitage Ave*'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Damen Ave & Coulter St'] <- 'Damen Ave/Coulter St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Kenosha & Wellington'] <- 'Kenosha Ave & Wellington Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Kilbourn & Roscoe'] <- 'Kilbourn Ave & Roscoe St'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lavergne & Fullerton'] <- 'Lavergne Ave & Fullerton Ave'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lincoln Ave & Roscoe St'] <- 'Lincoln Ave & Roscoe St*'
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Morgan St & Lake St'] <- 'Morgan St & Lake St*'
#elizabeth st &59th st + racine ave & 57th st have the same station ID -> current stations only show racine ave thus convert elizabet st to racine ave
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Elizabeth St & 59th St'] <- 'Racine Ave & 57th St'
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'MTV WH - Cassette Repair', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'NewHastings', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'OH - BONFIRE - TESTING', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'OH Charging Stx - Test', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'Old Hastings Monolith', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$end_station_name != 'Base - 2132 W Hubbard', ]

# THESE 2 STATION NAMES DO NOT SHOW UP UNDER ACTIVE STATIONS (901)
# Clark St & Randolph St 
# Lincoln Ave & Belmont Ave 
# plus a bunch with public rack 

# Clark St & Randolph St  and  Wells St & Randolph St have same station ID TA1305000030
# name changed in Jan 2024
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Clark St & Randolph St'] <- 'Wells St & Randolph St'
# cleaned_data1$end_lat[cleaned_data1$end_station_name == "Wells St & Randolph St"] <- 41.8843
# cleaned_data1$end_lng[cleaned_data1$end_station_name == "Wells St & Randolph St"] <- -87.63396

# Lincoln Ave & Belmont Ave and Lincoln Ave & Melrose St have same station ID  TA1309000042
# name changed in July 2023 
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lincoln Ave & Belmont Ave'] <- 'Lincoln Ave & Melrose St'
# cleaned_data1$end_lat[cleaned_data1$end_station_name == "Lincoln Ave & Melrose St"] <- 41.9406
# cleaned_data1$end_lng[cleaned_data1$end_station_name == "Lincoln Ave & Melrose St"] <- -87.66943


cleaned_data1 <- cleaned_data1 %>%
  left_join(stations, by = c("end_station_name" = "Station.Name")) %>%
  mutate(
    end_lat = if_else(!is.na(Latitude), Latitude, end_lat),
    end_lng = if_else(!is.na(Longitude), Longitude, end_lng)
  ) %>%
  select(-Latitude, -Longitude, -Location)
length(unique(cleaned_data1$end_lat)) #4208
length(unique(cleaned_data1$end_lng)) #4212
length(unique(cleaned_data1$end_station_name)) #1571
colSums(is.na(cleaned_data1))

freq_table <- cleaned_data1 %>%
  filter(!is.na(end_station_name)) %>%
  count(end_station_name, end_lat, end_lng, sort = TRUE) %>%
  arrange(end_station_name)

# file_path <- "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project"
# output_file <- file.path(file_path, "coordinatemapping.csv")
# write.csv(freq_table, output_file, row.names = FALSE)

# CLEANING START STATION NAMES 
# some have extra characters, TEMP or test

df <- data.frame(table(cleaned_data1$start_station_name))

cleaned_data1 <- cleaned_data1[cleaned_data1$start_station_name != '410', ]
cleaned_data1 <- cleaned_data1[cleaned_data1$start_station_name != 'Base - 2132 W Hubbard', ]
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Buckingham - Fountain'] <- 'Buckingham Fountain'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Buckingham Fountain (Columbus/Balbo)'] <- 'Buckingham Fountain'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Buckingham Fountain (Temp)'] <- 'Buckingham Fountain'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'California Ave & Francis Pl (Temp)'] <- 'California Ave & Francis Pl'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Campbell Ave & Montrose Ave (Temp)'] <- 'Campbell Ave & Montrose Ave'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Damen Ave & Coulter St'] <- 'Damen Ave/Coulter St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Kedzie Ave & 24th St (Temp)'] <- 'Kedzie Ave & 24th St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Kenosha & Wellington'] <- 'Kenosha Ave & Wellington Ave'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Kilbourn & Roscoe'] <- 'Kilbourn Ave & Roscoe St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Lavergne & Fullerton'] <- 'Lavergne Ave & Fullerton Ave'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Lincoln Ave & Belmont Ave (Temp)'] <- 'Lincoln Ave & Belmont Ave'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Noble St & Milwaukee Ave (Temp)'] <- 'Noble St & Milwaukee Ave'
cleaned_data1 <- cleaned_data1[cleaned_data1$start_station_name != 'OH Charging Stx - Test', ]
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Pulaski Rd & Eddy St (Temp)'] <- 'Pulaski Rd & Eddy St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Racine Ave & Fullerton Ave (Temp)'] <- 'Racine Ave & Fullerton Ave'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Rainbow Beach'] <- 'Rainbow - Beach'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Wentworth Ave & 24th St (Temp)'] <- 'Wentworth Ave & 24th St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Woodlawn & 103rd - Olive Harvey Vaccination Site'] <- 'Woodlawn & 103rd'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Elizabeth St & 59th St'] <- 'Racine Ave & 57th St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Clark St & Randolph St'] <- 'Wells St & Randolph St'
cleaned_data1$start_station_name[cleaned_data1$start_station_name == 'Lincoln Ave & Belmont Ave'] <- 'Lincoln Ave & Melrose St'


cleaned_data1 <- cleaned_data1 %>%
  left_join(stations, by = c("start_station_name" = "Station.Name")) %>%
  mutate(
    start_lat = if_else(!is.na(Latitude), Latitude, start_lat),
    start_lng = if_else(!is.na(Longitude), Longitude, start_lng)
  ) %>%
  select(-Latitude, -Longitude, -Location)
length(unique(cleaned_data1$start_lat)) #16033
length(unique(cleaned_data1$start_lng)) #16111
colSums(is.na(cleaned_data1))

freq_table_start <- cleaned_data1 %>%
  filter(!is.na(start_station_name)) %>%
  count(start_station_name, start_lat, start_lng, sort = TRUE) %>%
  arrange(start_station_name)
# 
# station_name <- cleaned_data1[cleaned_data1$end_station_name == "Lincoln Ave & Belmont Ave",]

file_path <- "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project"
output_file <- file.path(file_path, "cleandata.csv")
write.csv(cleaned_data1, output_file, row.names = FALSE)

#### DATASET IS CLEANED

### 2 OPTIONS: 

### 1. use cleaned_dataset where all rows with missing/NA values are removed
### HOWEVER the distribution for classic vs electric bikes are skewed 

### 2. use cleaned_dataset1 where all rows with missing lat and long are removed,
### and missing values for start_station_name and end_station_name are imputed with unknown to prevent bias
### and station names are cleaned and aligned with active stations 

### PICK FINAL CLEANED DATASET  -> Picked OPTION 2




rm(list = ls()) # clears objects from workspace

#libraries required 
library(dplyr)
library(readr)

# merged all csv files for all months in 2023
file_path <- "C://Users//....//Data" #enter full file path of where all months of 2023 data are stored. 
df <- list.files(path = file_path, full.names = TRUE, pattern = "\\.csv$") %>%
  lapply(read_csv) %>%
  bind_rows()
output_file <- file.path(file_path, "data2023.csv")
write.csv(df, output_file, row.names = FALSE)

## reading merged dataset for 2023
tripdata <- read.table(file = "Path of file//data2023.csv", sep = ",", header = TRUE)

# check for duplicate rides
length(unique(tripdata$ride_id)) 

# check for missing/null values
colSums(is.na(tripdata))
# cols start_station_name , sstart_station_id, end_station_name, end_station_id end_lat and end_lng have missing values

# remove id related columns since they don't provide useful info 
tripdata <- tripdata[ , -c(1, 6,8)]

# analyze the proportion of bike types
prop.table(table(tripdata$rideable_type))*100
# classic_bike   docked_bike electric_bike 
# 47.134073      1.368683     51.497244 

#there are three types but per the website there should only be two options classic and ebikes
#https://divvybikes.com/how-it-works/meet-the-bikes
#since electric bikes can be either docked or locked (not both at once) and classic bikes must be docked at a station to end the ride
# docked bikes only appear from Jan to August...after August there are no records of docked_bikes at all
#assume docked-bikes are the same as classic bikes since 

#converted all docked_bikes to classic_bikes 
tripdata <- tripdata %>%
  mutate(rideable_type = if_else(rideable_type == 'docked_bike', 'classic_bike', rideable_type))

prop.table(table(tripdata$rideable_type))*100
# classic_bike electric_bike 
# 48.50276      51.49724 

# remove all rows with missing lat and long 
cleaned_data1 =  tripdata[complete.cases(tripdata$end_lat, tripdata$end_lng), ]
colSums(is.na(cleaned_data1))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike (since they need to be docked at a station to end trip)
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(start_station_name) & rideable_type == 'classic_bike'))
# remove all lost/stolen records - remove rows where start/end station names are missing AND rideable_type is classic_bike
cleaned_data1 <- cleaned_data1 %>%
  filter(!(is.na(end_station_name) & rideable_type == 'classic_bike'))

# impute 'Locked' values under start_station_name and end_station from missing values
# this is because to park ebikes, it can either be docked or locked (but not both)
# per website  Dock at any Divvy station, or use the cable to lock at any e-station or at the 500+ Divvy approved public bike racks for no additional cost. 
cleaned_data1$start_station_name[is.na(cleaned_data1$start_station_name)] <- 'Locked at e-station/public rack'
cleaned_data1$end_station_name[is.na(cleaned_data1$end_station_name)] <- 'Locked at e-station/public rack'

colSums(is.na(cleaned_data1)) # no longer any missing values 
prop.table(table(cleaned_data1$rideable_type))*100 #approx 50-50 split
# classic_bike electric_bike 
# 48.43708      51.56292 

# may also need to clean station names, some have additional characters or (TEST)

# these are a list of all currently active stations with their respective lat and long as of 2-8-24
stations <- read.table(file = "C://Users//...//Divvy_Bicycle_Stations_20240208.csv", sep = ",", header = TRUE) # enter full file path
length(unique(stations$Latitude)) #898
length(unique(stations$Longitude)) #897
length(unique(stations$Station.Name)) #901 vs. 1598 (end) and 1593(start)

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

# Lincoln Ave & Belmont Ave and Lincoln Ave & Melrose St have same station ID  TA1309000042
# name changed in July 2023 
cleaned_data1$end_station_name[cleaned_data1$end_station_name == 'Lincoln Ave & Belmont Ave'] <- 'Lincoln Ave & Melrose St'

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

# export cleaned data
file_path <- "C://Users//" #enter file path where you want to save clean data csv file
output_file <- file.path(file_path, "cleandata.csv")
write.csv(cleaned_data1, output_file, row.names = FALSE)

#### DATASET IS CLEANED and ready for use in modeling 




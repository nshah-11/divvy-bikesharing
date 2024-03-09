rm(list = ls())

##libraries 
library(ggplot2)
library(dplyr)
library(cowplot)
library(lubridate)
library(ggcorrplot)

data <- read.table(file = "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project//clean_data.csv", sep = ",", header = TRUE)

# data <- data[, -c(1,2)]
# file_path <- "C://Users//nehas//Documents//GT 2023//CSE 6242 DVA//Project"
# output_file <- file.path(file_path, "clean_data.csv")
# write.csv(data, output_file, row.names = FALSE)

summary(data$trip_duration_mins)
data$month <- factor(data$month, levels = c("January", "February", "March", "April", "May", "June", 
                                                      "July", "August", "September", "October", "November", "December"))
data$day_of_week <- factor(data$day_of_week, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", 
                                            "Saturday"))
data$season <- factor(data$season, levels = c("Spring", "Summer", "Fall", "Winter"))
data$date <- as.Date(data$date, format="%m/%d/%Y")
data$member_casual <- as.factor(data$member_casual)
data$rideable_type <- as.factor(data$rideable_type)

# Convert time_of_start to a POSIXct object, assuming the date is not important
data$time_of_start1 <- as.POSIXct(data$time_of_start, format="%I:%M:%S %p")

data <- data %>%
  mutate(time_of_day = case_when(
    time_of_start1 >= as.POSIXct("08:00:00 PM", format="%I:%M:%S %p") | 
      time_of_start1 < as.POSIXct("04:00:00 AM", format="%I:%M:%S %p") ~ "LATE",
    time_of_start1 >= as.POSIXct("04:00:00 AM", format="%I:%M:%S %p") &
      time_of_start1 < as.POSIXct("10:00:00 AM", format="%I:%M:%S %p") ~ "AM",
    time_of_start1 >= as.POSIXct("10:00:00 AM", format="%I:%M:%S %p") &
      time_of_start1 < as.POSIXct("03:00:00 PM", format="%I:%M:%S %p") ~ "MID",
    time_of_start1 >= as.POSIXct("03:00:00 PM", format="%I:%M:%S %p") &
      time_of_start1 < as.POSIXct("08:00:00 PM", format="%I:%M:%S %p") ~ "PM",
    TRUE ~ "Other"  # Fallback category if needed
  ))

data <- data[, -c(18)]

data$time_of_day <- as.factor(data$time_of_day)

# --------------------- Distribution of bike type by member ------------------------
counts <- data %>%
  group_by(rideable_type, member_casual) %>%
  summarise(n = n(), .groups = 'drop')

# Calculate percentages
perc <- counts %>%
  group_by(rideable_type) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ungroup()

# Plot
ggplot(perc, aes(x = rideable_type, y = n, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text(aes(label = paste0(round(n), "\n(", round(percentage, 1), "%)"), 
                y = n), position = position_dodge(width = 0.9), vjust = 0.5, size = 2.5, fontface = "bold") +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Bike type by Member Type",
       x = "Bike Type",
       y = "Count") +
  theme_minimal() 

# ------------------------Time related variables vs member type--------------------------------

# DAY OF WEEK 
counts <- data %>%
  group_by(day_of_week, member_casual) %>%
  summarise(n = n(), .groups = 'drop')
# Calculate percentages
perc <- counts %>%
  group_by(day_of_week) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ungroup()
# Plot
p1 <- ggplot(perc, aes(x = day_of_week, y = n, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text(aes(label = paste0(round(n), "\n(", round(percentage, 1), "%)"), 
                y = n), position = position_dodge(width = 0.9), vjust = 0.5, size = 2.5,  fontface = "bold") +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Day of Week by Member Type",
       x = "Day of Week",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## SEASON 
counts <- data %>%
  group_by(season, member_casual) %>%
  summarise(n = n(), .groups = 'drop')
# Calculate percentages
perc <- counts %>%
  group_by(season) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ungroup()
p2 <- ggplot(perc, aes(x = season, y = n, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text(aes(label = paste0(round(n), "\n(", round(percentage, 1), "%)"), 
                y = n), position = position_dodge(width = 0.9), vjust = 0.5, size = 2.5, fontface = "bold") +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Season by Member Type",
       x = "Season",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## MONTH 
counts <- data %>%
  group_by(month, member_casual) %>%
  summarise(n = n(), .groups = 'drop')
# Calculate percentages
perc <- counts %>%
  group_by(month) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ungroup()
p3 <- ggplot(perc, aes(x = month, y = n, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text(aes(label = paste0(round(n), "\n(", round(percentage, 1), "%)"), 
                y = n), position = position_dodge(width = 0.9), vjust = 0.5, size = 2.5, fontface = "bold") +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Month by Member Type",
       x = "Month",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

top_row <- plot_grid(p1, p2, labels = c('A', 'B'), label_size = 12)
plot_grid(top_row, p3, labels = c('', 'C'), label_size = 12, ncol = 1)

## TIME OF DAY 
counts <- data %>%
  group_by(time_of_day, member_casual) %>%
  summarise(n = n(), .groups = 'drop')
# Calculate percentages
perc <- counts %>%
  group_by(time_of_day) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ungroup()
ggplot(perc, aes(x = time_of_day, y = n, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text(aes(label = paste0(round(n), "\n(", round(percentage, 1), "%)"), 
                y = n), position = position_dodge(width = 0.9), vjust = 0.5, size = 2.5, fontface = "bold") +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Month by Member Type",
       x = "Month",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

##DATE 
counts <- data %>%
  group_by(date, member_casual) %>%
  summarise(count = n(), .groups = 'drop')
##filter by month
january_data <- counts %>%
  filter(month(date) == 1)

# Now create the line chart
ggplot(january_data, aes(x = date, y = count, group = member_casual, color = member_casual)) +
  geom_line(linewidth = 1.0) +
  scale_color_brewer(palette = "Set1") + # This makes the chart colorful
  labs(title = "Date by Member Type",
       x = "Date",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

# -----------------------------Trip Duration vs Member Type --------------------------------

ggplot(data, aes(x = trip_duration_mins, fill = member_casual)) + 
  geom_bar(position = "dodge") +
  scale_fill_brewer(palette = "Paired") + # This makes the chart colorful
  labs(title = "Trip Duration by Member Type",
       x = "Trip Duration (mins",
       y = "Count") +
  theme_minimal()

# number of rides per day of week by month 
# number of rides per day of week by member 

# number or rides per season by month 
# number of rides per season by member 
data <- data[, -c(2,3,4,5,11,15,16)]

model.matrix(~+., data=data) %>% 
  cor(use="pairwise.complete.obs") %>% 
  ggcorrplot(show.diag=FALSE, type="lower", lab=TRUE, lab_size=2)


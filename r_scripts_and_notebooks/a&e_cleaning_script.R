# Libraries and Setting up
library(tidyverse)
library(lubridate)


a_and_e_data <- read_csv("raw_data/monthly_a&e_activity_and_waiting_times.csv") %>% 
  janitor::clean_names()

a_and_e_data <- a_and_e_data %>% 
  rename(date = month) %>% 
# Converting values in date column to date class
  mutate(date = ym(date)) %>% 
# Creating separate year and month columns
  mutate(year = year(date),
         month = month(date)) %>% 
  select(-ends_with("qf")) %>% 
  filter(date >= "2018-01-01") %>% 
  select(-id, -country, -starts_with("disch"))


# Add in health board names column
health_board_names <- read_csv("downloaded_data/health_board_codes.csv") %>% 
  janitor::clean_names() %>% 
  rename(hbt = hb) %>% 
  select(hbt, hb_name)

a_and_e_data <- a_and_e_data %>% 
  left_join(health_board_names, by = "hbt") %>% 
  relocate(hb_name, .after = hbt)

# Remove columns we aren't using
a_and_e_data <- a_and_e_data %>% 
  select(date, hbt, hb_name, treatment_location, department_type, 
         number_of_attendances_aggregate, number_meeting_target_aggregate)


# Create data called All Scotland which sums values from all health boards

all_scot_data <- a_and_e_data %>% 
  group_by(date) %>% 
  summarise(number_of_attendances_aggregate = 
              sum(number_of_attendances_aggregate, na.rm = TRUE),
            number_meeting_target_aggregate = 
              sum(number_meeting_target_aggregate, na.rm = TRUE))

hbt <- rep("S92000003", 58)
hb_name <- rep("All Scotland", 58)
treatment_location <- rep("All", 58)
department_type <- rep("NA", 58)

all_scot_data <- cbind(all_scot_data, hbt, hb_name, treatment_location, department_type) 
  
a_and_e_data <- rbind(a_and_e_data, all_scot_data)


# Adding percent meeting target column to dataframe
a_and_e_data <- a_and_e_data %>% 
  mutate(percent_meeting_target = number_meeting_target_aggregate / 
           number_of_attendances_aggregate * 100) 


write_csv(a_and_e_data, "clean_data/a_and_e_data_clean.csv")

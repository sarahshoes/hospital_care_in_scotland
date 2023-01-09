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

write_csv(a_and_e_data, "clean_data/a_and_e_data_clean.csv")

# libraries
library(tidyverse)
library(lubridate)

# data
stay_length <- read_csv("raw_data/Inpatient and day case activity by board of treatment, age and sex.csv") %>% 
  janitor::clean_names()

# create date field
stay_length <- stay_length %>% 
  mutate(year = str_sub(quarter, start = 1, end = 4), .after = quarter) %>% 
  mutate(month_num = case_when(
    str_sub(quarter, start = 5, end = 6) == "Q1" ~ 3, 
    str_sub(quarter, start = 5, end = 6) == "Q2" ~ 6, 
    str_sub(quarter, start = 5, end = 6) == "Q3" ~ 9, 
    str_sub(quarter, start = 5, end = 6) == "Q4" ~ 12, 
  ), .after = year
  ) %>% 
  mutate(made_date = make_datetime(year, month_num), .after = month_num)

# calculate average pre-pandemic stay length by hb, month, admission and age
stay_length_pre_pandemic_avg <- stay_length %>% 
  filter(year %in% c(2018, 2019)) %>% 
  group_by(hb, month_num, admission_type, age) %>% 
  summarise(average20182019 = mean(average_length_of_stay, na.rm = TRUE))

# join average to stay_length file
stay_length <- left_join(stay_length, stay_length_pre_pandemic_avg)

# write clean data to file
write_csv(stay_length, "clean_data/stay_length_clean.csv")


# libraries
library(tidyverse)
library(lubridate)

# data
bed_occupancy <- read_csv("raw_data/Beds by board of treatment and specialty.csv") %>% 
  janitor::clean_names()

health_boards <- read_csv("health_board_codes.csv") %>% 
  janitor::clean_names()

# join to health board data
bed_occupancy <- left_join(bed_occupancy, health_boards, by = "hb")

# create date
bed_occupancy <- bed_occupancy %>% 
  mutate(year = str_sub(quarter, start = 1, end = 4), .after = quarter) %>% 
  mutate(month_num = case_when(
    str_sub(quarter, start = 5, end = 6) == "Q1" ~ 3, 
    str_sub(quarter, start = 5, end = 6) == "Q2" ~ 6, 
    str_sub(quarter, start = 5, end = 6) == "Q3" ~ 9, 
    str_sub(quarter, start = 5, end = 6) == "Q4" ~ 12, 
  ), .after = year
  ) %>% 
  mutate(made_date = make_datetime(year, month_num), .after = month_num)

# write clean data to file
write_csv(bed_occupancy, "clean_data/bed_occupancy_clean.csv")



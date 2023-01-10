# libraries
library(tidyverse)
library(lubridate)

# data
beds_qtrly <- read_csv("Beds by board of treatment and specialty.csv") %>% 
  janitor::clean_names()

# add health board names
health_boards <- read_csv("health_board_codes.csv") %>% 
  janitor::clean_names()
beds_qtrly <- left_join(beds_qtrly, health_boards, by = "hb")

# create date
beds_qtrly_summ <- beds_qtrly %>% 
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
write_csv(beds_qtrly_summ, "clean_data/beds_qtrly_clean.csv")



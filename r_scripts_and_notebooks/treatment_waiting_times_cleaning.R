library(tidyverse)
library(lubridate)

ongoing_waits <- read_csv(here::here(
  "raw_data/sot_performance_ongoing_waits_sep22.csv")) %>% 
  janitor::clean_names()

ongoing_waits <- ongoing_waits %>% 
  mutate(month_ending = ymd(month_ending)) %>% 
  select(-ends_with("qf")) %>% 
  filter(month_ending >= "2018-01-01")
  
# Summing values from all health boards to create all Scotland data. The 
# data in the file (S92000003) has big dip at 2017 - 2018.
  


# Add in health board names


  
write_csv(ongoing_waits, "clean_data/treatment_waiting_times_ongoing.csv")
  

library(tidyverse)
library(lubridate)

ongoing_waits <- read_csv(here::here(
  "raw_data/sot_performance_ongoing_waits_sep22.csv")) %>% 
  janitor::clean_names()

ongoing_waits <- ongoing_waits %>% 
  mutate(month_ending = ymd(month_ending)) %>% 
  select(-ends_with("qf")) %>% 
  filter(month_ending >= "2018-01-01") %>% 
  rename(hb = hbt)

# Add in health board names

health_board_names <- read_csv(here::here("lookup_tables/health_board_codes.csv")) %>% 
  janitor::clean_names() %>% 
  select(hb, hb_name)

ongoing_waits <- ongoing_waits %>% 
  left_join(health_board_names, by = "hb") %>% 
  relocate(hb_name, .after = hb) 

# Scotland and Jubilee hospital codes aren't in file so this code adds them to dataframe  
ongoing_waits <- ongoing_waits %>%   
  mutate(hb_name = case_when(hb == "S92000003" ~ "All Scotland",
                             hb == "SB0801" ~ "NHS Golden Jubilee National Hospital",
                             TRUE ~ hb_name))
           
  

# There is a specialty category (Z9) which includes all. This means the data is 
# doubled as it is also divided into each specialty. 
# Don't currently plan to filter by specialty on app so going to remove this 
# from data. 

ongoing_waits <- ongoing_waits %>% 
  filter(specialty == "Z9") %>% 
  select(-specialty)



# Summing values from all health boards to create all Scotland data. The 
# data in the file (S92000003) has big dip at 2017 - 2018.

# Code used to ensure calculations were correct
original_scotland_values <- ongoing_waits %>% 
   filter(hb_name == "All Scotland")

# Calculate Scotland totals by summing each health board
calculated_scotland_totals <- ongoing_waits %>% 
  filter(!hb_name == "All Scotland") %>% 
  group_by(month_ending, patient_type) %>% 
  summarise(total_scot_by_month = sum(number_waiting, na.rm = TRUE),
            total_scot_by_month_over12weeks = sum(number_waiting_over12weeks,
          na.rm = TRUE))

# Replace original Scotland values with new calculate totals
calculated_scotland_totals <- left_join(original_scotland_values, calculated_scotland_totals, 
                          by = c("month_ending", "patient_type")) %>% 
  select(-number_waiting, -number_waiting_over12weeks) %>% 
  rename(number_waiting = total_scot_by_month,
         number_waiting_over12weeks = total_scot_by_month_over12weeks)

# Remove original Scotland data from ongoing_waits and replace with calculated 
# values
ongoing_waits <- ongoing_waits %>% 
  filter(!hb_name == "All Scotland") %>% 
  rbind(calculated_scotland_totals)


write_csv(ongoing_waits, here::here("clean_data/treatment_waiting_times_ongoing.csv"))
  




# Code to draw graph to check original Scotland totals and newly calculated ones overlaid 
# where they should
#scot_only %>% 
#  group_by(month_ending) %>% 
#  summarise(total = sum(number_waiting, na.rm = TRUE)) %>% 
#  ggplot(aes(month_ending, total)) +
#  geom_line() +
#  geom_line(data = test2, aes(month_ending, totalx))
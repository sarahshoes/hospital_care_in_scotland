#script for delayed discharge data

# data info https://www.isdscotland.org/health-topics/health-and-social-community-care/delayed-discharges/guidelines/docs/Background-of-delayed-discharge-information-and-glossary-of-terms.pdf
# data source

# Libraries and Setting up
library("tidyverse")
library("janitor")
library("lubridate")
library("snakecase")
library("tsibble")
library("tsibbledata")

#read in healthboard codes
hb_codes <- read_csv(here::here("downloaded_data/health_board_codes.csv"))
hb_codes <- clean_names(hb_codes)

#load in datafiles
delayed_discharge <- read_csv(here::here("raw_data/Delayed discharge bed days by health board.csv"))
delayed_discharge <- clean_names(delayed_discharge)

#data cleaning
delayed_discharge <- delayed_discharge %>% 
  rename(hb = hbt) %>% #use standardised names
  rename(hbqf = hbtqf) 

#merge hbnames into datafiles
delayed_discharge <- left_join(delayed_discharge,hb_codes)

delayed_discharge <- delayed_discharge %>% 
  select(-country) %>% 
  select(-starts_with("hb_date")) %>% 
  select(-ends_with("qf")) %>% 
  select(-starts_with("average_daily")) %>% 
  mutate(mdate = ym(month_of_delay), .after = month_of_delay) %>% 
  mutate(year = as.integer(str_sub(month_of_delay,1,4)), .after = mdate) %>% 
  mutate(month = as.integer(str_sub(month_of_delay,5,6)), .after = year) %>% 
  mutate(iswinter = ifelse(month %in% c(4,5,6,7,8,9),FALSE,TRUE), .after=month) %>%
  select(-month_of_delay) %>% 
  #tidying paramenter names
  mutate(hb_name = ifelse(hb=="S92000003","All Scotland",hb_name)) %>% 
  mutate(hb_name = ifelse(is.na(hb_name),"NHS Region Unknown",hb_name)) %>%
  mutate(age_group = ifelse(age_group=="18plus","All (18plus)",age_group)) %>%   
  relocate(hb_name, .after = hb)

#calculate 2018-2019 levels
pre_pandemic_avg <- delayed_discharge %>% 
  filter(between(year,2018,2019)) %>% 
  group_by(hb,age_group,reason_for_delay) %>% 
  summarise(avg_20182019 =  mean(number_of_delayed_bed_days)) 

#merge this column back into all data
delayed_discharge <- left_join(delayed_discharge,pre_pandemic_avg) 

#calculate percent variation
delayed_discharge <- delayed_discharge %>% 
  mutate(percent_var = 100*(number_of_delayed_bed_days-avg_20182019)/avg_20182019)

# setup data as a tsibble
delayed_discharge <- as_tsibble(delayed_discharge, key = id, index = mdate) 

#write out data file
write_csv(delayed_discharge, "clean_data/delayed_discharge_clean.csv")
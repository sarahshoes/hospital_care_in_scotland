#hospital admissions data cleaning script

# data sourced from wider covid imapcts
#https://www.opendata.nhs.scot/dataset/covid-19-wider-impacts-hospital-admissions

# Notes
# golden jubilee hospital data not included
# NHS Firth Valley data - warning
# disclosure control methods for low values


# Libraries and Setting up
library("tidyverse")
library("janitor")
library("lubridate")

#read in healthboard codes
hb_codes <- read_csv(here::here("lookup_tables/lookup_tables/health_board_codes.csv"))
hb_codes <- clean_names(hb_codes)

#load in datafiles
weekly_admissions_spec <- 
  read_csv(here::here("raw_data/Covid admissions by health board and speciality.csv"))
weekly_admissions_spec <- clean_names(weekly_admissions_spec)

weekly_admissions_dep <- 
  read_csv(here::here("raw_data/Covid admissions by health board and deprivation.csv"))
weekly_admissions_dep <- clean_names(weekly_admissions_dep)

weekly_admissions_demog <- 
  read_csv(here::here("raw_data/Covid admissions by health board, age and sex.csv"))
weekly_admissions_demog <- clean_names(weekly_admissions_demog)

# merge hbnames into datafiles
weekly_admissions_spec <- left_join(weekly_admissions_spec,hb_codes)
weekly_admissions_demog <- left_join(weekly_admissions_demog,hb_codes)
weekly_admissions_dep <- left_join(weekly_admissions_dep,hb_codes) 

# data cleaning
weekly_admissions_spec <- weekly_admissions_spec %>% 
  rename("speciality"= "specialty") %>% 
  rename("speciality_qf"= "specialty_qf") 

weekly_admissions_spec <- weekly_admissions_spec %>% 
  mutate(year = as.integer(str_sub(week_ending,1,4))) %>% 
  mutate(month = as.integer(str_sub(week_ending,5,6))) %>% 
  mutate(day = as.integer(str_sub(week_ending,7,8))) %>% 
  mutate(wdate = ymd(week_ending)) %>% 
  # identify "All Scotland" data
  mutate(hb_name = ifelse(hb=="S92000003","All Scotland",hb_name)) %>% 
  mutate(hb_name = ifelse(is.na(hb_name),"NHS Region Unknown",hb_name)) %>% 
  mutate(iswinter = ifelse(month %in% c(4,5,6,7,8,9),FALSE,TRUE)) %>% 
  mutate(above_thresh = ifelse(percent_variation>0,7,0))


monthly_admissions_spec <- weekly_admissions_spec

monthly_admissions_spec <- monthly_admissions_spec %>% 
  group_by(hb, admission_type, speciality, year, month) %>% 
  summarise(monthly_admissions = 4*mean(number_admissions, na.rm = TRUE)) %>% 
  mutate(mdate = as.Date(make_datetime(year, month, 15))) %>% 
  ungroup()


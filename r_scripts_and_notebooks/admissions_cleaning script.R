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
hb_codes <- read_csv(here::here("lookup_tables/health_board_codes.csv"))
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
  mutate(above_thresh = ifelse(percent_variation>0,7,0)) %>% 
  mutate(specialty_simple = case_when(
    speciality == "Accident & Emergency" ~ "A&E", 
    speciality == "Medical (excl. Cardiology & Cancer)" ~ "Medical", 
    speciality == "Paediatrics (medical & surgical)" ~ "Paediatrics", 
    TRUE ~ speciality
  ), .after = speciality) %>% 
  rename(percent_var = percent_variation)
  
weekly_admissions_demog <- weekly_admissions_demog %>% 
  mutate(year = as.integer(str_sub(week_ending,1,4))) %>% 
  mutate(month = as.integer(str_sub(week_ending,5,6))) %>% 
  mutate(day = as.integer(str_sub(week_ending,7,8))) %>% 
  mutate(wdate = ymd(week_ending)) %>% 
  # identify "All Scotland" data
  mutate(hb_name = ifelse(hb=="S92000003","All Scotland",hb_name)) %>% 
  mutate(hb_name = ifelse(is.na(hb_name),"NHS Region Unknown",hb_name)) %>% 
  mutate(iswinter = ifelse(month %in% c(4,5,6,7,8,9),FALSE,TRUE)) %>% 
  mutate(above_thresh = ifelse(percent_variation>0,7,0)) %>% 
  rename(percent_var = percent_variation)
 
weekly_admissions_dep <- weekly_admissions_dep %>% 
  mutate(year = as.integer(str_sub(week_ending,1,4))) %>% 
  mutate(month = as.integer(str_sub(week_ending,5,6))) %>% 
  mutate(day = as.integer(str_sub(week_ending,7,8))) %>% 
  mutate(wdate = ymd(week_ending)) %>% 
  # identify "All Scotland" data
  mutate(hb_name = ifelse(hb=="S92000003","All Scotland",hb_name)) %>% 
  mutate(hb_name = ifelse(is.na(hb_name),"NHS Region Unknown",hb_name)) %>% 
  mutate(iswinter = ifelse(month %in% c(4,5,6,7,8,9),FALSE,TRUE)) %>% 
  mutate(above_thresh = ifelse(percent_variation>0,7,0)) %>% 
  rename(percent_var = percent_variation)

# for this dataset pre-pandemic levels are already calculated

# setup data as a tsibble
#weekly_admissions_spec <- as_tsibble(weekly_admissions_spec, key = id, index = mdate) 

#write out data file
write_csv(weekly_admissions_spec, "clean_data/weekly_admissions_spec_clean.csv")
write_csv(weekly_admissions_demog, "clean_data/weekly_admissions_demog_clean.csv")
write_csv(weekly_admissions_dep, "clean_data/weekly_admissions_dep_clean.csv")

## create monthly version

monthly_admissions_spec <- weekly_admissions_spec

monthly_admissions_spec <- monthly_admissions_spec %>% 
  group_by(hb, admission_type, speciality, year, month) %>% 
  summarise(monthly_admissions = 4*mean(number_admissions, na.rm = TRUE)) %>% 
  mutate(mdate = as.Date(make_datetime(year, month, 15))) %>% 
  ungroup()

#re-calculate 2018-2019 levels for monthly data
pre_pandemic_avg <- weekly_admissions_spec %>% 
  filter(between(year,2018,2019)) %>% 
  group_by(hb,age_group,reason_for_delay) %>% 
  summarise(avg_20182019 =  mean(number_of_delayed_bed_days)) 

#merge this column back into all data
weekly_admissions_spec <- left_join(weekly_admissions_spec,pre_pandemic_avg) 

#calculate percent variation
weekly_admissions_spec <- weekly_admissions_spec %>% 
  mutate(percent_var = 100*(number_of_delayed_bed_days-avg_20182019)/avg_20182019)
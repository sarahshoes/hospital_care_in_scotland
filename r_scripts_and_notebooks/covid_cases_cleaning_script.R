#script for cleaning data on admssions with covid

# data info https://www.isdscotland.org/health-topics/health-and-social-community-care/delayed-discharges/guidelines/docs/Background-of-delayed-discharge-information-and-glossary-of-terms.pdf
# data source

# Libraries and Setting up
library("tidyverse")
library("janitor")
library("lubridate")

#load in datafiles
covid_cases <- read_csv(here::here("raw_data/admissions_ageband_week.csv"))
covid_cases <- clean_names(covid_cases)

# data cleaning
covid_cases <- covid_cases %>% 
  mutate(year = as.integer(str_sub(week_ending,1,4)), .after = week_ending) %>% 
  mutate(month = as.integer(str_sub(week_ending,5,6)), .after  =year) %>% 
  mutate(day = as.integer(str_sub(week_ending,7,8)), .after = month) %>% 
  mutate(wdate = ymd(week_ending), .after = week_ending) %>% 
  mutate(iswinter = ifelse(month %in% c(4,5,6,7,8,9),FALSE,TRUE), .after=day) %>%
  select(-week_ending) %>% 

  #tidying paramenter names  
  rename(hb = country) %>% 
  mutate(hb_name = "All Scotland", .after = hb) %>% 
  mutate(age_band = ifelse(age_band == "Total", "All ages (0plus)", age_band)) %>% 
  mutate(admissions_qf = coalesce(" ")) %>% # so the next line works better
  mutate(admissions = ifelse(admissions_qf =="c",1,admissions)) %>% 
  select(-ends_with("qf")) %>% 
  
  #merge into new age_bands
  mutate(age_band_new = case_when(
    age_band == "All ages (0plus)" ~ "All ages (0plus)",  
    age_band == "Under 18" ~ "Under 18",
    age_band == "80+" ~ "75+",
    age_band == "75-79" ~ "75+",
    TRUE ~ "18-74",)) %>% 

  group_by(wdate,age_band_new) %>% 
  mutate(admissions_new = sum(admissions, na.rm = TRUE)) %>% 

  #drop data we dont need
  select(-admissions) %>% 
  select(-age_band) %>% 
  rename(admissions = admissions_new) %>%   
  rename(age_band = age_band_new)    
 
  #calculate 2018-2019 levels
  pre_pandemic_avg <- covid_cases %>% 
  filter(between(year,2018,2019)) %>% 
  group_by(hb,age_band) %>% 
  summarise(avg_20182019 =  mean(admissions)) 

  #merge this column back into all data
  covid_cases <- left_join(covid_cases,pre_pandemic_avg) 

  #calculate percent variation
  covid_cases <-covid_cases %>% 
  mutate(percent_var = 100*(admissions-avg_20182019)/avg_20182019)

  # setup data as a tsibble
  #covid_cases <- rowid_to_column(covid_cases, "id") 
  #covid_cases<- as_tsibble(covid_cases, index = wdate, key = id)  

  #write out data file
  write_csv(covid_cases,here::here("clean_data/covid_cases_clean.csv"))

  
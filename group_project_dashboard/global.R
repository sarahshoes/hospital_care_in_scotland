# LOAD LIBRARIES

library(sf)
library(tidyverse)
library(leaflet)
library(shiny)
library(lubridate)
library(grid) #needed for custom annotation


# Load plot theme and function to prepare plot
source(here::here("palette_theme/define_theme.R"))
source(here::here("palette_theme/plot_timeseries.R"))
source(here::here("palette_theme/plot_timeseriesv2.R"))
palette = read_csv(here::here("palette_theme/phs_palette.csv"))

# HEALTH BOARD NAMES
health_board_list <- read_csv(here::here("lookup_tables/health_board_codes.csv")) %>% 
  janitor::clean_names() %>% 
  distinct(hb_name) %>% 
  pull()

# A&E WAITING TIMES

waiting_times <- read_csv(here::here("clean_data/a_and_e_data_clean.csv")) %>% 
  janitor::clean_names()

# Adding percent meeting target column to dataframe
waiting_times <- waiting_times %>% 
  mutate(percent_meeting_target = number_meeting_target_aggregate / 
           number_of_attendances_aggregate * 100)  

# Calculate average percent meeting target across all rows for 2018 and 2019
avg_2018_2019 <- waiting_times %>%  
  filter(date >= "2018-01-01" & date <= "2019-12-31") %>% 
  summarise(average_percent_meeting_target = mean(percent_meeting_target))

# ADMISSION - COVID CASES 
covid_cases <- read_csv(here::here("clean_data/covid_cases_clean.csv")) 


# TREATMENT WAITING TIMES

ongoing_waits <- read_csv(here::here("clean_data/treatment_waiting_times_ongoing.csv"))


# DISCHARGE DELAYS

delayed_discharge <- read_csv(here::here("clean_data/delayed_discharge_clean.csv"))  


# BED OCCUPANCY

bed_occupancy <- read_csv(here::here("clean_data/bed_occupancy_clean.csv"))


# HEALTH BOARD MAP

scot_hb_shapefile <- st_read(here::here("map_files/scotland_hb_shapefile_simplified/
         scot_hb_shapefile_simplified.shp"))

health_board_lat_lon <- read_csv(here::here("map_files/health_board_lat_lon.csv"))  

fake_data <- read_csv(here::here("map_files/fake_health_board_data.csv")) 


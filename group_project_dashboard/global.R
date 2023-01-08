# LOAD LIBRARIES

library(sf)
library(tidyverse)
library(leaflet)
library(shiny)


# READ IN DATA

# data <- read_csv("filepath.csv")





# PREPARE PLOTS AND / OR TABLES



# CREATE FUNCTIONS



# HEALTH BOARD MAP

# shapefile sourced from 
# https://github.com/tomwhite/covid-19-uk-data/issues/18



hb <- st_read(here::here("map_files/UK_covid_reporting_regions/UK_covid_reporting_regions.shp"))

health_boards <- c("Ayrshire and Arran", "Borders", "Dumfries and Galloway",
                   "Fife", "Forth Valley", "Grampian", "Greater Glasgow and Clyde", 
                   "Highland", "Lanarkshire", "Lothian", "Orkney", "Shetland",
                   "Tayside", "Western Isles")

scottish_hb <- hb %>% 
  filter(name %in% health_boards)


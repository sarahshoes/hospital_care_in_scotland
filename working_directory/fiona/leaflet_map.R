library(sf)
library(tidyverse)
library(leaflet)

# shapefile sourced from 
#https://github.com/tomwhite/covid-19-uk-data/issues/18

hb <- st_read("working_directory/fiona/UK_covid_reporting_regions/UK_covid_reporting_regions.shp")

health_boards <- c("Ayrshire and Arran", "Borders", "Dumfries and Galloway",
"Fife", "Forth Valley", "Grampian", "Greater Glasgow and Clyde", "Highland", 
"Lanarkshire", "Lothian", "Orkney", "Shetland", "Tayside", "Western Isles")

scottish_hb <- hb %>% 
  filter(name %in% health_boards)

rm(hb)


tictoc::tic()


leaflet(scottish_hb) %>% 
# addTiles adds scotland map from OpenStreetMap  
  addTiles() %>% 
# addPolygons adds health board shape from shapefile
    addPolygons(
    popup = ~name)


tictoc::toc()
library(sf)
library(tidyverse)
library(leaflet)


scot_hb_shapfile <- st_read(here::here("map_files/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp"))

scot_hb_shapfile <- st_transform(scot_hb_shapfile, "+proj=longlat +ellps=WGS84 +datum=WGS84")

leaflet(scot_hb_shapfile) %>% 
  # addTiles adds scotland map from OpenStreetMap  
  addTiles() %>% 
  # addPolygons adds health board shape from shapefile
  addPolygons(color = "black", weight = 1) %>% 
  # fit scotland onto map using fitBounds once we know the dimensions of the map
  fitBounds(lng1 = -1.867, lng2 = -4.867, lat1 = 54.8, lat2 = 60.4167)



simplepolys <- rmapshaper::ms_simplify(input = as(scot_hb_shapfile, 'Spatial')) %>%
  st_as_sf()


simple_polygons <- rmapshaper::ms_simplify(input = scot_hb_shapfile,
                                          keep = 0.001,
                                          keep_shapes = TRUE)


plot(scot_hb_shapfile)

simple_polygons <- st_simplify(scot_hb_shapefile)


ggplot(scot_hb_shapfile) + 
  geom_sf()

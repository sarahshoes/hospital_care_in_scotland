library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$map <- renderLeaflet({
     
     leaflet(scottish_hb) %>% 
# addTiles adds scotland map from OpenStreetMap  
       addTiles() %>% 
# addPolygons adds health board shape from shapefile
       addPolygons(color = "black", weight = 1) %>% 
# fit scotland onto map using fitBounds once we know the dimensions of the map
      fitBounds(lat1 = 55, lng1 = -4, lat2 = 60, lng2 = -2)
   }) 

# add names of health boards with addLabelOnlyMarkers but need to calculate
# centroid data with lat and lon values and make new dataframe
  
}



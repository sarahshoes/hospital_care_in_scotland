library(shiny)

# Define server logic required to draw a histogram
function(input, output) {

#   output&map <- renderLeaflet({
     
#     leaflet(scottish_hb) %>% 
       # addTiles adds scotland map from OpenStreetMap  
 #      addTiles() %>% 
       # addPolygons adds health board shape from shapefile
#       addPolygons(
#         popup = ~name)
#   }) 
  
  
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         xlab = 'Waiting time to next eruption (in mins)',
         main = 'Histogram of waiting times')
  })
  
  
}



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
  
   
   output$a_and_e_waiting_times <- renderPlot({
     
     waiting_times %>% 
       # Conduct this 2020 filtering step at an earlier stage
       filter(date >= "2020-01-01") %>% 
       filter(department_type %in% input$minor_or_emerg_dept) %>% 
       filter(hb_name == input$health_board) %>% 
       group_by(date) %>% 
       summarise(percent_meeting_target_by_month = mean(percent_meeting_target)) %>% 
       
       ggplot(aes(date, percent_meeting_target_by_month)) +
       geom_line(color = "grey20") +
       geom_hline(yintercept = 95, colour = "red", linetype = "dashed") + 
       geom_hline(yintercept = 97, colour = "blue", linetype = "dashed") +
       # use coord_cartesian to zoom in on y axis not scale_y_continuous() or ylim()
       coord_cartesian(ylim=c(70,100)) +
       theme_phs +
       labs(title = "Percentage of Attendances Meeting 4 Hour Target",
            subtitle = "Data Averaged by Month",
            y = "% Meeting 4 Hour Target",
            x = "Date") +
       geom_rect(aes(xmin = ymd("2022-9-15"), xmax = ymd("2023-03-15"), 
                     ymin = 0, ymax = Inf), fill = "skyblue", alpha = 0.01) +
       geom_rect(aes(xmin = ymd("2021-9-15"), xmax = ymd("2022-03-15"), 
                     ymin = 0, ymax = Inf), fill = "skyblue", alpha = 0.01) +
       geom_rect(aes(xmin = ymd("2020-9-15"), xmax = ymd("2021-03-15"), 
                     ymin = 0, ymax = Inf), fill = "skyblue", alpha = 0.01) +
       geom_rect(aes(xmin = ymd("2020-01-01"), xmax = ymd("2020-03-15"), 
                     ymin = 0, ymax = Inf), fill = "skyblue", alpha = 0.01) +
       
       theme(axis.text = element_text(size = 12)) +
       # Make sure only whole percent number shows on y-axis (not e.g. 92.5%)
       scale_y_continuous(labels = scales::label_number(accuracy = 1)) +
       geom_hline(yintercept = 95, colour = "red", linetype = "dashed") + 
       geom_hline(yintercept = 97, colour = "blue", linetype = "dashed") +
       annotate(geom = "text", x = as.Date("2022-08-01"), y = 94.2, 
                label = "NHS 95% Target", colour = "red") +
       annotate(geom = "text", x = as.Date("2022-08-01"), y = 96.2, 
                label = "2018/2019 Average", colour = "blue")
   })
   
   
}



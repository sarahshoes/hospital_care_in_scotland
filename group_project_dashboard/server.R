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
  
# A&E Waiting Times    
   output$a_and_e_waiting_times <- renderPlot({
     waiting_times %>% 
       # Conduct this 2020 filtering step at an earlier stage
       filter(date >= "2020-01-01") %>% 
       filter(department_type %in% input$minor_or_emerg_dept) %>% 
       filter(hb_name == input$health_board) %>% 
       group_by(date) %>% 
       summarise(percent_meeting_target_by_month = mean(percent_meeting_target)) %>% 
       
       timeseriesplot(aes(date, percent_meeting_target_by_month),
                      "Percentage of Attendances Meeting 4 Hour Target", 
                      "% Meeting 4 Hour Target") +
       labs(subtitle = "Data Averaged By Month") +
       theme(axis.text = element_text(size = 12)) +
       # Make sure only whole percent number shows on y-axis (not e.g. 92.5%)
       scale_y_continuous(labels = scales::label_number(accuracy = 1)) +
       geom_hline(yintercept = 95, colour = "red", linetype = "dashed") + 
       geom_hline(yintercept = 97, colour = "blue", linetype = "dashed") +
       annotate(geom = "text", x = as.Date("2022-08-01"), y = 94.5, 
                label = "NHS 95% Target", colour = "red") +
       annotate(geom = "text", x = as.Date("2022-08-01"), y = 96.5, 
                label = "2018/2019 Average", colour = "blue")
   })
   
   # Covid Cases
   output$covid_cases <- renderPlot({
      plotdata <- covid_cases %>% 
         filter(age_band %in% input$cc_age_group)
      plotmapping <- aes(x=wdate, y=admissions, colour =age_band) 
      plottitle <- ("Number of Covid Cases Admitted to Hospital - by age")
      plotylabel <- ("Number of admissions") 
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })
   
   
# Treatment Waiting Times
   
   output$treatment_waiting_times <- renderPlot({
   avg_2018_2019 <- ongoing_waits %>% 
     filter(month_ending >= "2018-01-01" & month_ending <= "2019-12-31") %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type == input$out_or_inpatient) %>% 
#     filter(hb_name == "NHS Highland") %>% 
#     filter(patient_type %in% c("New Outpatient, "Inpatient/Day case") %>%      
     group_by(month_ending) %>% 
     summarise(num_waiting_2018_2019_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     summarise(avg_num_waiting = mean(num_waiting_2018_2019_by_month))   
   
   ongoing_waits %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type == input$out_or_inpatient) %>% 
#     filter(hb_name == "NHS Highland") %>% 
#     filter(patient_type %in% c("New Outpatient, "Inpatient/Day case") %>%    
     group_by(month_ending) %>% 
     mutate(total_waiting_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     mutate(percentage_var = (total_waiting_by_month - avg_2018_2019$avg_num_waiting)
            / avg_2018_2019$avg_num_waiting * 100) %>% 
     
     timeseriesplot(aes(month_ending, percentage_var), "Treatment Waiting Times", 
                    "% change relative to 2018/19") 
   })
   
# Delayed Discharge      
      output$discharge_delays <- renderPlot({
      plotdata <- delayed_discharge %>% 
         filter(reason_for_delay %in% input$dd_reason_for_delay) %>% 
         filter(hb_name %in% input$dd_health_board) %>% 
         filter(age_group %in% input$dd_age_group)
      plotmapping <- aes(x=mdate, y=percent_var) 
      plottitle <- ("Number of delayed bed days - by xxx")
      plotylabel <- ("% change relative to 2018/19") 
      timeseriesplot2(plotdata,plotmapping,plottitle,plotylabel)
   })
   

# Bed occupancy
      output$beds <- renderPlot({
      plotdata <- bed_occupancy %>% 
        filter(specialty_name == "All Acute")
      plotmapping <- aes(x = made_date, y = percentage_occupancy)
      plottitle <- ("Hospital bed occupancy")
      plotylabel <- ("% occupancy")
      timeseriesplot2(plotdata,plotmapping,plottitle,plotylabel)
      })

}
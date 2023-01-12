library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$map <- renderLeaflet({

fake_data_to_map <- fake_data %>% 
       filter(fake_situation == input$map_data_to_display)
     
     leaflet(scot_hb_shapefile) %>% 
# addTiles adds scotland map from OpenStreetMap  
       addTiles() %>% 
# addPolygons adds health board shape from shapefile
       addPolygons(color = "black", weight = 1) %>% 
# fit scotland onto map using fitBounds once we know the dimensions of the map
      fitBounds(lat1 = 55, lng1 = -7, lat2 = 61, lng2 = 0) %>% 
       addCircleMarkers(lng = health_board_lat_lon$Longitude, 
                        lat = health_board_lat_lon$Latitude,
                        radius = fake_data_to_map$fake_number,
                        color = "purple",
                        weight = 3,
                        opacity = 0.8,
                        label = health_board_lat_lon$HBName)
   }) 

  
# A&E Waiting Times    
   output$a_and_e_waiting_times <- renderPlot({
     
     avg_2018_2019 <- waiting_times %>% 
       filter(date >= "2018-01-01" & date <= "2019-12-31") %>% 
       filter(department_type %in% input$minor_or_emerg_dept) %>% 
       filter(hb_name == input$health_board) %>% 
       summarise(avg_percent_meeting_target = mean(percent_meeting_target))  
     
     waiting_times %>% 
       filter(date >= "2020-01-01") %>% 
       filter(department_type %in% input$minor_or_emerg_dept) %>% 
       filter(hb_name == input$health_board) %>% 
       group_by(date) %>% 
       summarise(percent_meeting_target_by_month = mean(percent_meeting_target)) %>% 
       
       timeseriesplot(aes(date, percent_meeting_target_by_month),
                      "A&E - Percentage of Attendances Meeting 
                      4 Hour Target", 
                      "% Meeting 4 Hour Target") +
       geom_hline(yintercept = 95, colour = "#964091", linetype = "dashed") + 
       geom_hline(yintercept = avg_2018_2019$avg_percent_meeting_target, 
                  colour = "#86BC25", linetype = "dashed") +
       annotate(geom = "label", x = as.Date("2022-08-01"), y = 95, 
                label = "NHS 95% Target", colour = "#964091", fill = "white",
                alpha = 0.8) +
       annotate(geom = "label", x = as.Date("2022-08-01"), 
                y = avg_2018_2019$avg_percent_meeting_target, 
                label = "2018/2019 Average", colour = "#86BC25", fill = "white",
                alpha = 0.8)
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

# Hospital admissions  by speciality
   output$admissions_byspec <- renderPlot({
      plotdata <- admissions_spec %>% 
         filter(admission_type %in% input$ha_admission_type) %>% 
         filter(hb_name %in% input$ha_health_board) %>% 
         filter(age_group == "All ages") %>% 
         filter(speciality %in% input$ha_health_board) %>% 
         plotmapping <- aes(x=mdate, y=percent_var, colour = age_group) 
         plottitle <- ("Weekly number of hospital admissions - by speciality")
         plotylabel <- ("% change relative to 2018/19") 
         timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })    
   
      
# Hospital admissions  by age    
   output$admissions_byage <- renderPlot({
      plotdata <- admissions_demog %>% 
         filter(admission_type == "All") %>% 
         filter(hb_name %in% input$ha_health_board) %>% 
         filter(age_group %in% input$ha_age_group) %>% 
         filter(sex =="All") %>% 
      plotmapping <- aes(x=mdate, y=percent_var, colour = age_group) 
      plottitle <- ("Weekly number of hospital admissions - by age")
      plotylabel <- ("% change relative to 2018/19") 
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })   
   
# Treatment Waiting Times
   
   output$treatment_waiting_times <- renderPlot({
   avg_2018_2019 <- ongoing_waits %>% 
     filter(month_ending >= "2018-01-01" & month_ending <= "2019-12-31") %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type %in% input$out_or_inpatient) %>% 
#     filter(hb_name == "NHS Highland") %>% 
#    filter(patient_type %in% c("New Outpatient", "Inpatient/Day case")) %>%      
     group_by(month_ending) %>% 
     summarise(num_waiting_2018_2019_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     summarise(avg_num_waiting = mean(num_waiting_2018_2019_by_month))   
   
   ongoing_waits %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type %in% input$out_or_inpatient) %>% 
#     filter(hb_name == "NHS Highland") %>% 
#     filter(patient_type %in% c("New Outpatient", "Inpatient/Day case")) %>%    
     group_by(month_ending) %>% 
     mutate(total_waiting_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     mutate(percentage_var = (total_waiting_by_month - avg_2018_2019$avg_num_waiting)
            / avg_2018_2019$avg_num_waiting * 100) %>% 
     
     timeseriesplot(aes(month_ending, percentage_var, colour = patient_type), 
                    "Treatment Waiting Times for Ongoing Waits", 
                    "% change relative to 2018/19") +
     labs(subtitle = "Number of People on Waiting Lists")
   })
   
# Delayed Discharge  by age    
      output$discharge_delays_byage <- renderPlot({
      plotdata <- delayed_discharge %>% 
         filter(reason_for_delay == "All Delay Reasons") %>% 
         filter(hb_name %in% input$dd_health_board) %>% 
         filter(age_group %in% input$dd_age_group)
      plotmapping <- aes(x=mdate, y=percent_var, colour = age_group) 
      plottitle <- ("Number of delayed bed days - by age")
      plotylabel <- ("% change relative to 2018/19") 
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })
      
# Delayed Discharge  by reason for delay   
   output$discharge_delays_byreason <- renderPlot({
  plotdata <- delayed_discharge %>% 
       filter(reason_for_delay %in% input$dd_reason_for_delay) %>% 
       filter(hb_name %in% input$dd_health_board) %>% 
       filter(age_group == "All (18plus)")
     plotmapping <- aes(x=mdate, y=percent_var, colour = reason_for_delay) 
     plottitle <- ("Number of delayed bed days - by reason for delay")
     plotylabel <- ("% change relative to 2018/19") 
     timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
      })

# Bed occupancy
      output$beds <- renderPlot({
      plotdata <- bed_occupancy %>%
         filter(specialty_name == "All Acute") %>%
         filter(hb_name == input$occ_health_board) %>% 
         filter(location_qf == "d")
      plotmapping <- aes(x = made_date, y = percentage_occupancy)
      plottitle <- ("Hospital bed occupancy")
      plotylabel <- ("% occupancy")
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel) +
      geom_hline(yintercept = 85, colour = "#651C32", linetype = "dashed") + 
      annotate(geom = "label", x = as.Date("2022-08-01"), y = 85, 
                  label = "85% Risk Threshold", colour = "#651C32", fill = "white",
                  alpha = 0.8)
      })

# Length of stay (relative to 2018/19 avg)
      output$stay_change <- renderPlot({
      plotdata <- stay_length %>% 
         filter(hb_name == input$stay_change_health_board) %>% 
         filter(admission_type %in% c("Elective Inpatients", "Emergency Inpatients")) %>% 
         group_by(year, month_num, made_date, admission_type) %>% 
         summarise(avg_stay = sum(average_length_of_stay, na.rm = TRUE), 
                   pre_pan_avg = sum(average20182019, na.rm = TRUE)) %>% 
         mutate(pcent_change_to_pre_pan_avg = (avg_stay - pre_pan_avg) / pre_pan_avg * 100)
      plotmapping <- aes(x = made_date, y = pcent_change_to_pre_pan_avg, 
                         group = admission_type, colour = admission_type)
      plottitle <- ("Change in length of hospital stay (compared to 2018/19)")
      plotylabel <- ("% change relative to 2018/19")
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
      })
      
# Length of stay (admission type)
      output$stay_admission <- renderPlot({
      plotdata <- stay_length %>% 
         filter(hb_name == input$stay_admission_health_board) %>% 
         filter(admission_type %in% c("Elective Inpatients", "Emergency Inpatients")) %>% 
         group_by(year, month_num, made_date, admission_type) %>% 
         summarise(avg_stay = sum(average_length_of_stay, na.rm = TRUE))
      plotmapping <- aes(x = made_date, y = avg_stay, group = admission_type, colour = admission_type)
      plottitle <- ("Average length of hospital stay")
      plotylabel <- ("days")
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
      })
      
      
      
}
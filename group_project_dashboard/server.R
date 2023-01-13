library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$map <- renderLeaflet({

  data_to_map <- summary_tab_map_data %>% 
       filter(metric == input$map_data_to_display)
     
     leaflet(scot_hb_shapefile) %>% 
# addTiles adds scotland map from OpenStreetMap  
       addTiles() %>% 
# addPolygons adds health board shape from shapefile
       addPolygons(color = "black", weight = 1) %>% 
# fit scotland onto map using fitBounds once we know the dimensions of the map
      fitBounds(lat1 = 55, lng1 = -7, lat2 = 61, lng2 = 0) %>% 
       addCircleMarkers(lng = health_board_lat_lon$Longitude, 
                        lat = health_board_lat_lon$Latitude,
                        radius = data_to_map$scaled_value,
                        color = "purple",
                        weight = 3,
                        opacity = 0.8,
                        label = health_board_lat_lon$HBName)
   }) 

  output$summary_table <- renderTable(summary_tab_table_data)
   
   
   
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
                      "A&E Attendances Meeting 4 Hour Target", 
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
         filter(speciality %in% input$ha_speciality) 
         plotmapping <- aes(x=wdate, y=percent_var, colour = speciality) 
         plottitle <- ("Weekly number of hospital admissions - by speciality")
         plotylabel <- ("% change relative to 2018/19") 
         timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   }) 
   
# Hospital admissions  by speciality - barplot
   output$admissions_byspec_bar <- renderPlot({
      plotdata <- admissions_spec %>% 
         filter(speciality != "All") %>%
         ggplot() +
         aes(x=speciality, y=number_admissions, fill = as.factor(year)) +
         geom_col(position = "dodge") #+
         #scale_fill_manual(palette=palette$mycolours)
   })  
   
      
# Hospital admissions  by age    
   output$admissions_byage <- renderPlot({
      plotdata <- admissions_demog %>% 
         filter(admission_type %in% input$ha_admission_type) %>% 
         filter(hb_name %in% input$ha_health_board) %>% 
         filter(age_group %in% input$ha_age_group) %>% 
         filter(sex =="All")  
      plotmapping <- aes(x=wdate, y=percent_var, colour = age_group) 
      plottitle <- ("Weekly number of hospital admissions - by age")
      plotylabel <- ("% change relative to 2018/19") 
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })   
   
# Hospital admissions  by dep   
   output$admissions_bydep <- renderPlot({
      plotdata <- admissions_dep %>% 
         filter(admission_type %in% input$ha_admission_type) %>% 
         filter(hb_name %in% input$ha_health_board) %>% 
         filter(simd_quintile %in% input$ha_dep_index) 
      plotmapping <- aes(x=wdate, y=percent_var, colour = as.factor(simd_quintile)) 
      plottitle <- ("Weekly number of hospital admissions - by SIMD")
      plotylabel <- ("% change relative to 2018/19") 
      timeseriesplot(plotdata,plotmapping,plottitle,plotylabel)
   })      
   
# Treatment Waiting Times
   
   output$treatment_waiting_times <- renderPlot({
   avg_2018_2019 <- ongoing_waits %>% 
     filter(month_ending >= "2018-01-01" & month_ending <= "2019-12-31") %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type %in% input$out_or_inpatient) %>% 
     group_by(month_ending) %>% 
     summarise(num_waiting_2018_2019_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     summarise(avg_num_waiting = mean(num_waiting_2018_2019_by_month))   
   
   ongoing_waits %>% 
     filter(hb_name == input$treat_wait_health_board) %>% 
     filter(patient_type %in% input$out_or_inpatient) %>% 
     group_by(month_ending) %>% 
     mutate(total_waiting_by_month = sum(number_waiting, na.rm = TRUE)) %>% 
     mutate(percentage_var = (total_waiting_by_month - avg_2018_2019$avg_num_waiting)
            / avg_2018_2019$avg_num_waiting * 100) %>% 
     
     timeseriesplot(aes(month_ending, percentage_var, colour = patient_type), 
                    "Number of People on Waiting Lists for Treatment", 
                    "% change relative to 2018/19") 
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
      
# Delayed Discharge  for statistical analysis  
      output$discharge_delays_byreason_x <- renderPlot({
         plotdata <- delayed_discharge %>% 
            filter(reason_for_delay %in% input$stat_reason_for_delay) %>% 
            filter(hb_name %in% input$stat_health_board) %>% 
            filter(age_group %in% input$stat_age_group)
         plotmapping <- aes(x=mdate, y=percent_var, colour = reason_for_delay) 
         plottitle <- ("Number of delayed bed days - by reason for delay")
         plotylabel <- ("% change relative to 2018/19") 
         timeseriesplot2(plotdata,plotmapping,plottitle,plotylabel)
      })
         
 # Delayed Discharge  for statistical analysis  
      output$smooth_prepandemic <- renderPlot({
         seldata <- delayed_discharge %>% 
            filter(hb_name %in% input$stat_health_board) %>% 
            filter(age_group %in% input$stat_age_group) %>% 
            filter(reason_for_delay %in% input$stat_reason_for_delay) %>% 
            filter(mdate < as.Date("2020-01-01")) %>% 
            rename(param = number_of_delayed_bed_days) %>% 
            select(mdate, param, iswinter) 
         
         smoothed_data1 <- data_smoother(seldata[1],seldata)
         smoothed_data1 <- smoothed_data1 %>% 
            mutate(mvar = param - moving_avg) 
         # now for plot - could create function
         plotlim <- as.Date(c("2018-01-01","2019-12-31")) 
         ggplot(smoothed_data1) +
            geom_line(aes(x = mdate, y = param), colour = palette$mycolours[1]) +
            geom_line(aes(x = mdate, y = moving_avg), colour = palette$mycolours[2]) +
            geom_line(aes(x = mdate, y = mvar+mean(moving_avg)), colour = palette$mycolours[3]) +
            scale_x_date(limits=plotlim, date_breaks="3 month", 
                         labels = scales::label_date_short(), expand = c(0,0)) +
            # add dashed lines to show the boundaries 
            geom_vline(xintercept=ymd(20201001),color="gray",linetype="dotted", linewidth = 0.5) +
            geom_vline(xintercept=ymd(20211001),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20221001),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20200401),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20210401),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20220401),color="gray",linetype="dotted", linewidth = 0.5) +
            theme_phs +
            xlab("Date") +   
            ylab("data(purple), trend(red), residual+mean (green)") +
            ggtitle("Pre-pandemic Data") + 
         #add rectangles to denote winter
            annotate("rect", 
                     xmin=c(ymd(plotlim[1]),ymd(20181001),ymd(20191001)),
                     xmax=c(ymd(20180401),ymd(20190401),plotlim[2]), 
                     ymin=c(-Inf,-Inf,-Inf), 
                     ymax=c(Inf,Inf,Inf), 
                     alpha=0.1, fill="gray")   
      })   
      
      # Delayed Discharge  for statistical analysis  
      output$boxplot_prepandemic <- renderPlot({
         seldata <- delayed_discharge %>% 
            filter(hb_name %in% input$stat_health_board) %>% 
            filter(age_group %in% input$stat_age_group) %>% 
            filter(reason_for_delay %in% input$stat_reason_for_delay) %>% 
            filter(mdate < as.Date("2020-01-01")) %>% 
            rename(param = number_of_delayed_bed_days) %>% 
            select(mdate, param, iswinter) 
         
         smoothed_data1 <- data_smoother(seldata[1],seldata)
         smoothed_data1 <- smoothed_data1 %>% 
            mutate(mvar = param - moving_avg) 
         p_value1 <- stats_test(smoothed_data1)
       
         smoothed_data1 %>% 
            ggplot() +
            aes(x=iswinter, y=mvar) +
            geom_boxplot() +
            ylab("residual values (data - long term trend)") +
            xlab("Season") +
            scale_x_discrete(
               labels=c("FALSE" = "Summer (Apr-Sep)", "TRUE" = "Winter (Oct-Mar)"), 
               limits = c("FALSE","TRUE")) +
            theme_phs +
            if (p_value1 < 0.05){ggtitle(str_c("Seasonal Test  p_value=",as.character(p_value1)), 
                                        subtitle = "Winter higher than Summer")
            }else{
               ggtitle(c("Seasonal Test",as.character(p_value1)), 
                       subtitle = "No significant difference in Winter/Summer")     
               }
         
      })   
      # Delayed Discharge  for statistical analysis  
      output$smooth_postpandemic <- renderPlot({
         seldata <- delayed_discharge %>% 
            filter(hb_name %in% input$stat_health_board) %>% 
            filter(age_group %in% input$stat_age_group) %>% 
            filter(reason_for_delay %in% input$stat_reason_for_delay) %>% 
            filter(mdate > as.Date("2020-04-01")) %>% 
            rename(param = number_of_delayed_bed_days) %>% 
            select(mdate, param, iswinter) 
         
         smoothed_data2 <- data_smoother(seldata[1],seldata)
         smoothed_data2 <- smoothed_data2 %>% 
            mutate(mvar = param - moving_avg) 
         # now for plot - could create function
         plotlim <- as.Date(c("2020-01-01","2022-12-31")) 
         ggplot(smoothed_data2) +
            geom_line(aes(x = mdate, y = param), colour = palette$mycolours[1]) +
            geom_line(aes(x = mdate, y = moving_avg), colour = palette$mycolours[2]) +
            geom_line(aes(x = mdate, y = mvar+mean(moving_avg)), colour = palette$mycolours[3]) +
            scale_x_date(limits=plotlim, date_breaks="3 month", 
                         labels = scales::label_date_short(), expand = c(0,0)) +
            # add dashed lines to show the boundaries 
            geom_vline(xintercept=ymd(20201001),color="gray",linetype="dotted", linewidth = 0.5) +
            geom_vline(xintercept=ymd(20211001),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20221001),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20200401),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20210401),color="gray",linetype="dotted", linewidth = 0.5) + 
            geom_vline(xintercept=ymd(20220401),color="gray",linetype="dotted", linewidth = 0.5) +
            theme_phs +
            xlab("Date") +   
            ylab("data(purple), trend(red), residual+mean (green)") +
            ggtitle("Post-pandemic Data") + 
            #add rectangles to denote winter
            annotate("rect", 
                     xmin=c(ymd(plotlim[1]),ymd(20201001),ymd(20211001),ymd(20221001)),
                     xmax=c(ymd(20200401),ymd(20210401),ymd(20220401),plotlim[2]), 
                     ymin=c(-Inf,-Inf,-Inf,-Inf), 
                     ymax=c(Inf,Inf,Inf,Inf), 
                     alpha=0.1, fill="gray")  
      })   
      
      # Delayed Discharge  for statistical analysis  
      output$boxplot_postpandemic <- renderPlot({
         seldata <- delayed_discharge %>% 
            filter(hb_name %in% input$stat_health_board) %>% 
            filter(age_group %in% input$stat_age_group) %>% 
            filter(reason_for_delay %in% input$stat_reason_for_delay) %>% 
            filter(mdate > as.Date("2020-04-01")) %>% 
            rename(param = number_of_delayed_bed_days) %>% 
            select(mdate, param, iswinter) 
         
         smoothed_data2 <- data_smoother(seldata[1],seldata)
         smoothed_data2 <- smoothed_data2 %>% 
            mutate(mvar = param - moving_avg) 
         p_value2 <- stats_test(smoothed_data2)
         
         smoothed_data2 %>% 
            ggplot() +
            aes(x=iswinter, y=mvar) +
            geom_boxplot() +
            ylab("residual values (data - long term trend)") +
            xlab("Season") +
            scale_x_discrete(
               labels=c("FALSE" = "Summer (Apr-Sep)", "TRUE" = "Winter (Oct-Mar)"), 
               limits = c("FALSE","TRUE")) +
            theme_phs +
            if (p_value2 < 0.05){ggtitle("Seasonal Test  p_value=",as.character(p_value2))
            }else{
               ggtitle("Seasonal Test", subtitle = "No significant difference in Winter/Summer")     
            }
      })   
      
      
}
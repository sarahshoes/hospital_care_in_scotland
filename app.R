# LOAD LIBRARIES

library(sf)
library(tidyverse)
library(leaflet)
#library(shiny)
library(lubridate)
library(grid) #needed for custom annotation


# Load plot theme and function to prepare plot
source(here::here("palette_theme/define_theme.R"), local = TRUE)
source(here::here("palette_theme/plot_timeseries.R"), local = TRUE)
source(here::here("palette_theme/plot_timeseries_z.R"), local = TRUE)
source(here::here("palette_theme/plot_timeseriesv2.R"), local = TRUE)
palette <- read_csv(here::here("palette_theme/phs_palette.csv"))

#source functions for stats test
source(here::here("r_scripts_and_notebooks/fun_smoother.R"), local = TRUE)
source(here::here("r_scripts_and_notebooks/fun_stats_test.R"), local = TRUE)

# HEALTH BOARD NAMES
health_board_list <- read_csv(here::here("lookup_tables/health_board_codes.csv")) %>% 
  janitor::clean_names() %>% 
  distinct(hb_name) %>% 
  pull()

# A&E WAITING TIMES

waiting_times <- read_csv(here::here("clean_data/a_and_e_data_clean.csv")) %>% 
  janitor::clean_names()

# ADMISSION - COVID CASES 
covid_cases <- read_csv(here::here("clean_data/covid_cases_clean.csv")) 

# ADMISSIONS - BY SPECIALITY, DEMOG and DEPRIVATION 
admissions_spec <- read_csv(here::here("clean_data/weekly_admissions_spec_clean.csv")) 
admissions_demog <- read_csv(here::here("clean_data/weekly_admissions_demog_clean.csv")) 
admissions_dep <- read_csv(here::here("clean_data/weekly_admissions_dep_clean.csv")) 

# TREATMENT WAITING TIMES

ongoing_waits <- read_csv(here::here("clean_data/treatment_waiting_times_ongoing.csv"))


# DISCHARGE DELAYS

delayed_discharge <- read_csv(here::here("clean_data/delayed_discharge_clean.csv"))  


# BED OCCUPANCY

bed_occupancy <- read_csv(here::here("clean_data/bed_occupancy_clean.csv"))


# STAY LENGTH

stay_length <- read_csv(here::here("clean_data/stay_length_clean.csv"))


# HEALTH BOARD MAP 

scot_hb_shapefile <- st_read(here::here("map_files/scot_hb_shapefile_simplified.shp"))

health_board_lat_lon <- read_csv(here::here("map_files/health_board_lat_lon.csv"))  

summary_tab_map_data <- read_csv(here::here("clean_data/summary_tab_map_data.csv"))

# SUMMARY TAB DATA

summary_tab_table_data <- read_csv(here::here("clean_data/summary_tab_table_data.csv"))





# ui ----------------------------------------------------------------------


ui <- fluidPage(
  titlePanel("Hospital Care in Scotland"),
  tabsetPanel(
    tabPanel("Summary",
             fluidRow(
               column(4,
                      leafletOutput("map")
               ),
               column(8, 
                      #   tags$h2("Covid Admissions")
                      tableOutput("summary_table")
               )
             ),
             fluidRow(
               column(4, 
                      selectInput(inputId = "map_data_to_display",
                                  label = "Select Data to Display",
                                  choices = unique(summary_tab_map_data$metric),
                                  selected = "A&E % Treated in 4 h")
               )
             )
    ),
    
    
    tabPanel("Admissions - demographics",
             fluidRow(
               column(width = 3,
                      checkboxGroupInput(inputId = "ha_age_group",
                                         label = "Select Age Group",
                                         choices = unique(admissions_demog$age_group),
                                         selected = "All ages")
               )
               ,
               column(width = 3,                      
                      selectInput(inputId = "ha_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"),
               )
               ,
               column(width = 3,
                      radioButtons(inputId = "ha_admission_type",
                                   label = "Select Admission Type",
                                   choices = unique(admissions_spec$admission_type),
                                   selected = "All")
               )
               ,
               column(width = 3,
                      checkboxGroupInput(inputId = "ha_dep_index",
                                         label = "Select SIMD Index",
                                         choices = unique(admissions_dep$simd_quintile),
                                         selected=c(1,5),
                                         inline = TRUE)
               )
             ),
             fluidRow(
               column(width=6,
                      plotOutput("admissions_byage") 
               ),
               column(width=6,
                      plotOutput("admissions_bydep") 
               )
             ),
             fluidRow(  
               column(width=6,
                      checkboxGroupInput(inputId = "ha_speciality",
                                         label = "Speciality",
                                         choices = unique(admissions_spec$speciality),
                                         selected = "All", 
                                         inline = TRUE)
               )
             ),
             fluidRow(
               column(width=6,
                      plotOutput("admissions_byspec") 
               ),
               column(width=6,
                      plotOutput("admissions_byspec_bar") 
               )
             )
    ), 
    
    tabPanel("Admissions",
             # fluid row 1 - admissions
             fluidRow(
               column(width = 6, 
                      tags$h2("A&E Waiting Times")
               ),
               column(width = 6, 
                      tags$h2("Covid Admissions")
               )
             ),
             # fluid row 2 - admissions
             fluidRow(
               column(width = 3,
                      checkboxGroupInput(inputId = "minor_or_emerg_dept",
                                         label = "Select Department Type",
                                         choices = unique(waiting_times$department_type),
                                         selected = c("Minor Injury Unit or Other",
                                                      "Emergency Department")
                      )
               ),
               column(width = 3,
                      selectInput(inputId = "health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"
                      )
               ),
               column(width = 6,
                      checkboxGroupInput(inputId = "cc_age_group",
                                         label = "Select Age Group",
                                         choices = unique(covid_cases$age_band),
                                         selected = "All ages (0plus)"
                      )
               )
             ),
             # fluid row 3 - admissions
             fluidRow(
               column(width = 6,
                      plotOutput("a_and_e_waiting_times")
               ),
               column(width = 6,
                      plotOutput("covid_cases")
               )
             ),
             
             # fluid row 4 - admissions
             fluidRow(
               column(width = 6, 
                      tags$h2("Treatment Waiting Lists")
               )
             ),
             
             # fluid row 5 - admissions
             fluidRow(
               column(width = 3, 
                      checkboxGroupInput(inputId = "out_or_inpatient",
                                         label = "Patient Type",
                                         choices = unique(ongoing_waits$patient_type),
                                         selected = c("New Outpatient",
                                                      "Inpatient/Day case")
                      )
               ),
               column(width = 3,
                      selectInput(inputId = "treat_wait_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"
                      )
               )
             ),
             
             # fluid row 5 - admissions
             fluidRow(
               column(width = 6,
                      plotOutput("treatment_waiting_times"),
                      tags$a("Note: There are issues with NHS Tayside results caused by
                             missing data from 2017 and 2018.")
               ) 
             )
    ),
    
    tabPanel("Hospital Activity",
             fluidRow(
               column(width = 12, 
                      tags$h2("Length of Hospital Stay")
               )
             ),
             
             fluidRow(
               column(width = 6,
                      selectInput(inputId = "stay_admission_health_board", 
                                  label = "Select Health Board", 
                                  choices = health_board_list, 
                                  selected = "All Scotland"), 
                      plotOutput("stay_admission")
               ), 
               column(width = 6, 
                      selectInput(inputId = "stay_change_health_board", 
                                  label = "Select Health Board", 
                                  choices = health_board_list, 
                                  selected = "All Scotland"), 
                      plotOutput("stay_change")
               )
               
               
             ),
             
             fluidRow(
               column(width = 6, 
                      tags$h2("Bed Occupancy")
               )
             ),
             
             fluidRow(
               
               column(width = 6, 
                      selectInput(inputId = "occ_health_board", 
                                  label = "Select Health Board", 
                                  choices = health_board_list, 
                                  selected = "All Scotland"),
                      plotOutput("beds") 
               )
             )
    ),
    
    tabPanel("Discharge",
             # Delayed Discharge             
             fluidRow(
               column(width = 4,
                      checkboxGroupInput(inputId = "dd_age_group",
                                         label = "Select Age Group",
                                         choices = unique(delayed_discharge$age_group),
                                         selected = "All (18plus)")
               )
               ,
               column(width = 4,                      
                      selectInput(inputId = "dd_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"))
               ,
               column(width = 4,
                      checkboxGroupInput(inputId = "dd_reason_for_delay",
                                         label = "Select Delay Reason",
                                         choices = unique(delayed_discharge$reason_for_delay),
                                         selected = "All Delay Reasons")        
               )
             ),
             fluidRow(
               column(width = 6,
                      plotOutput("discharge_delays_byage")
               ),
               column(width=6,
                      plotOutput("discharge_delays_byreason")
               )
             ),
    ),
    tabPanel("Seasonal Statistics",
             fluidRow(
               column(width = 3,
                      checkboxGroupInput(inputId = "stat_reason_for_delay",
                                         label = "Select Delay Reason",
                                         choices = unique(delayed_discharge$reason_for_delay),
                                         selected = "All Delay Reasons"),
                      
                      selectInput(inputId = "stat_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"),
                      
                      radioButtons(inputId = "stat_age_group",
                                   label = "Select Age Group",
                                   choices = unique(delayed_discharge$age_group),
                                   selected = "All (18plus)")
               ),
               column(width = 8,
                      plotOutput("discharge_delays_byreason_x") 
               )
             ),
             fluidRow(
               column(width = 6, 
                      tags$h2("Statistical Analysis")
               )
             ),
             fluidRow(
               column(width=3,
                      plotOutput("smooth_prepandemic")
               ),
               column(width=3,
                      plotOutput("boxplot_prepandemic")
               ),
               column(width=3,
                      plotOutput("smooth_postpandemic")
               ),
               column(width=3,
                      plotOutput("boxplot_postpandemic")
               )
             )
    )
    #end brackets for fluidpage and tabsetpanel
  )
) 



# server ------------------------------------------------------------------



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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
  }) 
  
  # Hospital admissions  by speciality - barplot
  output$admissions_byspec_bar <- renderPlot({
    admissions_spec %>% 
      filter(speciality != "All") %>%
      ggplot() +
      aes(x=speciality, y=number_admissions, group = speciality) +
      geom_col(position = "dodge") +
      #scale_colour_manual(palette=palette$mycolours)
      theme_phs
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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
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
      
      timeseriesplot_z(aes(month_ending, percentage_var, colour = patient_type), 
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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
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
    timeseriesplot_z(plotdata,plotmapping,plottitle,plotylabel)
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
        ggtitle(str_c("Seasonal Test  p_value=",as.character(p_value1)), 
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
      if (p_value2 < 0.05){ggtitle(str_c("Seasonal Test  p_value=",as.character(p_value2)), 
                                   subtitle = "Winter higher than Summer")
      }else{
        ggtitle(str_c("Seasonal Test  p_value=",as.character(p_value2)), 
                subtitle = "No significant difference in Winter/Summer")     
      }
  })   
  
  
}


shinyApp(ui, server)

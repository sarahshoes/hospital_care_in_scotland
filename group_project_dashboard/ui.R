library(shiny)



ui <- fluidPage(
  titlePanel("Dashboard Title"),
  tabsetPanel(
    tabPanel("Summary",
             fluidRow(
               column(4,
                      leafletOutput("map")
               )
             )
    ),
    tabPanel("Admissions",
             # A&E Waiting Times 
             fluidRow(
               column(width = 6,
                      checkboxGroupInput(inputId = "minor_or_emerg_dept",
                                         label = "Select Department Type",
                                         choices = unique(waiting_times$department_type),
                                         selected = c("Minor Injury Unit or Other",
                                                      "Emergency Department")
                      ),
                      selectInput(inputId = "health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland"
                                  ),
                      plotOutput("a_and_e_waiting_times")
                      ),
               column(width = 6,
                      checkboxGroupInput(inputId = "cc_age_group",
                                         label = "Select Age Group",
                                         choices = unique(covid_cases$age_band),
                                         selected = "All ages (0plus)"),
                      plotOutput("covid_cases")
               )
             )
    ),
    
    
    tabPanel("Hospital Activity",
             # Treatment Waiting Times
             fluidRow(
               column(width = 6, 
                      checkboxGroupInput(inputId = "out_or_inpatient",
                                         label = "Patient Type",
                                         choices = unique(ongoing_waits$patient_type),
                                         selected = c("New Outpatient",
                                                      "Inpatient/Day case")
                      ),
                      selectInput(inputId = "treat_wait_health_board",
                                  label = "Select Health Board",
                                  choices = unique(ongoing_waits$hb_name),
                                  selected = "NHS Scotland"
                      ),
                      plotOutput("treatment_waiting_times"),
                      tags$a("Note: There are issues with NHS Tayside results caused by
                             missing data from 2017 and 2018.")
               ), 
               column(width = 6, 
                      selectInput(inputId = "occ_health_board", 
                                  label = "Select Health Board", 
                                  choices = health_board_list, 
                                  selected = "All Scotland"),
                      plotOutput("beds") 
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
               
               
             )
    ),
    
    
    tabPanel("Discharge",
             # Delayed Discharge             
             fluidRow(
               column(width = 6,
                      checkboxGroupInput(inputId = "dd_age_group",
                                         label = "Select Age Group",
                                         choices = unique(delayed_discharge$age_group),
                                         selected = "All (18plus)")
                      ,
                      selectInput(inputId = "dd_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland")
                      ,
                      
                      plotOutput("discharge_delays_byage")
               )
               ,
               column(width=6,
                      
                      checkboxGroupInput(inputId = "dd_reason_for_delay",
                                         label = "Select Delay Reason",
                                         choices = unique(delayed_discharge$reason_for_delay),
                                         selected = "All Delay Reasons")
                      ,
                      selectInput(inputId = "dd_health_board",
                                  label = "Select Health Board",
                                  choices = health_board_list,
                                  selected = "All Scotland")
                      ,
                      plotOutput("discharge_delays_byreason")
               )
             )
    )
    
    #end brackets for fluidpage and tabsetpanel
  )) 



library(shiny)

ui <- fluidPage(
  titlePanel("Hospital Care in Scotland"),
  tabsetPanel(
    tabPanel("Summary",
             fluidRow(
               column(4,
                      leafletOutput("map")
               )
               ),
             fluidRow(
               column(4, 
                      selectInput(inputId = "map_data_to_display",
                                  label = "Select Data to Display",
                                  choices = unique(fake_data$fake_situation),
                                  selected = "fake beds")
                      )
             )
    ),
    tabPanel("Admissions",
             # A&E Waiting Times 
             fluidRow(
               column(width = 6, 
                      tags$h2("A&E Attendances")
                      ),
               column(width = 6, 
                      tags$h2("Covid Admissions")
                     )
             ),
             
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
             
            fluidRow(
               column(width = 6,
                      plotOutput("a_and_e_waiting_times")
                      ),
               column(width = 6,
                      plotOutput("covid_cases")
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
                                         selected=c(1:5),
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
             fluidRow(),
             fluidRow(
               column(width=6,
                             plotOutput("admissions_byspec") 
                      ),
             column(width=2,
                    checkboxGroupInput(inputId = "ha_speciality",
                                label = "Speciality",
                                choices = unique(admissions_spec$speciality),
                                selected = "All")    
                    ),
             column(width=4,
                    plotOutput("admissions_byspec_bar") 
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
                                  choices = health_board_list,
                                  selected = "All Scotland"
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
             )
    )
    
    #end brackets for fluidpage and tabsetpanel
  )
  ) 



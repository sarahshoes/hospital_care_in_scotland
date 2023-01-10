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
                                  choices = unique(waiting_times$hb_name)
                                  ),
                      plotOutput("a_and_e_waiting_times")
                      ))
               ),
    tabPanel("Hospital Activity"),
    tabPanel("Discharge",
             fluidRow(
               column(width = 6,
                      checkboxGroupInput(inputId = "reason_for_delay",
                                         label = "Select Delay Reason",
                                         choices = unique(delayed_discharge$reason_for_delay,
                                                          selected = "All (18plus)")
                      ),
                      checkboxGroupInput(inputId = "age_group",
                                  label = "Select Age Group",
                                  choices = unique(delayed_discharge$age_group,
                                                   selected = "All (18plus)")
                      ),
                      selectInput(inputId = "health_board",
                                  label = "Select Health Board",
                                  choices = unique(delayed_discharge$hb_name,
                                  selected = "All Scotland")
                      ),
                      plotOutput("discharge_delays")
               ))
             )
  ) 
)


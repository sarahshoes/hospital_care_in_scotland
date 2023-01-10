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
                                         choices = unique(waiting_times$department_type)
                                         ),
                      selectInput(inputId = "health_board",
                                  label = "Select Health Board",
                                  choices = unique(waiting_times$hb_name)
                                  ),
                      plotOutput("a_and_e_waiting_times")
                      ))
               ),
    tabPanel("Hospital Activity"),
    tabPanel("Discharge")
  
)
)


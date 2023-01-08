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
    tabPanel("Admissions"),
    tabPanel("Hospital Activity"),
    tabPanel("Discharge")
  
)
)


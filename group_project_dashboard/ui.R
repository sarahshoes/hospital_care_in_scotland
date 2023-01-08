library(shiny)



ui <- fluidPage(
  titlePanel("Dashboard Title"),
  tabsetPanel(
    tabPanel("Summary",
             leafletOutput("map")
             ),
    tabPanel("Admissions"),
    tabPanel("Hospital Activity"),
    tabPanel("Discharge")
  )
)



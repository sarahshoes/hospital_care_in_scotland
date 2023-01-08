library(shiny)



ui <- fluidPage(
  
  titlePanel("Dashboard Title"),
  
  tabsetPanel(
    tabPanel("Summary"),
    tabPanel("Admissions"),
    tabPanel("Hospital Activity"),
    tabPanel("Discharge")
  )
)






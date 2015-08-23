
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(ggvis)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Varying Crime in Los Angeles in 2014"),
  
  # Sidebar with a slider input for number of bins
  sidebarPanel(
    uiOutput("crimeTypeSelector"),
    textOutput("incidentCount",inline=T)

  ),
  
  
  # Show a plot of the generated distribution
  mainPanel(
    ggvisOutput("p"),
    uiOutput("p_ui"),
    p("Please wait for about 10-20 seconds for initial data to load.
      Then, use the select box to choose a certain crime type. The chart will
      then update with a time series plot of reports for that crime in 2014.
      All data was found at 
      https://data.lacity.org/A-Safe-City/LAPD-Crime-and-Collision-Raw-Data-2014/eta5-h8qx")
  )
))

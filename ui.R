
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source("helpers.R")

shinyUI(fluidPage(

  # Application title
  titlePanel("Springfield What-If Scenarios"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(style="height:600px; overflow-y: scroll", width=9,
      div(style="float:left; margin-right:15px; font-size:75%;", dateRangeInput("popdates", "Enter PoP Date Range:", start=as.Date('2016-10-01'), end=as.Date('2016-12-31'), width="250px")),
      div(style="float:left; margin-right:15px; font-size:75%;", numericInput("target", "Enter Target Hours (total):", value=2325, step=1, min=0, width="180px")),
      div(style="float:left; margin-right:15px; font-size:75%;", numericInput("target_to_date", "Enter Target Hours (to-date):", value=2325/2, step=1, min=0, width="180px")),
      div(style="float:left; margin-right:15px; font-size:75%;", numericInput("actual_to_date", "Enter Actual Hours (to-date):", value=1043, step=1, min=0, width="180px")),
      hr(),
      person(1, "Todd"),
      person(2, "Geoff"),
      person(3, "Dustin"),
      person(4, "Jeff"),
      person(5, "Pete"),
      person(6, "Andy"),
      person(7, "Lauren"),
      person(8, "Ken")
    ),

    # Show a plot of the generated distribution
    mainPanel(width=3,
      strong("Hours that we need:"),
      div(style="font-size: 300%; color:blue;", textOutput("hours_needed")),
      strong("Hours with this scenario:"),
      div(style="font-size: 300%; color:blue;", textOutput("hours")),
      strong("Delta:"),
      div(style="font-size: 300%; color:blue;", textOutput("delta"))
    )
  )
))

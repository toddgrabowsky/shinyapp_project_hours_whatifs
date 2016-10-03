
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(tidyr)
library(dplyr)
library(lubridate)
library(rvest)
library(httr)
library(stringr)
library(R6)

source("helpers.R")

shinyServer(function(input, output) {

  for(i in 1:8) {
    local({
      my_i <- i
      dr <- paste0("daterange", my_i)
      output[[dr]] <- renderUI(dateRangeInput(paste0("daterng", my_i), "Date Range...", start=input$popdates[1], end=input$popdates[2], min=input$popdates[1], max=input$popdates[2]))
    })
  }
  
  # create a sequence of dates within a given range
  dates <- reactive(seq(input$popdates[1], input$popdates[2], by="day"))
  
  # find the business days
  business_days <- reactive(dates()[wday(dates()) %in% 2:6])

  people <- reactive({
    # create a list of Springfield staff and iteratively create objects for each person
    springfield_people <- c("Todd", "Geoff", "Dustin", "Jeff", "Pete", "Andy", "Lauren", "Ken")
    people <- list()
    for(p in springfield_people) {
      pdays <- person_days(business_days())
      eval(parse(text="x <- Person$new(name=p, days=pdays)"))
      eval(parse(text="people[[p]] <- x"))
    }
    people <- unlist(people)
    return(people)
  })
  
  total_hours <- reactive({
    p <- people()
    names <- names(p)
    print(names)
    hours <- c()
    for(i in 1:8) {
      p[[names[i]]]$update_hours(create_schedule(p[[names[i]]]$days, hpd = input[[paste0('hpd', i)]], rep=input[[paste0('rep', i)]], day=input[[paste0('day', i)]], every=input[[paste0('every', i)]], start=input[[paste0('daterng', i)]][1], end=input[[paste0('daterng', i)]][2], hol=input[[paste0('hol', i)]]))
      hours <- c(hours, p[[names[i]]]$hours)
    }
    sum(hours)
  })
  
  hours_needed <- reactive({
    input$target - input$actual_to_date
  })
  
  output$hours_needed <- renderText({
    hours_needed()
  })
  
  output$hours <- renderText({
    total_hours()
  })
  
  output$delta <- renderText({
    hours_needed() - total_hours()
  })

})

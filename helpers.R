# ---
# helper functions
# ---

person <- function(id=1, name="Name") {
  div(class="panel panel-info", style="width:400px;float:left;margin-right:15px;",
    div(class="panel-heading", h3(class="panel-title", strong(name))),
    div(class="panel-body",
      sliderInput(paste0("hpd", id), label="Hours per day:", min=0, max=10, value=8, step=1),
      h4("Schedule"),
      div(style="float:left; margin-right:15px;", selectInput(paste0("rep", id), "Repeat...", choices=c("daily", "weekly"), width="100px")),
      conditionalPanel(paste0("input.rep", id, " == 'weekly'"), 
        div(style="float:left; margin-right:15px;", selectInput(paste0("day", id), "On Days...", choices=c("Monday"=2, "Tuesday"=3, "Wednesday"=4, "Thursday"=5, "Friday"=6), multiple=TRUE, width="120px")),
        div(style="float:left;", numericInput(paste0("every", id), "Every...", value=1, min=1, max=10, step=1, width="50px"))
      ),
      div(style="display:inline-block; width:100%;",
        uiOutput(paste0("daterange", id)),
        checkboxInput(paste0("hol", id), "Exclude holidays?", value=TRUE)
      )
    )
  )
}


# federal holidays
url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/"
x <- GET(url, add_headers('user-agent' = 'r'))
html <- x %>% read_html
years <- html %>%
  html_nodes("section h1") %>%
  html_text() %>%
  .[-1] 

holidays <- html %>%
  html_nodes("table") %>%
  html_table %>%
  .[(length(.)-length(years)+1):length(.)]

names(holidays) <- years

holidays <- lapply(names(holidays), function(x) {
  df <- holidays[[x]]
  df$Date <- gsub("[*]", "", df$Date)
  df$Date <- paste(df$Date, x, sep=" ")
  df$Date <- unname(sapply(df$Date, function(x) str_extract(x, "(?<=, ).*")))
  df$Date <- as.Date(df$Date, format="%B %d %Y")
  holidays[[x]] <- df
})

names(holidays) <- years

# fix MLK Day 2011 which actually occurs in 2010
holidays[[10]]$Date[1] <- gsub(" 2011", "", holidays[[10]]$Date[1])

year <- as.character(2016)
holidays <- holidays[[year]]
holidays$Holiday <- repair_encoding(holidays$Holiday)


# create a person object
Person <- R6Class("Person",
                  public=list(
                    name=NA,
                    days=NA,
                    initialize=function(name, days) {
                      if (!missing(name)) self$name <- name
                      if (!missing(days)) self$days <- days
                      self$about()
                    },
                    # quick info about person
                    about=function() {
                      cat(paste0(self$name, " is awesome!\n"))
                    },
                    # create a function to update hours for a person
                    update_hours=function(hours) {
                      self$days$hours <- hours
                      cat(paste0(self$name, "'s hours have been updated.\n"))
                    }
                    
                  ),
                  active=list(
                    hours=function() {
                      sum(self$days$hours)
                    }
                  )
)

# write function to create a data frame of business days and hours for a person
person_days <- function(days) {
  pdays <- data.frame(matrix(ncol=2, nrow=length(days)))
  names(pdays) <- c("date", "hours")
  pdays$date <- days
  pdays$hours <- rep(0, length(days))
  return(pdays)
}

# write a function to create different types of schedules
create_schedule <- function(df, hpd=8, rep="weekly", day=2:5, every=1, start=min(days), end=max(days), hol=TRUE) {
  # need to make some assertions here for input validation
  
  # reset all hours values to zero
  df$hours <- 0 
  
  schedule <- switch(rep,
                     daily={
                       d <- seq(start+20, end, by="days")
                       d <- d[wday(d) %in% 2:6] # only use business days
                       if(hol) d <- d[!(d %in% holidays$Date)]
                       h <- df %>% 
                         mutate(hours=ifelse(date %in% d, hpd, hours)) %>% 
                         .$hours
                       
                       # need some exception/error handling here
                       
                       return(h)
                     },
                     weekly={
                       d <- df[wday(df$date) %in% day, c("date")]
                       if(hol) d <- d[!(d %in% holidays$Date)]
                       h <- df %>% 
                         mutate(period=week(date) %% every) %>%
                         mutate(hours=ifelse(date %in% d & period == week(start) %% every, hpd, hours)) %>%
                         filter(date >= start & date <= end) %>%
                         .$hours
                       
                       # need some exception/error handling here
                       
                       return(h)
                     },
                     monthly={
                       
                     })
}



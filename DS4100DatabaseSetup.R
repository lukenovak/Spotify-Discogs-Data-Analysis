library(rvest)
library(tidyverse)
library(stringr)
library(RPostgreSQL)
library(lubridate)

# By Jessica Cheng and Luke Novak
# For DS4100, Spring 2019, Northeastern University

billboard <- read_html("https://www.billboard.com/charts/billboard-200")

body <- html_node(billboard, 'body')
print(body)

root <- billboard %>% html_nodes("#main div")

# CSS Selector for Album Name
top_album <- html_nodes(root, ".chart-number-one__title , .chart-list-item__title-text") %>% html_text()
top_album_tidy <- top_album %>% str_remove_all("\n")

# CSS Selector for Artist
top_artist <- html_nodes(billboard, ".chart-number-one__artist a , .chart-list-item__artist") %>% html_text()
top_artist_tidy <- top_artist %>% str_remove_all("\n")


# scraper function
get_billboard_top_200 <- function(year, month, day) {
  
  year <- toString(year)
  
  # ensures that numbers less than 10 are prefixed with 0 to ensure proper url format
  if (day < 10) {
    day <- paste0('0', day)
  }
  else {
    day <- toString(day)
  }
  
  if (month < 10) {
    month <- paste0('0', month)
  }
  else {
    month <- toString(month)
  }
  
  # parameterize url
  billboard_url <- 'https://www.billboard.com/charts/billboard-200/%s-%s-%s'
  
  # `sprintf` replace "%s" for number arguements
  # `URLencode` ensures blank spaces in the keywords and location are
  # properly encoded, so that yelp will be able to recognize the URL
  billboard_url <- sprintf(billboard_url, URLencode(year), URLencode(month), URLencode(day))
  
  
  billboardsr <- read_html(billboard_url)
  
  # items contains the search results
  items <- billboardsr %>% html_nodes("#main div")
  
  # album names
  albums <- items %>% html_nodes(".chart-list-item__title-text") %>% html_text()
  albums <- albums %>% str_remove_all("\n")
  
  # artist names
  artists <- items %>% html_nodes(".chart-list-item__artist") %>% html_text()
  artists <- artists %>% str_remove_all("\n")
  
  # Return a data frame
  result <- tibble(
    albums,
    artists
  )
  return(result)
  
}

# Testing for the current date
current_top <- get_billboard_top_200(2019, 03, 17)

# Now let's get all of the billboard Top 200 since the list began
# The first chart was released in August 17, 1963. We can iterate by 7
# days for each date
start_date <- as_date("08-17-1963", format="%m-%d-%Y", tz="UTC")
api_dates <- seq(start_date, today(), by="week")
api_dates[0] <- api_dates[1]
aggregate_top_200 <- function() {
  result <- tibble()
    for(int in 1 : length(api_dates)) {
      result <- bind_rows(result,
                          get_billboard_top_200(day = mday(api_dates[int]), 
                          month = month(api_dates[int]), 
                          year = year(api_dates[int])))
      print(api_dates[int])
    }
  return(result)
  ## we sleep to avoid getting rate-limited
  sleep(2)
}
all_top_200 <- aggregate_top_200() %>% unique()


# Spotify Album Query
# Luke Novak, for DS4100, Northeastern University
library(dplyr)
library(spotifyr)
library(RPostgreSQL)
library(lubridate)
require(DBI)

drv <- dbDriver("PostgreSQL")
db <- dbConnect(drv) #DB DATA GOES HERE

get_album_query <- sql('SELECT * FROM album_samples_unique;')
albums <- dbGetQuery(db, get_album_query)

test_album <- search_spotify('Twin Fantasy', 'album')
test_artist <- test_album$artists[1][[1]][["name"]]

album_search_get_id <- function(title, artist) {
  print((paste(title, artist)))
  album_results <- search_spotify(title, 'album')
  if (length(album_results) > 0) {
    for (number in 1:length(album_results)) {
      album_artists <- album_results$artists[number][[1]][["name"]]
      for (album_artist in album_artists) {
        if (album_artist == artist) {
          print(title)
          return(album_results$id[number])
        }
      }
    }
  }
  return(NA)
}

vectorized_search <- Vectorize(album_search_get_id)
test_a_search <- album_search_get_id("Twin Fantasy", "Car Seat Headrest")
albums <- albums %>% rowwise() %>% mutate(id=album_search_get_id(title, artist))
albums_with_id <- albums %>% na.omit()

get_new_album_info <- function(id) {
  album_info <-get_album(id)
  print(album_info)
  title <- album_info$name
  artist <- album_info$artists$name
  upc <- album_info$external_ids$upc
  genre <- album_info$genres
  year <- album_info$release_date %>% ymd() %>% year()
  result <- tibble(upc, year)
  return(result)
}

albums_with_id <- albums_with_id %>% rowwise() %>% 
  mutate(upc=get_new_album_info(id)$upc, year=get_new_album_info(id)$year)



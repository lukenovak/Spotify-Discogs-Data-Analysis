# Spotify Album Query
# Luke Novak, for DS4100, Northeastern University
library(dplyr)
library(spotifyr)
library(RPostgreSQL)
library(lubridate)
library(stringr)
require(DBI)
drv <- dbDriver("PostgreSQL")
db <- dbConnect(drv, user = Sys.getenv("DB_USER"), password = Sys.getenv("DB_PW"),
                host = Sys.getenv("DB_HOST"), dbname = "music_analysis") #DB DATA GOES HERE

get_album_query <- sql('SELECT * FROM album_samples_unique;')
already_retreived_query <- sql('SELECT * FROM albums;')
albums <- dbGetQuery(db, get_album_query)
retreived_already <- dbGetQuery(db, already_retreived_query)

remaining_albums <- 
  anti_join(albums, retreived_already, by=c("title" = "title", "artist" = "artist")) %>%
  arrange(desc(title))


test_album <- search_spotify('Twin Fantasy', 'album')
test_artist <- test_album$artists[1][[1]][["name"]]

album_search_get_id <- function(dbconn, title, artist) {
  print((paste(title, artist)))
  album_results <- search_spotify(title, 'album')
  if (length(album_results) > 0) {
    for (number in 1:length(album_results)) {
      album_artists <- album_results$artists[number][[1]][["name"]]
      for (album_artist in album_artists) {
        if (album_artist == artist) {
          title <- str_replace_all(title, "'", "''")
          artist <- str_replace_all(artist, "'", "''")
          print(title)
          id <- album_results$id[number]
          query <- paste0('INSERT INTO albums (id, title, artist) VALUES (',
                          "'", id, "'",", '", title, "'", ",", "'", artist,"');")
          query <- sql(query)
          result = tryCatch({
            dbSendStatement(dbconn, query)
          }, error = function(e){
            print(paste("db error,", e, title, "not added, moving onto next album"))
          })
          return(album_results$id[number])
        }
      }
    }
  }
  return(NA)
}

vectorized_search <- Vectorize(album_search_get_id)
test_a_search <- album_search_get_id(db, "Twin Fantasy", "Car Seat Headrest")
remaining_albums <- remaining_albums %>% rowwise() %>% mutate(id=album_search_get_id(db, title, artist))
albums_with_id <- albums %>% na.omit()

get_new_album_info <- function(dbconn, id) {
  print(paste("Getting album id", id))
  album_info <- get_album(id)
  title <- album_info$name
  artist <- album_info$artists$name
  artist <- str_replace_all(artist, "'", "''")
  upc <- album_info$external_ids$upc
  genre <- album_info$genres
  release_year <- album_info$release_date %>% substr(1, 4) %>% as.numeric()
  result <- tibble(upc, release_year)
  query <- paste0('UPDATE albums SET upc = ', upc, ", year = ", release_year, 
                  ", artist = '", artist, "' WHERE id = '", id, "';")
  result = tryCatch({
    dbSendQuery(db, query)
    }, error = function(e){
    print("db error, moving onto next album")
    })
  return(result)
}

testinfo <- get_new_album_info(db, test_a_search)

albums_with_id <- dbGetQuery(db, 'SELECT * FROM albums;')
albums_with_no_upc <- dbGetQuery(db, 'SELECT * FROM albums where upc IS NULL;')
lapply(albums_with_no_upc$id, FUN = get_new_album_info, dbconn = db)

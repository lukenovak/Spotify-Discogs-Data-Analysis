library(dplyr)
library(spotifyr)
library(RPostgreSQL)
library(lubridate)
library(stringr)
require(DBI)

drv <- dbDriver("PostgreSQL")
db <- dbConnect(drv) #DB DATA GOES HERE


search_spotify('Twin Fantasy', 'track')


get_new_album_info('20U1UWeGcGq7JVW0tf8yfH')

test_a_search <- album_search_get_id("Twin Fantasy", "Car Seat Headrest")

# test
album_tracks <- get_album_tracks(test_a_search)
track <- album_tracks
track_name <- track$name
track_id <- track$id
track_dur <- track$duration_ms
track_audio <- get_track_audio_features(track_id)
track_key <- track_audio$key
track_dance <- track_audio$danceability
track_valence <- track_audio$valence
track_tempo <- track_audio$tempo

get_track_info <- get_track("3z3BsIVe0RHu7m6J1KZxg1")
get_track_popularity <- get_track_info$popularity
get_track_id <- get_track_info$id

tracks_popularity <- sapply(track_id, function(id)get_track(id)$popularity)

#function
get_song_info <- function(dbconn, album_id) {
  validRequest <- FALSE
  print(paste("searching for album", album_id))
  while(!validRequest) {
    tryCatch({
      songs <- get_album_tracks(album_id)
      validRequest <- TRUE
    }, error = function(e) {
      print("HTTP Error: perhaps you hit the rate limit? sleeping for 5s")
      Sys.sleep(1)
      print("4")
      Sys.sleep(1)
      print("3") 
      Sys.sleep(1)
      print("2") 
      Sys.sleep(1)
      print("1") 
      Sys.sleep(1)
    })
  }
  song_info <- songs
  song_name <- song_info$name
  song_name <-str_replace_all(song_name, "'", "''")
  song_id <- song_info$id
  song_dur <- song_info$duration_ms
  ## we need this to make one query for all tracks
  song_id_string <- paste(song_id, collapse = ',')
  print(song_id_string)
  song_audio <- get_track_audio_features(song_id_string)
  song_key <- song_audio$key
  song_dance <- song_audio$danceability
  song_valence <- song_audio$valence
  song_tempo <- song_audio$tempo
  song_pop <- get_tracks(song_id_string)$popularity
  result <- tibble(id = song_id,
                   album_id = album_id,
                   name = song_name,
                   popularity = song_pop,
                   duration = song_dur,
                   key = song_key,
                   danceability = song_dance,
                   valence = song_valence,
                   tempo = round(song_tempo))
  dbWriteTable(dbconn, "songs", result, append = TRUE, row.names = F)
  print(paste("Added songs from", album_id))
  return(result)
}

albums_with_id <- dbGetQuery(db, 'SELECT * FROM albums;')
albums_already_scraped <- dbGetQuery(db, 'SELECT album_id FROM songs GROUP BY album_id')
remaining_albums_songs <- anti_join(albums_with_id, albums_already_scraped, by=c("id" = "album_id"))
lapply(remaining_albums_songs$id, FUN = get_song_info, dbconn = db)


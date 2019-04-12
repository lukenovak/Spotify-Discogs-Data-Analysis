library(dplyr)
library(spotifyr)
library(RPostgreSQL)
library(lubridate)
require(DBI)


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
get_song_info <- function(album_id) {
  songs <- get_album_tracks(album_id)
  song_info <- songs
  song_name <- song_info$name
  song_id <- song_info$id
  song_dur <- song_info$duration_ms
  song_audio <- get_track_audio_features(song_id)
  song_key <- song_audio$key
  song_dance <- song_audio$danceability
  song_valence <- song_audio$valence
  song_tempo <- song_audio$tempo
  song_pop <- sapply(song_id, function(id)get_track(id)$popularity)
  result <- tibble(song.id = song_id,
                   album.id = album_id,
                   name = song_name,
                   popularity = song_pop,
                   duration = song_dur,
                   key = song_key,
                   danceability = song_dance,
                   valence = song_valence,
                   tempo = song_tempo)
  return(result)
}

get_song_info('20U1UWeGcGq7JVW0tf8yfH')

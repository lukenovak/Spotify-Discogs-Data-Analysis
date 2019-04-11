search_spotify('Twin Fantasy', 'track')


get_new_album_info('20U1UWeGcGq7JVW0tf8yfH')

test_a_search <- album_search_get_id("Twin Fantasy", "Car Seat Headrest")

album_tracks <- get_album_tracks(test_a_search)
first_track <- album_tracks[1,]
first_track_name <- first_track$name
first_track_id <- first_track$id
first_track_dur <- first_track$duration_ms
first_track_audio <- get_track_audio_features(first_track_id)
first_track_key <- first_track_audio$key

get_song_info <- function(album_id) {
  songs <- get_album_tracks(album_id)
  first_song_info <- songs[1,]
  first_song_name <- first_song_info$name
  first_song_id <- first_song_info$id
  first_song_dur <- first_song_info$duration_ms
  first_song_audio <- get_track_audio_features(first_song_id)
  first_song_key <- first_song_audio$key
  result <- tibble(song.id = first_song_id,
                   album.id = album_id,
                   name = first_song_name,
                   duration = first_song_dur,
                   key = first_song_key)
  return(result)
}

get_song_info('20U1UWeGcGq7JVW0tf8yfH')
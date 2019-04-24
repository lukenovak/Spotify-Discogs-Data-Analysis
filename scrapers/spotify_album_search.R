# Matt Lowe
# DS4100

library(dplyr)
library(spotifyr)

access_token <- get_spotify_access_token(client_id = "756eb77dadc64332af86131c35fc0b88",
                         client_secret = "8d5922a5250e4d969ef1d289cc2d9750")


album_search_query <- function(album_title) {
  album_result <- search_spotify(album_title, "album", limit = 1, authorization = access_token)
  spot_id <- album_result$id
  
  album <- get_album(spot_id, authorization = access_token)
  
  title <- album$name
  artist <- as.character(album$artists[3])
  genre <- as.character(album$genres[1])
  upc <- as.numeric(album$external_ids[1])
  release <- album$release_date
  
  album_info <- tibble(album_name = title,
                       album_artist = artist,
                       album_genre = genre,
                       album_upc = upc,
                       album_release = release,
                       album_id = spot_id)
  
  album_info

}

album_search_query("Yellow Submarine Songtrack")
album_search_query("Blue Lonesome")


library(dplyr)
library(ggplot2)
library(RPostgreSQL)
library(stringr)
require(DBI)

drv <- dbDriver("PostgreSQL")
db <- dbConnect(drv, user=user, host=host,
                password=pw, dbname='music_analysis') #DB DATA GOES HERE

formats <- dbGetQuery(db, "SELECT * FROM releases;")
all_albums <- dbGetQuery(db, "SELECT * FROM albums;")
formats_joined <- inner_join(formats, all_albums, by = 'id')
count_format_per_year <- formats_joined %>% select(format, year) %>% 
  group_by(format, year) %>% summarize(total = n())

## We need to remove some outliers, like CDs prior to their inventin in 1982
count_format_per_year <- count_format_per_year %>% 
  filter(format != 'CD' | year > 1981)
## multiply the current year by 3 to extrapolate out
count_format_per_year <- count_format_per_year %>% 
  mutate(total = ifelse(year == 2019, total * 4, total))

ggplot(count_format_per_year, aes(x = year, y=total, color=format)) + geom_line()

genres <- all_albums %>% filter(genre != 'None')
count_genre_per_year <- genres %>% select(genre, year) %>% 
  group_by(genre, year) %>% summarize(total = n())

count_genre_per_year <- count_genre_per_year %>% 
  mutate(total = ifelse(year == 2019, total * 4, total)) %>% filter(year > 1955)


ggplot(count_genre_per_year, aes(x = year, y=total, color=genre)) + geom_line()

count_genre_no_rock <- count_genre_per_year %>% filter(genre != 'Rock' & year > 1960)

ggplot(count_genre_no_rock, aes(x = year, y=total, color=genre)) + geom_line()

count_genre_just_big_ones <- count_genre_no_rock %>% 
  filter (genre != 'Non-Music' & genre != 'Children\'s' & genre != 'Classical' &
          genre != 'Stage & Screen' & genre != 'Reggae' & genre != 'Blues' & year != 2019)

ggplot(count_genre_just_big_ones, aes(x = year, y=total, color=genre)) + geom_line()


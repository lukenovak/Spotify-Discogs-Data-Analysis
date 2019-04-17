library(RPostgreSQL)
library(ggplot2)
library(tidyverse)

driver <- dbDriver("PostgreSQL")

# username and pw stored locally 
db <- dbConnect(driver, user = username, password = pw, host = "fernando.nluken.com", dbname = "music_analysis")

## Creates a plot for seeing the most popular key in music since 1960
# Selects year, key, and the count of each key for all songs
keyQuery <- as_tibble(dbGetQuery(db, "SELECT year, key, COUNT(key) AS keyCount FROM songs 
                INNER JOIN albums ON songs.album_id = albums.id
                WHERE year > 1960
                GROUP BY year, key
                ORDER BY year DESC, COUNT(key) DESC;
                "))
# Arranges count of keys in decreasing order
keyQuery <- keyQuery %>%
  arrange(desc(keycount))
# Takes unique years to get the max count for every year 
keyQueryUnique <- !duplicated(keyQuery["year"])
# Puts the all the unique rows back in a dataframe for plotting
keyQueryDF <- keyQuery[keyQueryUnique,]
# Plots the most popular key in each year
keyPlot <- ggplot(data = keyQueryDF) +
  geom_point(mapping = aes(x=year, y=key, color = key)) + 
  scale_y_discrete(name ="Most popular key", limits=c(0:11))

## Function allows user to specify start and end year
keyFunc <- function(startYear, endYear) {
  
  yearConditionStart <- paste(startYear, " and year < ", sep = '')
  yearConditionEnd <- paste(yearConditionStart, endYear, sep = '')
  
  queryStart <- paste("SELECT year, key, COUNT(key) AS keyCount FROM songs INNER JOIN albums ON songs.album_id = albums.id
                      WHERE year >", yearConditionEnd, sep = '')
  
  funcTibble <- as_tibble(dbGetQuery(db, paste(queryStart, "GROUP BY year, key ORDER BY year DESC, COUNT(key) DESC;", sep = '')))
  
  # Arranges count of keys in decreasing order
  funcTibble <- funcTibble %>%
    arrange(desc(keycount))
  # Takes unique years to get the max count for every year 
  tibbleUnique <- !duplicated(funcTibble["year"])
  # Puts the all the unique rows back in a dataframe for plotting
  tibbleFinal <- funcTibble[tibbleUnique,]
  # Plots the most popular key in each year
  
  ggplot(data = tibbleFinal) +
    geom_point(mapping = aes(x=year, y=key, color = key)) + 
    scale_y_discrete(name ="Most popular key", limits=c(0:11))
}

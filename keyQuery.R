library(RPostgreSQL)
library(ggplot2)

driver <- dbDriver("PostgreSQL")

# usernmme and pw stored locally 
db <- dbConnect(driver, user = username, password = pw, host = "fernando.nluken.com", dbname = "music_analysis")

# Creates a plot for seeing the average key in music since 1960
keyPlot <- ggplot(data = dbGetQuery(db, "SELECT avg(key) AS key, year FROM songs 
                       INNER JOIN albums ON songs.album_id = albums.id WHERE year > 1960
                         GROUP BY year")) +
  geom_point(mapping = aes(x=year, y=key, color = key))

# Function allows user to specify start and end year
keyFunc <- function(startYear, endYear) {
  
  yearConditionStart <- paste(startYear, " and year < ", sep = '')
  yearConditionEnd <- paste(yearConditionStart, endYear, sep = '')
  
  queryStart <- paste("SELECT avg(key) AS key, year FROM songs 
                       INNER JOIN albums ON songs.album_id = albums.id WHERE year > ", yearConditionEnd, sep = '')
  
  ggplot(data = dbGetQuery(db, paste(queryStart, "GROUP BY year", sep = ''))) +
    geom_point(mapping = aes(x=year, y=key, color = key))
}




  
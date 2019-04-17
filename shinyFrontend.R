library(shiny)
library(shinythemes)
library(dplyr)
library(RPostgreSQL)


frontEnd <- fluidPage(theme = shinytheme("slate"),
                titlePanel("Spotify and Discogs Analysis"),
                sidebarLayout(
                  sidebarPanel(
                    selectInput(inputId = "type", label = strong("Audio Feature"), choices = c("Tempo", "Key", "Genre"), selected = "Key"),
                    numericInput(inputId = "start", label = "Start Year", value = 1960, min = 1960, max = 2019),
                    numericInput(inputId = "end", label = "End Year", value = 2019, min = 1960, max = 2019)
                  ),
                  
                  mainPanel(
                    plotOutput(outputId = "plot", height = "300px")
                  )
))

server <- function(input, output) {
  
  driver <- dbDriver("PostgreSQL")
  # username and pw stored locally 
  db <- dbConnect(driver, user = user, password = pw, host = "fernando.nluken.com", dbname = "music_analysis")
  
  # Create scatterplot object the plotOutput function is expecting
  output$plot <- renderPlot({
    
    startYear <- input$start
    endYear <- input$end
    graphType <- input$type
    
    
    if (graphType == "Key") {
      yearConditionStart <- paste(startYear, " and year < ", sep = '')
      yearConditionEnd <- paste(yearConditionStart, endYear, sep = '')
      queryStart <- paste("SELECT year, key, COUNT(key) AS keyCount FROM songs INNER JOIN albums ON songs.album_id = albums.id WHERE year >", 
                          yearConditionEnd, sep = '')
      print(queryStart)
      
      funcTibble <- as_tibble(dbGetQuery(db, paste(queryStart, "GROUP BY year, key ORDER BY year DESC, COUNT(key) DESC;", sep = '')))
      
      # Arranges count of keys in decreasing order
      funcTibble <- funcTibble %>%
        arrange(desc(keycount))
      # Takes unique years to get the max count for every year 
      tibbleUnique <- !duplicated(funcTibble["year"])
      # Puts the all the unique rows back in a dataframe for plotting
      tibbleFinal <- funcTibble[tibbleUnique,]
      print(head(tibbleFinal))
      # Plots the most popular key in each year
      
      return(ggplot(tibbleFinal) +
        geom_point(mapping = aes(x=year, y=key, color=key), show.legend = FALSE) + 
        scale_y_discrete(name ="Most popular key", limits=c(0:11)))
      
        
    }
    
    if (graphType == "Tempo") {
      df_tempo_all <- dbGetQuery(db, paste("SELECT AVG(tempo) as tempo, year 
                                           FROM albums INNER JOIN songs ON albums.id = songs.album_id 
                                           WHERE year BETWEEN", startYear, "AND", endYear, 
                                           "GROUP BY year ORDER BY year"))
     return(ggplot(df_tempo_all, mapping = aes(x = year,  y = tempo, color = tempo)) + 
        geom_point() + labs(x = "Year", y = "Average Tempo") + 
        ggtitle("Average Tempo Over Time") +
        theme(plot.title = element_text(hjust = 0.5)) + scale_color_gradient())
      

    }
    
    if (graphType == "Genre") {
      all_albums <- dbGetQuery(db, "SELECT * FROM albums;")
      genres <- all_albums %>% filter(genre != 'None')
      count_genre_per_year <- genres %>% select(genre, year) %>% 
        group_by(genre, year) %>% summarize(total = n())
      
      count_genre_per_year <- count_genre_per_year %>% 
        mutate(total = ifelse(year == 2019, total * 4, total)) %>% 
        filter(year > startYear & year < endYear)
      
      
      return(ggplot(count_genre_per_year, aes(x = year, y=total, color=genre)) + geom_line())
      
    }
  })
}

shinyApp(frontEnd, server)

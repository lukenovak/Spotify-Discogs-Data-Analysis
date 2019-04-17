library(shiny)
library(shinythemes)
library(dplyr)
library(RPostgreSQL)


frontEnd <- fluidPage(theme = shinytheme("superhero"),
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
  db <- dbConnect(driver, user = username, password = pw, host = "fernando.nluken.com", dbname = "music_analysis")
  
  # Create scatterplot object the plotOutput function is expecting
  output$plot <- renderPlot({
    
    startYear <- input$start
    endYear <- input$end
    
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
      geom_point(mapping = aes(x=year, y=key, color = key), show.legend = FALSE) + 
      scale_y_discrete(name ="Most popular key", limits=c(0:11))
    
  })
}

shinyApp(frontEnd, server)

library(shiny)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(RPostgreSQL)


frontEnd <- fluidPage(theme = shinytheme("slate"),
            tags$head(
              tags$style(HTML("

                              h1 {
                              text-align:center;
                              }
                              
                              h3 {
                              text-align:center
                              }

                              h5 {
                              text-align:center
                              }
                              
                              .threecol {
                                -webkit-column-count: 3;
                                -moz-column-count: 3;
                                column-count: 3;
                              }"
                              ))
              ),     
                    
              h1("Analysis of The Billboard 200"),
              h3("by Luke Novak, Jessica Cheng, and Matt Lowe"),
              h5("Northeastern University"),
              sidebarLayout(
                sidebarPanel(
                  selectInput(inputId = "type", label = strong("Audio Feature"),
                              choices = c("Tempo", "Key", "Genre", "Release Format"), selected = "Key"),
                  numericInput(inputId = "start", label = "Start Year", 
                               value = 1960, min = 1960, max = 2019),
                  numericInput(inputId = "end", label = "End Year", 
                               value = 2019, min = 1960, max = 2019)
                ),
                
                mainPanel(
                  plotOutput(outputId = "plot", height = "300px"),
                  conditionalPanel(condition = "input.type == 'Genre'",
                                   uiOutput("genre_panel")
                  )
                )),
            
              p(paste0("About this data: This was a survey of",
                       " all albums in the billboard 200 since its",
                       " inception in the 1960's. Data about songs was",
                       " gathered from Spotify with release format and",
                       " genre data gathered from Discogs"))
            
  
)

server <- function(input, output) {
  
  driver <- dbDriver("PostgreSQL")
  # username and pw stored locally 
  db <- dbConnect(driver, user = Sys.getenv('DB_USER'),
                  password = Sys.getenv("DB_PW"), 
                  host = Sys.getenv("DB_HOST"), 
                  dbname = "music_analysis")
  
  observeEvent(input$type, {
    genre_vector <- 
      na.exclude(dbGetQuery(db, "SELECT DISTINCT(genre) FROM albums")$genre) %>%
      Filter(f = function(x) {
        return(x != "None")
      })
    
    if (input$type == "Genre") {
      output$genre_panel <-
        renderUI({
          div(class = "threecol",
            checkboxGroupInput(
              inputId = "genres_incl",
              label = strong("Include Genres:"),
              choices = genre_vector,
              selected = genre_vector
            )
          )
        })
      return()
    }
  })
  
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
      genres_selected <- input$genres_incl
      genres <- all_albums %>% filter(genre != 'None') %>%
        filter(genre %in% genres_selected)
      count_genre_per_year <- genres %>% select(genre, year) %>% 
        group_by(genre, year) %>% summarize(total = n())
      
      count_genre_per_year <- count_genre_per_year %>% 
        mutate(total = ifelse(year == 2019, total * 4, total)) %>% 
        filter(year > startYear & year < endYear)
      
      return(ggplot(count_genre_per_year, 
                    aes(x = year, y=total, color=genre)) + geom_line() +
               labs(x = "Year", y = "Total number of albums") +
               ggtitle("Genre Changes over time in the billboard 200") +
               theme(plot.title = element_text(hjust = 0.5)))
      
    }
    
    if (graphType == "Release Format") {
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
      
      ## filter by selected year
      count_format_per_year <- count_format_per_year %>%
        filter(year > startYear & year < endYear)
      
      return(ggplot(count_format_per_year, 
                    aes(x = year, y=total, color=format)) + 
               geom_line())
      
    }
  })
}

shinyApp(frontEnd, server)

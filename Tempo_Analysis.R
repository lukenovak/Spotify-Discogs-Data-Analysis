# all tempo data between 1960 and 2019
df_tempo_all <- dbGetQuery(db, "SELECT tempo, duration, year 
                           FROM albums INNER JOIN songs ON albums.id = songs.album_id 
                           WHERE year BETWEEN 1960 AND 2019 
                           ORDER BY year")

# visualize outliers
tempo_all_plot <- ggplot(df_tempo_all, 
                         mapping = aes(x = as.factor(year), 
                                       y = tempo, fill= as.factor(year))) + 
  geom_boxplot() + 
  labs(x = "Year", y = "Tempo") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position="none")
tempo_all_plot

# function to remove outliers (outside of 1.5*IQR range) and replace them with NAs
remove_outliers <- function(x, na.rm = TRUE) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

#info on df_tempo_all
str(df_tempo_all)

# distinct years
years <- df_tempo_all %>% distinct(year)
year_list <- years$year

# function to produce table for given year
table_year <- function(year_num) {
  df_tempo_all %>% filter(year == year_num)
}

# list of tables for each distinct year
list_tables <- lapply(year_list, table_year)

#function that takes in a df and produces a vector of tempo from df
year_tempo <- function(ydf) {
  ydf$tempo
}

# list of list of tempos for each year's tempo table
list_year_tempo <- lapply(list_tables, year_tempo)

# apply replace outliers with NAs to each list of list of tempos from each year
list_no_outliers <- lapply(list_year_tempo, remove_outliers)

# combines lists of tempos into one list
tempo_no_outliers <- unlist(list_no_outliers)
# check length of tempos list
length(tempo_no_outliers) # 246778
# extracts years from original tempo df
tempo_years <- df_tempo_all$year
# make sure length of years same as length of tempos list
length(tempo_years) #246778

# create df of tempo data
df <- cbind(tempo_no_outliers, tempo_years)
tempo_table <- as.data.frame(df)
names(tempo_table) <- c("tempo", "year")
tempo_table

#count how many outliers as NAs
na_tempo_count <- tempo_table %>% 
  summarise(na_count = sum(is.na(tempo)))
# tempo df with outlier/NAs removed
tempo_df <- tempo_table %>% filter(!is.na(tempo))
#check na rows have been removed
na_tempo_new_count <- tempo_df %>% 
  summarise(na_count = sum(is.na(tempo)))
# new boxplot with NAs outliers removed
tempo_df_plot <- ggplot(tempo_df, 
                        mapping = aes(x = as.factor(year), 
                                      y = tempo, 
                                      fill= as.factor(year))) + 
  geom_boxplot() + 
  labs(x = "Year", y = "Tempo") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position="none")

#Average tempos
tempo_avg <- tempo_df %>% group_by(year) %>% 
  summarise(avg_tempo = mean(tempo))
# plot avg tempo over time with outliers/ NAs removed
avg_tempo_plot <- ggplot(tempo_avg, 
                         mapping = aes(x = year, 
                                       y = avg_tempo, 
                                       color = avg_tempo)) + 
  geom_point() + 
  labs(x = "Year", y = "Average Tempo") + 
  ggtitle("Average Tempo Over Time") +
  theme(plot.title = element_text(hjust = 0.5))
avg_tempo_plot + scale_color_gradient()


# duration vs tempo
dur_tempo_plot <- ggplot(df_tempo_all, 
                         mapping = aes(x = duration, 
                                       y = tempo, 
                                       color = tempo)) + 
  geom_point() + 
  labs(x = "Duration", y = "Tempo") + 
  ggtitle("Tempo Over Duration") +
  theme(plot.title = element_text(hjust = 0.5))
dur_tempo_plot + scale_color_gradient()
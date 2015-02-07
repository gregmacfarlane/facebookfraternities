# combine data from Tom's airports files so that we can save space in our folders
# and improve run time.
library(dplyr)
library(reshape2)

# 25 miles
ap25 <- read.csv("./data/geocode/geocoded_datatables/allairports_25_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_25 = sum(Population))
  
# 50 miles
ap50 <- read.csv("./data/geocode/geocoded_datatables/allairports_50_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_50 = sum(Population))

# 75 miles
ap75 <- read.csv("./data/geocode/geocoded_datatables/allairports_75_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_75 = sum(Population))
  
  
# 100 miles
ap100 <- read.csv("./data/geocode/geocoded_datatables/allairports_100_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_100 = sum(Population))
  
  
# 125 miles
ap125 <- read.csv("./data/geocode/geocoded_datatables/allairports_125_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_125 = sum(Population))

# 150 miles
ap150 <- read.csv("./data/geocode/geocoded_datatables/allairports_150_MSAPop.csv",
                 stringsAsFactors = FALSE) %>%
  select(airport, Population) %>% group_by(airport) %>% 
  summarize(pop_150 = sum(Population))


# get latlong from all airports, and join population to it
allairports <- read.csv("./data/geocode/geocoded_datatables/allairports.csv",
                        stringsAsFactors = FALSE) %>%
  select(airport, latitude, longitude) %>%
  left_join(., ap25) %>% left_join(., ap50) %>% left_join(., ap75) %>%
  left_join(., ap100) %>% left_join(., ap125) %>% left_join(., ap150) %>%
  melt(., id.vars = c("airport", "latitude", "longitude"), as.is = TRUE, 
       value.name = "population", variable.name = "buffer") %>%
  mutate(buffer = gsub("pop_","", buffer))

save(allairports, file = "./data/airportpopulations.Rdata")




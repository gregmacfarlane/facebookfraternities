# Load and do basic data munging on fraternity surveys.
library(dplyr)
library(readr)
library(data.table)
library(igraph)

# Clean user table
user <- tbl_df(read_csv("../data/PRIVATEDATA/user.csv")) %>%
  select(
    id, fb_id, zip, location_from, lives_in, age, gender, race, 
    collected_friends_size, fraternity_id
    )  %>%
  setnames(
    c("id", "fbid", "zip", "from", "at", "age", "sex", "race", 
      "collected", "fraternity_id")
    ) 

# useable records must have friends collected
user <- user %>%
  mutate_each(funs(ifelse( . == "NULL", NA, .))) %>%
  filter(collected > 0) 

# make sure numeric cols are num, character are chr
user <- user %>%
  mutate_each(funs(as.numeric(.)), age,  collected) %>%
  mutate(zip = sprintf("%05d", zip))

# attach fraternity information
user <- user %>%
  left_join(read.csv("../data/fraternities.csv", colClasses = "character"))


saveRDS(user, file = "../data/clean/user.rds")


# Clean trip data
trips <- read_csv("../data/PRIVATEDATA/trip.csv") %>%
  tbl_df()  %>%
  select(
    id = user_id, 
    purpose, 
    origin_airport = origin_airport_code, 
    destination_airport = destination_airport_code) 

saveRDS(trips, file = "../data/clean/trips.rds")

# Clean friends data
friends <- read_csv("../data/PRIVATEDATA/user_friends_info.csv") %>%
  tbl_df() %>%
  transmute(
    fbid = fb_id,
    id = user_id,
    from = tolower(location_from),
    at = tolower(lives_in)
  )


saveRDS(friends, file = "../data/clean/friends.rds")



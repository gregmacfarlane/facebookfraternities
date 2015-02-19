# Load and do basic data munging on fraternity surveys.
library(dplyr)
library(data.table)
library(igraph)

# Load user data and trim to useable fields
user <- read.csv("../data/PRIVATEDATA/user.csv", stringsAsFactors = FALSE) %>%
  select(
    id, fb_id, zip, location_from, lives_in, age, gender, race,
    friend_list_size, collected_friends_size
    ) %>%
  setnames(
    c("id", "fbid", "zip", "from", "at", "age", "sex", "race", "friends", 
      "collected")
    ) 

# useable records must have friends collected
user <- user %>%
  mutate_each(funs(ifelse( . == "NULL", NA, .))) %>%
  filter(collected > 0) 

# make sure numeric cols are num, character are chr
user <- user %>%
  mutate_each(funs(as.numeric(.)), age, friends, collected) %>%
  mutate(zip = sprintf("%05d", zip))


# calculate trips for each user





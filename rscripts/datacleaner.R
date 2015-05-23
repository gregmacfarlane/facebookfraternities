# Load and do basic data munging on fraternity surveys.
library(dplyr)
library(readr)
library(data.table)
library(igraph)

# Clean user table -----
user <- tbl_df(read_csv("../data/PRIVATEDATA/user.csv")) %>%
  select(
    id, fb_id, zip, location_from, lives_in, age, gender, race, 
    collected_friends_size, fraternity_id
    )  %>%
  setnames(
    c("id", "fbid", "zip", "from", "at", "age", "sex", "race", 
      "collected", "fraternity_id")
    ) %>%

  # useable records must have friends collected
  mutate_each(funs(ifelse( . == "NULL", NA, .))) %>%
  filter(id > 147) %>%

  # variable cleanup
  mutate(
    race = ifelse(race != "White" | is.na(race), "Other", "White"),
    from = tolower(from),
    at = tolower(at),
    zip = sprintf("%05d", zip) 
  ) %>%
  mutate_each(funs(as.numeric(.)), age,  collected) %>%
  
  # attach fraternity information
  left_join(read.csv("../data/fraternities.csv", colClasses = "character"))
  



#saveRDS(user, file = "../data/clean/user.rds")


# Clean trip data ------
trips <- read_csv("../data/PRIVATEDATA/trip.csv") %>%
  tbl_df()  %>%
  select(
    id = user_id, 
    purpose, 
    origin_airport = origin_airport_code, 
    destination_airport = destination_airport_code) 

#saveRDS(trips, file = "../data/clean/trips.rds")

# calculate how close friend's cities are to Atlanta -----
# distance from Atlanta 
get_miles_from_atl <- function (long2, lat2) {
  long1 <- -84.38966 * pi / 180; lat1 <- 33.75449 * pi / 180
  long2 <- long2 * pi / 180; lat2 <- lat2 * pi / 180
  dsigma <- acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(abs(long1 - long2)) )
  dsigma * 6371 * 0.621371
}

# coordinates for the friends' cities
cities <- read_csv("../data/PRIVATEDATA/geocode/geocoded_datatables/allcities.csv") %>%
  tbl_df() %>%
  mutate(
    miles_from_atl = get_miles_from_atl(longitude, latitude),
    # if missing coordinates, replace with the average
    miles_from_atl = ifelse(is.na(miles_from_atl), 
                            mean(miles_from_atl, na.rm = TRUE), miles_from_atl)
  )



# Clean friends data -----
friends <- read_csv("../data/PRIVATEDATA/user_friends_info.csv") %>%
  tbl_df() %>%
  transmute(
    fbid = fb_id,
    id = user_id,
    from = tolower(location_from),
    at = tolower(lives_in)
  ) %>%
  # FIXME: see Issue #1
  left_join(cities, by = c("from" = "city"))


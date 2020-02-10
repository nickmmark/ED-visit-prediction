# exploration of weather conditions as a model feature using the rwundergound library
# nick mark 4/22/18

library(rwunderground)

rwunderground::set_api_key("4d317bc46e2e0d9b")  # note that this is a free API login, number of pulls is limited

location = "seattle"

# moon phase
#data=astronomy(location, key = get_api_key(), raw=FALSE, message=TRUE)

# historical data on this date
#data=almanac(location, use_metric = FALSE, key = get_api_key(), raw = FALSE, message = TRUE)

# current temperature, weather condition, humidity, wind, feels-like, temperature, barometric pressure, and visibility
data=conditions(location, use_metric = FALSE, key = get_api_key(), raw = FALSE, message = TRUE)

str(data)

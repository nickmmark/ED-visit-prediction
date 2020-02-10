# exploration of Google trends as a model feature using the gtrendsR library
# nick mark 4/22/18

# load libraries
library(gtrendsR)
library(reshape2)

# Google login - optional
# username <- "<gmail id>"
# password <- "<password>"
# gconnect(username,password)

# define search parameters
search_word="evergreenr"
time_range="2018-06-01T01 2018-06-02T12"
geo_range="US-WA"

# time_range options: "now 1-H" Last hour, "now 4-H" Last four hours, "now 1-d" Last day, "now 7-d" Last seven days
#                     "today 1-m" Past 30 days, "today 3-m" Past 90 days, "today 12-m" Past 12 months, "today+5-y" Last five years (default)
#                     "all" Since the beginning of Google Trends (2004), "Y-m-d Y-m-d" Time span between two dates
#                     pulling granular data historically: specify the exact date range with the hour suffix (T__) after the time
#                     example time_range="2017-02-06T1 2017-02-12T24" returns hourly results
# geo_range options:  can specify country > state > city as desired

# perform search
google.trends = gtrends(c(search_word), gprop = "web", time = time_range, geo = geo_range)[[1]]
google.trends = dcast(google.trends, date ~ keyword + geo, value.var = "hits")
rownames(google.trends) = google.trends$date
google.trends$date = NULL

# export results
downloadDir="/Users/drnick/Desktop/GT exploration"
setwd(downloadDir)
write.csv(google.trends, file = "MyData.csv")

# known errors: 
#   widget$status_code == 200 is not TRUE - this seems to arise when the number of requests exceeds some maximum (?500 per day)


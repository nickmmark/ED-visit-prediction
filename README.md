# ED-visit-prediction
Using google search trends and local weather to predict emergency department (ED) visits

# Background
The volume of patients who visit emergency departments is highly variable. Environmental factors (weather, local events, traffic, etc) can influence the decision to go to the ED. Google search is often used to identify the closest EDs as part of the planning process. Using APIs for weather and Google Trends I demonstrate that environmental factors and Google Search trends can be used to predict visits to local emergency departments.

![pattern of ED visits and Google searches](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/ED%20load%20and%20GT%20correlation.png)


# Details
To gather the data I used two R packages:
- [gtrendsR](https://cran.r-project.org/web/packages/gtrendsR/gtrendsR.pdf) which is a "pseudo-APi" that pulls google trends data as specified. Note that there are limitations imposed on this (max of 4000 searches per day, so creative solutions (using a VPN) can be helpful to build a large historical dataset for model training.
- [rwunderground](https://cran.r-project.org/web/packages/rwunderground/index.html) which uses the Weather Underground API to pull historical or current weather data. There are free API keys available, however I recommend a paid subscription.

To pull the Google Trends data for a particular hospital you can use the following code:
```
# load library
library(gtrendsR)

# connect to google (optional)
username <- "<gmail id>"
password <- "<password>"
gconnect(username,password)

# define search parameters
search_word="hospital name"
time_range="2018-06-01T01 2018-06-02T12"
geo_range="US-WA"

# perform search
google.trends = gtrends(c(search_word), gprop = "web", time = time_range, geo = geo_range)[[1]]
google.trends = dcast(google.trends, date ~ keyword + geo, value.var = "hits")
rownames(google.trends) = google.trends$date
google.trends$date = NULL

# export results
downloadDir="filename"
setwd(downloadDir)
write.csv(google.trends, file = "MyData.csv")
```


These diurnal patterns exist for all hospitals, however they are specific to the individual hospital and importantly can predict the arrivals at that hospital.
![local hospitals autocorrelation](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/specific%20local%20hospitals.png)


Even as a single variable, Google Searches for the name of a specific hospital predicts the number of arrivals in the next hour.
![searches in the last 30 minutes predict the arrivals in the next 30 minutes](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/GT%20ED%20arrivals%20prelim%20exporation.jpg)



# Version/To-do


# References
- [Health-Related Google Searches Doubled in the Week Before Patients’ Emergency Department Visits](https://www.pennmedicine.org/news/news-releases/2019/february/health-related-google-searches-doubled-in-the-week-before-patients-emergency-department-visits)
- 

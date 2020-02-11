# ED-visit-prediction
Using google search trends and local weather to predict emergency department (ED) visits

# Background
The volume of patients who visit emergency departments is highly variable in part because numerous environmental factors (weather, local events, traffic, etc) can effect the onset of illness/injury and influence the decision to go to the ED. For this reason, Emergency Departments exhibit significant hourly, daily, and seasonal variability in the number of patients arriving. I explored how publicly available data, such as Google Searches and local weather, can be used to predict the number of patients arriving at local emergency department arrivals.

Google Trends has been used as a near realtime method of predicting interest; for example GT has been used to [predict sales of retail, automotive, and home sales](https://static.googleusercontent.com/media/www.google.com/en//googleblogs/pdfs/google_predicting_the_present.pdf)
, to [forecast stock market changes](https://editorialexpress.com/cgi-bin/conference/download.cgi?db_name=SNDE2018&paper_id=100), to [predict changes in cryptocurrency prices](https://www.researchgate.net/publication/279917417_Bitcoin_Spread_Prediction_Using_Social_And_Web_Search_Media/figures?lo=1), to to [predict political election results](https://www.reddit.com/r/dataisbeautiful/comments/8bqgeb/google_trends_predict_15_historic_election/).

In the medical arena, [Google Trends was used for many years to estimate influenza activity in more than 25 countries, potentially predicting the onset of outbreaks by up to 10 days](https://en.wikipedia.org/wiki/Google_Flu_Trends). 


# Details
First I compared the pattern of searches for "hospital" and the pattern of ED arrivals in a publically available database. (MIMIC III is a good place to start for those interested in doing this work themeselves; for those interested in requesting access see [here](https://mimic.physionet.org/gettingstarted/access/)). I observed that the same diurnal pattern in ED visits was also noted in GT searches:

![pattern of ED visits and Google searches](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/ED%20load%20and%20GT%20correlation.png)


These diurnal patterns exist for all hospitals, however they are specific to the individual hospital and importantly can predict the arrivals at that hospital. For example if I search for three local hospitals in the Seattle area:
![local hospitals autocorrelation](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/specific%20local%20hospitals.png)



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




Even as a single variable, Google Searches for the name of a specific hospital predicts the number of arrivals in the next hour.
![searches in the last 30 minutes predict the arrivals in the next 30 minutes](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/GT%20ED%20arrivals%20prelim%20exporation.jpg)



# Version/To-do


# References
- [Health-Related Google Searches Doubled in the Week Before Patients’ Emergency Department Visits](https://www.pennmedicine.org/news/news-releases/2019/february/health-related-google-searches-doubled-in-the-week-before-patients-emergency-department-visits)
- 

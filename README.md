# ED-visit-prediction
Using Google search trends and local weather to predict patient visits to local emergency departments 
I conceived of this shortly after my toddler accidentally gave me a corneal abrasion; one of the first things I did was google my local ED for driving directions. This led me to wonder, how many ED walk ins are preceeded by people doing the same? Can the volume of searches for ED's be used to predict visits in the near term?

# Background
Emergency Departments exhibit significant hourly, daily, and seasonal variability in the number of new patients arriving. The volume of patients who visit emergency departments is highly variable in part because numerous environmental factors (weather, local events, traffic, etc) can effect the onset of illness/injury and influence the decision of patients to seek care the ED. Being able to accurately predict patient arrivals at emergency departments is useful because it can be used to optimize staffing and resource availability to minimize patient waiting times and maintain optimal staffing ratios.

I explored how publicly available data, such as Google Searches and local weather, can be used to predict the number of patients arriving at local emergency department arrivals.

Google Trends has been used as a near realtime method of predicting interest; for example GT has been used to [predict sales of retail, automotive, and home sales](https://static.googleusercontent.com/media/www.google.com/en//googleblogs/pdfs/google_predicting_the_present.pdf)
, to [forecast stock market changes](https://editorialexpress.com/cgi-bin/conference/download.cgi?db_name=SNDE2018&paper_id=100), to [predict changes in cryptocurrency prices](https://www.researchgate.net/publication/279917417_Bitcoin_Spread_Prediction_Using_Social_And_Web_Search_Media/figures?lo=1), to to [predict political election results](https://www.reddit.com/r/dataisbeautiful/comments/8bqgeb/google_trends_predict_15_historic_election/).

In the medical arena, [Google Trends was used for many years to estimate influenza activity in more than 25 countries, potentially predicting the onset of outbreaks by up to 10 days](https://en.wikipedia.org/wiki/Google_Flu_Trends). 


# Google Trends predicts ED arrivals
First I compared the pattern of searches for "hospital" and the pattern of ED arrivals in a publically available database. (MIMIC III is a good place to start for those interested in doing this work themeselves; for those interested in requesting access see [here](https://mimic.physionet.org/gettingstarted/access/)). I observed that the same diurnal pattern in ED visits was also noted in GT searches:

![pattern of ED visits and Google searches](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/ED%20load%20and%20GT%20correlation.png)


These diurnal patterns exist for all hospitals, however they are specific to the individual hospital and importantly can predict the arrivals at that hospital. For example if I search for three local hospitals in the Seattle area:
![local hospitals autocorrelation](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/specific%20local%20hospitals.png)


To gather the data I used two R packages:
- [gtrendsR](https://cran.r-project.org/web/packages/gtrendsR/gtrendsR.pdf) which is a "pseudo-APi" that pulls google trends data as specified. Note that there are limitations imposed on this (max of 4000 searches per day, so creative solutions (using a VPN) can be helpful to build a large historical dataset for model training.
- [rwunderground](https://cran.r-project.org/web/packages/rwunderground/index.html) which uses the Weather Underground API to pull historical or current weather data. There are free API keys available, however I recommend a paid subscription.

To pull the Google Trends data for a particular hospital you can use the following code:
```R
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
This API can provide data at different levels of granularity, depending on the time scale. For predicting ED arrivals in the next hour we need to pick an appropriate time scale. For example we could choose between these time scales:
![search for 'emergency room' at different time scales](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/GT%20at%20different%20time%20scales.png)

Using the above code, with a simple `for` loop to automate different searches and string the results together, I pulled an hourly dataset covering a month. By aligning the GT searches and the *NEXT* hour's ED arrivals we can build a database and perform some basic analysis. It is straightforward to do this R:

```R
library(Hmisc)
rcorr(GTandArrivals, type="pearson")
```

You can graph the results as a [correlogram](https://en.wikipedia.org/wiki/Correlogram) using 
```R
library(corrgram)
corrgram(GTandArrivals, order=TRUE, lower.panel=panel.shade,
  upper.panel=panel.pie, text.panel=panel.txt,
  main="Last hour Google Searches and ED arrivals")
```

I made a slightly nicer looking figure using [GraphPad Prism](https://www.graphpad.com/scientific-software/prism/). As you can see below, even as a single variable, Google Searches for the name of a specific hospital predicts the number of arrivals there in the next hour. 
![searches in the last 30 minutes predict the arrivals in the next 30 minutes](https://github.com/nickmmark/ED-visit-prediction/blob/master/figures/GT%20ED%20arrivals%20prelim%20exporation.jpg)
If we use the (admittedly arbitrary) number of searches >= 35/hr as cutoff it does a reasonable job of predicting high or low volume over the next hour. It is important to recognize that a lot of this is just due to similar diurnal patterns in both GT searches and ED arrivals, but imagine how this data point could be *combined* with other temporal and environment features to build an even better predictive model.

# Local weather predicts ED arrivals
Anyone who's every worked in an ED knows that extreme weather (blizzard, torrential rain, etc) often "keeps people home."
I posited that incorporating real-time weather information can help predict ED arrivals for the immediate future.


# Parsing 911 dispatched to predict ED arrivals
Another data signature that may preceed an ED visit is a call to 911 and the dispatch on an ambulance.
When I worked in the Harborview ED as IM Resident, I would always keep the Seattle Fire Realtime 911 dispatch window open for situational awareness about EMS activity. This was a great way to know (before the radio call) about serious medical emergencies like cardiac arrest, overdoses, difficulty breathing, etc.
* Caveat: Most cities don't provide EMS dispatch in real-time like Seattle.

My Hypothesis is that by combining Google searches (for lower acuity emergencies) and 911 dispatches (for higher acuity) we can build a more robust ED arrivals prediction.

# Version/To-do
[] explore other publically available API data: *traffic*, *social media posts* (such as with the ```Rtweet``` twitter API), etc

[] Demonstrate how to build more sophisticated models that use time, weather, and GT searches to predict the next hours ED volume

[] In the future I would love to combine this with the work I did with the [Seattle Fire realtime 911 API](https://data.seattle.gov/Public-Safety/Seattle-Real-Time-Fire-911-Calls/kzjm-xkqj) and [geospatial exporation of out of hospital cardiac arrest](https://github.com/nickmmark/mapping-seattle-911).

# References
- [Google Trends](https://static.googleusercontent.com/media/www.google.com/en//googleblogs/pdfs/google_predicting_the_present.pdf)
- [Health-Related Google Searches Doubled in the Week Before Patients’ Emergency Department Visits](https://www.pennmedicine.org/news/news-releases/2019/february/health-related-google-searches-doubled-in-the-week-before-patients-emergency-department-visits)
- Preis et al, [Quantifying Trading Behavior in Financial Markets Using Google Trends](https://www.nature.com/articles/srep01684?__hstc=113740504.2a1e835c34ab7bf88e972fdd7a7debc8.1424476800061.1424476800062.1424476800063.1&__hssc=113740504.1.1424476800064&__hsfp=3972014050), Scientific Reports 2013
- Carniero et al, [Google Trends: A Web-Based Tool for Real-Time Surveillance of Disease Outbreaks](https://academic.oup.com/cid/article/49/10/1557/298019), Clinical Infectious Disease 2009
- Casey et al, [Predicting Patients at Risk for Leaving without Being Seen in the Emergency Department using Machine Learning](https://www.annemergmed.com/article/S0196-0644(18)30753-4/fulltext), Annals of Emergency Medicine 2018

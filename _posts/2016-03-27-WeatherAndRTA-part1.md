---
title: "Does weather cause accidents - part 1"
author: "Roman Popat"
date: "27 March 2016"
output: html_document
layout: post
---

# Blending weather data

Scotland and other parts of the UK have some nicely curated open data on road traffic accidents. For individual cases, where and when they happened, how severe they were, the prevailing road conditions, which emergency services were involved and so on. It felt to me like this should be a very valuable resource and might help us learn about what the causes or maybe correlates of road traffic accidents are. This is partly inspired by Ben Moores work at <http://blackspot.org.uk/>.

One thought that sprang to mind was could we test the common belief that adverse weather conditions result in increased incidence and severity of road traffic accidents. The first part of this was to collect and blend some information on weather conditions for each crash recorded. In this blog, I will explain how I obtained / blended weather information relating to each road traffic incident.

The raw data can be found on [Edinburgh City Council's website]( http://www.edinburghopendata.info/dataset/vehicle-collisions) or pinched from the [github repository](https://github.com/rmnppt/Road_Traffic_Accidents) associated with this post, see the `/data` folder. 

I used a very convenient service from <http://forecast.io/> which I think is designed for weather app makers but I think it can be reasonably employed for small amounts of data plundering. Head to <https://developer.forecast.io/> and get yourself a free API key which you will need for this. Most importantly we are using the Rforecastio package which is housed [here](https://github.com/hrbrmstr/Rforecastio) thanks to [hrbrmstr](https://github.com/hrbrmstr) for providing it. Before starting you should install this with `devtools::install_github("hrbrmstr/Rforecastio")`.

Now you're ready to go fire up R and load in some libraries.




```r
library(dplyr)
library(lubridate)
library(Rforecastio)
```

I had to set the `scipen` option to avoid an error (i'll explain later on).


```r
options(scipen = 100)
```

Next you want to read in the data and I am also going to sample 1000 rows. This is because the forecast API will let you make 1000 free API calls per day. Ideally it would be nice to get the weather data for all of the rows but lets just go with a subset for now. Note I also create a numeric version of the date variable, for later use with `Rforecastio`.


```r
d <- read.csv("data/acc-scot-2005-2012.csv")
d$Date <- dmy(d$Date) %>% as.numeric
d <- d %>% sample_n(1000)
```

Now we need to connect our session to the API, you can visit the `Rforecastio` documentation for this but all you need to do is place your key in the system environment as follows.


```r
Sys.setenv(FORECASTIO_API_KEY = "<Insert your API key here>") 
forecastio_api_key()
```

Now I am going to set up the data collection as follows; first I will define wrapper that calls the API through the `Rforecastio::get_forecast_for()` function. This function will call the API using longitude, latitude and date/time information from the road traffic accidents. I do this because I know that certain things will be fixed such as the level of granularity and what aspect of the results we want to keep. I will then call this function once on the first row of our road traffic accidents, mainly to get an object of the with the correct size and attributes to then collect our results in.


```r
getDailyWeather <- function(lat, lon, time) {
  this <- get_forecast_for(
    lat, lon, time,
    exclude = "minutely,hourly,currently,alerts,flags"
  )
  return(this$daily)
}
weather <- get_forecast_for(
  d$Latitude[1], 
  d$Longitude[1], 
  d$Date[1],
  exclude = "minutely,hourly,alerts,flags,current"
)$daily
weather[1,] <- NA
```

The object called `weather` is a `data.frame` in which we will store our results. Now all we need to do is loop through this object, each time collecting a result with our wrapper for `get_forecast_for`. At this point I was getting an error if the numeric date was too round and being formatted in scientific notation. That is why we set the `scipen` option earlier.


```r
for(i in 1:nrow(d)) {
  weather[i,] <- getDailyWeather(
    d$Latitude[i], 
    d$Longitude[i], 
    d$Date[i]
  )
  if(i%%10 == 0) cat((i/nrow(d))*100, "% done\n")
}
```

Finally we can rejoin this to the original data and its done. We have now blended together the road traffic accidents with historical weather from forecast.io.


```r
names(weather) <- paste0("WTR_", names(weather))
weather_d <- cbind(d, weather)
write.csv(weather_d, "data/sample_weather.csv", row.names = FALSE)
```


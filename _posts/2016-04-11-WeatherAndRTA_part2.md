---
title: "Does weather cause accidents - part 2"
output: html_document
author: "Roman Popat"
date: "12 April 2016"
layout: post
---

In part 1 I showed how to grab data from the forecast.io, now that we have all of that I want to use it to investigate the effects of weather on accidents. First, I realised after playing around a little that one possible way of doing this was as follows; In part 1 we grabbed weather data associated with each accident (time and location). But to compare we might also want weather data from a sample of days where there were no accidents. To do this, I went back to the forecast.io API and for each incident location, I downloaded data from a randomly chosen second day, at least 3 days away from the day of the incident at that location. In this way I am trying to compare weather information from the exact location and time of an accident to some random baseline. In other words is there anything special about weather at the time and location of road traffic accidents (RTA). So I went back to forecsat.io and got some baseline weather data as described (see `scripts/getBaselineWeather.R` in the [GH repo](https://github.com/rmnppt/Road_Traffic_Accidents)), I won't recount it here as its just another use of the same API, much the same as part 1.

Here I will present that analysis that asks; is there anything special about the weather at locations and times where there has been an incident.

Lets set it up.


```r
library(dplyr)
library(tidyr)
library(ggplot2)
d <- read.csv("https://raw.githubusercontent.com/rmnppt/Road_Traffic_Accidents/master/data/sample_weather_control.csv")
```

This next bit is not pretty but I wanted a method to select numeric collumns from `data.frame`. I tried stuff with `apply` but had no luck. 


```r
isNum <- function(dd) {
  n <- ncol(dd)
  num_ind <- logical(n)
  for(i in 1:n) {
    num_ind[i] <- is.numeric(dd[,i])
  }
  return(num_ind)
}
```

I also want to be able to calculate the standard error of the mean.


```r
se <- function(x) sd(x) / sqrt(length(x))
```

This next bit is a big chunk of munging (made easy with `dplyr` and `tidyr`). First I restrict the data to only numeric collumns, then I select some identifiers and the weather variables. Then we gather those weather variables so we have a collumn denoting the weather variable and a collumn storing the value. Then I tidy up the names, spread the accident days from the control days and calculate the difference between the two. 


```r
wthr <- d %>% 
  select(which(isNum(d))) %>%
  select(Date, no_accident_dates, Accident_Severity, matches("WTR")) %>%
  gather(weather_var, value, -c(1:3)) %>%
  separate(weather_var, c("type", "variable"), "_", extra = "merge") %>%
  mutate(variable = sub("WTR_", "", variable)) %>%
  spread(type, value) %>%
  mutate(weather_difference = CONTROL - WTR)
```

Now we have a collumn tracking the difference between values of weather variables between at the point of an accident paired with its randomly sampled control value. Next I want to desribe the distribution of this value. You could do this how you want but I will first scale the values within each variable (they will then be in units of standard deviation). Then I will just plot the mean and standard error for each variable.


```r
summaries <- wthr %>%
  group_by(variable) %>%
  mutate(scaled_weather_diff = scale(weather_difference, F, T)) %>%
  summarise_each(funs(mean, se), scaled_weather_diff)
```

And to finish up we can plot it out.


```r
ggplot(summaries, aes(x = 1, y = mean)) +
  geom_hline(aes(yintercept = 0), col = "grey") +
  geom_pointrange(aes(ymin = mean - se, ymax = mean + se)) +
  facet_wrap(~variable, nrow = 1) + 
  xlab("") + ylab("") +
  theme(panel.background = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_text(hjust = 0.5), 
        strip.text = element_text(angle = 90, vjust = 0))
```

![plot of chunk unnamed-chunk-6](/figure/source/2016-04-11-WeatherAndRTA_part2/unnamed-chunk-6-1.svg)

So what are we to think about this? Not much evidence that these weather variables differ in accident vs. non accident cases. Why? First we are plotting 1 standard error so the full confidence interval would be quite large. Second these are very small effects, on the order of 0.05 standard deviations. 

Some caveats - first and foremost we are using quite a small subset of the data, recall that forecast only let us do 1000 API calls in a day and I limited the analysis to a subset of 1000. Secondly, we are taking weather alone here and it might well be that weather has strong effects in different directions when combined with other information. In other words we cannot rule out interactions between intrinsic factors such as information on the driver and weather variables. Still, interesting nonetheless that in this small escercise, weather did not help us much to understand road traffic accidents. 

Ideas for more or comments to make, feel free to email me, click the  link below.

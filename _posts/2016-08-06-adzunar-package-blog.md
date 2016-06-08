---
title: "Noob package development: job ads data in R with Adzuna"
output: html_document
layout: post
---



Part of our mission at The Data Lab is to create jobs in Data Science. This got us thinking that perhaps we should find a systematic way of quantifying the job market in Scotland and generally. We stumbled upon Adzuna, never heard of it? It's quite cool, looks and feels like a jobs board but is actually a very data enabled service. For example you can upload your CV and it will leverage its database of job ads to predict your salary worth. I still have not had the guts to upload my own :-)

Anyway the good news for us is that Adzuna has a nice REST API that we can query and get results for Scotland or any geographical area. One of my short term goals was to learn more about packages in R and so I decided this was a good opportunity to develop a lightweight R package. First of all go and read [this blog](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) by [Hilary Parker](https://twitter.com/hspter) which was an absolutely perfect distillation of the process. In fact, this page is a shameless re-hash of Hilary's page with my own function. Unless you're interested in getting job data or data from other REST API's then go and read her page instead.

Before you start you need to install a few packages.


```r
install.packages("devtools")
library("devtools")
devtools::install_github("klutometis/roxygen")
library(roxygen2)
```

First step is to create the package directory in R studio.


```r
setwd("parent_directory")
create("adzunar")
```

This will create the directory and some basic template files for your new package. Now its time to add some functions, in my case, I wanted to have a function that would help me query the Adzuna API. You can read the documentation for their API [here](https://developer.adzuna.com/). First of all what does a typical REST API call look like?  


```r
http://api.adzuna.com/v1/api/property/gb/search/1?app_id={YOUR_APP_ID}&app_key={YOUR_APP_KEY}
```

As you can see, it is simply a url. The url contains the base location of the assets `api.adzuna.com`, the geographic location of interest `gb` and after the final `/` some further arguments, a minumum of your api key and app id (obtained from the sample place as the API documentation).

So all we would need to do in R is construct this url pasting in the values of our arguments of choice. Once we have this we can use a very handy function from `library(jsonlite)` that will submit the API call, retrieve the json data object and convert it to a data.frame. Wow! Tip of the hat to the author of `library(jsonlite)` [Jeroen Ooms](https://twitter.com/opencpu).

I wrote this function as follows;


```r
get_country_page <- function(
  keyword, 
  country, 
  app_id, 
  app_key, 
  page
) {
  
  this_url <- paste0(
    "http://api.adzuna.com:80/v1/api/jobs/",
    country,
    "/search/",
    page, "?",
    "app_id=", app_id,
    "&app_key=", app_key,
    "&results_per_page=50",
    "&what=", keyword
  )
  
  dat <- fromJSON(this_url)
  
  return(dat)
  
}
```

All thats happening here is the construction of that url for the api call, passing it to `fromJSON()` and then returning the result. In this case the i'm allowing for some search terms, a different geographic location, the app key and id and finally the page. If you imagine that the web front end returns results in pages that you navigate through, the API is the same, you need to request a particular page of the results. In reality I have added some more functionality to this, which you can examine at the github repo for [adzunar](https://github.com/rmnppt/adzunar). 

Once you have your function, its then really easy to write all of the documentation. What you do is write special comments at the top of the file for the function, then `library(roxygen2)` will compile it into the help file for that function. Below is an example for the function I wrote.


```r
#' Function to query the API by keyword country and results page.
#'
#' This function allows you to query the adzuna API, specifying a keyword, a country code and the number of results that you want. The API limit is 50 per page but if you specify more than that this function will continue to run your query, request succesive pages of the results and return the aggregate data object as a `data.frame`. You can request results that exceed the maximum returned by the API.
#' @param keyword A search string (required)
#' @param country A two letter country code. Any one of "gb", "au", "br", "ca", "de", "fr", "in", "nl", "pl", "ru", "za". Defaults to "gb".
#' @param app_id Your app id provided by Adzuna (required)
#' @param app_key Your app key provided by Adzuna (required)
#' @param n_results The number of results requested. Defaults to 50.
#' @keywords adzuna, API, data download, job adverts
#' @export
#' @examples
#' # (not run)
#' # id <- [Your app id]
#' # key <- [Your app key]
#' # get_country_page("data science", "gb", id, key)
```

Now when you call the `document()` function from your console, this will be compiled into the help file for that function. The next step is to share your package. This can be easily done with github. I'm not going to provide much detail about this as this can be found elsewhere but for the basics you need four commands to share your package on github.


```r
git init
git add
git commit
git push
```

Once your package lives on github all someone needs to do is install as follows.


```r
devtools::install_github("rmnppt/adzunar")
library(adzunar)
```

And away we are. now the user can start calling functions and importantly help files from the new package.



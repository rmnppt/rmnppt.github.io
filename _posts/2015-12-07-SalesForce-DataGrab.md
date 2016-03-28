---
title: "Extracting data from Salesforce"
author: "Roman Popat"
date: "7 December 2015"
output: html_document
layout: post
---

I have been asked to access and present some of our own internal data, stored on a CRM system called Salesforce. Luckily for me someone had already written a set of R bindings for it (phew). As always thank a million to the authors of `RForcecom`, details of which can be found [here](http://rforcecom.plavox.info/). A while ago, I was struggling to extract data from objects because you needed to know the names of the fields you wanted to return before submitting your query. Seems simple but this had me stumped for a while so I thought I would share the solution.

First we authenticate the session (I have all my keys in a seperate folder).


```r
library(RForcecom)
source("~/OneDriveBusiness/Projects/Authentications/SalesForce.R")
session <- rforcecom.login(username, password, instanceURL, apiVersion)
```

Now we can get a list of all the objects available to us.


```r
objects <- rforcecom.getObjectList(session)
```

Here is the tricky bit, to query one of these `objects` we need to know the names of the fields we're interested in. I just wanted everything so wrote a wrapper that would pull all of the fields.


```r
getAllFields <- function(objectName) {
  description <- rforcecom.getObjectDescription(session, objectName)
  fields <- as.character(description$name)
  rforcecom.retrieve(session, objectName, fields)
}
```

Now we can call this function and we're done.


```r
accounts <- getAllFields("Account")
```





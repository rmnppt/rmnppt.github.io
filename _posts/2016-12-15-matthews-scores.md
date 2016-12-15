---
title: "Keith Matthews Exam Question..."
output: html_document
layout: post
---

> Help? I set an exam question with 10 boxes to be filled from 13 possible answers. If randomly completed, what should be the average mark?
> - @KeithRMatthews, 12:13 PM - 15 Dec 2016  


```r
library(ggplot2)
answers <- letters[1:10]
options <- letters[1:13]
```

functions to give random answers and mark them

```r
giveAnswers <- function(options) sample(options, size = 10, replace = FALSE)
markAnswers <- function(correct, given) sum(given == correct)
```

collect scores

```r
scores <- numeric(1e5L)
for(i in seq_along(scores)) {
  scores[i] <- markAnswers(answers, giveAnswers(options))
}
```

averages

```r
mean(scores)
```

```
## [1] 0.766
```

```r
median(scores)
```

```
## [1] 1
```

plot

```r
ggplot(data.frame(score = scores), aes(x = scores)) +
  geom_bar(stat = "count")
```

![plot of chunk unnamed-chunk-5](/figure/source/2016-12-15-matthews-scores/unnamed-chunk-5-1.png)

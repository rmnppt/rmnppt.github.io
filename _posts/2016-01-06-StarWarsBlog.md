---
title: "Language categorisation of Star Wars character names"
author: "Roman Popat"
date: "6 January 2016"
output: html_document
layout: post
---

Last year in December, in time for the big release, myself and a colleague at The Data Lab were having some fun with an Star Wars character names that we had scraped from [Wikipedia](https://en.wikipedia.org/wiki/List_of_Star_Wars_characters). Luckily for us a national outlet, The Scotsman [picked up on this](http://www.scotsman.com/edinburgh/what-nationality-would-star-wars-characters-be-in-the-real-world-1-3976537) and put out an article on their website. We had the idea one lunch time to attempt to cluster the Star Wars names by similarity. What we setlled on was to classify the names into groups. One way to do this is to employ the popular text categorisation software 'textcat'. This can be used to classify new unseen text on the basis of a labelled corpus of previous text. In this case we will use it to classify the language of the unseen text. I've put two key papers in the footnotes here which I heartily recommend, thanks to all athors and conrtibuters[^1]. I'll explain the basis of the method here briefly.

First the labelled corpus of text is split into letter [n-grams](https://en.wikipedia.org/wiki/N-gram) or consecutive letter combinations. For example the word STAR would be split into S, T, A, R, ST, TA, AR, STA and TAR and STAR. An n-gram frequency distribution can be attrubuted to each class, in this case each language. The unseen text is then also split into n-grams and a frequency distribution generated. Then its a matter of using a distance measure to compare the n-grams of the unseen text to those of the labelled corpus and choosing the smallest distance. All of this is done for you in the beautiful R package `textcat` see [^1]. 

First things first, there is a huge caveat here. We are using very small samples of unseen text, the length of a character name, to 'guess' the language that it comes from. My hunch is that this is not a good idea. It is however quite fun. On top of that we can only detect languages for which we have a corpus, see [^1] for more info on how the authors of `texcat` did this. On top of *that* we have no attempt at assigning the relative probabilities of each possible classification. This is actually quite interesting and if anyone has ideas on that I would love to hear from you.

With caveats firmly in place, lets set it up.


```r
library(MASS)
library(textcat)
library(dplyr)
library(ggplot2)
library(pander)

charNames <- read.csv("https://raw.githubusercontent.com/rmnppt/StarWars_textcat/master/Data/star_wars_dataframe.csv", 
                      header = F, as.is = T, sep = "\t", skip = 1)
names(charNames) <- c("name", "desc")
```

Thats the data loaded in, lets take a quick look at similarity between different n-gram profiles stored in the textcat package.


```r
ds <- textcat_xdist(TC_char_profiles)
mds <- isoMDS(ds)
```

```
## initial  value 33.975940 
## final  value 33.975940 
## converged
```

```r
distances <- data.frame(
  lang = rownames(mds$points),
  x = mds$points[,1],
  y = mds$points[,2]
)

ggplot(distances, aes(x = x, y = y)) +
  geom_point() +
  geom_text(aes(label = lang), hjust = -0.1, colour = grey(0.5))
```

![plot of chunk unnamed-chunk-2](/figure/source/2016-01-06-StarWarsBlog/unnamed-chunk-2-1.png) 

Horrible overlap of text labels, I know. If you can overlook that for now, this picture gives us a good idea of which languages it will be harder to discriminate between. Now lets perform the text categorisation.


```r
charNames$langCat <- ""
for(i in 1:nrow(charNames)){
  charNames$langCat[i] <- textcat(charNames$name[i])
}
```

Thats done, now we can examine the results. For extra caution I refer again to the caveats in pragraph 3. With that in mind, lets look at which languages are most common.


```r
counts <- data.frame(table(charNames$langCat))
names(counts)[1] <- "language"
counts$language <- reorder(counts$language, counts$Freq)

ggplot(counts, aes(x = language, y = Freq)) +
  geom_bar(stat = "identity") +
  coord_flip()
```

![plot of chunk unnamed-chunk-4](/figure/source/2016-01-06-StarWarsBlog/unnamed-chunk-4-1.png) 

Lets have a look at characters that have been classified as either english or german.


```r
charNames %>% 
  filter(langCat == "english" | langCat == "german") %>%
  select(name, langCat) %>%
  arrange(langCat)
```

```
##                                 name langCat
## 1                       Tavion Axmis english
## 2                  Empatojayos Brand english
## 3                       Armand Isard english
## 4                   Karina the Great english
## 5                         Tion Medon english
## 6                  Poggle the Lesser english
## 7                         Darth Sion english
## 8                        Riff Tamson english
## 9             Grand Moff Thistleborn english
## 10              Grand Admiral Thrawn english
## 11                     Ace Tiberious english
## 12                            Tiplee english
## 13                    Admiral Trench english
## 14                          Triclops english
## 15                       Stass Allie  german
## 16                             B4-D4  german
## 17                      Darth Bandon  german
## 18                       Bren Derlin  german
## 19 Orgus Din - voiced by Robert Pine  german
## 20            Grand Moff Vilim Disra  german
## 21              Grand Moff Dunhausen  german
## 22                        Bant Eerin  german
## 23                            EV-9D9  german
## 24                       Davin Felth  german
## 25         Grand Moff Bertroff Hissa  german
## 26                               Ken  german
## 27                        Agen Kolar  german
## 28                        Jaden Korr  german
## 29                General Pong Krell  german
## 30                      Satine Kryze  german
## 31             Warmaster Tsavong Lah  german
## 32                         Beru Lars  german
## 33                         Owen Lars  german
## 34                              MD-5  german
## 35                       Bengel Morr  german
## 36                      Karness Muur  german
## 37                 Grand Moff Muzzer  german
## 38                    Ruwee Naberrie  german
## 39                        Ferus Olin  german
## 40                    Echuu Shen-Jon  german
## 41         Grand Moff Wilhuff Tarkin  german
## 42                    Longo Two-Guns  german
## 43                       Darth Vader  german
## 44                     Darth Vitiate  german
## 45                           Taun We  german
## 46                     Beru Whitesun  german
## 47                            Winter  german
```

As usual, all of this stuff and more has been shoved into a [github repository](https://github.com/rmnppt/StarWars_textcat).
See you again soon.


[^1]: 

1. Cavnar, W.B., Trenkle, J.M., (1994) N-Gram-Based Text Categorization. Proceedings of SDAIR-94, 3rd Annual Symposium on Document Analysis and Information Retrieval [http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.53.9367](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.53.9367)

2. Hornik, K., Mair, P., Rauch, J., Geiger, W., Buchta, C., & Feinerer, I. (2013). The textcat Package for n-Gram Based Text Categorization in R. Journal of Statistical Software, 52(6), 1 - 17. [doi:http://dx.doi.org/10.18637/jss.v052.i06](doi:http://dx.doi.org/10.18637/jss.v052.i06)

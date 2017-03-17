---
title: "R + D3, A powerful and beautiful combo"
output: html_document
layout: post
---

For a while now, I have been looking for ways to incorporate pretty D3 graphics into R markdown reports or shiny apps. 

[Here is my attempt so far](https://thedatalab.shinyapps.io/rc3_shiny_test/)

Ok well I wasn't looking too hard because it completely escaped me that you could do this with [htmlwidgets](http://www.htmlwidgets.org/). I stumbled upon this when I was browsing the [shiny user showcase](https://www.rstudio.com/products/shiny/shiny-user-showcase/) and I came across the [FRISS Analytics example](https://frissdemo.shinyapps.io/FrissDashboard/) which is accompanied by a really [fantastic set of tutorials](http://shiny.rstudio.com/tutorial/) under 'other tutorials'. If you want to do this to customise for your own plotting needs, I strongly suggest you start there with those tutorials. They are very thourough and step-wise and will allow you to build a R-D3 binding for the first time with very little hassle, as I have done.

It looks a little like this...

- You write a package.
- The package contains R functions.
- Those functions invoke JavaScript as you define it.
- htmlwidgets binds them together and provide the plumbing between your R objects and the JavaScript that you feed them into.

The outcome is that you can easily create an interactive graphic in the end my simply calling an R function. **The real beauty** though is being able to update the javascript plot in response to user input on the R side, without plotting a new plot each time in the slightly awkward way that I was previously doing. If you have loaded the app try typing extra zeros into the sample size, you'll see the plot update as the underlying data is updated. Smooth. This is what I was looking for.

Of course you don't need to be a JavaScript programmer to get this done. You can use higher levels js libraries such as [C3](c3js.org) in my case or [nvd3](nvd3.org), maybe there are more?

So all in all the chain is...

`R -> htmlwidgets -> || C3 -> D3 -> JavaScript.`

Where htmlwidgets is reaching through the border between R and JavaScript.

This post is obviously not a tutorial just a flag and a signpost, to find out how to do this yourself, go to the FRISS Analytics tutorial either [here on rstudio](http://shiny.rstudio.com/tutorial/) or [here on github](https://github.com/FrissAnalytics/shinyJsTutorials). Thanks a million to the [folks at FRISS analytics](https://github.com/FrissAnalytics/shinyJsTutorials/graphs/contributors) and the [authors of htmlwidgets](https://github.com/ramnathv/htmlwidgets/graphs/contributors).




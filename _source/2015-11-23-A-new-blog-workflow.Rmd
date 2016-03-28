---
layout: post
title: "A new blogging workflow"
date: 2015-11-23 09:32:00 +0000
categories: introduction RMarkdown blog workflow
---

Just disovered the [Jekyll](jekyllrb.com) - [github pages](https://pages.github.com/) combination. Perfect for a very simple static blog site. I also found a pretty neat integration with RMarkdown which suits me perfectly, as I am mainly using R and will be posting bits and pieces of that. 

A summary of how it works...

* Install Jekyll on a local directory and build the site on your disk.
* Create a repo for your github pages site, push the Jekyll directory.
* Done

I'm not going to explain these steps in any detail as they are very well explained in the links above, however if you are an R fanatic like me, it's worth noting the integration with RStudio / RMarkdown. First go install a package called `servr`.

```
install.packages("servr")
```

Thanks for writing and maintainging this [Yihui Xie](https://github.com/yihui).

The package include a function `jekyll()`. First create a directory in your Jekyll route directory called `_source`. Put your `.Rmd` blog scripts in here and then call the `jekyll()` function from R with `setwd()` pointed at your Jekyll route directory. This will compile the script, including any output. The resulting `.md` files go into the `_posts` directory and any figures go into `figure`. Then `git commit` and `git push` and your blog is posted.

It really is that easy, now time for my first post...

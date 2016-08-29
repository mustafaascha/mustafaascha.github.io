---
layout: post  
title: Bookdown Tutorial  
date: 2016-08-28  
---

### Why Bookdown 

There are several tools for making cool documents using markdown, and one of the best tools for producing statistical/data reports is [R Markdown](https:///rmarkdown.rstudio.com). R Markdown is great, but it seems geared towards producing single-file documents. On this page, I'll be briefly reviewing how to make more complex reports using [Yihui Xie's bookdown](https://bookdown.org/yihui/bookdown/). 

If you've never used markdown, you should know that it's used in a lot of different contexts, and has achieved this populatrity by being both simple and readable. [It's used for comments on Reddit, for example](https://www.reddit.com/r/reddit.com/comments/6ewgt/reddit_markdown_primer_or_how_do_you_do_all_that/c03nik6). [This blog is made using markdown, too, powered by Jekyll](https://github.com/mustafaascha/mustafaascha.github.io). If you're interested, [there's an R Markdown cheatsheet here](https://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf). 

If you'd like to produce a long and complicated report [(or website with many pages)](https://bookdown.org/yihui/bookdown/) using several R Markdown files, you should try making a book out of it. The organization that you achieve using several files translates into several chapters--making it easier for you to organize bigger projects. Websites made using bookdown look cool, too. 

If you're familiar with [jekyll](https://jekyllrb.com/), you'll probably get the hang of it quickly. Documents made using Bookdown contain content both within the file and in the file name--kind of like how blog posts written as `yyyy-mm-dd-Post_Name.md` that are saved in the `_posts` folder are used as blog posts. Similarly, Bookdown chapters are organized alphabetically in your Bookdown folder.

Anyway, let's get started.  

### Necessities

I'm going to assume that you're familiar with R Markdown. If you're not familiar, you can get started with [the official RStudio R Markdown documentation](http://rmarkdown.rstudio.com/) or check out a (rudimentary and sparse) tutorial that I wrote on [GitHub](https://github.com/mustafaascha/rmarkdownTutorial).

[The Bookdown author recommends using the RStudio preview version](https://bookdown.org/yihui/bookdown/get-started.html), so I would [visit the RStudio website and install the preview version](https://www.rstudio.com/products/rstudio/download/preview/).

You can install Bookdown using the `devtools` package and the command `devtools::install_github("rstudio/bookdown")`. 

The easiest way to get started is by copying an example book through GitHub. To do this, open your terminal and `cd` to a folder where you'd like to start your project. You'll have to install `git`, then run `git clone https://github.com/rstudio/bookdown-demo`. 

### Trying out your clone

At this point, hopefully you've cloned the Bookdown minimal example. This folder contains what you'll need to build your book. 

To get an idea of the workflow, go ahead and open the Rproj file that's in the Bookdown folder (double click, or get there by opening the file directly within RStudio). Once you've opened the project file, try out the command: `bookdown::render_book("index.Rmd")`. Once the prompt says `Output created: _book/index.html`, you can open the `_book/index.html` file and see what's been compiled. It should [look something like this](https://bookdown.org/yihui/bookdown-demo/). 

Congratulations! You just made a Bookdown book! 

If you'd prefer a PDF, you can specify as much using the `output_format = "pdf_book"` (or `output_format = "bookdown::pdf_book"`, my gut tells me that specifying the package is more fault-tolerant). 

### So what's going on? 

One of the first things to understand is the role of "index.Rmd". Bookdown is organized like a website, and websites use an "index.html" file as the main page that you view. For example, when you go to [mustafa.fyi](http://mustafa.fyi), you're actually visiting [mustafa.fyi/index](http://mustafa.fyi/index). 

Bookdown works similarly, where the "index.Rmd" file helps organize the future Bookdown website. From there, files are included as chapters based on alphanumerical order. So, you'll notice the files are named with two-digit numbers preceding the title. 

Personally, I prefer to keep all of the content together by naming my index file "00-index.Rmd" instead of "index.Rmd", then naming subsequent files with increasing two-digit values. 

### Getting technical

A normal (lonely) R Markdown file acts as its own R session. Here, though, we've got several R Markdown files. So is the book made in one session? Or is it several sessions? 

The answer is: whatever you want. 

By default, all of the Rmd files in a book are run in the same session. This has at least one really important implication--you **must** use unique chunk names in **all** of the bookdown Rmd files. 

Sometimes, you might have a **really** complicated project. In that case, you can run each markdown file using the `render_book` option `new_session = TRUE` or by including the line `new_session: yes` in your `_bookdown.yml` configuration file. By using new sessions for each markdown file, you can avoid accumulating a lot of unnecessary libraries, objects, etc. in your R session. This could mean the difference between running out of RAM and running along smoothly. So, for a big project, consider this option. 

### Getting fancy

I just mentioned that you can use the `_bookdown.yml` configuration file to specify whether you'd like each markdown file to use a new R session. Well, there are other options, too! 

Instead of explaining the various configuration options, [I'll leave it to the bookdown package author to describe what you can do with `_bookdown.yml`](https://bookdown.org/yihui/bookdown/configuration.html). 

If you'd like to get even fancier, you can play around with the CSS files to create a more customized website. I'll be trying that out, someday....

### Conclusions? 

This has been a brief, perhaps even stylized explanation of bookdown. You have far more available to mess around with, and I highly recommend [fully reviewing the documentation that the bookdown author provides](https://bookdown.org/yihui/bookdown/). 

Besides what has been described here, you can do a lot of other cool things. You can add bibliographic references, HTML widgets, Shiny apps, and a whole lot more (that you should really read in the documentation linked above). 

I hope this serves as a useful starting point. If you do make your own book, I highly recommend hosting it through [your own GitHub page](https://pages.github.com/) and [let me know!](mustafa.ascha@gmail.com). 

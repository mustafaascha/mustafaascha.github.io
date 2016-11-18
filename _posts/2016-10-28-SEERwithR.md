---
layout: post
title: Reading SEER data into R
date: 2016-10-28
---

**Note**

I wrote this about a year ago, but I'm posting it here in case someone
finds it helpful.

### Intro/purpose

The Surveillance, Epidemiology, and End Results (SEER) Program provides
a lot of potentially useful cancer data. Unfortunately, the data 
require either SAS or a heavy time commitment to be useful. This document 
shows how to obtain SEER data and combine the 40 provided files into 
just a few files.

### Requesting/Downloading the data

To begin doing anything, you'll have to obtain data. Go to [this
page](http://seer.cancer.gov/data/access.html) to request the data and
sign their agreement form.

After returning the agreement form, you'll be linked to [this
site](http://seer.cancer.gov/data/options.html). Pick ZIP or exe,
whatever you prefer, as long as you download the *ASCII text version of
the data*. You'll have to give them your username/pw to download the
data, of course.

Unpack the files, they should be something like 3GB total. You'll
probably notice that there are dozens of files, spread across several
folders. This...is inconvenient. Fortunately, there's an R package for
that!

### Installing SEERaBomb

Thanks to the hard work of researchers at the Cleveland Clinic
Foundation, there's an R package that will assemble the many SEER materials
into just a few coherent files. Moreover, you'll have the data in native R 
format and as a database! 

If you're interested in learning more about it, check out the [SEERaBomb
documentation here](https://cran.r-project.org/web/packages/SEERaBomb/index.html).

Installing the R package dependencies for SEERaBomb also requires
installing a library outside of R, the Open GL Utility, "GLU".

Ubuntu users can just run `sudo apt-get install libglu1-mesa-dev`; and
RedHat users can run `yum install Mesa-devel`.

If you're using a Mac, check
[here](http://alumni.cs.ucsb.edu/~wombatty/tutorials/opengl_mac_osx.html)
for instructions.

For Windows (or more detailed instructions for other operating systems), see [here](https://www.opengl.org/documentation/implementations/) for how to install GLU.

After installing the dependencies, install and load `SEERaBomb`:  

    install.packages("SEERaBomb")

    library(SEERaBomb)

I recall I had to install the dependencies by hand, so if the previous 
commands didn't work then try this: 


    install.packages(c("LaF",
                "RSQLite",
                "dplyr",
                "XLConnect",
                "Rcpp",
                "rgl",
                "reshape2",
                "mgcv",
                "DBI",
                "bbmle"))

    install.packages("SEERaBomb")

    library(SEERaBomb)


### SEERaBomb Prep Work

The command `getFields` parses out the SAS files to generate a dataframe
(without data yet) that contains all of the SEER fields. Use it as
follows:

    df <- getFields(seerHome = "SEER_1973_2012_TEXTDATA/")

This next command will create a dataframe that only extracts those
variables that we want. It was intended to allow the user to select
variables of interest, allowing for faster and more streamlined work. I
used this package with the intention of exploring the data, so I want
all the variables!

    df <- pickFields(sas = df, picks = df$names)

If you want the program to run faster, probably select which variables
you'd like. You can do this by substituting a subset of `df$names` in
the `picks` option of the previous command.

Congratulations! You've successfully prepared to put the files together.

### Assemble the files!

The following command will assemble the 40 separate files into four, of
which the rest of this tutorial will focus on one. Personally, I ran
this command and grabbed a cup of coffee.

    mkSEER(df, seerHome = "SEER_1973_2012_TEXTDATA/")


At this point, you'll have a new folder called `mrgd` that contains 
database files and an RData file for you to use. 

If the `mkSEER` command doesn't work, try having it only make the 
RData file. This requires less RAM: 

    mkSEER(df, 
           seerHome = "SEER_1973_2012_TEXTDATA/", 
           writePops = FALSE, 
           writeDB = FALSE)

The worst case scenario that I can envision is that, if your R session
hangs even after removing `writePops` and `writeDB`, you might have 
to select fewer variables. 

### Wrapping up

You'll have to recode the variables. This is a bit annoying, but you'll 
have a headstart if you use code [from here](https://github.com/mustafaascha/SEERwithR/blob/master/02%20-%20Recoding/cleaningFakeData.R).

Otherwise, best of luck and happy hunting! 


#### Citations:

\[1\] T. Radivoyevitch. *SEERaBomb: SEER and Atomic Bomb Survivor Data
Analysis Tools*. R package version 2016.2. 2016. &lt;URL:
<https://CRAN.R-project.org/package=SEERaBomb>&gt;.


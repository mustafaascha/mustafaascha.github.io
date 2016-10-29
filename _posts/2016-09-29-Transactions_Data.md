---
layout: post
title: Graphing association
date: 2016-09-29
---

-   [Load libraries, get data](#load-libraries-get-data)
-   [Format data for arules](#format-data-for-arules)
-   [Checking out our data](#checking-out-our-data)
-   [`arules` and friends](#arules-and-friends)
-   [Interpreting this information](#interpreting-this-information)
-   [To come....](#to-come....)

In the last post, we went through the process of simulating some random
billing claims data, then putting it through the CSPADE algorithm to see
if there were any interesting frequent sequences. Here, we'll review how 
to graph association rules without sequences.

Before we begin any coding, I'd like to point out that our model will
involve considering patients as transactions, and diseases as items.
There are also several metrics for evaluating associations; for more 
on understanding association rules, [check out the `arules` package author's
document.](https://cran.r-project.org/web/packages/arules/vignettes/arules.pdf)
It's a great website, and I highly recommend reading through it.

Load libraries, get data
------------------------

First, of course, we'll have to load some libraries.

    library(arules)
    library(arulesViz)
    library(dplyr)
    library(ggplot2)
    library(tidyr)
    library(stringr)

Because this is a simulation, there will be some randomness involved. To
make sure you can replicate everything, we'll set a seed:

    set.seed(9001)

To begin making data, here's a list of diseases. We'll use that to make 
a dataframe with five patients.

    diseases <- 
        c("Heart_disease",
          "Hypertension",
          "Kidney_disease",
          "Liver_cirrhosis",
          "Gall_stones",
          "Kidney_stones",
          "Tonsiliths",
          "Unspecified_cancer",
          "Vitamin_D_deficiency",
          "Trichtillomania",
          "Hearing_loss")

    claims_data <- 
        data.frame(disease = sample(diseases, 20, replace = TRUE), 
               patient = rep_len(1:5, 20), stringsAsFactors = FALSE)

Format data for arules
----------------------

Given some data, let's prepare it for associations analysis. We'll use
the `split` command to produce a list of the diseases that contains a
vector of patient identifiers for patients with those diseases.

Here we go:

    claims_tx <- split(claims_data$patient, claims_data$disease)

I'll be artificially adding "Hypertension" and "Kidney disease" to
several of the patients, just to make sure arules works. ;)

    claims_tx$Hypertension <- c(claims_tx$Hypertension, 1:3)

    claims_tx$Kidney_disease <- c(claims_tx$Kidney_disease, 1:3)

    claims_tx$Heart_disease <- c(claims_tx$Heart_disease, 1:3)

Hopefully that will work..

Note that `arules` won't accept "tidLists" with a transaction listed
more than once. In our case, that means that patients who have several
of the same diagnosis will be considered only in terms of their yes-no
disease status. If you're interested in recommender systems that can
handle ratings or counts data, I recommend looking into [collaborative
filtering approaches](https://en.wikipedia.org/wiki/Netflix_Prize).

    claims_tx <- lapply(claims_tx, function(x) sort(unique(x)))

    claims_tx <- as(claims_tx, "tidLists")

Checking out our data
---------------------

Even before running the *apriori* or *eclat* algorithms, there's a lot
to learn about the data.

Here's what R shows when you ask for the object:

    claims_tx

    ## tidLists in sparse format with
    ##  10 items/itemsets (rows) and
    ##  5 transactions (columns)

That's useful--we know how many items (diagnoses) and how many
transactions (patients) we have.

We can also `inspect` the claims:

    claims_inspect <- inspect(claims_tx)

<table style="width:50%;">
<colgroup>
<col width="29%" />
<col width="20%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">items</th>
<th align="center">transactionIDs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Hearing_loss</td>
<td align="center">{2,3,4}</td>
</tr>
<tr class="even">
<td align="center">Heart_disease</td>
<td align="center">{1,2,3,5}</td>
</tr>
<tr class="odd">
<td align="center">Hypertension</td>
<td align="center">{1,2,3,5}</td>
</tr>
<tr class="even">
<td align="center">Kidney_disease</td>
<td align="center">{1,2,3}</td>
</tr>
<tr class="odd">
<td align="center">Kidney_stones</td>
<td align="center">{2}</td>
</tr>
<tr class="even">
<td align="center">Liver_cirrhosis</td>
<td align="center">{3}</td>
</tr>
<tr class="odd">
<td align="center">Tonsiliths</td>
<td align="center">{4}</td>
</tr>
<tr class="even">
<td align="center">Trichtillomania</td>
<td align="center">{1,2,3}</td>
</tr>
<tr class="odd">
<td align="center">Unspecified_cancer</td>
<td align="center">{4,5}</td>
</tr>
<tr class="even">
<td align="center">Vitamin_D_deficiency</td>
<td align="center">{5}</td>
</tr>
</tbody>
</table>

The previous table tells us which patients have which diseases. There
are a few ways to interpret this, as far as extracting interesting
information.

For a more extensive list of things to do with `tidLists`, we can use
the `methods` function:

    methods(class = "tidLists")

    ##  [1] abbreviate        coerce            c                
    ##  [4] dimnames<-        dimnames          dim              
    ##  [7] image             initialize        inspect          
    ## [10] itemFrequency     itemInfo<-        itemInfo         
    ## [13] itemLabels        labels            length           
    ## [16] LIST              show              size             
    ## [19] summary           [                 transactionInfo<-
    ## [22] transactionInfo   t                
    ## see '?methods' for accessing help and source code

The last exploration we'll do before association analyses is a
visualization:

    image(claims_tx)

![](http://mustafa.fyi/assets/image_claims-1.png)

`arules` and friends
--------------------

At this point, let's see what the *apriori* algorithm has to say. First,
we'll have R calculate the relationships according to our own
parameters: minimum support, minimum confidence and the maximum length of an
association.


    claims_rules <- 
      apriori(claims_tx, parameter = list(support = 0.01, confidence = 0.1, maxlen = 2))

    ## Apriori
    ## 
    ## Parameter specification:
    ##  confidence minval smax arem  aval originalSupport maxtime support minlen
    ##         0.1    0.1    1 none FALSE            TRUE       5    0.01      1
    ##  maxlen target   ext
    ##       2  rules FALSE
    ## 
    ## Algorithmic control:
    ##  filter tree heap memopt load sort verbose
    ##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
    ## 
    ## Absolute minimum support count: 0 
    ## 
    ## set item appearances ...[0 item(s)] done [0.00s].
    ## set transactions ...[10 item(s), 5 transaction(s)] done [0.00s].
    ## sorting and recoding items ... [10 item(s)] done [0.00s].
    ## creating transaction tree ... done [0.00s].
    ## checking subsets of size 1 2 done [0.00s].
    ## writing ... [66 rule(s)] done [0.00s].
    ## creating S4 object  ... done [0.00s].

There are a few packages for rules visualization, it's worth going
through `rules` class methods before getting our hands dirty with the
raw data: 


    methods(class = "rules")

    ##  [1] abbreviate             aggregate              coerce                
    ##  [4] coverage               c                      dissimilarity         
    ##  [7] duplicated             generatingItemsets     head                  
    ## [10] %in%                   info<-                 info                  
    ## [13] initialize             inspectDT              inspect               
    ## [16] interestMeasure        intersect              is.element            
    ## [19] is.maximal             is.redundant           is.significant        
    ## [22] is.subset              is.superset            itemInfo              
    ## [25] itemLabels             items                  labels                
    ## [28] length                 lhs<-                  lhs                   
    ## [31] match                  plot                   quality<-             
    ## [34] quality                rhs<-                  rhs                   
    ## [37] [                      sample                 setdiff               
    ## [40] setequal               show                   size                  
    ## [43] sort                   subset                 summary               
    ## [46] support                supportingTransactions tail                  
    ## [49] t                      union                  unique                
    ## [52] write                 
    ## see '?methods' for accessing help and source code
    
There's a lot available to explore!

To get you going, here's one of the default plotting methods: 

    plot(claims_rules, method = "graph", control = list(type = "items"))

![](http://mustafa.fyi/assets/plot_rules-1.png)

Interpreting this information
-----------------------------

This is healthcare data, so it makes the sense to look at tests of 
difference and odds ratios. There are other measures of rules, definitely check out the
documentation.

Here's how to calculate the interest measures and cbind them to a data
frame showing associations and other measures:

    claims_rules_measures <- interestMeasure(x = claims_rules, 
                                             measure = c("chiSquared", "FishersExactTest", "oddsRatio"), 
                                             transactions = claims_tx)

    claims_rules_measures <- 
      cbind(as(claims_rules, "data.frame"), claims_rules_measures)

There's some munging required...

    library(statnet)

    claims_rules_measures$rules <- as.character(claims_rules_measures$rules)

    claims_rules_measures <- 
      claims_rules_measures %>% 
        separate(col = "rules", 
               into = c("First_disease", "Second_disease"), 
               sep = "\\=\\>", 
               extra = "drop")

    claims_rules_measures$First_disease <- 
      str_replace_all(string = claims_rules_measures$First_disease, pattern = "\\{|\\}", replacement = "")

    claims_rules_measures$Second_disease <- 
      str_replace_all(string = claims_rules_measures$Second_disease, pattern = "\\{|\\}", replacement = "")

    claims_rules_measures <- 
      claims_rules_measures %>% filter(First_disease != " ")

    claims_rules_measures <- 
      claims_rules_measures[rep_len(c(TRUE, FALSE), nrow(claims_rules_measures)),]
      
We can then use this data to make a network of disease-disease associations (which can be assigned attributes according to the rules measures, but that's for another time): 

    claims_network <- 
      network(x = cbind(claims_rules_measures$First_disease, claims_rules_measures$Second_disease), directed = TRUE)

Let's see what this `network` object looks like:

    plot(claims_network)

![](http://mustafa.fyi/assets/claims_viz-1.png)

Or, we can try doing something like this with igraph:

    library(igraph)

    claims_igraph <- graph.data.frame(d = claims_rules_measures %>% select(First_disease, Second_disease, oddsRatio))

    plot(claims_igraph, edge.arrow.size = 0.04)

![](http://mustafa.fyi/assets/gg_claims-1.png)

    class(claims_igraph)

    ## [1] "igraph"

    methods(class = "igraph")

    ##  [1] cohesion     difference   -            [<-          [           
    ##  [6] [[           $<-          $            *            +           
    ## [11] intersection modularity   plot         print        rep         
    ## [16] rglplot      scg          str          summary      union       
    ## see '?methods' for accessing help and source code

We can even use `ggplot2`:

    library(ggnetwork)

    library(viridis)


    claims_ggnetwork <- ggnetwork(claims_network)

    claims_ggnetwork$vertex.names <- as.character(claims_ggnetwork$vertex.names)


    ggplot(claims_ggnetwork, aes()) + 
      geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) + 
      geom_point(aes(x, y, col = vertex.names), size = 10) + 
      scale_color_viridis(discrete = TRUE) + 
      theme(legend.position = "right")

![](http://mustafa.fyi/assets/check_methods-1.png)

To come....
-----------

-   Network analysis with `rules` objects
-   Getting started with SEER data in R
-   Analyzing time to second cancer using SEER

---
layout: post
title: Healthcare Claims, Sequences Analysis
date: 2016-09-05
---

Purpose
-------

[There
are](http://michael.hahsler.net/research/arules_RUG_2015/talk/arules_RUG2015.pdf)
[a lot](http://www.rdatamining.com/examples/association-rules) of [great
resources](http://statistical-research.com/association-rule-learning-and-the-apriori-algorithm/)
for [performing market-basket (association)
analysis](http://www.salemmarafi.com/code/market-basket-analysis-with-r/).

There are fewer resources on mining sequences data. This
document will review how to (1) convert a set of billing claims to an appropriate format
for the R package arulesSequences, and (2) run the CSPADE sequences analysis algorithm. 
As you might expect, cleaning the data is the hard part. For anyone who was in 
my position and had billing claims of similar form, this might help save some time.

Future posts will simulate data with particular sequences added, which will then by 
analyzed using CSPADE and results interpreted. Also, for those of you working with
"big" data, there is an adapted sequences-reading function that takes advantage of 
the tidyverse and parallel CPU processes. 

Software
--------

There are a few packages for mining sequences associations in R. I'll be
using
[arulesSequences](https://cran.r-project.org/web/packages/arulesSequences/index.html)
for this post, but I would like to point out one alternative,
[TraMineR](http://traminer.unige.ch/).

The TraMineR website has a lot of resources, though there seem to be
fewer for arulesSequences. The best source for learning arulesSequences,
at the moment, appears to be [this Data Mining Algorithms in R
Wikibook](https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Sequence_Mining/SPADE).
The previously-linked tutorial uses data provided by the arulesSequences
package, though, and I know that I had trouble figuring out how to make
things work using my own data.

We'll be using the tidyverse packages to fit data into its correct
format. Here are the libraries you'll need:

    library(pander)
    library(lubridate)
    library(dplyr)
    library(tidyr)
    library(purrr)
    library(stringr)

Data
----

Alright, so first let's simulate some data. I'll be working under the
assumption that you have a list of one diagnosis per patient, though
there may be several listings for the same visit.

Because we are working with healthcare data, it is important to note
that we will consider each patient to be an "event". This becomes useful
as we construct the data.

Our goal will be to move from the format of:

<table style="width:62%;">
<colgroup>
<col width="18%" />
<col width="27%" />
<col width="16%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">patient_diagnosis</th>
<th align="center">date_visit</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">Heart</td>
<td align="center">1910-01-01</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">Lung</td>
<td align="center">1910-01-10</td>
</tr>
<tr class="odd">
<td align="center">1</td>
<td align="center">Lung</td>
<td align="center">1910-01-20</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">Liver</td>
<td align="center">1910-01-30</td>
</tr>
</tbody>
</table>

to the format:

<table style="width:51%;">
<colgroup>
<col width="11%" />
<col width="18%" />
<col width="13%" />
<col width="8%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">items</th>
<th align="center">sequenceID</th>
<th align="center">eventID</th>
<th align="center">size</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Heart</td>
<td align="center">1</td>
<td align="center">1</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">Lung</td>
<td align="center">1</td>
<td align="center">2</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">Liver</td>
<td align="center">2</td>
<td align="center">1</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">Brain</td>
<td align="center">2</td>
<td align="center">2</td>
<td align="center">1</td>
</tr>
</tbody>
</table>

Note that, because there is more than one diagnosis per patient-visit,
we will have a size greater than one.

If you want to see the example "zaki" data provided by `arulesSequences`, you can
load the library and run `data(zaki)`. If you convert it to a data.frame
(`as(zaki, "data.frame")`), you should see something like this:

<table style="width:54%;">
<colgroup>
<col width="13%" />
<col width="18%" />
<col width="13%" />
<col width="8%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">items</th>
<th align="center">sequenceID</th>
<th align="center">eventID</th>
<th align="center">SIZE</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">{C,D}</td>
<td align="center">1</td>
<td align="center">10</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">{A,B,C}</td>
<td align="center">1</td>
<td align="center">15</td>
<td align="center">3</td>
</tr>
<tr class="odd">
<td align="center">{A,B,F}</td>
<td align="center">1</td>
<td align="center">20</td>
<td align="center">3</td>
</tr>
<tr class="even">
<td align="center">{A,C,D,F}</td>
<td align="center">1</td>
<td align="center">25</td>
<td align="center">4</td>
</tr>
<tr class="odd">
<td align="center">{A,B,F}</td>
<td align="center">2</td>
<td align="center">15</td>
<td align="center">3</td>
</tr>
<tr class="even">
<td align="center">{E}</td>
<td align="center">2</td>
<td align="center">20</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">{A,B,F}</td>
<td align="center">3</td>
<td align="center">10</td>
<td align="center">3</td>
</tr>
<tr class="even">
<td align="center">{D,G,H}</td>
<td align="center">4</td>
<td align="center">10</td>
<td align="center">3</td>
</tr>
<tr class="odd">
<td align="center">{B,F}</td>
<td align="center">4</td>
<td align="center">20</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">{A,G,H}</td>
<td align="center">4</td>
<td align="center">25</td>
<td align="center">3</td>
</tr>
</tbody>
</table>

To simulate data, I'll be using a list of fake diseases that correlate
to each `patient_diagnosis` as follows:

<table style="width:44%;">
<colgroup>
<col width="27%" />
<col width="16%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_diagnosis</th>
<th align="center">disease</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">Heart</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">Lung</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">Kidney</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">Liver</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">Gall Bladder</td>
</tr>
<tr class="even">
<td align="center">6</td>
<td align="center">Foot</td>
</tr>
<tr class="odd">
<td align="center">7</td>
<td align="center">Mouth</td>
</tr>
<tr class="even">
<td align="center">8</td>
<td align="center">Colon</td>
</tr>
<tr class="odd">
<td align="center">9</td>
<td align="center">Shoulder</td>
</tr>
<tr class="even">
<td align="center">10</td>
<td align="center">Hair</td>
</tr>
</tbody>
</table>

Here's how we'll simulate the data:

    sim_from <- 
      data.frame(patient_ID = 
                   rep_len(1:5, 100), 
               patient_diagnosis = 
                   round(runif(n = 100, min = 1, max = 10)), 
               date_visit = 
                   rep_len(paste("1990/1/", 1:30, sep = ""), length.out = 100))

The reason why I insist on using diagnosis codes is because healthcare
billing claims are often coded according to the [International
Classfication of
Disease](https://en.wikipedia.org/wiki/International_Statistical_Classification_of_Diseases_and_Related_Health_Problems),
[Healthcare Common Procedure Coding
System](https://en.wikipedia.org/wiki/Healthcare_Common_Procedure_Coding_System),
or [Current Procedural
Terminology](https://en.wikipedia.org/wiki/Current_Procedural_Terminology).
You can find a list of [ICD codes to
diagnoses](https://www.cms.gov/Medicare/Coding/ICD9ProviderDiagnosticCodes/codes.html)
or [HCPCS codes to
procedures](https://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets/index.html)
at the Centers for Medicare and Medicaid Services website if you're
interested. I've found that CPT codes are harder to obtain, though feel
free to email me and let me know if they're easily
available: <mustafa.ascha@gmail.com>.

Cleaning the data so it fits
----------------------------

There are a couple of issues with the initial format:

-   - We've got dates, but we need sequences
-   - We need the diagnosis names instead of their codes
-   - We need all of the items for each transaction listed in one row,
    instead of one row for each transaction-diagnosis

### Fixing the date

Let's start with lubridating the dates for easier handling:

    sim_from$date_visit <- 
      parse_date_time(sim_from$date_visit, orders = "ymd")

And then we'll turn them into rankings for each patient-visit using the
`dplyr` function `dense_rank` to rank.There may be multiple diagnoses
per patient-visit, but this isn't an issue because the `dense_rank`
function handles ties by assigning the same value to each tied
observation.

    sim_from <- 
      sim_from %>% 
      group_by(patient_ID) %>% 
      mutate(sequenceID = dense_rank(date_visit)) %>%
      data.frame()

And let's see how that looks:

    pander(head(sim_from))

<table style="width:82%;">
<colgroup>
<col width="18%" />
<col width="27%" />
<col width="18%" />
<col width="18%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">patient_diagnosis</th>
<th align="center">date_visit</th>
<th align="center">sequenceID</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">1990-01-01</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">8</td>
<td align="center">1990-01-02</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">2</td>
<td align="center">1990-01-03</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">7</td>
<td align="center">1990-01-04</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">6</td>
<td align="center">1990-01-05</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">2</td>
<td align="center">1990-01-06</td>
<td align="center">2</td>
</tr>
</tbody>
</table>

We don't need the date anymore because we'll just be looking at
sequences, so let's get rid of that:

    sim_from$date_visit <- NULL

Given the simulated data, we can expect three or four diagnoses per
patient-visit. Here's a summary of the number of diagnoses for patient
number 1:

    sim_from %>%
      group_by(patient_ID, sequenceID) %>% 
      summarize(diagnoses_size = n()) %>% 
      head %>% 
      pander

<table style="width:58%;">
<colgroup>
<col width="18%" />
<col width="18%" />
<col width="22%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">sequenceID</th>
<th align="center">diagnoses_size</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">1</td>
<td align="center">4</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">2</td>
<td align="center">4</td>
</tr>
<tr class="odd">
<td align="center">1</td>
<td align="center">3</td>
<td align="center">3</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">3</td>
</tr>
<tr class="odd">
<td align="center">1</td>
<td align="center">5</td>
<td align="center">3</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">6</td>
<td align="center">3</td>
</tr>
</tbody>
</table>

### Translating diagnosis codes

This part isn't too hard, it's just a `left_join`. To learn more about
two-table verbs, [check out this very useful
tutorial](http://stat545.com/bit001_dplyr-cheatsheet.html). I've
referred to that website more times than I can count, and it makes me
think I should understand SQL better than I do.

Anyway, here's the code and a sample of its output:

    sim_from <- 
      left_join(sim_from, diagnosis_codes)

    ## Joining, by = "patient_diagnosis"

You'll notice that `dplyr` says the tables were joined by
"patient\_diagnosis". That's the only variable common between the two
tables, so `dplyr` picked it as the ID variable to use for joining.

Here's what the joined table looks like:

    pander(head(sim_from))

<table style="width:76%;">
<colgroup>
<col width="18%" />
<col width="27%" />
<col width="18%" />
<col width="12%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">patient_diagnosis</th>
<th align="center">sequenceID</th>
<th align="center">disease</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Liver</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">8</td>
<td align="center">1</td>
<td align="center">Colon</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">2</td>
<td align="center">1</td>
<td align="center">Lung</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">7</td>
<td align="center">1</td>
<td align="center">Mouth</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">6</td>
<td align="center">1</td>
<td align="center">Foot</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">2</td>
<td align="center">2</td>
<td align="center">Lung</td>
</tr>
</tbody>
</table>

When doing sequences analysis, it's a lot easier to interpret the words
"heart" and "lung" than it is to refer numbers back to diseases. So,
we'll remove the coded diagnosis and keep the disease name.

    sim_from$patient_diagnosis <- NULL

### Making a basket size variable

Given the CSPADE program's requirements, we'll need to make a variable
for the number of diagnoses at that visit. `dplyr` makes this task
really easy!

    sim_from <- 
     sim_from %>% 
      group_by(patient_ID, sequenceID) %>% 
      mutate(basket_size = n())

Let's see what we've got, at this point:

    pander(head(sim_from))

<table style="width:68%;">
<colgroup>
<col width="18%" />
<col width="18%" />
<col width="13%" />
<col width="18%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">sequenceID</th>
<th align="center">disease</th>
<th align="center">basket_size</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">1</td>
<td align="center">Liver</td>
<td align="center">4</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">1</td>
<td align="center">Colon</td>
<td align="center">4</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">1</td>
<td align="center">Lung</td>
<td align="center">4</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Mouth</td>
<td align="center">4</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">1</td>
<td align="center">Foot</td>
<td align="center">4</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">2</td>
<td align="center">Lung</td>
<td align="center">4</td>
</tr>
</tbody>
</table>

### Splitting by patient-visit

I already mentioned that the CSPADE algorithm used by `arulesSequences`
is specific about the format of the data required, but this is probably
the most CSPADE-specific requirement. For the data format used in this
tutorial, we'll have to make a new variable listing each disease that
was diagnosed at a patient's visit.

In keeping with `arulesSequences` standards, we'll refer to the
diagnoses as "items".

    sim_from$disease <- as.character(sim_from$disease)

    sim_split <- 
      sim_from %>% 
      group_by(patient_ID, basket_size, sequenceID) %>% 
      nest() %>% 
      mutate(items = map_chr(data, paste0, ","))

Here's a look at what we've got so far:

    pander(head(sim_split))

<table style="width:94%;">
<caption>Table continues below</caption>
<colgroup>
<col width="18%" />
<col width="19%" />
<col width="18%" />
<col width="38%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">basket_size</th>
<th align="center">sequenceID</th>
<th align="center">data</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Liver, Foot, Gall Bladder, Shoulder</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Colon, Heart, Heart, Colon</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Lung, Foot, Colon, Foot</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Mouth, Hair, Hair, Heart</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Foot, Foot, Kidney, Foot</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">2</td>
<td align="center">Lung, Mouth, Shoulder, Mouth</td>
</tr>
</tbody>
</table>

<table style="width:42%;">
<colgroup>
<col width="41%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">items</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">c(&quot;Liver&quot;, &quot;Foot&quot;, &quot;Gall Bladder&quot;, &quot;Shoulder&quot;),</td>
</tr>
<tr class="even">
<td align="center">c(&quot;Colon&quot;, &quot;Heart&quot;, &quot;Heart&quot;, &quot;Colon&quot;),</td>
</tr>
<tr class="odd">
<td align="center">c(&quot;Lung&quot;, &quot;Foot&quot;, &quot;Colon&quot;, &quot;Foot&quot;),</td>
</tr>
<tr class="even">
<td align="center">c(&quot;Mouth&quot;, &quot;Hair&quot;, &quot;Hair&quot;, &quot;Heart&quot;),</td>
</tr>
<tr class="odd">
<td align="center">c(&quot;Foot&quot;, &quot;Foot&quot;, &quot;Kidney&quot;, &quot;Foot&quot;),</td>
</tr>
<tr class="even">
<td align="center">c(&quot;Lung&quot;, &quot;Mouth&quot;, &quot;Shoulder&quot;, &quot;Mouth&quot;),</td>
</tr>
</tbody>
</table>

The data appears to be in the right form at this point because `tidyr`
data shows up that way. However, we'll need to do a little bit of string
formatting before we've reached the right form for CSPADE.

I'll remove the `data`, now that we've got a list of each patient-visit.

    sim_split$data <- NULL

And then also fix the strings so that they look like "zaki".

    sim_split$items <- 
      str_replace_all(sim_split$items, 
                      pattern = "^c\\(|\\)", 
                      replacement = "") %>% 
      str_replace_all(pattern = '"', replacement = "") %>% 
      as.character

I added the `as.character` because `stringr` returns more complex data
structures.

Besides the curly braces that wrap the items in "zaki", this looks
complete:

    pander(head(sim_split))

<table style="width:96%;">
<colgroup>
<col width="18%" />
<col width="19%" />
<col width="18%" />
<col width="40%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">patient_ID</th>
<th align="center">basket_size</th>
<th align="center">sequenceID</th>
<th align="center">items</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Liver, Foot, Gall Bladder, Shoulder,</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Colon, Heart, Heart, Colon,</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Lung, Foot, Colon, Foot,</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Mouth, Hair, Hair, Heart,</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">4</td>
<td align="center">1</td>
<td align="center">Foot, Foot, Kidney, Foot,</td>
</tr>
<tr class="even">
<td align="center">1</td>
<td align="center">4</td>
<td align="center">2</td>
<td align="center">Lung, Mouth, Shoulder, Mouth,</td>
</tr>
</tbody>
</table>

The hardest part is now over.

Running the algorithm
---------------------

Alright, so let's load the `arulesSequences` library:

    library(arulesSequences)

`read_baskets` only accepts data that is written to disk, so we'll have
to do that:

    write.table(sim_split, "transactions.csv", 
                row.names = FALSE, 
                col.names = FALSE,
                sep = ' ',
                quote = FALSE)

And now we can get the data in transactions form:

    sim_tx <- 
      read_baskets("transactions.csv", info = c("eventID", "size", "sequenceID"))

Let's see how that looks as a `data.frame`:

    pander(head(as(sim_tx, "data.frame")))

<table style="width:94%;">
<colgroup>
<col width="54%" />
<col width="13%" />
<col width="9%" />
<col width="16%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">items</th>
<th align="center">eventID</th>
<th align="center">size</th>
<th align="center">sequenceID</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">{Bladder,,Foot,,Gall,Liver,,Shoulder,}</td>
<td align="center">1</td>
<td align="center">4</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">{Colon,,Heart,}</td>
<td align="center">2</td>
<td align="center">4</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">{Colon,,Foot,,Lung,}</td>
<td align="center">3</td>
<td align="center">4</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">{Hair,,Heart,,Mouth,}</td>
<td align="center">4</td>
<td align="center">4</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">{Foot,,Kidney,}</td>
<td align="center">5</td>
<td align="center">4</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">{Lung,,Mouth,,Shoulder,}</td>
<td align="center">1</td>
<td align="center">4</td>
<td align="center">2</td>
</tr>
</tbody>
</table>

Nice!

Knowing that the data was randomly generated, we shouldn't expect to
find anything very interesting. Still, let's run the algorithm:

    sim_cspade <- 
      cspade(sim_tx, 
             parameter = list(support = 0.1, maxlen = 3, mingap = 2), 
             control = list(verbose = TRUE, summary = TRUE, bfstype = TRUE))

    ## 
    ## parameter specification:
    ## support : 0.1
    ## maxsize :  10
    ## maxlen  :   3
    ## mingap  :   2
    ## 
    ## algorithmic control:
    ## bfstype  :  TRUE
    ## verbose  :  TRUE
    ## summary  :  TRUE
    ## tidLists : FALSE
    ## 
    ## preprocessing ... 1 partition(s), 0 MB [0.008s]
    ## mining transactions ... 0.11 MB [0.012s]
    ## reading sequences ... [0.28s]
    ## 
    ## total elapsed time: 0.301s

### Starting to interpret results

[I'll point one of the `arules` package author's
tutorials](http://michael.hahsler.net/research/arules_RUG_2015/demo/)
before writing anything myself, but I will start by saying it's pretty
easy to explore the analysis.

First, let's see what R tells us if we try to directly look at the
object:

    sim_cspade

    ## set of 4816 sequences

Alright, that's helpful information. We have 4816 sequences.

The `inspect` function is really the workhorse that we'll use, here.
`inspect` allows you to subset, which is really useful if you know what
sorts of things you'd like to learn about the data.

Here's a peek at what `inspect` says when we give it the simulated data:

    inspect(sim_cspade[1:10])

    ##     items          support 
    ##   1 <{Bladder,}> 0.8333333 
    ##   2 <{Colon,}>   0.8333333 
    ##   3 <{Foot,}>    1.0000000 
    ##   4 <{Gall}>     0.8333333 
    ##   5 <{Hair,}>    0.3333333 
    ##   6 <{Heart,}>   0.5000000 
    ##   7 <{Kidney,}>  0.8333333 
    ##   8 <{Liver,}>   0.6666667 
    ##   9 <{Lung,}>    1.0000000 
    ##  10 <{Mouth,}>   1.0000000 
    ## 

Well, that's not very interesting. I'll be doing more to explore these
results in the next post. Keep an eye out!

Closing thoughts
----------------

It's not too surprising that getting data to fit the analysis was the
hardest part of this exercise. Still, I am surprised.

These data aren't too interesting. In my next post, I hope to inject a
little bias into the data to see what happens. Maybe something like
making every one of the last sequences "Heart" or "Foot", to see what
the algorithm has to say.

I'll also note that there is a whole lot more to do with the
`arulesSequences` and `arules` packages. There are cool visualizations,
for example.

Until next time, happy hunting!

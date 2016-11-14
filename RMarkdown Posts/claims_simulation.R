# code to simulate claims data
# find more at http://mustafa.fyi/blog/2016/09/29/Transactions_Data

library(arules)
library(arulesViz)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)

set.seed(9001)

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

claims_tx <- split(claims_data$patient, claims_data$disease)

claims_tx$Hypertension <- c(claims_tx$Hypertension, 1:3)

claims_tx$Kidney_disease <- c(claims_tx$Kidney_disease, 1:3)

claims_tx$Heart_disease <- c(claims_tx$Heart_disease, 1:3)

claims_tx <- lapply(claims_tx, function(x) sort(unique(x)))

claims_tx <- as(claims_tx, "tidLists")

claims_rules <- 
  apriori(claims_tx, parameter = list(support = 0.01, confidence = 0.1, maxlen = 2))

claims_rules_measures <- interestMeasure(x = claims_rules, 
                                         measure = c("chiSquared", "FishersExactTest", "oddsRatio"), 
                                         transactions = claims_tx)

claims_rules_measures <- 
  cbind(as(claims_rules, "data.frame"), claims_rules_measures)

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
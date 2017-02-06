
#We'll use the whole set of diagnosis codes for the purposes of testing here

carclaimsa <- feather::read_feather("cache/carclaimsa.feather")

carclaimsa <-
system.time(
carclaimsa[5:25] <-
  lapply(carclaimsa[5:25], function(x) gsub(x = x, pattern = "[A-Z].+", replacement = ""))
)
#times at: 
#  user  system elapsed 
# 3.072   0.016   3.088 

test_str <-
system.time(
carclaimsa <-
   purrr::map_at(carclaimsa,
         5:25,
         ~ stringr::str_extract_all(string = .x, pattern = "[^A-Z].+", simplify = TRUE)[,1]) %>%
  as_data_frame()
)
#times at: 
#   user  system elapsed 
# 18.080   0.084  18.162 

system.time(
carclaimsa <-
  purrr::map_at(carclaimsa,
        5:25,
        ~ gsub(x = .x, pattern = "[A-Z].+", replacement = "")) %>%
 as_data_frame()
)
#times at
#  user  system elapsed 
# 3.092   0.016   3.109 

carclaimsa[5:25] <- 
  lapply(carclaimsa[5:25], function(x) gsub(x = x, pattern = "[A-Z].+", replacement = ""))

# note that this introduces a blank in place of the character codes. These observations will 
# be removed upon coercion to numeric types. 

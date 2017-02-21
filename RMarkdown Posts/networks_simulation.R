library(network)



nw_random <-  function(ncol, nrow) { 
    network(x = matrix(rbinom(100, 100, 0.3), ncol = ncol, nrow = nrow), directed = TRUE)

    }

library(ggnetwork)

nwp <- function(nw) {

  ggplot(ggnetwork(nw, layout = "fruchtermanreingold", cell.jitter = 0),
         aes(x = x, y = y, xend = xend, yend = yend)) + 
    geom_edges()
  
}

library(purrr)



library(gridExtra)





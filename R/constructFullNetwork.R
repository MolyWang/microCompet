#' Build a full sugar degradation network for one genome.
#'
#' Given a list of sugar degradation enzymes, construct a metabolism network
#' of these enzymes and create a network plot.
#' One vertex represents one compound. Size of the vertex suggests its importance,
#' the larger the vertex, the more pathways this compound is involved in.
#' One edge represents one enzymatic reaction that convert the tail vertex (a
#' compound) to the head vertex (another compound). The thicker the edge, the more
#' enzymes can catalyze this reaction.
#' Color of the edge represents the sugar degradation pathway this enzyme involved in.
#'
#' @param gene_lst A list of gene names that represent sugar degradation enzymes.
#'
#' @example
#' \dontrun{
#'  gene_lst = c("tpiA", "glpX", "gpmM", "xylA", "xylB", "treF", "malP", "rpe", "pgk",
#'  "fbaA", "rpiA", "fucU", "fucK", "fucI")
#'  constructFullNetwork(gene_lst)
#' }
#'
#'@export
#'@import igraph
#'
constructFullNetwork <- function(gene_lst) {
  data("EnzymaticReactions")
  require(igraph)

  # build all required dataframes to initialize the network
  relevant_reactions <- EnzymaticReactions[is.element(EnzymaticReactions$Gene, gene_lst), ]
  edge_frame <- createEdgeFrame(relevant_reactions)
  node_frame <- createNodeFrame(edge_frame)

  network <- graph_from_data_frame(d = edge_frame,
                                   vertices = node_frame,
                                   directed = TRUE)

  # prepare colors for different sugar degradation pathways
  sugars <- sort((E(network)$sugar))
  colors_ <- factor(sugars)

  # the smallest node is size 5,
  # and the largest is size 25
  node_count_dif <- max(V(network)$weight) - min(V(network)$weight)
  node_size_fold <- 20 / node_count_dif

  coords <- layout_with_dh(network)

  plot(network,
       vertex.size = V(network)$weight * node_size_fold + 5,
       vertex.label.dist = 1,
       vertex.label.cex = 0.8,
       vertex.frame.color = "grey80",
       vertex.color = "grey80",
       edge.width = E(network)$num_of_enzymes * 1.5,
       edge.arrow.size = .5,
       edge.color = colors_,
       layout = coords)

  legend("topleft",
         unique(sugars),
         pch = 21,
         pt.bg = colors_,
         cex = 0.8)
}



#' Create a dataframe to be used as edges for FullNet
#'
#' Given a list of enzymatic reactions (a subset of the EnzymaticReactions dataset),
#' extract unique reactions, count genes encoding enzymes for each reaction, and
#' keep the "sugar" column for coloring purpose.
#' This function is only called as a helper for constructFullNetwork.
#'
#' @param relevant_reactions A list of enzymatic_reactions, containing only enzymes
#' encoded by genes from gene_lst (input of constructFullNetwork).
#'
#' @return A dataframe with 4 columns
#' @format
#'  \describe{
#'   \item{substrate}{substrate of this reaction, tail of the edge}
#'   \item{product}{product of the reaction, head of the edge}
#'   \item{num_of_enzymes}{numbef of genes encoding enzymes that can catalyze this reaction}
#'   \item{sugar}{the sugar degradation pathway this enzyme participates in.}
#'  }
#'
#' @example
#' \dontrun{
#'  data("EnzymaticReactions")
#'  relevant_reactions <- EnzymaticReactions[EnzymaticReactions$Sugar == "ribose", ]
#'  edge_frame <- createEdgeFrame(relevant_reactions)
#' }
#'
#'
createEdgeFrame <- function(relevant_reactions) {
  relevant_frame <- data.frame(relevant_reactions$Substrate,
                               relevant_reactions$Product,
                               relevant_reactions$Sugar)
  colnames(relevant_frame) <- c("Substrate", "Product", "Sugar")
  unique_reactions <- unique(relevant_frame)

  # initialize all cols of the final dataframe
  unique_reaction_counts <- length(unique_reactions)
  edge_substrates <- unique_reactions$Substrate
  edge_products <- unique_reactions$Product
  edge_weights <- vector(mode = "integer", unique_reaction_counts)
  edge_sugar <- vector(mode = "character", unique_reaction_counts)

  # count edge weight as adding them into empty edge columns
  for (i in 1:length(edge_substrates)) {
    same_substrate <- relevant_reactions[relevant_reactions$Substrate == edge_substrates[i],]
    same_product <- same_substrate[same_substrate$Product == edge_products[i], ]
    edge_weights[i] <- nrow(same_product)
    edge_sugar[i] <- same_product$Sugar[1]

  }

  edge_frame <- data.frame(edge_substrates,
                           edge_products,
                           edge_weights,
                           edge_sugar)
  colnames(edge_frame) <- c("substrate", "product", "num_of_enzymes", "sugar")
  return(edge_frame)
}


#' Create a dataframe to be used as edges for FullNet
#'
#' Given a list of enzymatic reactions (a subset of the EnzymaticReactions dataset),
#' extract unique reactions, count genes encoding enzymes for each reaction, and
#' keep the "sugar" column for coloring purpose.
#' This function is only called as a helper for constructFullNetwork.
#'
#' @param relevant_reactions A list of enzymatic_reactions, containing only enzymes
#' encoded by genes from gene_lst (input of constructFullNetwork).
#'
#' @return A dataframe with 2 columns
#' @format
#'  \describe{
#'   \item{compound}{the compound this vertex represents.}
#'   \item{weight}{number of edges this vertex involves in}
#'  }
#'
#' @example
#' \dontrun{
#'  data("EnzymaticReactions")
#'  relevant_reactions <- EnzymaticReactions[EnzymaticReactions$Sugar == "ribose", ]
#'  edge_frame <- createEdgeFrame(relevant_reactions)
#'  node_frame <- createNodeFrame(edge_frame)
#' }
createNodeFrame <- function(edge_frame) {
  all_compounds <- c(edge_frame$substrate, edge_frame$product)
  node_frame <- as.data.frame(table(all_compounds))
  colnames(node_frame) <- c("compound", "weight")

  return(node_frame)
}

#[END]

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
#' @param genome_name The name of microbe to be graphed.
#' @param gene_lst A list of gene names that represent sugar degradation enzymes.
#'
#' @param ER A list of enzymatic_reactions, containing only enzymes
#'    encoded by genes from gene_lst.
#' @format A dataframe with four required columns, can have other columns.
#'  \describe{
#'   \item{Gene}{Genes encoding the enzyme}
#'   \item{Substrate}{Substrate of the enzyatic reaction.}
#'   \item{Product}{Product of the reaction.}
#'   \item{Sugar}{Sugar degradation pathway this enzyme participates in.}
#'  }
#'
#' @example
#' \dontrun{
#'  require("microCompet")
#'  ER <- microCompet::EnymaticReactions
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_gene_lst <- ED$Gene
#'  genome_file_path = "./Klebsiella_variicola.gb"
#'  carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
#'  full_pathway <- constructFullNetwork("Kvari", carbo_genes, ER)
#'  full_pathway
#' }
#'
#'@export
#'@import igraph
#'@import ggraph
#'@import network
#'@import sna
#'@import ggplot2
#'
constructFullNetwork <- function(genome_name, gene_lst, ER) {
  require(ggraph)
  require(network)
  require(sna)
  require(ggplot2)
  require(igraph)

  # build all required dataframes to initialize the network
  relevant_reactions <- ER[is.element(ER$Gene, gene_lst), ]
  edge_frame <- createEdgeFrame(relevant_reactions)
  node_frame <- createNodeFrame(edge_frame)

  net <- igraph::graph_from_data_frame(d = edge_frame,
                                           vertices = node_frame,
                                           directed = TRUE)

  # to change aes label in ggraph
  Relative_Reaction_Count <- node_frame$weight
  Relative_Enzyme_Count <- edge_frame$num_of_enzymes
  Sugar_Pathway <- edge_frame$sugar

  full_network <-
    ggraph(net,layout = "fr") +
    geom_edge_link(arrow = arrow(length = unit(3, 'mm')),
                   end_cap = circle(2, 'mm'),
                   aes(color = Sugar_Pathway,
                       width = Relative_Enzyme_Count)) +
    geom_node_point(aes(size = Relative_Reaction_Count)) +
    scale_size(range = c(1, 5)) +
    theme_void() +
    scale_edge_width(range = c(1, 2)) +
    geom_node_text(label = node_frame$compound, size = 4, color = "gray30", repel = TRUE) +
    #geom_edge_fan(color = E(network)$sugar) +
    ggtitle(paste("Full Sugar Degradation Pathway for", genome_name)) +
    theme(plot.title = element_text(hjust = 0.5, lineheight = 1.5))

  return(full_network)
}




#' Create a dataframe to be used as edges for FullNetwork
#'
#' Given a list of enzymatic reactions, extract unique reactions, count genes encoding
#' enzymes for each reaction.
#' This function is only called as a helper for constructFullNetwork.
#'
#' @param relevant_reactions A list of enzymatic_reactions, containing only enzymes
#'     encoded by genes from gene_lst.
#' @format A dataframe with four required columns, can have other columns.
#'  \describe{
#'   \item{Gene}{Genes encoding the enzyme, though not directly accessed, it's counted}
#'   \item{Substrate}{Substrate of the enzyatic reaction.}
#'   \item{Product}{Product of the reaction.}
#'   \item{Sugar}{Sugar degradation pathway this enzyme participates in.}
#'  }
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
#'  library("microCompet")
#'  ER <- microCompet::EnzymaticReactions
#'  relevant_reactions <- ER[ER$Sugar == "ribose", ]
#'  edge_frame <- createEdgeFrame(relevant_reactions)
#'  edge_frame
#' }
#'
#' @import dplyr
#'
createEdgeFrame <- function(relevant_reactions) {
  require(dplyr)
  relevant_frame <- dplyr::select(relevant_reactions, Substrate, Product, Sugar)

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
    # unique genes counted through nrow here
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


#' Create a dataframe to be used as vertices for FullNetwork.
#'
#' Given an edge frame (have columns "substrate" and "product), count total
#' unique compounds involved in all reactions, and their weight (how many
#' reactions this compound is involved in.)
#' This function is only called as a helper for constructFullNetwork.
#'
#' @param edge_frame A data frame created by createEdgeFrame, must have
#'     "substrate", "product" columns, case sensitive.
#'
#' @return A dataframe with 2 columns.
#' @format
#'  \describe{
#'   \item{compound}{the compound this vertex represents.}
#'   \item{weight}{number of edges this vertex involves in}
#'  }
#'
#' @example
#' \dontrun{
#'  ER <- microCompet::EnzymaticReactions
#'  relevant_reactions <- ER[ER$Sugar == "ribose", ]
#'  edge_frame <- createEdgeFrame(relevant_reactions)
#'  node_frame <- createNodeFrame(edge_frame)
#'  node_frame
#' }
createNodeFrame <- function(edge_frame) {
  all_compounds <- c(edge_frame$substrate,
                     edge_frame$product)
  node_frame <- as.data.frame(table(all_compounds))
  colnames(node_frame) <- c("compound", "weight")

  return(node_frame)
}

#[END]

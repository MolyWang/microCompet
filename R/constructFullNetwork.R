#' Build A Full Simple Sugar Degradation Network For One Genome
#'
#' Given a name of a microbe, a vector of gene names for sugar degradation enzymes,
#' and a data.frame containing all enzymatic reactions of interest, this function
#' constructs a network plot that represents all sugar degradation steps the given
#' microbe/genome can perform.
#'
#' In the output plot, one vertex represents one compound, and its size suggests the
#' number of sugar degradation pathways it involves in. You can interpret vertex size
#' as the importance of a compound within this network.
#'
#' Similarly, one edge represents one enzymatic reaction that convert the tail vertex (a
#' reaction substrate) to the head vertex (a reaction product). Thickness of one edge
#' represents number of genes that encoding enzymes capable of catalyzing this reaction,
#' and represents the robustness of this step.
#'
#' Color of the edge represents the sugar degradation pathway this step involved in.
#'
#' @param genomeName Name of the microbe to be plotted.
#' @param geneVec A vector containing gene names of all sugar degradation enzymes present
#'    in the given microbial genome (\code{genomeName}).
#' @param ER A data.frame containing all enzymatic reactions of interest, and should represent
#'     enzymatic reactions with at least four characteristics: Gene, Substrate, Product, Sugar.
#'     Header should be EXACTLY the same. (See the sample dataset EnzymaticReactions for example
#'     by \code{?EnzymaticReactions}). Rows containing NA will be removed.
#'
#' @return A network graph representing the full simple sugar degradation pathway of the
#'     genome given as geneVec.
#'
#' @examples
#' \dontrun{
#'  require("microCompet")
#'  ER <- microCompet::EnzymaticReactions
#'  ED <- microCompet::EnzymeDistribution
#'  fullEnzymeGeneVec <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Lactobacillus_johnsonii.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
#'  fullNetwork <- constructFullNetwork("Lactobacillus_johnsonii", carboGenes, ER)
#'  fullNetwork
#' }
#'
#'@export
#'
#'@importFrom igraph graph_from_data_frame
#'@import ggraph
#'@import network
#'@import sna
#'@import ggplot2
#'@importFrom stats complete.cases
#'
constructFullNetwork <- function(genomeName, geneVec, ER) {
  # ============ Check ER ============
  # check the given dataset ER have all required columns with expected names
  expectedColNames <- c("Gene", "Substrate", "Product", "Sugar")
  if (!all(expectedColNames %in% colnames(ER))) {
    stop("The provided dataset ER lacks required columns (Gene, Substrate, Product, Sugar), double check before continuing.")
  }

  # check the dataset ER and drop rows with NA.
  originalRowNum <- nrow(ER)
  ER <- ER[stats::complete.cases(ER), ]
  completeRowNum <- nrow(ER)
  sprintf("Running constructFullNetwork now, %d rows out of %d in the given ER dataset contain NA and are removed.",
          originalRowNum - completeRowNum,
          originalRowNum)

  # ============ start construction ============
  # build all required data.frames to initialize the network
  relevantReactions <- ER[is.element(ER$Gene, geneVec), ]
  #createEdgeFrame and createNodeFrame are helpers defined later in this file.
  edgeFrame <- createEdgeFrame(relevantReactions)
  nodeFrame <- createNodeFrame(edgeFrame)

  # create the backbone of the network
  net <- igraph::graph_from_data_frame(d = edgeFrame,
                                       vertices = nodeFrame,
                                       directed = TRUE)

  # to change aes legends in the output graph
  Relative.Reaction.Count <- nodeFrame$Weight
  Relative.Enzyme.Count <- edgeFrame$NumOfEnzymes
  Sugar.Pathway <- edgeFrame$Sugar

  # ============ Visualization ============
  fullNetwork <-
    ggraph::ggraph(net,layout = "fr") +
    ggraph::geom_edge_link(arrow = arrow(length = unit(3, 'mm')),
                           end_cap = circle(2, 'mm'),
                           aes(color = Sugar.Pathway,
                               width = Relative.Enzyme.Count)) +
    ggraph::geom_node_point(aes(size = Relative.Reaction.Count)) +
    ggplot2::scale_size(range = c(2, 5)) +
    ggplot2::theme_void() +
    ggraph::scale_edge_width(range = c(0.5, 1)) +
    ggraph::geom_node_text(label = nodeFrame$Compound,
                           size = 5,
                           color = "gray30",
                           repel = TRUE) +
    ggplot2::ggtitle(paste("Full Pathway Network of", genomeName)) +
    ggplot2::theme(plot.title = element_text(hjust = 0.5,
                                             lineheight = 1.5))

  return(fullNetwork)
}



#' Create A Data.frame To Represent All Edges in fullNetwork
#'
#' Given a list of enzymatic reactions, extract unique reactions, count number of genes encoding
#' enzymes that catalyze each reaction.
#' This is a helper function defined for constructFullNetwork and is called only internally.
#'
#' @param relevantReactions A data.frame of enzymatic reactions, containing the required columns:
#'     Gene, Substrate, Product, Sugar (case sensitive).
#'
#' @return A data.frame with 4 columns. Substrate and Product are tail and head of each edge;
#'     NumOfEnzymes is count of enzymes that can catalyze the reaction; Sugar is the simple sugar
#'     degradation pathway this reaction is one step of.
#'
#' @examples
#' \dontrun{
#'  library("microCompet")
#'  ER <- microCompet::EnzymaticReactions
#'  relevantReactions <- ER[ER$Sugar == "ribose", ]
#'  edgeFrame <- createEdgeFrame(relevantReactions)
#'  edgeFrame
#' }
#'
#' @importFrom dplyr select
#'
createEdgeFrame <- function(relevantReactions) {
  relevantFrame <- dplyr::select(relevantReactions, "Substrate", "Product", "Sugar")
  uniqueReactions <- unique(relevantFrame)

  # initialize all cols of the output data.frame
  uniqueReactionCounts <- length(uniqueReactions)
  edgeSubstrates <- uniqueReactions$Substrate
  edgeProducts <- uniqueReactions$Product
  edgeWeights <- vector(mode = "integer", uniqueReactionCounts)
  edgeSugar <- vector(mode = "character", uniqueReactionCounts)

  # count edge weight as adding them into empty edge columns
  for (i in 1:length(edgeSubstrates)) {
    sameSubstrate <- relevantReactions[relevantReactions$Substrate == edgeSubstrates[i],]
    sameProduct <- sameSubstrate[sameSubstrate$Product == edgeProducts[i], ]
    # unique genes counted through nrow here
    edgeWeights[i] <- nrow(sameProduct)
    edgeSugar[i] <- sameProduct$Sugar[1]
  }

  edgeFrame <- data.frame(edgeSubstrates,
                          edgeProducts,
                          edgeWeights,
                          edgeSugar)

  colnames(edgeFrame) <- c("Substrate", "Product", "NumOfEnzymes", "Sugar")
  return(edgeFrame)
}



#' Create A Data.frame To Represent All Vertices in fullNetwork.
#'
#' Given an edge frame (have columns "Substrate" and "Product), count total
#' unique compounds involved in all reactions, and their weight (how many
#' reactions this compound is involved in.)
#' This is a helper function defined for constructFullNetwork and is called only internally.
#'
#' @param edgeFrame A data frame created by createEdgeFrame, must have
#'     "Substrate" and "Product" columns, case sensitive.
#'
#' @examples
#' \dontrun{
#'  ER <- microCompet::EnzymaticReactions
#'  relevantReactions <- ER[ER$Sugar == "ribose", ]
#'  edgeFrame <- createEdgeFrame(relevantReactions)
#'  nodeFrame <- createNodeFrame(edgeFrame)
#'  nodeFrame
#' }
#'
createNodeFrame <- function(edgeFrame) {
  allCompounds <- c(edgeFrame$Substrate,
                     edgeFrame$Product)
  nodeFrame <- as.data.frame(table(allCompounds))
  colnames(nodeFrame) <- c("Compound", "Weight")

  return(nodeFrame)
}


#[END]

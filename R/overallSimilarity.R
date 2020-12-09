#' Compare Overall Similarity Of A Genome And Microbiota Members
#'
#' Based on the presence of simple sugar degradation enzymes, this function compares
#' the overall similarity of one genome with other genome profiles provided as a
#' data.frame.
#'
#' @param genomeName Name of the genome represented by geneVec
#' @param geneVec A vector gene names represented by 3-5 characters, such as "rpiB",
#'     containing all present simple sugar degradation enzymes in the microbe with
#'     genomeName.
#' @param ED An enzyme distribution data.frame that represents sugar degradation enzyme
#'     profiles in genomes that genomeName microbe is to be compared with. This data.frame
#'     contains a column "Gene" (case sensitive), and at least one genome profile
#'     from column index firstMicrobe to column index lastMicrobe CONTINUOUSLY. Genome
#'     profiles use 1 to indicate the presence of a gene, and 0 for absence. T/TRUE and
#'     F/FALSE can be coerced into 1 and 0, but not recommended.
#'     See \code{?EnzymeDistribution} for example.
#' @param firstMicrobe A positive integer. Index of the first column in ED data.frame that
#'     represents a microbial genome. Count starts from 1. That is if ED contains microbial
#'     genome profiles from column 4-9, firstMicrobe is 4.
#' @param lastMicrobe A positive integer. Index of the last column in ED data.frame that
#'     represents a microbial genome. Count starts from 1. That is if ED contains microbial
#'     genome profiles from column 4-9, firstMicrobe is 9. Default of lastMicrobe is
#'     the last column of data.frame ED.
#'
#' @return A radar chart with microbial species on corners and the user input genome
#'     in the middle. The genome of interest (genomeName) receives a score when compred
#'     with each genome in the data.frame ED, and is formatted as [number of shared genes]
#'     out of [total number of genes of interest].
#'
#' @examples
#' \dontrun{
#'  require("microCompet")
#'  genomeName <- "L. johnsonii"
#'  ED <- microCompet::EnzymeDistribution
#'  fullEnzymeGeneVec <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Lactobacillus_johnsonii.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
#'  overSimi <- overallSimilarity(genomeName, carboGenes, ED, 5, 13)
#'  overSimi
#' }
#'
#' @export
#'
#' @importFrom radarchart chartJSRadar
#'
overallSimilarity <- function(genomeName, geneVec, ED,
                              firstMicrobe, lastMicrobe = ncol(ED)) {

  # ============ Check ED and column indices ============
  reportVec <- checkUserED(ED, firstMicrobe, lastMicrobe)

  # update lastMicrobe if necessary
  if (reportVec["lastMicrobeTooLarge"]) {
    lastMicrobe <- ncol(ED)
  }

  # update unexpected values in ED to 0 if necessary
  if (reportVec["UnexpectedValuesInED"]) {
    relevantSection <- ED[firstMicrobe:lastMicrobe]
    unexpectedValues <- (relevantSection != 0) & (relevantSection != 1)
    relevantSection[unexpectedValues] <- 0
    ED[firstMicrobe:lastMicrobe] <- relevantSection
  }


  # ============ start construction ============
  # transformToVector is a helper defined later in this file
  uniqueGenes <- unique(ED$Gene)
  genomeVec <- transformToVector(geneVec, uniqueGenes)
  availableMicrobes <- colnames(ED)[firstMicrobe:lastMicrobe]

  # initialize the vector for the output radarchart
  overSimiScores <- vector(mode = "integer",
                           length = length(availableMicrobes))
  names(overSimiScores) <- availableMicrobes

  # fill the vector with scores
  for (microbeName in availableMicrobes) {
    oneMicrobe <- ED[microbeName]
    oneMicrobe <- unlist(oneMicrobe)
    names(oneMicrobe) <- uniqueGenes
    # compareTwoGenomes is a helper defined later in this file
    overSimiScores[microbeName] <- compareTwoGenomes(genomeVec,
                                                     oneMicrobe,
                                                     length(uniqueGenes))
  }

  # transform the score vector into a dataframe for RadarGraph
  overSimiScoresDF <- as.data.frame(overSimiScores)
  colnames(overSimiScoresDF) <- c(genomeName)


  # ============ Visualization ============
  overSimiChart <- radarchart::chartJSRadar(scores = overSimiScoresDF,
                                            labs = availableMicrobes,
                                            maxScale = length(genomeVec))
  return(overSimiChart)
}



#' Compare Two Genomes And Count Number Of Shared Genes
#'
#' Given two genomes represented by vectors of 0 and 1 (genes in the same order),
#' count total number of genes with shared status. This includes genes that are
#' present in both or neither of the two genomes.
#' This is a helper only called internally by overallSimilarity.
#'
#' @param genome1 A vector of 0 and 1, and each element is named by the gene whose
#'     status it represents. 0 for absence, and 1 for presence.
#' @param genome2 Same as genome1, but represents another genome
#' @param totalGeneCount Total number of genes of interest to be compared.
#'
#' @return An integer indicating number of genes shared by genome1 and genome2.
#'
#' @examples
#' \dontrun{
#'  ED <- microCompet::EnzymeDistribution
#'  allGenes <-ED$Gene
#'  geneVec1 <- ED$Gene[4:25]
#'  genome1 <- transformToVector(geneVec1, allGenes)
#'  geneVec2 <- ED$Gene[10:35]
#'  genome2 <- transformToVector(geneVec2, allGenes)
#'  totalGeneCount <- length(allGenes)
#'  score <- compareTwoGenomes(genome1, genome2, totalGeneCount)
#'  score
#' }
#'
compareTwoGenomes <- function(genome1, genome2, totalGeneCount) {
  # This function first applies xor on two vectors (Only 0 + 1 = 1)
  # and counts all genes that are not shared by two genomes
  notShared <- (genome1 + genome2) == 1
  notSharedCount <- sum(as.integer(notShared))

  # then not "not shared" are shared
  return(totalGeneCount - notSharedCount)
}



#' Transform A Vector Of Gene Names Into A Vector Of 0 And 1
#'
#' Given a vector of genes that represents a genome, transform it into a simple sugar
#' degradation enzyme profile as a vector of 0 and 1. A 0 indicates the gene represented
#' by element name is absent in the genome, and a 1 indicates its presence.
#'
#' @param geneVec A vector of gene names, represented by 3-5 characters, such as "eno",
#'     this vector includes all simple sugar degradation enzymes present in a microbial
#'     genome of interest.
#' @param allGenes A vector containing all (unique) sugar degradation genes of interest.
#'
#' @return A named vector of 0 and 1, indicating whether each sugar degradation enzyme,
#'     represented by the element's name, is presetn in the geneVec.
#'
#' @examples
#' \dontrun{
#'  ED <- microCompet::EnzymeDistribution
#'  allGenes <- ED$Gene
#'  geneVec <- ED$Gene[4:25]
#'  genomeVec <- transformToVector(geneVec, allGenes)
#'  genomeVec
#' }
#'
transformToVector <- function(geneVec, allGenes) {
  genomeVec <- vector(mode = "logical",
                      length = length(allGenes))
  names(genomeVec) <- allGenes

  for (gene in allGenes) {
    genomeVec[gene] <- is.element(gene, geneVec)
  }
  # convert T and F to 1 and 0.
  return(as.integer(genomeVec))
}


#[END]

#' Visualize A Microbe's Competition For Simple Sugars With Other Microbiota Members
#'
#' This fuction visualizes the competition of one microbe of interest (specified by
#' genomeName and geneVec) with other microbiota members (in ED data.frame) based on
#' the simple sugar degradation pathways, considering their pathway existence and
#' completeness.
#'
#' The output result is a radar chart, and the score one microbe achieves for one
#' sugar degradation pathway is calculated as (number of steps can be catalyzed) over
#' (total steps required to fully degrade one simple sugar).
#'
#' @param genomeName Steing represents the name of a genome/microbe.
#' @param geneVec A list of sugar degradation gene names in microbe genomeName
#' @param ER A data.frame that describing enzymatic reactions with at least 3 factors,
#'     "Gene" for gene name encoding an enzyme, "Reaction.EC" for categorization of one
#'     enzymatic reaction, and "Sugar" for the degradation pathway this enzyme involves
#'     in. Column names are case sensitive, see \code{?EnzymaticReactions} for example.
#' @param ED An enzyme distribution data.frame that represents sugar degradation enzyme
#'     profiles in genomes that genomeName microbe is to be compared with. This data.frame
#'     contains a column "Gene" (case sensitive), and at least one genome profile
#'     from column index firstMicrobe to column index lastMicrobe CONTINUOUSLY. Genome
#'     profiles use 1 to indicate the presence of a gene, and 0 for absence. T/TRUE and
#'     F/FALSE can be coerced into 1 and 0, but not recommended.
#'     See \code{?EnzymeDistribution} for example.
#' @param firstMicrobe Column index of first microbe genome in dataset ED
#' @param lastMicrobe Column index of last microbe genome in dataset ED. Default set
#'   to the last column of ED.
#'
#' @examples
#'  \dontrun{
#'  library("microCompet")
#'  genomeName <- "L. johnsonii"
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_geneVec <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Lactobacillus johnsonii.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
#'  firstMicrobe <- 5
#'  lastMicrobe <- 13
#'  ER <- microCompet::EnzymaticReactions
#'  compMicrob <- competeMicrobiota(genomeName, carbo_genes, ER,
#'                                          ED, firstMicrobe, lastMicrobe)
#'  compMicrob
#'  }
#'
#' @export
#' @importFrom radarchart chartJSRadar
#'
competeMicrobiota <- function(genomeName, geneVec, ER,
                              ED, firstMicrobe, lastMicrobe = ncol(ED)) {
  require(radarchart)
  available_microbes <- colnames(ED)[firstMicrobe:lastMicrobe]
  # do not want to mask available genomes by the new input genome.
  if (is.element(genomeName, available_microbes)) {
    stop(sprintf("Already have %s in available datasets, please rename your genome.",
                 genomeName))
  }

  allSugars <- sort(unique(ER$Sugar))
  pathCompScores <- pathCompleteness(genomeName, geneVec, allSugars, ER,
                                     ED, firstMicrobe, lastMicrobe)
  competitions <- radarchart::chartJSRadar(scores = pathCompScores[, 2:ncol(pathCompScores)],
                                           labs = allSugars,
                                           maxScale = 1)
  return(competitions)
}



#' Evaluate completeness of sugar degradation paths
#'
#' Evalute path completeness of all sugar degradation pathways listed in allSugars
#'
#' @param genomeName Name of the species of interest
#'
#' @param geneVec A list of gene name that represent the species
#'
#' @param allSugars Name of all sugar pathways relevant
#'
#' @param ER A dataset with at least 3 columns. Gene name for an enzyme, Reaction.EC for
#'   one catalytic reaction, and Sugar for degradation pathway. Column names are case
#'   sensitive.
#'
#' @param ED A dataset with at least Gene, Reaction.EC, and columns for genome
#'   sugar pathways data from different genomes. See EnzymeDistribution for example.
#'
#' @param firstMicrobe Column index of first microbe genome in dataset ED
#'
#' @param lastMicrobe Column index of last microbe genome in dataset ED. Default set
#'   to the last column of ED.
#'
#'
pathCompleteness <- function(genomeName, geneVec, allSugars, ER,
                             ED, firstMicrobe, lastMicrobe) {

  totalSteps <- calculateTotalStepsForAllSugars(allSugars, ER)

  path_pct <- data.frame("Sugar" = allSugars)
  path_counts <- allSugarScoresForOneGenome(geneVec, allSugars, ER)
  path_pct[genomeName] <- round(path_counts/totalSteps, digits = 2)

  genomeNames <- colnames(ED)

  for (i in firstMicrobe:lastMicrobe) {
    genomeName <- genomeNames[i]
    microbe <- ED[i]
    geneVec <- unique(ER$Gene[microbe == 1])
    path_counts <- allSugarScoresForOneGenome(geneVec, allSugars, ER)
    path_pct[genomeName] <- round(path_counts/totalSteps, digits = 2)
  }

  return(path_pct)
}


#' Calculate pathway completeness for all pathways within a genome.
#'
#' Use the calculateStepsForOneSugar function for all sugar pathways one by one,
#' and build a named vector for all pathways
#'
#' @param geneVec Gene list represents on genome
#' @param allSugars A list representing all sugar degradation pathways.
#' @param ER A dataset with at least 3 columns. Gene name for an enzyme, Reaction.EC for
#'   one catalytic reaction, and Sugar for degradation pathway. Same requirement for
#'   the next calculateStepsForOneSugar function, since it's only for passing to the helper.
#'
#' @return A vector containing a genome's score for all sugar degradatin pathways.
#'
#' @examples
#' \dontrun{
#'  geneVec <- c("rpe", "rpiB", "eno", "fucK")
#'  ER <- microCompet::EnzymaticReactions
#'  ED <- microCompet::EnzymeDistribution
#'  allSugars <- sort(unique(ED$Sugar))
#'  ECCounts <- allSugarScoresForOneGenome(geneVec, allSugars, ER)
#'  ECCounts
#' }
#'
allSugarScoresForOneGenome <- function(geneVec, allSugars, ER) {
  score_vec <- vector(mode = "integer", length = length(allSugars))
  names(score_vec) <- allSugars
  for (sugar in allSugars) {
    score_vec[sugar] <- calculateStepsForOneSugar(geneVec, sugar, ER)
  }
  return(score_vec)
}


#' Calculate Number Of Sugar Specific Degradation Enzymes In A Vector
#'
#' Given a vector of gene names that contain all sugar degradation enzymes from
#' a genome of interest, count of number of different enzymes encoded by these genes
#' that involve in the degradation of the specified sugar. Enzymes with same catalytic
#' function (Reaction.EC) but encoded by different genes are counted once.
#'
#' @param geneVec A vector of gene encoding sugar degradation enzymes.
#' @param sugar The desired sugar degradation pathway. A simple sugar such as "fructose".
#' @param ER A data.frame describing enzymatic reactions with at least 3 columns: "Gene"
#'     for gene encoding an enzyme, "Reaction.EC" for categorization of catalytic reactions,
#'     and "Sugar" for degradation pathway. Column names need to be EXACTLY the same,
#'     case sensitive.
#'
#' @return ECCount An integer. Number of different sugar specific enzymes present in the geneVec.
#'
#' @examples
#' \dontrun{
#'  geneVec <- c("rpe", "rpiB", "eno", "fruK")
#'  ER <- EnzymaticReactions
#'  ECCount <- calculateStepsForOneSugar(geneVec, "fructose", ER)
#'  ECCount
#' }
#'
calculateStepsForOneSugar <- function(geneVec, sugar, ER) {
  # look for genes in geneVec encoding enzymes that degrade the specified sugar
  presentEC <- ER[is.element(ER$Gene, geneVec) & ER$Sugar == sugar,
                  Reaction.EC]
  ECCount <- length(unique(presentEC))

  return(ECCount)
}



#' Calculate Total Steps In The Degradation Pathway Of All Sugars
#'
#' For each sugar degradation pathway, count total number of enzymatic steps required.
#' Total counts are calculated based on number of enzymes with different EC number, not
#' genes with different names.
#'
#' @param allSugars A vector of all sugar whose degradation steps are to be calculated.
#' @param ER A data.frame with at least two required columns with specified names.
#'     Sugar (sugar pathway), Reaction.EC (enzymatic reaction type)
#'
#' @return A vector summarizing enzymatic steps in each sugar degradation pathway. Counts
#'     as elements and sugar pathway as names.
#'
#' @examples
#' \dontrun{
#'  library("microCompet")
#'  ER <- microCompet::EnzymaticReactions
#'  allSugars <- ER$Sugar
#'  totalSteps <- calculateTotalStepsForAllSugars(allSugars, ER)
#'  totalSteps
#' }
#'
calculateTotalStepsForAllSugars <- function(allSugars, ER) {
  # initialize totalSteps vector
  totalSteps <- vector(mode = "integer", length = length(allSugars))
  names(totalSteps) <- allSugars

  # fill in values for totalSteps
  for (sugar in allSugars) {
    # count of unique ECs is the targeted steps number
    totalSteps[sugar] <- length(unique(ER[ER$Sugar == sugar, Reaction.EC]))
  }

  return(totalSteps)
}


#[END]

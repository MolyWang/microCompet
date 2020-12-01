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
#'     to the last column of ED.
#'
#' @return A radar chart for comparing completeness of sugar degradation pathways for microbe
#'     of interest and microbiota members.
#'
#' @examples
#'  \dontrun{
#'  library("microCompet")
#'  genomeName <- "L. johnsonii"
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_geneVec <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Lactobacillus_johnsonii.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
#'  firstMicrobe <- 5
#'  lastMicrobe <- 13
#'  ER <- microCompet::EnzymaticReactions
#'  competitions <- competeMicrobiota(genomeName, carboGenes, ER,
#'                                    ED, firstMicrobe, lastMicrobe)
#'  competitions
#'  }
#'
#' @export
#'
#' @importFrom radarchart chartJSRadar
#'
competeMicrobiota <- function(genomeName, geneVec, ER,
                              ED, firstMicrobe, lastMicrobe = ncol(ED)) {
  # ============ Check ============
  # check ER
  if (!all(c("Gene", "Reaction.EC", "Sugar") %in% colnames(ER))) {
    stop("Columns Gene, Reaction.EC, Sugar (case sensitive) are required for ER dataframe.")
  }

  # check genomeName uniqueness
  availableMicrobes <- colnames(ED)[firstMicrobe:lastMicrobe]
  # do not want to mask available genomes by the new input genome.
  if (is.element(genomeName, availableMicrobes)) {
    stop(sprintf("Already have %s in available datasets, please rename your genome.",
                 genomeName))
  }

  # check ED and indices
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
  allSugars <- sort(unique(ER$Sugar))
  totalSteps <- calculateTotalStepsForAllSugars(allSugars, ER)

  #initialize the DF for radar chart
  completenessDF <- data.frame("Sugar" = allSugars)
  # first calculate completeness for the genome of interest
  completenessDF[genomeName] <- completenessForAllPathways(geneVec, allSugars, ER, totalSteps)

  # then for microbes in the data.frame ED
  genomeNames <- colnames(ED)
  for (i in firstMicrobe:lastMicrobe) {
    genomeName <- genomeNames[i]
    microbe <- ED[i]
    geneVec <- unique(ED$Gene[microbe == 1])
    completenessDF[genomeName] <- completenessForAllPathways(geneVec, allSugars, ER, totalSteps)
  }


  # ============ Visualization ============
  competitions <- radarchart::chartJSRadar(scores = completenessDF[, 2:ncol(completenessDF)],
                                           labs = allSugars,
                                           maxScale = 1)
  return(competitions)
}



#' Evaluate The Completeness Of All Sugar Degradation Pathways
#'
#' Given a genome of interest, described by genomeName and a vector of sugar degradation
#' genes, evaluate the completeness of all sugar degradation pathways. The completeness
#' is evaluated by (steps can be catalyzed) over (total steps within a pathway), and this
#' score should always be between 0 and 1 (inclusive).
#'
#' @param geneVec A vector of gene names, representing all sugar degradation enzymes
#'     present in one genome of interest.
#' @param allSugars A vector of all sugar degradation pathways.
#' @param ER A data.frame describing enzymatic reactions with at least 3 columns: "Gene"
#'     for gene encoding an enzyme, "Reaction.EC" for categorization of catalytic reactions,
#'     and "Sugar" for degradation pathway. Column names need to be EXACTLY the same,
#'     case sensitive.
#' @param totalSteps A vector containing counts of total steps for all sugar degradation
#'     pathways. Result of helper function \code{calculateTotalStepsForAllSugars}
#'
#' @return A named vector containing completeness score for all sugar degradation pathways.
#'
completenessForAllPathways <- function(geneVec, allSugars, ER, totalSteps) {
  sugarScoreVec <- allSugarScoresForOneGenome(geneVec, allSugars, ER)

  # convert score to completeness (between 0 and 1)
  completenessScoreVec <- round(sugarScoreVec/totalSteps, digits = 2)
  names(completenessScoreVec) <- allSugars

  return(completenessScoreVec)
}



#' Calculate Completeness Of All Sugar Degradation Pathways Within One Genome
#'
#' Use the calculateStepsForOneSugar function for all sugar pathways one by one,
#' and build a named vector for all pathways.
#'
#' @param geneVec A vector of gene names, representing all sugar degradation enzymes
#'     present in one genome of interest.
#' @param allSugars A vector of all sugar degradation pathways.
#' @param ER A data.frame describing enzymatic reactions with at least 3 columns: "Gene"
#'     for gene encoding an enzyme, "Reaction.EC" for categorization of catalytic reactions,
#'     and "Sugar" for degradation pathway. Column names need to be EXACTLY the same,
#'     case sensitive.
#'
#' @return A vector containing a genome's score for all sugar degradation pathways.
#'
#' @examples
#' \dontrun{
#'  geneVec <- c("rpe", "rpiB", "eno", "fucK")
#'  ER <- microCompet::EnzymaticReactions
#'  ED <- microCompet::EnzymeDistribution
#'  allSugars <- sort(unique(ED$Sugar))
#'  sugarScoreVec <- allSugarScoresForOneGenome(geneVec, allSugars, ER)
#'  sugarScoreVec
#' }
#'
allSugarScoresForOneGenome <- function(geneVec, allSugars, ER) {
  # initialize the score vector
  sugarScoreVec <- vector(mode = "integer", length = length(allSugars))
  names(sugarScoreVec) <- allSugars

  # fill in score for each sugar pathway by calling the helper function.
  for (sugar in allSugars) {
    sugarScoreVec[sugar] <- calculateStepsForOneSugar(geneVec, sugar, ER)
  }
  return(sugarScoreVec)
}



#' Calculate Number Of Sugar Specific Degradation Enzymes In A Vector
#'
#' Given a vector of gene names that contain all sugar degradation enzymes from
#' a genome of interest, count of number of different enzymes encoded by these genes
#' that involve in the degradation of one specified sugar. Enzymes with same catalytic
#' function (Reaction.EC) but encoded by different genes are counted once.
#'
#' @param geneVec A vector of gene encoding sugar degradation enzymes.
#' @param sugar The desired sugar degradation pathway. A simple sugar such as "fructose".
#' @param ER A data.frame describing enzymatic reactions with at least 3 columns: "Gene"
#'     for gene encoding an enzyme, "Reaction.EC" for categorization of catalytic reactions,
#'     and "Sugar" for degradation pathway. Column names need to be EXACTLY the same,
#'     case sensitive.
#'
#' @return An integer. Number of different sugar specific enzymes present in the geneVec.
#'
#' @examples
#' \dontrun{
#'  geneVec <- c("rpe", "rpiB", "eno", "fruK")
#'  ER <- EnzymaticReactions
#'  sugarScore <- calculateStepsForOneSugar(geneVec, "fructose", ER)
#'  sugarScore
#' }
#'
calculateStepsForOneSugar <- function(geneVec, sugar, ER) {
  # look for genes in geneVec encoding enzymes that degrade the specified sugar
  presentEC <- ER[is.element(ER$Gene, geneVec) & ER$Sugar == sugar,
                  "Reaction.EC"]
  sugarScore <- length(unique(presentEC))

  return(sugarScore)
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
    totalSteps[sugar] <- length(unique(ER[ER$Sugar == sugar, "Reaction.EC"]))
  }

  return(totalSteps)
}


#[END]

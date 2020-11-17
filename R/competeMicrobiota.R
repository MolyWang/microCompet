#' Visualize the competition by a radarchart.
#'
#' Visualize the competiion between a given microbe and other 9 available
#' microbiota members in the EnzymeDistribution dataset.
#'
#' @param genome_name Steing represents the name of a genome/microbe.
#' @param gene_lst A list of sugar degradation gene names in microbe genome_name
#'
#' @param ER A dataset with at least 3 columns. Gene name for an enzyme, Reaction.EC for
#'   one catalytic reaction, and Sugar for degradation pathway. Column names are case
#'   sensitive.
#'
#' @param ED A dataset with at least Gene, Reaction.EC, and columns for genome
#'   sugar pathways data from different genomes. See EnzymeDistribution for example.
#' @param first_microbe Column index of first microbe genome in dataset ED
#' @param last_microbe Column index of last microbe genome in dataset ED. Default set
#'   to the last column of ED.
#'
#' @example
#'  \dontrun{
#'  library(microCompet)
#'  genome_name <- "L. johnsonii"
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_gene_lst <- ED$Gene
#'  genome_file_path = "./Klebsiella_variicola.gb"
#'  carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
#'  first_microbe = 5
#'  last_microbe = 13
#'  ER <- microCompet::EnzymaticReactions
#'  compete_microbiota <- competeMicrobiota(genome_name, carbo_genes, ER,
#'                                          ED, first_microbe, last_microbe)
#'  compete_microbiota
#'  }
#'
#' @export
#' @import radarchart
competeMicrobiota <- function(genome_name, gene_lst, ER,
                              ED, first_microbe, last_microbe = ncol(ED)) {
  require(radarchart)
  available_microbes <- colnames(ED)[first_microbe:last_microbe]
  # do not want to mask available genomes by the new input genome.
  if (is.element(genome_name, available_microbes)) {
    stop(sprintf("Already have %s in available datasets, please rename your genome.",
                 genome_name))
  }

  all_sugars <- sort(unique(ER$Sugar))
  pathCompScores <- pathCompleteness(genome_name, gene_lst, all_sugars, ER,
                                     ED, first_microbe, last_microbe)
  competitions <- radarchart::chartJSRadar(scores = pathCompScores[, 2:ncol(pathCompScores)],
                                           labs = all_sugars,
                                           maxScale = 1)
  return(competitions)
}


# cols are microbes
# rows are sugars
# each cell is a score, num of enzymes the microbe have for this pathway
# same as the competeMicrobiota
pathCompleteness <- function(genome_name, gene_lst, all_sugars, ER,
                             ED, first_microbe, last_microbe) {

  total_steps <- calculateTotalSteps(all_sugars, ER)

  path_pct <- data.frame("Sugar" = all_sugars)
  path_counts <- allSugarScoresForOneGenome(gene_lst, all_sugars, ER)
  path_pct[genome_name] <- round(path_counts/total_steps, digits = 2)

  genome_names <- colnames(ED)

  for (i in first_microbe:last_microbe) {
    genome_name <- genome_names[i]
    microbe <- ED[i]
    gene_lst <- unique(ER$Gene[microbe == 1])
    path_counts <- allSugarScoresForOneGenome(gene_lst, all_sugars, ER)
    path_pct[genome_name] <- round(path_counts/total_steps, digits = 2)
  }

  return(path_pct)
}


#' Calculate pathway completeness for all pathways within a genome.
#'
#' use the calculateCount function for all sugar pathways.
#'
#' @param gene_lst Gene list represents on genome
#' @param all_sugars A list representing all sugar degradation pathways.
#' @param ER A dataset with at least 3 columns. Gene name for an enzyme, Reaction.EC for
#'   one catalytic reaction, and Sugar for degradation pathway. Same requirement for
#'   the next calculateCount function, since it's only for passing to the helper.
#'
#' @return A vector containing a genome's score for all sugar degradatin pathways.
#' \dontrun{
#'  gene_lst <- c("rpe", "rpiB", "eno", "fucK")
#'  ER <- microCompet::EnzymaticReactions
#'  ED <- microCompet::EnzymeDistribution
#'  all_sugars <- sort(unique(ED$Sugar))
#'  enzyme_count <- calculateCount(gene_lst, all_sugars, ER)
#'  enzyme_count
#' }
#'
#'
allSugarScoresForOneGenome <- function(gene_lst, all_sugars, ER) {
  score_vec <- vector(mode = "integer", length = length(all_sugars))
  names(score_vec) <- all_sugars
  for (sugar in all_sugars) {
    score_vec[sugar] <- calculateCount(gene_lst, sugar, ER)
  }
  return(score_vec)
}


#' Calculate number of sugar-degradation specific enzymes in gene_lst.
#'
#' Given a gene_lst, probably represent all sugar-degradatinon enzymes from a genome,
#' extract enzymes encoded by these genes that involve in the specific degradation
#' pathway of the given sugar. Enzymes with same catalytic function but encoded by
#' different genes are treated as the same.
#'
#' @param gene_lst A list of gene names represented by 3-5 letters, such as "tktA".
#'
#' @param sugar The desired sugar degradation pathway. A simple sugar such as "fructose".
#'
#' @param ER A dataset with at least 3 columns. Gene name for an enzyme, Reaction.EC for
#'   one catalytic reaction, and Sugar for degradation pathway.
#'
#' @return enzyme_count Number of sugar_specific enzymes inside the gene_lst.
#'
#' @example
#' \dontrun{
#'  gene_lst <- c("rpe", "rpiB", "eno", "fruK")
#'  ER <- EnzymaticReactions
#'  enzyme_count <- calculateCount(gene_lst, "fructose", ER)
#'  enzyme_count
#' }
#'
calculateCount <- function(gene_lst, sugar, ER) {
  # data("EnzymaticReactions")
  enzymes_carried_df <- ER[is.element(ER$Gene, gene_lst), ]
  enzyme_count <- length(unique(enzymes_carried_df[enzymes_carried_df$Sugar == sugar, ]$Reaction.EC))
  return(enzyme_count)

}



#' calculate total steps involved in each sugar degradation pathway
#'
#' For each sugar, count total number of enzymatic steps required to construct
#' the entire sugar degradation pathway. Total counts are calculated based on
#' number of enzymes with different EC number.
#'
#' @param all_sugars A list of sugar names whose pathway enzyme count are to
#'   be calculated.
#' @param ER A dataset with at least two required columns with specified names.
#'   Sugar (sugar pathway), Reaction.EC (enzymatic reaction type)
#'
#' @return A vector. Name of each value is the sugar degraded, and the value
#'   is the number of steps involved.
#'
#' @example
#' \dontrun{
#'  library(microCompet)
#'  ER <- microCompet::EnzymaticReactions
#'  all_sugars <- ER$Sugar
#'  total_steps <- calculateTotalSteps(all_sugars, ER)
#'  total_steps
#' }
#'
calculateTotalSteps <- function(all_sugars, ER) {

  total_steps <- vector(mode = "integer", length = length(all_sugars))
  names(total_steps) <- all_sugars

  for (sugar in all_sugars) {
    # count of unique ECs is the targeted steps number
    total_steps[sugar] <- length(unique(ER[ER$Sugar == sugar, ]$Reaction.EC))
  }
  return(total_steps)
}

#[END]

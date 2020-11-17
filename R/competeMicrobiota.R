
# https://www.kaggle.com/erykwalczak/top-20-football-players

#' Visualize the competition by a radarchart.
#'
#' Visualize the competiion between a given microbe and other 9 available
#' microbiota members in the EnzymeDistribution dataset.
#'
#' @param genome_name
#'
#' @param gene_lst
#'
#' @export
#' @import radarchart
competeMicrobiota <- function(genome_name, gene_lst) {
  require(radarchart)
  #data("EnzymaticReactions")
  available_microbes <- colnames(EnzymeDistribution)
  if (is.element(genome_name, available_microbes)) {
    stop(sprintf("Already have %s in available datasets (%s), please rename your genome.",
                 genome_name,
                 paste(available_microbes, collapse = ", ")))
  }
  all_sugars <- sort(unique(EnzymaticReactions$Sugar))
  pathCompScores <- pathCompleteness(genome_name, gene_lst, all_sugars)
  competitions <- radarchart::chartJSRadar(scores = pathCompScores[, 2:11],
                                           labs = all_sugars,
                                           maxScale = 1)
  return(competitions)
}


# cols are microbes
# rows are sugars
# each cell is a score, num of enzymes the microbe have for this pathway
pathCompleteness <- function(genome_name, gene_lst, all_sugars) {
  #data("EnzymeDistribution")

  total_steps <- calculateTotalSteps(all_sugars)

  path_pct <- data.frame("Sugar" = all_sugars)
  path_counts <- allSugarScoresForOneGenome(gene_lst, all_sugars)
  path_pct[genome_name] <- path_counts/total_steps

  genome_names <- colnames(EnzymeDistribution)

  for (i in 5:13) {
    genome_name <- genome_names[i]
    microbe <- EnzymeDistribution[i]
    gene_lst <- unique(EnzymaticReactions$Gene[microbe == 1])
    path_counts <- allSugarScoresForOneGenome(gene_lst, all_sugars)
    path_pct[genome_name] <- round(path_counts/total_steps, digits = 2)
  }

  return(path_pct)
}







allSugarScoresForOneGenome <- function(gene_lst, all_sugars) {
  score_vec <- vector(mode = "integer", length = length(all_sugars))
  names(score_vec) <- all_sugars
  for (sugar in all_sugars) {
    score_vec[sugar] <- calculateCount(gene_lst, sugar)
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
#' @return enzyme_count Number of sugar_specific enzymes inside the gene_lst.
#'
#' @example
#' \dontrun{
#'  gene_lst <- c("rpe", "rpiB", "eno", "fucK")
#'  enzyme_count <- calculateCount(gene_lst, "fructose")
#' }
#'
calculateCount <- function(gene_lst, sugar) {
  # data("EnzymaticReactions")
  enzymes_carried_df <- EnzymaticReactions[is.element(EnzymaticReactions$Gene, gene_lst), ]
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
#'
#' @return A vector. Name of each value is the sugar degraded, and the value
#'   is the number of steps involved.
#'
#' @example
#' \dontrun{
#'  data("EnzymaticReactions")
#'  total_steps <- calculateTotalSteps()
#' }
#'
calculateTotalSteps <- function(all_sugars) {
  # only called internally from pathCompleteness, dataset pre-loaded.
  # all_sugars <- sort(unique(EnzymaticReactions$Sugar))
  total_steps <- vector(mode = "integer", length = length(all_sugars))
  names(total_steps) <- all_sugars

  for (sugar in all_sugars) {
    # count of unique ECs is the targeted steps number
    total_steps[sugar] <- length(unique(EnzymaticReactions[EnzymaticReactions$Sugar == sugar, ]$Reaction.EC))
  }
  return(total_steps)
}

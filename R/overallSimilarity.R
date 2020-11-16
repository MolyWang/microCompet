#' Compare overall similarity of the given genomes and microbiota.
#'
#' Based on sugar degradation genes, compare the overall similarity
#' of the given genome and other 9 microbial species from microbiota
#' available species in the EnzymeDistribution dataset.
#'
#' @param genome_name Name of the genome represented by gene_lst
#' @param gene_lst A list of gene names represented by 3-5 characters, such as "rpiB"
#'
#' @return A radar chart with microbial species on corners and the user input genome
#'    in the middle.
#'
#' @example
#' \dontrun{
#'  genome_name <- "random_genes"
#'  gene_lst <- EnzymeDistribution$Gene[19: 40]
#'  overall_similarity <- overallSimilarity(genome_name, gene_lst)
#' }
#'
#' @export
#' @import radarchart
#'
overallSimilarity <- function(genome_name, gene_lst) {
  require(radarchart)

  genome_vector <- transformToVector(gene_lst)
  available_microbes <- colnames(EnzymeDistribution)[5:13]
  overall_similarity <- vector(mode = "integer",
                               length = length(available_microbes))
  names(overall_similarity) <- available_microbes
  for (microbe_name in available_microbes) {
    microbe <- EnzymeDistribution[microbe_name]
    overall_similarity[microbe_name] <- compareTwoGenomes(genome_vector, microbe)
  }

  df_for_chart <- as.data.frame(overall_similarity)
  colnames(df_for_chart) <- c(genome_name)

  comparison_chart <- chartJSRadar(scores = df_for_chart,
                                   labs = available_microbes,
                                   maxScale = length(genome_vector))
  return(comparison_chart)
}



#' Compare two genomes and count shared genes
#'
#' Given two genomes represented by a vector of 0 and 1 (genes in the same order),
#' count shared genes. This includes genes both genomes have or neither.
#'
#' @param genome1 A vector of 0 and 1, genes ordered as in EnzymaticDistribution
#'
#' @param genome2 Same as genome1, but represents another genome
#'
#' @return An integer indicating number of shared genes by genome1 and genome2.
#'
#' @example
#' \dontrun{
#'  gene_lst1 <- EnzymeDistribution$Gene[4:25]
#'  genome1 <- transformToVector(gene_lst1)
#'  gene_lst2 <- EnzymeDistribution$Gene[10:35]
#'  genome2 <- transformToVector(gene_lst2)
#'  score <- compareTwoGenomes(genome1, genome2)
#' }
compareTwoGenomes <- function(genome1, genome2) {
  # Only 0 + 1 = 1
  # This counts all genes that are not shared by two genomes
  not_shared <- (genome1 + genome2) == 1
  total_not_shared <- sum(as.integer(not_shared))

  return(length(EnzymeDistribution$Gene) - total_not_shared)
}



#' Transform a list of gene into a vector of 0 and 1
#'
#' Given a list of genes, transform it into a vector of 0 and 1.
#' Each cell is a named gene, 0 indicating this genome is not included
#' inside the gene_lst, 1 indicating it's included
#'
#' @param gene_lst A list of gene_names, represented by 3-5 characters, such as "eno".
#'
#' @return A vector of 0 and 1, indicating whether each sugar degradation enzyme (from
#' the EnzymeDistribution dataset) is included in the gene_lst.
#'
#' @example
#' \dontrun{
#'  data(EnzymeDistribution)
#'  gene_lst <- EnzymeDistribution$Gene[4:25]
#'  genome_vector <- transformToVector(gene_lst)
#' }
#'
transformToVector <- function(gene_lst) {
  data("EnzymaticReactions")
  all_genes <- EnzymaticReactions$Gene
  genome_vector <- vector(mode = "logical",
                          length = length(all_genes))
  names(genome_vector) <- all_genes
  for (gene in all_genes) {
    genome_vector[gene] <- is.element(gene, gene_lst)
  }

  return(as.integer(genome_vector))
}

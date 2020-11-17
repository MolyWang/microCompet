#' Compare overall similarity of the given genomes and microbiota.
#'
#' Based on sugar degradation genes, compare the overall similarity
#' of the given genome and other 9 microbial species from microbiota
#' available species in the EnzymeDistribution dataset.
#'
#' @param genome_name Name of the genome represented by gene_lst
#' @param gene_lst A list of gene names represented by 3-5 characters, such as "rpiB"
#' @param ED An enzyme distribution dataset that at least contain gene names and one
#'   microbial genome.
#' @param first_microbe An integer. The index of first column in ED dataset that
#'   represents a microbial genome.
#' @param last_microbe An integer. Same as first_microbe, just the index of last
#'   microbe genome
#'
#' @return A radar chart with microbial species on corners and the user input genome
#'    in the middle.
#'
#' @example
#' \dontrun{
#'  library(microCompet)
#'  genome_name <- "L. johnsonii"
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_gene_lst <- ED$Gene
#'  genome_file_path = "./Klebsiella_variicola.gb"
#'  carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
#'
#'  overall_similarity <- overallSimilarity(genome_name, carbo_genes, ED, 5, 13)
#'  overall_similarity
#' }
#'
#' @export
#' @import radarchart
#'
overallSimilarity <- function(genome_name, gene_lst, ED,
                              first_microbe, last_microbe = ncol(ED)) {
  require(radarchart)

  genome_vector <- transformToVector(gene_lst, ED$Gene)
  available_microbes <- colnames(ED)[first_microbe:last_microbe]
  overall_similarity <- vector(mode = "integer",
                               length = length(available_microbes))
  names(overall_similarity) <- available_microbes

  # now fill the vector with scores
  # then transform it into a dataframe for RadarGraph
  for (microbe_name in available_microbes) {
    microbe <- ED[microbe_name]
    overall_similarity[microbe_name] <- compareTwoGenomes(genome_vector,
                                                          microbe,
                                                          length(ED$Gene))
  }

  df_for_chart <- as.data.frame(overall_similarity)
  colnames(df_for_chart) <- c(genome_name)

  comparison_chart <- radarchart::chartJSRadar(scores = df_for_chart,
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
#' @param total_genes Total number of genes of interest to be compared.
#'
#' @return An integer indicating number of shared genes by genome1 and genome2.
#'
#' @example
#' \dontrun{
#'  gene_lst1 <- EnzymeDistribution$Gene[4:25]
#'  genome1 <- transformToVector(gene_lst1)
#'  gene_lst2 <- EnzymeDistribution$Gene[10:35]
#'  genome2 <- transformToVector(gene_lst2)
#'  ED <- microCompet::EnzymaticDistribution
#'  total_genes_num <- length(ED$Gene)
#'  score <- compareTwoGenomes(genome1, genome2, total_genes_num)
#'  score
#' }
compareTwoGenomes <- function(genome1, genome2, total_genes_num) {
  # Only 0 + 1 = 1
  # This counts all genes that are not shared by two genomes
  not_shared <- (genome1 + genome2) == 1
  total_not_shared <- sum(as.integer(not_shared))

  # then not "not shared" are shared
  return(total_genes_num - total_not_shared)
}



#' Transform a list of gene into a vector of 0 and 1
#'
#' Given a list of genes, transform it into a vector of 0 and 1.
#' Each cell is a named gene, 0 indicating this genome is not included
#' inside the gene_lst, 1 indicating it's included
#'
#' @param gene_lst A list of gene_names, represented by 3-5 characters, such as "eno".
#' @param all_genes A list of all sugar degradation genes that may be possibily included.
#'
#' @return A vector of 0 and 1, indicating whether each sugar degradation enzyme (from
#' the EnzymeDistribution dataset) is included in the gene_lst.
#'
#' @example
#' \dontrun{
#'  ED <- microCompet::EnzymeDistribution
#'  all_genes <- ED$Gene
#'  gene_lst <- ED$Gene[4:25]
#'  genome_vector <- transformToVector(gene_lst)
#'  genome_vector
#' }
#'
transformToVector <- function(gene_lst, all_genes) {
  genome_vector <- vector(mode = "logical",
                          length = length(all_genes))
  names(genome_vector) <- all_genes
  for (gene in all_genes) {
    genome_vector[gene] <- is.element(gene, gene_lst)
  }

  return(as.integer(genome_vector))
}

#' Extract Carbohydrate-degrading Genes from Microbe Genome
#'
#' This functions extract genes encoding enzymes that participate in simple
#' sugar degradation from the given genome.
#'
#' @param genome_file_path Full path to a GenBank file that represents a microbial genome.
#'     This GenBank file must at least have gene names annotated.
#'     Only enzymes listed in the EnzymaticReactions dataset will be extracted.
#'
#' @return A list of gene names that encode simple sugar degradation enzymes.
#'
#' @examples
#' \dontrun{
#'  file_path = "Path_to_File.gb"
#'  carboGenes <- extractCarboGenes(file_path)
#' }
#'
#' @export
#' @importFrom genbankr readGenBank
#'
extractCarboGenes <- function(genome_file_path) {
  library("genbankr")

  # check if file exists

  genome_record <- genbankr::readGenBank(genome_file_path)
  gene_lst <- genes(genome_record)$gene

  # here check if the list length is zero

  full_enzyme_gene_lst <- EnzymaticReactions$Gene

  carboGenes <- vector(mode = "list")
  # extract all genes in record that's also in the full_lst


  # return the extracted list.
  return(carboGenes)

}




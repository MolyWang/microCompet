#' Extract Carbohydrate-degrading Genes from Microbe Genome
#'
#' This functions extract genes encoding enzymes that participate in simple
#' sugar degradation from the given genome.
#' The imported function is known to produce warnings because microbial genomes
#' do not contain introns.
#'
#' @param genome_file_path Full path to a GenBank file that represents a microbial genome.
#'     This GenBank file must at least have gene names annotated.
#'     Only enzymes listed in the EnzymaticReactions dataset will be extracted.
#'
#' @return A list of gene names that encode simple sugar degradation enzymes.
#'
#' @examples
#' \dontrun{
#'  require("genbankr")
#'  genome_file_path = "./Klebsiella_variicola.gb"
#'  carboGenes <- extractCarboGenes(genome_file_path)
#' }
#'
#' @export
#' @importFrom genbankr readGenBank
#'
extractCarboGenes <- function(genome_file_path) {
  require("genbankr")
  data("EnzymaticReactions")

  # check if file exists
  if (!file.exists(genome_file_path)) {
    stop("File does not exist, double check the file path to the genome file.")
  }

  # check the proper file type
  if (!endsWith(genome_file_path, ".gb")) {
    stop("A file with extension 'gb' is required, such as Klebsiella_variicola.gb")
  }

  # extract all genes from a genome represented by the input gb file
  genome_record <- genbankr::readGenBank(genome_file_path)
  gene_lst <- genes(genome_record)$gene
  if (length(gene_lst) == 0) {
    stop("The GenBank file does not have gene names annotated in 'CDS' section.")
  }


  full_enzyme_gene_lst <- unique(EnzymaticReactions$Gene)

  carboGenes <- vector()
  # extract all genes in record that's also in the full_enzyme_gene_lst
  for (gene in gene_lst) {
    if (is.element(gene, full_enzyme_gene_lst)) {
      print("yes")
      carboGenes <- append(carboGenes, gene)
    }
  }

  return(carboGenes)

}


#[END]

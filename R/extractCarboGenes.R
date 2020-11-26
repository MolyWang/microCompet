#' Extract Carbohydrate Degradation Genes from Microbe Genome
#'
#' This function reads a genbank file specified by path line by line and
#' extracts genes encoding enzymes that participate in simple sugar
#' degradation from the given genome.
#'
#' There are other available packages that format the whole genbank file into
#' one organized object, but information other than geneName are not
#' useful to this package, and those functions would take about 30 more
#' seconds on a Windows system, so this function is provided.
#'
#'
#' @param genomeFilePath Full path to a GenBank file that represents a microbial genome.
#'     This GenBank file must at least have gene names annotated, see provided file
#'     "Klebsiella variicola.gb" and "Lactobacillus johnsonii.gb" in extdata for example,
#'     they have lines in the format /gene="gene_name".
#' @param fullEnzymeGeneList A list of all sugar degradation genes to be searched for in
#'     the user-provided genome (the file with genomeFilePath).
#'
#' @return A list of gene names that encode simple sugar degradation enzymes.
#'
#' @examples
#' \dontrun{
#'  require("microCompet")
#'  ED <- microCompet::EnzymeDistribution
#'  fullEnzymeGeneList <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Klebsiella variicola.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneList)
#'  carboGenes
#'  # carboGenes should be the same as the following geneList
#'  expectedCarboGenes <- microCompet::sampleGenomeKvari
#' }
#'
#' @export
#'
extractCarboGenes <- function(genomeFilePath, fullEnzymeGeneList) {
  # check if file exists
  if (!file.exists(genomeFilePath)) {
    stop("File does not exist, double check the file path to the genome file.")
  }

  # check if fullEnzymeGeneList is valid
  if (length(fullEnzymeGeneList) == 0) {
    stop("The given fullEnzymeGeneList is not valid, should contain at least one gene.")
  }

  carboGenes <- vector(mode = "character")
  genome_file <- file(genomeFilePath, "r")
  line <- readLines(genome_file, n = 1)
  while (nchar(line) > 0) {
    line <- trimws(line)
    # specific format of genbank file.
    if (nchar(line) < 20 & substr(line, 1, 7) == '/gene="') {
      gene_name <- substr(line, 8, nchar(line) - 1)
      if (is.element(gene_name, fullEnzymeGeneList)) {
        carboGenes <- c(carboGenes, gene_name)
      }
    }
    line <- readLines(genome_file, n = 1)
  }
  close(genome_file)

  # only very rare cases microbes have duplication of a gene, thus using
  # unique before return is better than check in the loop.
  return(unique(carboGenes))
}

#[END]

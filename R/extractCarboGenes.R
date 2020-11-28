#' Extract Simple Sugar Degradation Genes from A Microbial Genome
#'
#' This function reads a user-provided genbank file line by line and
#' extracts genes encoding enzymes that participate in simple sugar
#' degradation as a vector.
#'
#' There are other available packages that format the whole genbank file into
#' one organized object, but information other than geneName are not
#' useful to this package, and those functions would take about 30 more
#' seconds on a Windows system, so this function is provided.
#'
#'
#' @param genomeFilePath Full path to a GenBank file that represents a microbial genome.
#'     This GenBank file must at least have gene names annotated. See provided file
#'     "Klebsiella_variicola.gb" and "Lactobacillus_johnsonii.gb" in extdata for example,
#'     they have lines in the format /gene="geneName". And see example for how to extract
#'     full path to the example files. (\code{genomeFilePath <-} part)
#' @param fullEnzymeGeneVec A list of all sugar degradation genes to be searched for in
#'     the user-provided genome (the file with genomeFilePath).
#'
#' @return A vector of gene names that encode simple sugar degradation enzymes.
#'
#' @examples
#' \dontrun{
#'  require("microCompet")
#'  ED <- microCompet::EnzymeDistribution
#'  fullEnzymeGeneVec <- ED$Gene
#'  genomeFilePath <- system.file("extdata",
#'                                "Klebsiella_variicola.gb",
#'                                package = "microCompet",
#'                                mustWork = TRUE)
#'  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
#'  carboGenes
#' }
#'
#' @export
#'
extractCarboGenes <- function(genomeFilePath, fullEnzymeGeneVec) {
  # ============ Check ============
  # check if file exists
  if (!file.exists(genomeFilePath)) {
    stop("File does not exist, double check the file path to the genome file.")
  }

  # check if fullEnzymeGeneVec is valid
  if (length(fullEnzymeGeneVec) == 0) {
    stop("The given fullEnzymeGeneVec is not valid, should contain at least one gene.")
  }

  # ============ Extraction ============
  carboGenes <- vector(mode = "character")
  genomeFile <- file(genomeFilePath, "r")
  line <- readLines(genomeFile, n = 1)
  while (nchar(line) > 0) {
    line <- trimws(line)
    # specific format of genbank file.
    if (nchar(line) < 20 & substr(line, 1, 7) == '/gene="') {
      geneName <- substr(line, 8, nchar(line) - 1)
      if (is.element(geneName, fullEnzymeGeneVec)) {
        carboGenes <- c(carboGenes, geneName)
      }
    }
    line <- readLines(genomeFile, n = 1)
  }
  close(genomeFile)

  # only very rare cases microbes have duplication of a gene, thus using
  # unique before return is better than check in the loop.
  return(unique(carboGenes))
}


#[END]

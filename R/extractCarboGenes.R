#' Extract Carbohydrate-degrading Genes from Microbe Genome
#'
#' This functions extract genes encoding enzymes that participate in simple
#' sugar degradation from the given genome.
#' There are other available packages that format the whole genbank file into
#' one organized object, but information other than "gene_names" are not
#' useful to this package, and those functions would take about 30 more
#' seconds on a Windows system, so this function is provided.
#'
#'
#' @param genome_file_path Full path to a GenBank file that represents a microbial genome.
#'     This GenBank file must at least have gene names annotated, see provided file
#'     "Klebsiella_variicola.gb" and "Lactobacillus_johnsonii.gb" for example, they have
#'     lines starting with "/gene=".
#' @param full_enzyme_gene_lst A list of all sugar degradation genes to be searched for in
#'     the user-defined genome.
#'
#' @return A list of gene names that encode simple sugar degradation enzymes.
#'
#' @examples
#' \dontrun{
#'  require("microCompet")
#'  ED <- microCompet::EnzymeDistribution
#'  full_enzyme_gene_lst <- ED$Gene
#'  genome_file_path <- "./Klebsiella_variicola.gb"
#'  carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
#'  carbo_genes
#' }
#'
#' @export
#'
extractCarboGenes <- function(genome_file_path, full_enzyme_gene_lst) {
  # check if file exists
  if (!file.exists(genome_file_path)) {
    stop("File does not exist, double check the file path to the genome file.")
  }

  # check if gene_lst is valid
  if (length(full_enzyme_gene_lst) == 0) {
    stop("The given gene_lst is not valid, should contain at least one gene.")
  }

  carbo_genes <- vector(mode = "character")
  genome_file <- file(genome_file_path, "r")
  line <- readLines(genome_file, n = 1)
  while (nchar(line) > 0) {
    line <- trimws(line)
    # specific format of gbk file.
    if (nchar(line) < 20 & substr(line, 1, 7) == '/gene="') {
      gene_name <- substr(line, 8, nchar(line) - 1)
      if (is.element(gene_name, full_enzyme_gene_lst)) {
        carbo_genes <- c(carbo_genes, gene_name)
      }
    }
    line <- readLines(genome_file, n = 1)
  }
  close(genome_file)

  # only very rare cases microbes have duplication of a geen, thus using
  # unique before return is better than check in the loop.
  return(unique(carbo_genes))
}

#[END]

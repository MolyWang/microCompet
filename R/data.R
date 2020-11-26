#' Enzymatic Reactions of Carbohydrate Degradation
#'
#' A list of 91 enzymatic steps that's required by microbes to degrade several
#' simple sugars.
#'
#' @source MetaCyc from metacyc.org
#'
#' @format A matrix with 96 rows and 6 variables:
#' \describe{
#'  \item{Gene}{Name of the gene that encodes the enzyme represented in this row.}
#'  \item{Reaction.EC}{Enzyme Commission (EC) number of this enzyme, assigned based
#'    on the reaction it catalyzes.}
#'  \item{Enzyme}{Full name of the enzyme.}
#'  \item{Substrate}{Starting material of the enzyme. If one reaction requires more
#'    than one substrates, the reaction is split into more than one lines.}
#'  \item{Product}{Product of this enzymatic reaction. If more than one products are
#'    produced, they are split into more than one lines.}
#'  \item{Sugar}{The sugar degradation pathway this enzyme acts in.}
#' }
#'
#' @examples
#' \dontrun{
#' head(EnzymaticReactions)
#' }
"EnzymaticReactions"


#' Distribution of Sugar Degradation Enzymes
#'
#' The distribution of 66 sugar degradation enzymes in 9 representative
#' human microbiota members. Some enzymes can catalyze more than one
#' reactions. "0" suggests the enzyme represented by the row is not
#' found in the column microbe, while "1" suggests it's found.
#'
#' E. coli is usually treated as a positive control species since it contains
#' very abundant metabolic genes and can survive with minimal minerals and
#' simple sugars.
#'
#' @source Genomes downloaded from NCBI
#'
#' @format A matrix with 71 rows (genes) and 13 variables
#'  \describe{
#'   \item{Gene}{Name of gene encoding this sugar degradation enzyme.}
#'   \item{Reaction.EC}{EC category of this enzyme, indicating its reaction type.}
#'   \item{Enzyme}{Full name of the enzyme}
#'   \item{Sugar}{The sugar degradation pathway this enzyme invoved in.}
#'   \item{Lplan}{Enzyme distribution in Lactobacillus plantarum}
#'   \item{Ecoli}{Enzyme distribution in Escherichia coli}
#'   \item{Blong}{Enzyme distribution in Bifidobacterium longum}
#'   \item{Paeru}{Enzyme distribution in Pseudomonas aeruginosa}
#'   \item{Bthet}{Enzyme distribution in Bacteroides thetaiotaomicron}
#'   \item{Cbotu}{Enzyme distribution in Clostridium botulinum}
#'   \item{Enter}{Enzyme distribution in Enterobacter sp. EA-01}
#'   \item{Kvari}{Enzyme distribution in Klebsiella variicola}
#'   \item{Spneu}{Enzyme distribution in Streptococcus pneumoniae}
#'  }
#'
#'@examples
#'\dontrun{
#'head(EnzymeDistribution)
#'}
"EnzymeDistribution"


#' Sample carboGenes extracted from Klebsiella variicola
#'
#' A list of all simple sugar degradation enzymes present in Klebsiella variicola.
#'
#' @examples
#' \dontrun{
#' sampleGenomeKvari
#' }
"sampleGenomeKvari"


#' Sample carboGenes extracted from Lactobacillus johnsonii
#'
#' A list of all simple sugar degradation enzymes present in Lactobacillus johnsonii.
#'
#' @examples
#' \dontrun{
#' sampleGenomeLjohn
#' }
"sampleGenomeLjohn"


#' Information about genomes used in EnzymeDistribution
#'
#'  @format A matrix with 9 rows and 3 variables
#'  \describe{
#'   \item{Bacterial.Genome}{Full name of 9 bacteria.}
#'   \item{Accession}{Accession of this genome on NCBI.}
#'   \item{Description}{Full description of this genome on NCBI, including strain name.}
#'   }
"GenomesInfo"


#[END]

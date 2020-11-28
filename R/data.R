#' Enzymatic Reactions Of Simple Sugar Degradation
#'
#' A list of 72 enzymatic reactions that involve in microbial degradation of
#' several simple sugars. Because some reactions can be catalyzed by more than one
#' enzymes, the dataset have more than 72 rows.
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
#'    than one substrates, the reaction is split multiple lines.}
#'  \item{Product}{Product of this enzymatic reaction. If more than one products are
#'    produced, they are split into multiple lines.}
#'  \item{Sugar}{The sugar degradation pathway this enzyme participates in.}
#' }
#'
#' @examples
#'  \dontrun{
#'   head(EnzymaticReactions)
#' }
#'
"EnzymaticReactions"


#' Distribution Of Simple Sugar Degradation Enzymes In Microbes
#'
#' The distribution of 66 sugar degradation enzymes in 9 representative
#' human microbiota members. Because some enzymes can catalyze more than one
#' reactions, this dataset has more than 66 rows. When reading this dataset,
#' "0" suggests the enzyme represented by the row is not present in the column
#' microbe, while "1" suggests it's present
#'
#' E. coli is usually treated as a positive control species because it survives
#' in minimal media and can synthesize and degrade almost all common sugars.
#'
#' @source Genomes downloaded from NCBI, see dataset GenomesInfo for details.
#'
#' @format A matrix with 71 rows (genes) and 13 variables
#'  \describe{
#'   \item{Gene}{Name of gene encoding this sugar degradation enzyme.}
#'   \item{Reaction.EC}{EC category of this enzyme, indicating its reaction type.}
#'   \item{Enzyme}{Full name of the enzyme}
#'   \item{Sugar}{The sugar degradation pathway this enzyme invoved in.}
#'   \item{Lplan}{Lactobacillus plantarum}
#'   \item{Ecoli}{Escherichia coli}
#'   \item{Blong}{Bifidobacterium longum}
#'   \item{Paeru}{Pseudomonas aeruginosa}
#'   \item{Bthet}{Bacteroides thetaiotaomicron}
#'   \item{Cbotu}{Clostridium botulinum}
#'   \item{Enter}{Enterobacter sp. EA-01}
#'   \item{Kvari}{Klebsiella variicola}
#'   \item{Spneu}{Streptococcus pneumoniae}
#'  }
#'
#' @examples
#'  \dontrun {
#'   head(EnzymeDistribution)
#'}
#'
"EnzymeDistribution"


#' Information About Genomes Included In EnzymeDistribution
#'
#' This dataset offers detailed information about genomes included in another dataset
#' EnzymeDistribution (See with \code{?EnzymeDistribution}). You can find the original
#' genbank files on NCBI by searching the Accession.
#'
#' @format A matrix with 9 rows and 3 variables
#'  \describe{
#'   \item{Bacterial.Genome}{Full name of bacterial species.}
#'   \item{Accession}{Accession of this genome on NCBI.}
#'   \item{Description}{Full description of this genome on NCBI, including strain name.}
#'   }
#' @examples
#'  \dontrun {
#'   GenomesInfo
#'}
#'
"GenomesInfo"


#[END]

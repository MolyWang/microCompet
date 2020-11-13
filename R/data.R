#' Enzymatic Reactions of Carbohydrate Degradation
#'
#' A list of 91 enzymatic steps that's required by microbes to degrade several
#' simple sugars.
#'
#' @source MetaCyc from metacyc.org
#'
#' @format A matrix with 91 rows and 5 variables:
#' \describe{
#'  \item{Gene}{Name of the gene that encodes the enzyme represented in this row.}
#'  \item{Reaction.EC}{Enzyme Commission (EC) number of this enzyme, assigned based
#'    on the reaction it catalyzes.}
#'  \item{Enzyme}{Full name of the enzyme.}
#'  \item{Substrate}{Starting material of the enzyme. If one reaction requires more
#'    than one substrates, the reaction is split into more than one lines.}
#'  \item{Product}{Product of this enzymatic reaction. If more than one products are
#'    produced, they are split into more than one lines.}
#' }
#'
#' @examples
#' head(EnzymaticReactions)
"EnzymaticReactions"

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractCarboGenes.R
\name{extractCarboGenes}
\alias{extractCarboGenes}
\title{Extract Simple Sugar Degradation Genes from A Microbial Genome}
\usage{
extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
}
\arguments{
\item{genomeFilePath}{Full path to a GenBank file that represents a microbial genome.
This GenBank file must at least have gene names annotated. See provided file
"Klebsiella_variicola.gb" and "Lactobacillus_johnsonii.gb" in extdata for example,
they have lines in the format /gene="geneName". And see example for how to extract
full path to the example files. (\code{genomeFilePath <-} part)}

\item{fullEnzymeGeneVec}{A list of all sugar degradation genes to be searched for in
the user-provided genome (the file with genomeFilePath).}
}
\value{
A vector of gene names that encode simple sugar degradation enzymes.
}
\description{
This function reads a user-provided genbank file line by line and
extracts genes encoding enzymes that participate in simple sugar
degradation as a vector.
}
\details{
There are other available packages that format the whole genbank file into
one organized object, but information other than geneName are not
useful to this package, and those functions would take about 30 more
seconds on a Windows system, so this function is provided.
}
\examples{
\dontrun{
 require("microCompet")
 ED <- microCompet::EnzymeDistribution
 fullEnzymeGeneVec <- ED$Gene
 genomeFilePath <- system.file("extdata",
                               "Klebsiella_variicola.gb",
                               package = "microCompet",
                               mustWork = TRUE)
 carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
 carboGenes
}

}

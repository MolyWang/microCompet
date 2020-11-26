
<!-- README.md is generated from README.Rmd. Please edit that file -->

# microCompet

<!-- badges: start -->

<!-- badges: end -->

## Description

R package ***microCompet*** is for visualizing potential microbial
competitions for nutrition, mainly simple sugars such as pentoses an
pyranoses. This package offers functions to:

1.  visualize all sugar degradation activities one microbe can carry out
    (See function *_constructFullNetwork_*)

2.  Compare a microbe’s overall sugar degradation pathway similarity to
    other microbes (See functions *_overallSimilarity_* and
    *_competeMicrobiota_*)

## Installation

``` r
require("devtools")
devtools::install_github("MolyWang/microCompet", build_vignettes = TRUE)
library("microCompet")
```

## Overview

``` r
ls("package:microCompet")
data(package = "microCompet")
```

*microCompet* package contains 4 functions and 2 datasets.

Dataset ***EnzymaticReactions*** describe enzymatic steps for sugar
degradation pathways with 5 factors: gene encoding the enzyme, enzyme
catagory by EC number (such as 2.1.5.77), reaction substrate and
product, and the sugar pathway.

Dataset ***EnzymeDistribution*** lists genes for unique enzymes *AND*
offers the genome data of 9 diverse microbe strains from human
microbiota, using 0 and 1 to indicate whether a specific microbe (one
column) carries the gene represented by the row. See these genomes by

``` r
library("microCompet")

# from the description for dataset by
?EnzymeDistribution
#or
ED <- microCompet::EnzymeDistribution
colnames(ED)[5:13]
```

Function ***extractCarboGenes*** extract sugar degradation enzymes from
user-given GenBank file. The file must have genes annotated, that is
they have lines in the format of */gene=“gene\_name”* (See the included
*Klebsiella\_variicola.gb* and *Lactobacillus\_johnsonii.gb* for
example, they are in the main folder). Other R packages are available
for formatting GenBank file, but they parse the whole file into one
object, which is not necessary for this package.

Function ***constructFullNetwork*** takes a genome and plot its full
sugar degradation pathways, the following image is a sample output using
the provided *Lactobacillus\_johnsonii.gb* genome.

``` r
require("microCompet")
#> Loading required package: microCompet

ER <- microCompet::EnzymaticReactions
ED <- microCompet::EnzymeDistribution
fullEnzymeGeneList <- ED$Gene
genomeFilePath <- system.file("extdata",
                              "Lactobacillus johnsonii.gb",
                              package = "microCompet",
                              mustWork = TRUE)
carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneList)
fullPathway <- constructFullNetwork("Lactobacillus johnsonii", carboGenes, ER)
fullPathway
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Function ***overallSimilarity*** count sugar degradation genes in common
between the given genome and other microbial species, and creates an
interactive radar graph.

``` r
library("microCompet")
require("radarchart")
genome_name <- "L. johnsonii"
ED <- microCompet::EnzymeDistribution
full_enzyme_gene_lst <- ED$Gene
genome_file_path <- system.file("extdata",
                              "Lactobacillus johnsonii.gb",
                              package = "microCompet",
                              mustWork = TRUE)
carbo_genes <- microCompet::extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
overall_similarity <- overallSimilarity(genome_name, carbo_genes, ED, 5, 13)
overall_similarity
```

<img src="./inst/extdata/overSimi1.png" width="100%" />

The final function ***competeMicrobiota*** visualize available microbes
in terms of pathway completeness, suggesting their ability to fully
degrade indicated sugar sources.

``` r
library("microCompet")
require("radarchart")
genome_name <- "L. johnsonii"
ED <- microCompet::EnzymeDistribution
full_enzyme_gene_lst <- ED$Gene
genome_file_path <- system.file("extdata",
                              "Lactobacillus johnsonii.gb",
                              package = "microCompet",
                              mustWork = TRUE)
carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)
first_microbe <- 5
last_microbe <- 13
ER <- microCompet::EnzymaticReactions
compete_microbiota <- competeMicrobiota(genome_name, carbo_genes, ER,
                                       ED, first_microbe, last_microbe)
compete_microbiota
```

<img src="./inst/extdata/comp1.png" width="100%" />

Refer to package vignettes for more details.

``` r
browseVignettes("microCompet")
```

The package tree structure is provided below.

``` r
- microCompet
  |- microCompet.Rproj
  |- DESCRIPTION
  |- NAMESPACE
  |- LICENSE
  |- README
  |- data
    |- EnzymaticReactions.rda
    |- EnzymeDistribution.rda
  |- inst
    |- CITATION
    |- extdata
      |- comp1.png
      |- comp2.png
      |- Kvari_pathway.png
      |- Ljohn.png
      |- microbiome.jpg
      |- overSimi1.png
  |- man
    |- allSugarScoresForOneGenome.Rd
    |- calculateCount.Rd
    |- calclateTotalSteps.Rd
    |- compareTwoGenomes.Rd
    |- competeMicrobiota.Rd
    |- constructFullNetwork.Rd
    |- createEdgeFrame.Rd
    |- createNodeFrame.Rd
    |- EnzymaticReactions.Rd
    |- EnzymeDistribution.Rd
    |- extractCarboGenes.Rd
    |- overallSimilarity.Rd
    |- transformToVector.Rd
  |- R
    |- competeMicrobiota.R
    |- constructFullNetwork.R
    |- data.R
    |- extractCarboGenes.R
    |- overallSimilarity.R
  |- tests
```

## Contributions

Written by Zhuyi Wang.

## References

1.  Butts, C. 2008. “network: a Package for Managing Relational Data in
    R.” *Journal of Statistical Software*. 24(2). \<URL:
    <https://www.jstatsoft.org/v24/i02/paper>\>.

2.  Butts, C. 2020. network: Classes for Relational Data. The Statnet
    Project (\<URL:<http://www.statnet.org>\>). R package version
    1.16.1, \<URL: <https://CRAN.R-project.org/package=network>\>.

3.  Butts, C.T. 2020. sna: Tools for Social Network Analysis. R package
    version 2.6. <https://CRAN.R-project.org/package=sna>

4.  Csardi, G., Nepusz, T. 2006. The igraph software package for complex
    network research, InterJournal, Complex Systems 1695.
    <https://igraph.org>

5.  Karp, P.D., Riley, M., Paley, S.M., and Pellegrini-Toole A. 2002.
    The MetaCyc Database. *Nucleic Acids Res*. 30(1):59-61.
    <doi:10.1093/nar/30.1.59>

6.  National Center for Biotechnology Information (NCBI)\[Internet\].
    Bethesda (MD): National Library of Medicine (US), National Center
    for Biotechnology Information; \[1988\]. Available from:
    <https://www.ncbi.nlm.nih.gov/>

7.  Pedersen, T.L. 2020. ggraph: An Implementation of Grammar of
    Graphics for Graphs and Networks. R package version 2.0.3.
    <https://CRAN.R-project.org/package=ggraph>

8.  R Core Team. 2020. R: A language and environment for statistical
    computing. R Foundation for Statistical Computing, Vienna, Austria.
    URL: <https://www.R-project.org/>.

9.  Wickham, H. 2016. ggplot2: Elegant Graphics for Data Analysis.
    Springer-Verlag New York.

10. Cite the R-package textbook here.

## Acknowledgements

This package was developed as part of an assessment for 2019-2020
BCB410H: Applied Bioinformatics, University of Toronto, Toronto, CANADA.

## Examples

## Consent

As on 2020-11-26, I, Zhuyi Wang, consent to leave this package public
and share it with future BCB410 students.

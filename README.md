
<!-- README.md is generated from README.Rmd. Please edit that file -->

# microCompet

<!-- badges: start -->

<!-- badges: end -->

## Description

R package *microCompet* is for visualizing potential microbial
competitions for nutrition, mainly simple sugars such as pentoses an
pyranoses. This package offers functions to: 1. visualize all sugar
degradation activities one microbe can carry out (See function
constructFullNetwork) 2. Compare a microbe’s overall sugar degradation
pathway similarity to other microbes (See functions overallSimilarity
and competeMicrobiota)

## Installation

``` r
require("devtools")
devtools::install_github("MolyWang/microCompet", build_vignettes = TRUE)
library("microCompet)
```

## Overview

``` r
ls("package:microCompet")
data(package = "microCompet")
```

*microCompet* package contains 4 functions and 2 datasets. Dataset
*EnzymaticReactions* describe enzymatic steps for sugar degradation
pathways with 5 factors: gene encoding the enzyme, enzyme catagory by EC
number (such as 2.1.5.77), reaction substrate and product, and the sugar
pathway. Dataset *EnzymeDistribution* lists genes for unique enzymes
*AND* offers the genome data of 9 diverse microbe strains from human
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

Function *extractCarboGenes* extract sugar degradation enzymes from
user-given GenBank file. The file must have genes annotated, that is
they have lines in the format of */gene=“gene\_name”* (See the included
*Klebsiella\_variicola.gb* and \*Lactobacillus\_johnsonii.gb" for
example, they are in the main folder). Other R packages are available
for formatting GenBank file, but they parse the whole 20M file into one
object, which is not necessary for this package.

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
  |- man
  |- R
  |- tests
```

An overview of the package is illustrated below.

![](./inst/extdata/microbiome.jpg)

<https://emerypharma.com/blog/human_microbiome_healthier_life/>

## Contributions

## References

Karp, P.D., Riley, M., Paley, S.M., and Pellegrini-Toole A. 2002. The
MetaCyc Database. *Nucleic Acids Res*. 30(1):59-61.
<doi:10.1093/nar/30.1.59>

Gabriel Becker and Michael Lawrence (2020). genbankr: Parsing GenBank
files into semantically useful objects. R package version 1.16.0.

R Core Team (2020). R: A language and environment for statistical
computing. R Foundation for Statistical Computing, Vienna, Austria. URL:
<https://www.R-project.org/>.

Csardi G, Nepusz T: The igraph software package for complex network
research, InterJournal, Complex Systems 1695. 2006. <https://igraph.org>

National Center for Biotechnology Information (NCBI)\[Internet\].
Bethesda (MD): National Library of Medicine (US), National Center for
Biotechnology Information; \[1988\]. Available from:
<https://www.ncbi.nlm.nih.gov/>

H. Wickham. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag
New York. 2016.

Butts C (2020). *network: Classes for Relational Data*. The Statnet
Project (\<URL: <http://www.statnet.org>\>). R package version 1.16.1,
\<URL: <https://CRAN.R-project.org/package=network>\>.

Butts C (2008). “network: a Package for Managing Relational Data in R.”
*Journal of Statistical Software*, *24*(2). \<URL:
<https://www.jstatsoft.org/v24/i02/paper>\>.

Carter T. Butts (2020). sna: Tools for Social Network Analysis. R
package version 2.6. <https://CRAN.R-project.org/package=sna>

Thomas Lin Pedersen (2020). ggraph: An Implementation of Grammar of
Graphics for Graphs and Networks. R package version 2.0.3.
<https://CRAN.R-project.org/package=ggraph>

## Acknowledgements

This package was developed as part of an assessment for 2019-2020
BCB410H: Applied Bioinformatics, University of Toronto, Toronto, CANADA.

## Examples

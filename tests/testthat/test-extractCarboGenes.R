genomeFilePath <- system.file("extdata",
                              "Klebsiella_variicola.gb",
                              package = "microCompet",
                              mustWork = TRUE)


test_that("Empty fullEnzymeGeneVec is not valid", {
  expect_error(extractCarboGenes(genomeFilePath, c()))
})


test_that("No external genes extracted", {
  ED <- microCompet::EnzymeDistribution
  fullEnzymeGeneVec <- ED$Gene
  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)
  expect_equal(all(carboGenes %in% fullEnzymeGeneVec),
               TRUE)
})


test_that("Expect all genes extracted", {
  ED <- microCompet::EnzymeDistribution
  fullEnzymeGeneVec <- ED$Gene
  carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)

  ranEnzymeGeneVec <- sample(carboGenes, 5, replace = FALSE)
  carboGenes2 <- extractCarboGenes(genomeFilePath, ranEnzymeGeneVec)

  expect_equal(sort(carboGenes2),
               sort(ranEnzymeGeneVec))
})


#[END]

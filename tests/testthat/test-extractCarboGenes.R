# Due to relative path issue, change the path before running Check or Test
genomeFilePath <- system.file("extdata",
                              "Klebsiella_variicola.gb",
                              package = "microCompet",
                              mustWork = TRUE)
ED <- microCompet::EnzymeDistribution
fullEnzymeGeneVec <- ED$Gene
carboGenes <- extractCarboGenes(genomeFilePath, fullEnzymeGeneVec)

test_that("No external genes extracted", {
  expect_equal(setequal(intersect(carboGenes, fullEnzymeGeneVec), carboGenes), TRUE)
})

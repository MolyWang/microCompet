test_that("Compare Two Same Genome", {
  genome <- sample(c(0, 1), replace = TRUE, size = 83)
  expect_equal(compareTwoGenomes(genome, genome, 83),
               83)
})


test_that("Compare Two Different Genome", {
  genome1 <- sample(c(0, 1), replace = TRUE, size = 76)
  genome2 <- 1 - genome1
  expect_equal(compareTwoGenomes(genome1, genome2, 76),
               0)
})


test_that("Have Five Common Genes", {
  genome1 <- sample(c(0, 1), replace = TRUE, size = 57)
  genome2 <- 1 - genome1
  indices <- sort(sample(1:57, replace = FALSE, size = 6))
  genome1[indices] <- 0
  genome2[indices] <- 0
  expect_equal(compareTwoGenomes(genome1, genome2, 57),
               6)
})


test_that("Transform to vector, all genes present", {
  genomeVec <- unique(EnzymeDistribution$Gene)
  expect_equal(transformToVector(genomeVec, genomeVec),
               rep(1, length(genomeVec)))
})


test_that("Transform to vector, no genes", {
  allEnzymes <- unique(EnzymeDistribution$Gene)
  expect_equal(transformToVector(c(), allEnzymes),
               rep(0L, length(allEnzymes)))
})


test_that("Transform to vector, some genes", {
  allEnzymes <- unique(EnzymeDistribution$Gene)
  l <- length(allEnzymes)
  indices <- sort(sample(1:l, replace = FALSE, size = 10))
  genomeVec <- allEnzymes[indices]
  expectedVec <- rep(0L, l)
  expectedVec[indices] <- 1
  expect_equal(transformToVector(genomeVec, allEnzymes),
               expectedVec)
})


#[END]

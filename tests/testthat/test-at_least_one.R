genome_file_path = "../../Klebsiella_variicola.gb"
test_that("At least one sugar degradation enzyme is found", {
  expect_equal(length(extractCarboGenes(genome_file_path)) > 0, TRUE)
})

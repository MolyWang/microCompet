# Due to relative path issue, change the path before running Check or Test
genome_file_path = "C:/Users/Helia/Documents/microCompet/Klebsiella_variicola.gb"
ED <- microCompet::EnzymeDistribution
full_enzyme_gene_lst <- ED$Gene
carbo_genes <- extractCarboGenes(genome_file_path, full_enzyme_gene_lst)

test_that("No external genes extracted", {
  expect_equal(setequal(intersect(carbo_genes, full_enzyme_gene_lst), carbo_genes), TRUE)
})

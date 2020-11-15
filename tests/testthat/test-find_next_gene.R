test_that("find_next_gene in constructFullPathways.R", {
  data("EnzymaticReactions")
  expect_equal(sort(find_next_gene("alsE", 1, EnzymaticReactions$Gene)), c("pfkA", "pfkB"))
  expect_equal(sort(find_next_gene("talB", -1, EnzymaticReactions$Gene)), c("tktA", "tktB", "tpiA"))
})

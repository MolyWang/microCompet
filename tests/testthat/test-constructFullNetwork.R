library("dplyr")

test_that("Create Edge Frame - edge count", {
  relevantReactions <- dplyr::slice_sample(EnzymaticReactions, n = 20)
  edgeFrame <- createEdgeFrame(relevantReactions)
  expect_equal(nrow(edgeFrame),
               nrow(unique(dplyr::select(relevantReactions, Substrate, Product))))
})


test_that("Create Node Frame - node count", {
  relevantReactions <- dplyr::slice_sample(EnzymaticReactions, n = 20)
  edgeFrame <- createEdgeFrame(relevantReactions)
  nodeFrame <- createNodeFrame(edgeFrame)
  expect_equal(setequal(nodeFrame$Compound,
                        unique(c(edgeFrame$Substrate, edgeFrame$Product))),
               TRUE)
})



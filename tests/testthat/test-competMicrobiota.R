test_that("competeMicrobiota", {
  expect_equal(calculateTotalSteps(c("ribose"), EnzymaticReactions)[["ribose"]],
               length(unique((EnzymaticReactions[EnzymaticReactions$Sugar == "ribose", ]$Reaction.EC))))

  expect_equal(length(calculateTotalSteps(c("fructose", "fucose"), EnzymaticReactions)),
               2)

  expect_equal(calculateCount(c("rpe", "rpiB", "eno", "fruK"), "fructose", EnzymaticReactions),
               2)


})

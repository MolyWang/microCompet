test_that("competeMicrobiota", {
  expect_equal(calculateTotalStepsForAllSugars(c("ribose"), EnzymaticReactions)[["ribose"]],
               length(unique((EnzymaticReactions[EnzymaticReactions$Sugar == "ribose", ]$Reaction.EC))))

  expect_equal(length(calculateTotalStepsForAllSugars(c("fructose", "fucose"), EnzymaticReactions)),
               2)

  expect_equal(calculateStepsForOneSugar(c("rpe", "rpiB", "eno", "fruK"), "fructose", EnzymaticReactions),
               2)


})

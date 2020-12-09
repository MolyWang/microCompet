test_that("calculate total steps for all sugars", {
  expect_equal(length(calculateTotalStepsForAllSugars(c("fructose", "fucose"), EnzymaticReactions)),
               2)
})


test_that("calculate total steps for all sugars 2", {
  expect_equal(calculateTotalStepsForAllSugars(c("ribose"), EnzymaticReactions)[["ribose"]],
               length(unique((EnzymaticReactions[EnzymaticReactions$Sugar == "ribose", ]$Reaction.EC))))

})


test_that("calculate steps for one sugar", {
  expect_equal(calculateStepsForOneSugar(c("rpe", "rpiB", "eno", "fruK"), "fructose", EnzymaticReactions),
               2)
})


#[END]

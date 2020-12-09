doubleFalse <- c(F, F)
names(doubleFalse) <- c("lastMicrobeTooLarge", "UnexpectedValuesInED")

doubleTrue <- c(T, T)
names(doubleTrue) <- c("lastMicrobeTooLarge", "UnexpectedValuesInED")

firstTrue <- c(T, F)
names(firstTrue) <- c("lastMicrobeTooLarge", "UnexpectedValuesInED")

secondTrue <- c(F, T)
names(secondTrue) <- c("lastMicrobeTooLarge", "UnexpectedValuesInED")



test_that("CheckUserED - Builtin ED Passes with correct columns", {
  EDResult1 <- checkUserED(EnzymeDistribution, 5, 13)
  expect_equal(EDResult1, doubleFalse)
})


test_that("CheckUserED - Builtin ED Passes with Fewer genome columns", {
  EDResult2 <- checkUserED(EnzymeDistribution, 6, 10)
  expect_equal(EDResult2, doubleFalse)
})


test_that("CheckUserED - Builtin ED including character column", {
  EDResult3 <- checkUserED(EnzymeDistribution, 4, 8)
  expect_equal(EDResult3, secondTrue)
})


test_that("CheckUserED - lastMicrobe too large", {
  EDResult4 <- checkUserED(EnzymeDistribution, 5, ncol(EnzymeDistribution) + 10)
  expect_equal(EDResult4, firstTrue)
})


test_that("CheckUserED - lastMicrobe too large and characters in selected columns", {
  EDResult5 <- checkUserED(EnzymeDistribution, 4, ncol(EnzymeDistribution) + 10)
  expect_equal(EDResult5, doubleTrue)
})


test_that("CheckUserED - Missing required column", {
  EDCopy <- EnzymeDistribution
  colnames(EDCopy)[colnames(EDCopy) == "Gene"] <- "G"

  expect_error(checkUserED(EDCopy, 5, 13))
})


#[END]

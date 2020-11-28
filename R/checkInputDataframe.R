#' Check Whether The User Input ED Dataframe Satisfies Function Requirement
#'
#'
#'
#'
#' @export
#'
checkED <- function(ED, requiredColsVec, firstMicrobe, lastMicrobe) {
  # ============ Check for problems that have to "stop" ============
  # check user provided indices firstMicrobe and lastMicrobe are positive integers
  if (firstMicrobe <= 0 | floor(fistMicrobe) != firstMicrobe |
      lastMicrobe <= 0 | floor(lastMicrobe) != lastMicrobe) {
    stop("firstMicrobe or lastMicrobe is invalid, positive integers are required.")
  }

  # check all required columns are present with specified names
  if (!all(requiredColsVec %in% colnames(ED))) {
    errorInfo <- sprintf("Columns %s (case sensitive) are required, and at least one is missing in your data.frame.",
                         paste(requiredColsVec, collapse = ", "))
    stop(errorInfo)
  }

  # check at least one genomes are provided in ED
  if (firstMicrobe > lastMicrobe) {
    stop("Invalid column indices, firstMicrobe should be no larger than lastMicobe.")
  }

  # check indices are no larger than total number of columns available
  if (firstMicrobe > ncol(ED)) {
    stop("Start index firstMicrobe should be no larger than total number of columns available. (", ncol(ED), ")")
  }

  # ============ Check for problems can be solved ============
  # initiate report vector
  reportVec <- c(FALSE, FALSE)
  names(reportVec) <- c("lastMicrobeTooLarge", "UnexpectedValuesInED")

  # Remind if lastMicrobe is larger than total columns available
  if (lastMicrobe > ncol(ED)) {
    sprintf("The given lastMicrobe index is larger than total columns available, and will be replaced by %d.",
            ncol(ED))
    reportVec["lastMicrobeTooLarge"] <- TRUE
  }

  # check whether columns from firstMicrbe to lastMicrobe contains only 0 and 1,
  relevantSection <- ED[firstMicrobe:lastMicrobe]
  unexpectedValues <- (relevantSection != 0) & (relevantSection != 1)
  unexpectedValuesCount <- sum(as.integer(unexpectedValues))
  if (unexpectedValuesCount > 0) {
    sprintf("%d cells from column %d to column %d in the provided data.frame is not 0 or 1, and will be replaced by 0.",
            sum(as.integer(unexpectedValues)),
            firstMicrobe,
            lastMicrobe)
    reportVec["UnexpectedValuesInED"] <- TRUE
  }

  return(reportVec)

}

#' Launch Shiny App For microCompet
#'
#' This function launches the Shiny app for this package microCompet, which
#' targeted users with limited background in R language.
#'
#'
#' @return No values return, this function opens a Shiny page.
#'
#' @examples
#'  \dontrun{
#'   microCompet::runMicroCompet()
#'  }
#'
#' @references
#' Grolemund, G. (2015). Learn Shiny - Video Tutorials. \href{https://shiny.rstudio.com/tutorial/}{Link}
#'
#' @export
#'
#' @importFrom shiny runApp
#'
runMicroCompet <- function() {
  appDir <- system.file("shiny-scripts",
                        package = "microCompet")
  shiny::runApp(appDir, display.mode = "normal")
  return()
}


# [END]

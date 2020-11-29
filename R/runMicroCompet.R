#' Launch Shiny App For microCompet
#'
#' -------------.
#'
#' @return No values return, this function opens a Shiny page.
#'
#' @examples
#'  \dontrun{
#'   microCompet::runMicroCompet()
#'  }
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

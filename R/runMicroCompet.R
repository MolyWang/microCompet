#' Launch Shiny App for microCompet
#'
#' @export
runTestingPackage <- function() {
  appDir <- system.file("shiny-scripts",
                        package = "microCompet")
  shiny::runApp(appDir, display.mode = "normal")
  return()
}


# [END]

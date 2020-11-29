library("shiny")

options(shiny.maxRequestSize = 10*1024^2)

ui <- fluidPage(

  sidebarPanel(
    fileInput(inputId = "genome",
              label = "Upload the annotated genbank file for your microbe of interest.",
              accept = c(".gb", ".gbk")
              ),
  ),

  mainPanel(
    tableOutput(outputId = "carboGenes")
  )
)

server <- function(input, output) {

  output$carboGenes <- renderTable({
    microCompet::extractCarboGenes(input$genome$datapath,
                                   microCompet::EnzymaticReactions$Gene)
  })

}

shinyApp(ui = ui, server = server)


library("shiny")

options(shiny.maxRequestSize = 10*1024^2)

ui <- fluidPage(

  titlePanel("Welcom to microCompet"),

  sidebarLayout(
    sidebarPanel(
      textInput(inputId = "genomeName",
                label = "Enter the name of your microbe."),

      fileInput(inputId = "genome",
                label = "Upload the annotated genbank file for your microbe of interest.",
                accept = c(".gb", ".gbk")
      ),

      actionButton(inputId = "extractCarboGenes",
                   label = "Extract Carbo Genes"),

      conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                       tags$div("Ahh, I am running! Give me some time ~",id="loadmessage"))

    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Extract Sugar Degradation Genes",
                 tableOutput(outputId = "carboGenes")
        )
      )
    )
  )
)

server <- function(input, output) {


  # ============ For extractCarboGenes ============
  carboGenes <- eventReactive(eventExpr = input$extractCarboGenes, {
    microCompet::extractCarboGenes(input$genome$datapath,
                                   microCompet::EnzymaticReactions$Gene)
  })

  genomeName <- reactive({
    if (input$genomeName == "") {
      "User Genome"
    } else {
      input$genomeName
    }
  })

  output$carboGenes <- renderTable({
    matrix(data = carboGenes(),
           dimnames = list(list(), genomeName()))
  })




}

shinyApp(ui = ui, server = server)


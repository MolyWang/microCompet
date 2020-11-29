library("shiny")

options(shiny.maxRequestSize = 10*1024^2)

ui <- fluidPage(

  titlePanel("Welcom to microCompet: Identify Microbial Competitors for Nutrition"),

  sidebarLayout(

    sidebarPanel(

      # ============ Ask for Info about the genome of interest ============
      textInput(inputId = "genomeName",
                label = "Enter the name of your microbe."),

      fileInput(inputId = "genome",
                label = "Upload the annotated genbank file for your microbe of interest.",
                accept = c(".gb", ".gbk")),


      # ============ Ask for the dataset ED ============
      selectInput(inputId = "selectED",
                  label = "Select an ED dataset",
                  choices = list("Use built-in EnzymeDistribution", "Upload my own")),

      uiOutput("selectEDFile"),

      actionButton(inputId = "preview", label = "Preview ED"),


      # ============ Ask for the dataset ER ============


      # ============ Button to run microCompet functions ============
      # extractCarboGenes
      actionButton(inputId = "extractCarboGenes",
                   label = "Extract Carbo Genes"),

      # constructFullNetwork

      # overallSimilarity

      # competMicrobiota


      # ============ Show running message ============
      conditionalPanel(condition = "$('html').hasClass('shiny-busy')",
                       tags$div("Ahh, I am running! Give me some time ~",id="loadmessage")),

    ),

    mainPanel(

      tags$strong("Functions are not run until you select the output panel.",
                  style = "color:orange"),

      tabsetPanel(

        tabPanel("Dataset (ER & ED) Preview and Check",
                 textOutput(outputId = "datasetCheckResult"),
                 tableOutput(outputId = "previewPanel")),

        tabPanel("Extract Sugar Degradation Genes",
                 tableOutput(outputId = "carboGenes")
        )
      )
    )
  )
)

server <- function(input, output) {

  # ============ Determine ED ============
  needUploadED <- reactive({
    input$selectED == "Upload my own"
  })

  output$selectEDFile <- renderUI({
    if (needUploadED()) {
      fileInput(inputId = "ED",
                label = "Upload your ED dataset here.")
    }
  })

  ED <- reactive({
    if (needUploadED()) {
      read.delim2(input$ED$datapath)
    } else {
      microCompet::EnzymeDistribution
    }
  })

  EDPreview <- eventReactive(input$preview, {
    ED()
  })

  output$previewPanel <- renderTable({
    EDPreview()
  })




  # ============ For extractCarboGenes ============
  carboGenes <- eventReactive(eventExpr = input$extractCarboGenes, {
    microCompet::extractCarboGenes(input$genome$datapath,
                                   ED()$Gene)
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


#[END]

library("shiny")
library("radarchart")

options(shiny.maxRequestSize = 10*1024^2)


ui <- fluidPage(
  tags$head(
    tags$style(HTML(
      "label { font-size:100%;
               font-weight: 200;
               font-family: Arial;
               margin-bottom: 0px;}"
    ))
  ),


  titlePanel(h1("microCompet: Microbial Competitors for Nutrition",
             style = "font-family: 'Lobster', cursive;
                      font-weight: 500; line-height: 1.1;
                      color: #4d3a7d;")),

  sidebarLayout(

    sidebarPanel(
      tags$p("Introduction"),

      # ============ Ask for Datasets ============
      tags$strong("Step 1: Select Your Datasets"),

      # ED
      selectInput(inputId = "selectED",
                  label = "Select An ED Dataset",
                  choices = list("Use built-in EnzymeDistribution", "Upload my own")),
      uiOutput("selectEDFile"),
      uiOutput("selectMicrobeColsSlider"),

      # ER
      selectInput(inputId = "selectER",
                  label = "Select An ER Dataset",
                  choices = list("Use built-in EnzymaticReactions", "Upload my own")),
      uiOutput("selectERFile"),


      # ============ Ask for Info about the genome of interest ============
      tags$strong("Step 2: Info of Microbial Genome"),
      textInput(inputId = "genomeName",
                label = "Enter Name of The Microbial Genome",
                placeholder = "-- Name of the Microbe --"),

      fileInput(inputId = "genome",
                label = "Upload An Annotated Microbial Genome (.gb or .gbk)",
                accept = c(".gb", ".gbk"),
                placeholder = "Microbial Genome"),




      # ============ Button to run microCompet functions ============
      tags$p("Step 3: Now Ready To Run Package Functions!"),
      # extractCarboGenes
      actionButton(inputId = "extractCarboGenes",
                   label = "Extract Carbo Genes"),

      # constructFullNetwork
      actionButton(inputId = "constructFullNetwork",
                   label = "Construct Sugar Degradation Pathway Network"),

      # overallSimilarity
      actionButton(inputId = "calOverallSimilarity",
                   label = "Compare overall similarity."),

      # competMicrobiota
      actionButton(inputId = "calCompeteMicrobiota",
                   label = "Visualize microbial nutrition competition"),

      # ============ Show running message ============
      conditionalPanel(condition = "$('html').hasClass('shiny-busy')",
                       tags$div(h4("Ahh, I am running! Give me some time ~",
                                   style = "font-family: 'Lobster', cursive;
                                            font-weight: 300;
                                            color: blue;"),
                                id="loadmessage")),
    ),

    mainPanel(

      tabsetPanel(

        tabPanel("Extract Sugar Degradation Genes",
                 tableOutput(outputId = "carboGenes")),

        tabPanel("Full Sugar Degradation Pathway Network",
                 plotOutput(outputId = "constructFullNetworkFig")),

        tabPanel("Sugar Pathway Similarity",
                 chartJSRadarOutput(outputId = "overallSimilarityFig")),

        tabPanel("Sugar Pathway Overlapping",
                 chartJSRadarOutput(outputId = "competeMicrobiotaFig"))
      )
    )
  )
)

server <- function(input, output) {

  genomeName <- reactive({
    if (input$genomeName == "") {
      "User Genome"
    } else {
      input$genomeName
    }
  })

  # ============ ED ============
  # ED <- reactive({microCompet::EnzymeDistribution})
  needUploadED <- reactive({input$selectED == "Upload my own"})

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

  output$selectMicrobeColsSlider <- renderUI({
    if (needUploadED()) {
      sliderInput(inputId = "selectMicrobeCols",
                  label = "Select Column Inidces",
                  min = 1,
                  max = 13,
                  value = c(min, max))
    }
  })

  firstMicrobe <- reactive({
    if (needUploadED()) {
      input$selectMicrobeCols[1]
    } else {5}
  })

  lastMicrobe <- reactive({
    if (needUploadED()) {
      input$selectMicrobeCols[2]
    } else {13}
  })


  # ============ ER ============
  # ER <- reactive({microCompet::EnzymaticReactions})
  needUploadER <- reactive({
    input$selectER == "Upload my own"
  })

  output$selectERFile <- renderUI({
    if (needUploadER()) {
      fileInput(inputId = "ER",
                label = "Upload your ER dataset here.")
    }
  })

  ER <- reactive({
    if (needUploadER()) {
      read.delim2(input$ER$datapath)
    } else {
      microCompet::EnzymaticReactions
    }
  })




  # ============ For microCompet Functions ============

  carboGenes <- reactive({
    if (input$extractCarboGenes) {
      microCompet::extractCarboGenes(input$genome$datapath,
                                     ED()$Gene)}
    })


  # extractCarboGenes
  output$carboGenes <- renderTable({carboGenes()})

  # constructFullNetwork
  output$constructFullNetworkFig <- renderPlot({
    if (input$constructFullNetwork) {
      microCompet::constructFullNetwork(genomeName(), carboGenes(), ER())
    }})

  # overallSimilarity
  output$overallSimilarityFig <- renderChartJSRadar({
      if (input$calOverallSimilarity) {
        microCompet::overallSimilarity(genomeName(), carboGenes(), ED(),
                                                         firstMicrobe(), lastMicrobe())}
      })

  # competeMicrobiota
  output$competeMicrobiotaFig <- renderChartJSRadar({
    if (input$calCompeteMicrobiota){
      microCompet::competeMicrobiota(genomeName(), carboGenes(), ER(),
                                     ED(), firstMicrobe(), lastMicrobe())}
    })

}


shinyApp(ui = ui, server = server)


#[END]

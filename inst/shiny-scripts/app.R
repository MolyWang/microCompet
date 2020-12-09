library("shiny")
library("radarchart")

options(shiny.maxRequestSize = 10*1024^2)


ui <- fluidPage(
  tags$head(
    tags$style(HTML(
      "label {font-size: 14px;
              font-weight: 100;
              font-family: Arial;
              margin-bottom: 0px;}"))
  ),

  tags$head(
    tags$style(HTML("
      .shiny-output-error-validation {
        font-size: 16px;
        font-family: Arial;
        color: red;
        font-weight: 100;}"))
  ),

  tags$style(HTML(
    "#genomesInfoName {font-size: 30px;
                      font-family: Arial;
                      color: #4d3a7d;
                      display: block;}")),

  tags$style(HTML(
    "#builtinEDName {font-size: 30px;
                     font-family: Arial;
                     color: #4d3a7d;
                     display: block;}")),

  tags$style(HTML(
    "#builtinERName {font-size: 30px;
                    font-family: Arial;
                    color: #4d3a7d;
                    display: block;}")),

  tags$style(HTML(
    "#checkUserED {font-size: 16px;
                      font-family: Arial;
                      color: red;
                      display: block;}")),

  tags$style(HTML(
    "#checkUserER {font-size: 16px;
                      font-family: Arial;
                      color: red;
                      display: block;}")),


  tags$style(HTML(
    "#EDName {font-size: 30px;
                      font-family: Arial;
                      color: #4d3a7d;
                      display: block;}")),

  tags$style(HTML(
    "#ERName {font-size: 30px;
                      font-family: Arial;
                      color: #4d3a7d;
                      display: block;}")),

  tags$style(HTML(
    "#overSimiMsg {font-size: 16px;
                      font-family: Arial;
                      color: red;
                      display: block;}")),

  tags$style(HTML(
    "#competMicroMsg {font-size: 16px;
                      font-family: Arial;
                      color: red;
                      display: block;}")),


  titlePanel(h1("microCompet: Microbial Competitors for Nutrition",
                style = "font-family: cursive;
                      font-weight: 500; line-height: 1.1;
                      color: #4d3a7d;")),

  sidebarLayout(

    sidebarPanel(
      tags$strong("Introduction"),
      tags$p("microCompet helps to identify potential microbial competitors for nutritions. Follow the five steps listed in the sidebar."),
      # ============ Have a look at Datasets ============
      tags$strong("Step 1: Have A Look at Built-in Datasets"),
      tags$p(""),
      actionButton(inputId = "preview",
                   label = "Preview Built-in Datasets"),
      br(),
      br(),

      # ============ Ask for Datasets ============
      tags$strong("Step 2: Choose Datasets & Check"),

      # ED
      selectInput(inputId = "selectED",
                  label = "Select An ED Dataset",
                  choices = list("Use built-in EnzymeDistribution", "Upload my own")),
      uiOutput("selectEDFile"),
      uiOutput("selectMicrobeColsSlider"),
      uiOutput("checkUserEDButton"),

      # ER
      br(),
      selectInput(inputId = "selectER",
                  label = "Select An ER Dataset",
                  choices = list("Use built-in EnzymaticReactions", "Upload my own")),
      uiOutput("selectERFile"),
      uiOutput("checkUserERButton"),
      br(),

      # preview selected DS
      actionButton(inputId = "previewSelectedDS",
                   label = "Preview Selected Datasets",
                   style = "color: red; font-family: Arial; font-size: 16px"),

      br(),


      # ============ Ask for Info about the genome of interest ============
      br(),
      tags$strong("Step 3: Info of Microbial Genome"),

      selectInput(inputId = "selectGenome",
                  label = "Select An Genome",
                  choices = list("Use Lactobacillus johnsonii",
                                 "Use Klebsiella variicola",
                                 "Upload My Own")),
      uiOutput("selectGenomeFile"),

      textInput(inputId = "genomeName",
                label = "Enter Name of The Microbial Genome",
                placeholder = "-- Name of the Microbe --"),


      # ============ Button to run microCompet functions ============
      br(),

      tags$strong("Step 4: Extract Sugar Degradation Genes From Selected Genome!"),
      # extractCarboGenes
      actionButton(inputId = "extractCarboGenes",
                   label = "Extract Sugar Degradation Genes"),
      # ============ Show running message ============
      conditionalPanel(condition = "$('html').hasClass('shiny-busy')",
                       tags$div(h3("Ahh, I am running! Give me some time ~",
                                   style = "font-family: cursive;
                                            font-size: 16px;
                                            color: red;"),
                                id="loadmessage")),

      br(),
      br(),
      tags$strong("Step 5: Ready To Try Functions!"),
      # constructFullNetwork
      br(),
      actionButton(inputId = "constructFullNetwork",
                   label = "Construct Pathway Network"),
      br(),

      # overallSimilarity
      actionButton(inputId = "calOverallSimilarity",
                   label = "Compare Overall Similarity."),
      br(),

      # competMicrobiota
      actionButton(inputId = "calCompeteMicrobiota",
                   label = "Identify Competition"),
      br(),


    ),

    mainPanel(
      h3("Functions Would Not Run Until You Select The Corresponding Panel",
         style = "color: orange;"),

      tabsetPanel(
        tabPanel("Preview Built-In Datasets",
                 br(),
                 textOutput(outputId = "genomesInfoName"),
                 dataTableOutput(outputId = "genomesInfo"),
                 br(),
                 br(),
                 textOutput(outputId = "builtinEDName"),
                 dataTableOutput(outputId = "builtinED"),
                 br(),
                 br(),
                 textOutput(outputId = "builtinERName"),
                 dataTableOutput(outputId = "builtinER")
        ),

        tabPanel("Preview Selected Datasets",
                 br(),
                 textOutput(outputId = "checkUserED"),
                 br(),
                 textOutput(outputId = "checkUserER"),
                 br(),
                 br(),
                 textOutput(outputId = "EDName"),
                 dataTableOutput(outputId = "seeED"),
                 br(),
                 br(),
                 textOutput(outputId = "ERName"),
                 dataTableOutput(outputId = "seeER")
        ),


        tabPanel("Extract Sugar Degradation Genes",
                 tableOutput(outputId = "carboGenes")),

        tabPanel("Full Sugar Degradation Pathway Network",
                 plotOutput(outputId = "constructFullNetworkFig")),

        tabPanel("Compare Overall Pathway Similarity",
                 textOutput(outputId = "overSimiMsg"),
                 chartJSRadarOutput(outputId = "overallSimilarityFig")),

        tabPanel("Identify Microbial Competition",
                 textOutput(outputId = "competMicroMsg"),
                 chartJSRadarOutput(outputId = "competeMicrobiotaFig"))
      )
    )
  )
)



server <- function(input, output) {
  # ============ Preview Built-in Datasets ============
  # genomesInfo
  output$genomesInfoName <- renderText({
    if (input$preview) {"Built-in microCompet::GenomesInfo"}
  })

  output$genomesInfo <- renderDataTable({
    if (input$preview) {microCompet::GenomesInfo}
  }, options = list(lengthMenu = c(5, 10),
                    pageLength = 10))

  # EnzymeDistribution
  output$builtinEDName <- renderText({
    if (input$preview) {"Built-in microCompet::Enzymedistribution"}
  })

  output$builtinED <- renderDataTable({
    if (input$preview) {microCompet::EnzymeDistribution}
  }, options = list(lengthMenu = c(10, 25, 50),
                    pageLength = 10))

  # EnzymaticReactions
  output$builtinERName <- renderText({
    if (input$preview) {"Built-in microCompet::EnzymaticReactions"}
  })

  output$builtinER <- renderDataTable({
    if (input$preview) {microCompet::EnzymaticReactions}
  }, options = list(lengthMenu = c(10, 25, 50),
                    pageLength = 10))




  # ============ Select ED and ER  & Check ============
  # Load ED
  needUploadED <- reactive({input$selectED == "Upload my own"})

  output$selectEDFile <- renderUI({
    if (needUploadED()) {
      fileInput(inputId = "ED",
                label = "Upload your ED dataset here.",
                accept = c(".tsv", ".tab", ".txt"))
    }
  })

  ED <- reactive({
    if (needUploadED()) {
      validate(need(input$ED,
                    message = "Choose An ED dataset."),
               need(tools::file_ext(input$ED$datapath) %in% c("tsv", "tab", "txt"),
                    message = "Only accept tsv, txt and tab files."))
      read.delim2(input$ED$datapath)
    } else {
      microCompet::EnzymeDistribution
    }
  })

  maxInd <- reactive({
    validate(need(input$ED,
                  message = "Select An ED Dataset first!"))
    if (needUploadED()) {ncol(ED())}
    else {13}
  })

  output$selectMicrobeColsSlider <- renderUI({
    if (needUploadED()) {
      validate(need(input$ED,
                    message = "Select An ED Dataset first!"))
      sliderInput(inputId = "selectMicrobeCols",
                  label = "Select Column Inidces",
                  min = 1,
                  max = ncol(ED()),
                  value = c(min, max),
                  step = 1)
    }
  })

  firstMicrobe <- reactive({
    if (needUploadED()) {
      validate(need(input$selectMicrobeCols,
                    message = "Choose your ED dataset and then select column indices before checking!"))
      input$selectMicrobeCols[1]
    } else {5}
  })

  lastMicrobe <- reactive({
    if (needUploadED()) {
      validate(need(input$selectMicrobeCols,
                    message = "Choose your ED dataset and then select column index before checking!"))
      input$selectMicrobeCols[2]
    } else {13}
  })

  output$checkUserEDButton <- renderUI({
    if (needUploadED()) {
      actionButton(inputId = "checkUserED",
                   label = "Check My ED",
                   style = "color: orange; font-size: 16px")
    }
  })

  # Check User ED
  output$checkUserED <- renderText({
    if (!needUploadED()) {""}
    else if (input$checkUserED) {
      isolate({
        result <- microCompet::checkUserED(ED(), firstMicrobe(), lastMicrobe())
        if (result[[1]]) {
          "The lastMicrobe column you selected is larger than total column present in your ED."
        } else if (result[[2]]) {
          "The columns you selected contain values other than 0 and 1, these would be replaced by 0. Click on 'Preview Selected Datasets' to see your dataets."
        } else {
          "Hooray! Your ED looks good!"
        }
        })
    }
  })


  # Load ER
  needUploadER <- reactive({
    input$selectER == "Upload my own"
  })

  output$selectERFile <- renderUI({
    if (needUploadER()) {
      fileInput(inputId = "ER",
                label = "Upload your ER dataset here.",
                accept = c(".tsv", ".tab", ".txt"))
    }
  })

  ER <- reactive({
    if (needUploadER()) {
      validate(need(input$ER,
                    message = "Choose An ER dataset."),
               need(tools::file_ext(input$ER$datapath) %in% c("tsv", "tab", "txt"),
                    message = "Only accept tsv, txt and tab files."))
      read.delim2(input$ER$datapath)
    } else {
      microCompet::EnzymaticReactions
    }
  })

  output$checkUserERButton <- renderUI({
    if (needUploadER()) {
      actionButton(inputId = "checkUserER",
                   label = "Check My ER",
                   style = "color: orange; font-size: 16px")
  }})

  # Check User ER
  output$checkUserER <- renderText({
    if (!needUploadER()) {""}
    else if (input$checkUserER) {
      isolate({
        if (all(c("Gene", "Reaction.EC", "Sugar") %in% colnames(ER()))) {
          "Looks good! Your ER contains all required columns."
        } else {
          "T_T. At Least one required column Gene, Reaction,EC, Sugar (case sensitive) are missing. Click on 'Preview Selected Datasets' to see."
        }
      })
    }
  })


  # ============ Preview Selected ED and ER ============
  # ED
  EDNameText <- eventReactive(input$previewSelectedDS, {
    if (needUploadED()) {"User Provided ED Dataset"}
    else {"Built-in microCompet::EnzymeDistribution"}
  })
  output$EDName <- renderText({EDNameText()})

  output$seeED <- renderDataTable({
    if (input$previewSelectedDS) {isolate(ED())}},
    options = list(lengthMenu = c(10, 25, 50, 75),
                   pageLength = 10))

  # ER
  ERNameText <- eventReactive(input$previewSelectedDS, {
    if (needUploadER()) {"User Provided ER Dataset"}
    else {"Built-in microCompet::EnzymaticReactions"}
  })
  output$ERName <- renderText({ERNameText()})

  output$seeER <- renderDataTable({
    if (input$previewSelectedDS) {isolate(ER())}},
    options = list(lengthMenu = c(10, 25, 50, 75),
                   pageLength = 10))


  # ============ For Selecting An Genome ============
  output$selectGenomeFile <- renderUI({
    if (input$selectGenome == "Upload My Own") {
      input$reset
      fileInput(inputId = "genome",
                label = "Upload An Annotated Microbial Genome (.gb or .gbk)",
                accept = c(".gb", ".gbk"),
                placeholder = "Microbial Genome")
      }})

  genomePath <- reactive({
    if (input$selectGenome == "Use Lactobacillus johnsonii") {
      system.file("extdata",
                  "Lactobacillus_johnsonii.gb",
                  package = "microCompet",
                  mustWork = TRUE)
    } else if (input$selectGenome == "Use Klebsiella variicola") {
      system.file("extdata",
                  "Klebsiella_variicola.gb",
                  package = "microCompet",
                  mustWork = TRUE)
    } else {
      validate(need(input$genome),
               message = "Choose One .gb or .gbk File As The Genome of Interest.")
      input$genome$datapath
    }
  })

  genomeName <- reactive({
    if (input$genomeName == "") {
      "User Genome"
    } else {
      input$genomeName
    }
  })


  # ============ For microCompet Functions ============
  # only triggered by clicking the button, thus all wrapped in isolate()
  carboGenes <- reactive({
    if (input$extractCarboGenes) {
      isolate(microCompet::extractCarboGenes(genomePath(),
                                     ED()$Gene))}
    else {c()}
    })

  # extractCarboGenes
  output$carboGenes <- renderTable({
    # df <- data.frame()
    # df[genomeName()] <- carboGenes
    if (length(carboGenes()) > 0) {
      df <- data.frame(carboGenes())
      names(df) <- c(genomeName())
      df}
    })

  # constructFullNetwork
  output$constructFullNetworkFig <- renderPlot({
    if (input$constructFullNetwork) {
      validate(need((length(carboGenes()) > 0),
                    message = 'Click and run Extract Sugar Degradation Genes first'))
      isolate(microCompet::constructFullNetwork(genomeName(), carboGenes(), ER()))
    }}, width = 800, height = 600)

  # overallSimilarity
  overSimiMsg <- reactive({
    if (length(carboGenes()) == 0) {
      "Click and run Extract Sugar Degradation Genes first."
    } else if (input$calOverallSimilarity) {""}
  })

  output$overSimiMsg <- renderText({overSimiMsg()})

  output$overallSimilarityFig <- renderChartJSRadar({
    if (input$calOverallSimilarity &
        length(carboGenes()) > 0) {
      isolate(microCompet::overallSimilarity(genomeName(), carboGenes(), ED(),
                                     firstMicrobe(), lastMicrobe()))}
  })


  # competeMicrobiota
  nameToUse <- reactive({
    name <- genomeName()
    if (name %in% colnames(ED())){
      while (name %in% colnames(ED())) {
        name <- paste0(name, "_")
      }
      name
    } else {genomeName()}})

  competMicroMsg <- reactive( {
    if (length(carboGenes()) == 0) {
      "Click and run Extract Sugar Degradation Genes first."
    }
    else if (input$calCompeteMicrobiota &
             isolate(genomeName() %in% colnames(ED()))) {
       {paste0("The genome name you provided is already present in ED dataset, replaced by ", nameToUse(), " when running function competeMicrobiota")}
    } else {""}
    })

  output$competMicroMsg <- renderText({competMicroMsg()})

  output$competeMicrobiotaFig <- renderChartJSRadar({
    if (input$calCompeteMicrobiota &
        length(carboGenes() > 0)) {
      isolate(microCompet::competeMicrobiota(nameToUse(), carboGenes(), ER(),
                                     ED(), firstMicrobe(), lastMicrobe()))}
  })
}


shinyApp(ui = ui, server = server)


#[END]

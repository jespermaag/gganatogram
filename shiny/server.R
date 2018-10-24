list.of.packages <- c("shiny", "DT", "colourpicker", "viridis", "RColorBrewer", "shinyWidgets", "rhandsontable")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
  install.packages(new.packages, repos='http://cran.us.r-project.org')
}
if (! "gganatogram" %in% installed.packages()[,"Package"]){
  devtools::install_github("jespermaag/gganatogram")
}


library(shiny)
library(gganatogram)
library(DT)
library(colourpicker)
library(viridis)
library(RColorBrewer)
library(shinyWidgets)
library(rhandsontable)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$Species <- renderUI({
  
    allSpecies <- c("human_male", "human_female", "mouse_male", "mouse_female", "cell", names(other_key))
    selectInput("SpeciesInput", "Species",
                choices=allSpecies,
                selected=allSpecies[1])
  })
  
  
  output$fill <- renderUI({
    if (is.null(anat_key())) {
      return(NULL)
    }
    selectInput("fillInput", "Fill based on colour or value. Both colour and value can be changed in the table",
                c("colour", "value"),
                selected = c("value"))
  })
  
  

  anat_key <- reactive({
    if (is.null(input$SpeciesInput)) {
      return(NULL)
    }
    selectedSpecies <- input$SpeciesInput
    if (selectedSpecies == "human_male" ) {
      hgMale_key
    } else if (selectedSpecies =="human_female" ) {
      hgFemale_key
    } else if (selectedSpecies=="mouse_male" ) {
      mmMale_key
    } else if (selectedSpecies=="mouse_female" ) {
      mmFemale_key
    } else if (selectedSpecies =="cell" ) {
      cell_key[["cell"]]
    } else {
      other_key[[selectedSpecies]]
    }
  
  })
  
  output$Organs <- renderUI({
    if (is.null(anat_key())) {
      return(NULL)
    }
    organs <- anat_key()$organ
    pickerInput("OrgansInput","Organs - Select before changing value", choices = organs, selected = organs, options = list(`actions-box` = TRUE),multiple = T)
  })
  
  output$valueColour <- renderUI({
    colourOptions <- c('viridis', 'magma', 'inferno', 'plasma', 'cividis', rownames(brewer.pal.info[brewer.pal.info$category != 'qual',]))
    #"magma" (or "A"), "inferno" (or "B"), "plasma" (or "C"), "viridis" (or "D", the default option) and "cividis" (or "E").
    selectInput("colourValue", "Value colour",
                choices=colourOptions,
                selected='viridis')

  })
    
   
  organism <- reactive({
    if (is.null(anat_key())) {
      return(NULL)
    }
    selectedSpecies <- input$SpeciesInput
    if (selectedSpecies == "human_male" | selectedSpecies == "human_female"  ) {
      "human"
    } else if (selectedSpecies=="mouse_male" | selectedSpecies=="mouse_female"  ) {
      "mouse"
    } else if (selectedSpecies =="cell" ) {
      "cell"
    } else {
      selectedSpecies
    }
    
  })
  
  
  
  sex <- reactive({
    if (is.null(anat_key())) {
      return(NULL)
    }
    selectedSpecies <- input$SpeciesInput
    if (selectedSpecies == "human_male" | selectedSpecies == "mouse_male"  ) {
      "male"
    } else if (selectedSpecies=="mouse_female" | selectedSpecies=="human_female"  ) {
      "female"
    } else {
      "female"
    }
    
  })
  
  Reactive_key <- reactiveValues(data = NULL)
  Reactive_key$data <-reactive({ 
    if (is.null(anat_key())) {
      return(NULL)
    }
    anat_key()})


  
  output$mytable2 <- renderRHandsontable({
    if (is.null(anat_key())) {
      return(NULL)
    }
    #print(class())
    
    
    organTable <- Reactive_key$data()
    organTable <- organTable[organTable$organ %in% input$OrgansInput,]

    rhandsontable(organTable)
  
  })
  
  reactive({
    reactiveTemp <- Reactive_key$data()
    plotAnat <- hot_to_r(input$mytable2)
    reactiveTemp$value[match(plotAnat$organ, reactiveTemp$organ)] <- plotAnat$value
   # head( Reactive_key$data()[match(plotAnat$organ, Reactive_key$data()$organ),])
    print(head( reactiveTemp$organ))
    print(class(plotAnat))
    Reactive_key$data <- reactiveTemp
      })
  
  
  output$gganatogram <- renderPlot({
    if (is.null(anat_key()) | is.null(input$mytable2)) {
      return(NULL)
    }
    
    
    plotAnat <- hot_to_r(input$mytable2)
    if (length(input$OrgansInput)<1) {
      p <- gganatogram(fillOutline= input$col, outline=input$showOutline, organism=organism(), sex=sex(), fill=input$fillInput) +theme_void() + coord_fixed() + ggtitle(input$ggtitle) +   theme(plot.title = element_text(hjust = 0.5))
    } else {
      plotOrgans <- plotAnat
      plotOrgans <- plotOrgans[plotOrgans$organ %in% input$OrgansInput, ]
      p <- gganatogram(plotOrgans, outline=input$showOutline, fillOutline= input$col, organism=organism(), sex=sex(), fill=input$fillInput) +theme_void() + coord_fixed() +ggtitle(input$ggtitle) +  theme(plot.title = element_text(hjust = 0.5))
  
    }
    if (input$reverseId ) {
      Palettedirection = 1
    } else {
      Palettedirection = -1
    }
    
    if ( input$fillInput == "value" ) {
      if ( input$colourValue %in% c('viridis', 'magma', 'inferno', 'plasma', 'cividis') ) {
        p <- p + scale_fill_viridis(option = input$colourValue, direction= Palettedirection)
      } else {
        p <- p + scale_fill_distiller(palette = input$colourValue, direction = Palettedirection)
      }
    }
    
  p
  })
  
  output$plot.ui <- renderUI({
    if (is.null(input$height) ) {
      ggheight <-100
    } else {
      ggheight <- input$height
    }

      
    plotOutput("gganatogram", height = paste0(ggheight, "cm"))
  })
  #END
})

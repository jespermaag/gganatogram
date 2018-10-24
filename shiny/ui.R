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
shinyUI(fluidPage(
  
  titlePanel("gganatogram"),
  h4("Github:", tags$a(href="https://github.com/jespermaag/gganatogram", "https://github.com/jespermaag/gganatogram")),
  h4("Cite:", tags$a(href="https://f1000research.com/articles/7-1576/v1", "Maag JLV. 2018")),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(

       uiOutput('Species'),
       checkboxInput("showOutline", "Show outline", value = TRUE, width = NULL),
       uiOutput('fill'),
       colourInput("col", "Outline colour", "#a6bddb"),
       uiOutput("valueColour"),
       checkboxInput("reverseId", "reverse colour palette", value = TRUE, width = NULL),
       uiOutput('Organs'),
       textInput("height", label = "Height in cm", value = "15"),
       textInput("ggtitle", label = "Plot title", value = "")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      #uiOutput('Species'),
      uiOutput("plot.ui"),
      tabPanel("Species_Key", rHandsontableOutput("mytable2")),
      h4('Contact information:'),
      h5('Author: Jesper Maag, PhD'),
      h5("Email:", tags$a(href="mailto:maagj@mskcc.org", "maagj@mskcc.org")),
      h5("Website:", tags$a(href="https://jespermaag.com", "https://jespermaag.com"))
    )
  )
))

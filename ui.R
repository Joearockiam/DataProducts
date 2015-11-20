library(shiny)
library(markdown)

shinyUI(
  
  navbarPage("Storm Data Explorer Application",tabPanel("Data Plot",
  pageWithSidebar(
      headerPanel("Application Options"),
      sidebarPanel(
      sliderInput("timeline", "Timeline Range:", min = 1950, max = 2011,value = c(1950, 2011)),
      uiOutput("evtypeControls")
      ),
mainPanel(
  tabsetPanel(
            tabPanel(p("Visualization"),
            plotOutput("myplot",width = "100%", height = "300px"),
            plotOutput("ploteconomicImpact",width = "100%", height = "300px"),
            plotOutput("plotpopulationImpact",width = "100%", height = "300px")
                    ), 
            tabPanel(p("Data"),dataTableOutput(outputId="mytable"))
            )
        )
)  
                                            
  ),
  tabPanel("Help",mainPanel(includeMarkdown("help.md")))
  
  ))


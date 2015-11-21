library(shiny)
library(data.table)
library(reshape2)
library(ggplot2)

data <- fread('data/aggregate_data.csv')
data$EVTYPE <- toupper(data$EVTYPE)
evtypes <<- sort(unique(data$EVTYPE))

shinyServer(
  function(input, output) {
    
  output$evtypeControls <- renderUI({
      if(1) {
        checkboxGroupInput('evtypes', 'Event types', evtypes, selected=evtypes)
      }
    })
  
  data.agg <- reactive({
    tmp <- merge(
      data.frame(STATE=sort(unique(data$STATE))),data[YEAR >= input$timeline[1] & YEAR <= input$timeline[2] & EVTYPE %in% input$evtypes,
                                                  list(COUNT=sum(COUNT),INJURIES=sum(INJURIES),FATALITIES=sum(FATALITIES),PROPDMG=round(sum(PROPDMG), 2),CROPDMG=round(sum(CROPDMG), 2)),
                                                  by=list(STATE)],
      by=c('STATE'), all=TRUE
    )
    tmp[is.na(tmp)] <- 0
    tmp
  })
  
  dataTable <- reactive(
{
  data.agg()
})

  output$mytable <- renderDataTable(
{
  dataTable()}, options = list(pageLength = 10))


output$myplot <- renderPlot({
    subdata <- dat_aggregatebyyear()[, list(COUNT=sum(COUNT)), by=list(YEAR)]
    p = ggplot(subdata, aes(YEAR, COUNT)) + geom_line(colour="red", size=1.5)+ ggtitle("Number of Event by Year")
    print(p)
})

#Population impact
output$plotpopulationImpact <- renderPlot({
  populationdata <- melt(dat_aggregatebyyear()[, list(Year=YEAR, Injuries=INJURIES, Fatalities=FATALITIES)],id='Year')
  p1 <- ggplot(populationdata, aes(x=Year, y=value, colour=variable)) +
    geom_line(size=1.5) + ggtitle("Population Impact")
  print(p1)
})

#Economic impact
output$ploteconomicImpact <- renderPlot({
  economydata <- melt(dat_aggregatebyyear()[, list(Year=YEAR, Propety=PROPDMG, Crops=CROPDMG)],id='Year')
    p2 <- ggplot(economydata, aes(x=Year, y=value)) +
    geom_boxplot(aes(fill = factor(variable)))+ ggtitle("Economic Impact")
  print(p2)
})

dat_aggregatebyyear <- reactive({data[YEAR >= input$timeline[1] & YEAR <= input$timeline[2] & EVTYPE %in% input$evtypes,
                                      list(COUNT=sum(COUNT),INJURIES=sum(INJURIES),PROPDMG=round(sum(PROPDMG), 2),FATALITIES=sum(FATALITIES),CROPDMG=round(sum(CROPDMG), 2)),
                                      by=list(YEAR)]
})

})
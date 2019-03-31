library(shiny)
library(leaflet)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme('cerulean'),
  
  # Application title
  titlePanel("Visualizing Twitter Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("hashtag",
                "Enter hashtag or phrase to search \n (e.g. 'Boston Redsox'):",
                value = ""),
      
      sliderInput("n_tweets", 'Number of tweets', value = 500, min = 0, max = 1000, step = 100),
      submitButton('Search')
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      leafletOutput(outputId = 'tweet_map')
    )
  )
))

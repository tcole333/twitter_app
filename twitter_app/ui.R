library(shiny)
library(rtweet)
#library(tidytext)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Twitter Data Visualizations"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("hashtag",
                "Hashtag",
                value = "Enter hashtag or word to search:"),
      
      sliderInput("n_tweets", 'Number of tweets', value = 500, min = 0, max = 1000, step = 100)
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))

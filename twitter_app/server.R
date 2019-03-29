library(shiny)
library(rtweet)
library(tidytext)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(httr)

createTokenNoBrowser<- function(appName, consumerKey, consumerSecret, 
                                accessToken, accessTokenSecret) {
  app <- httr::oauth_app(appName, consumerKey, consumerSecret)
  params <- list(as_header = TRUE)
  credentials <- list(oauth_token = accessToken, 
                      oauth_token_secret = accessTokenSecret)
  token <- httr::Token1.0$new(endpoint = NULL, params = params, 
                              app = app, credentials = credentials)
  return(token)
}
token1 <- createTokenNoBrowser('Travis Cole',
                              'sVVmrSupCidOO2VHJZm6NsBvf',
                              'hGcKP7jV0npTSTwTu4G2XjgrL6zAfHn1usvhS0fmm3ZXoq8jNy',
                              '318139041-RWZzSAi461Dr2FNkyQ2jO4zjg0vCQP5s9LELdJNZ',
                              'yx95n9Yjy1Z3AIB0TrfJ4qUkoimFigMjYyhIYFhL44GCk')

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  #define the variables
  set.seed(45)
  
  
  #info for connecting to the twitter REST ap
  
  
  #need to make the number of tweets a variable as well
  tweets_df <- reactive({
    search_tweets(q = input$hashtag, n = input$n_tweets, include_rts = FALSE, token = token1)
  })
  
  #create the plot
  output$distPlot <- renderPlot({
    tweet <- tweets_df()
    tweet_corpus <- Corpus(VectorSource(tweet$text))
    tweet_text <- tm_map(tweet_corpus, content_transformer(tolower))
    tweet_text <- tm_map(tweet_corpus, removeWords, stopwords("english"))
    tweet_text <- tm_map(tweet_corpus, removePunctuation)
    tweet_text <- tm_map(tweet_corpus, stripWhitespace)
    
    #build a matrix of the terms in the tweets
    ttm <- TermDocumentMatrix(tweet_corpus)
    tweet_matrix <- as.matrix(ttm)
    words <- sort(rowSums(tweet_matrix), decreasing = TRUE)
    term_df <- data.frame(word = names(words), freq=words)
    
    #make the wordcloud
    if (nrow(term_df) > 0) {
      wordcloud(words = term_df$word, freq = term_df$freq, min.freq = 1,
                max.words = 300, random.order = FALSE, rot.per = 0.25,
                colors = brewer.pal(8, 'Dark2'))
    }
    
  })
  
  
})

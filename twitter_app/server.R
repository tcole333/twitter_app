library(shiny)
library(twitteR)
library(leaflet)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(httr)

#api connection need to move these to environment variables
setup_twitter_oauth('sVVmrSupCidOO2VHJZm6NsBvf',
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
    #stop if nothing has been inputted
    req(input$hashtag)
    tweets <- searchTwitter(input$hashtag, n = input$n_tweets, resultType = 'recent')
    tweets <- try(twListToDF(tweets), silent = TRUE)
  })
  
  #create the plot

  output$distPlot <- renderPlot({
    #stop if nothing has been inputted
    req(input$hashtag)
    #clean the text some
    tweet <- enc2native(tweets_df()$text)
    tweet_corpus <- Corpus(VectorSource(tweet))
    
    tweet_text <- tm_map(tweet_corpus, content_transformer(tolower))
    search_terms <- tolower(input$hashtag)
    tweet_text <- tm_map(tweet_text, removeWords, c(stopwords("english"), search_terms))
    tweet_text <- tm_map(tweet_text, removePunctuation)
    tweet_text <- tm_map(tweet_text, stripWhitespace)
  
    #build a matrix of the terms in the tweets
    ttm <- TermDocumentMatrix(tweet_text)
    tweet_matrix <- as.matrix(ttm)
    words <- sort(rowSums(tweet_matrix), decreasing = TRUE)
    term_df <- data.frame(word = names(words), freq=words)
    #make the wordcloud when data has loaded into the dataframe
    if (nrow(term_df) > 0) {
      wordcloud(words = term_df$word, freq = term_df$freq, min.freq = 2,
                max.words = 200, random.order = FALSE, rot.per = 0.35,
                colors = brewer.pal(8, 'Dark2'), scale=c(4, 0.5))
    }
    
  })
  #create the map
  output$tweet_map <- renderLeaflet({
    print(tweets_df()$longitude)
    map <- leaflet() %>% 
      addTiles() %>%
      addCircles(lng = as.numeric(tweets_df()$longitude), 
                 lat = as.numeric(tweets_df()$latitude),
                 weight = 8, 
                 radius = 40, 
                 color = "#fb3004", 
                 stroke = TRUE, 
                 fillOpacity = 0.8)
    
  })
  
})

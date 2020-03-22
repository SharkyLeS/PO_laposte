## Importing necessary libraries
## Enter in console install.packages("_____") if error on loading library

library(prophet)
library(gdata)
library(Metrics)
library(matrixStats)

rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 0)			# number of digits to display


## Defining parameters

## Defining interval between two predictions (in hours)
interval <- 0.25

## Number of periods to be predicted onwards (in days)
nb_periods <- 7

## Number of months given as input data
nb_mois_donnees <- 10

## Number of final intervals predicted
nb_intervals <- nb_periods*24/interval

## Reading data
data <- read.csv("C:/Travail A3/Projet d'option/data_cleaned.csv",sep=",", header=TRUE,dec=".")

## Cleaning and extracting data
data <- subset(data, data$CBN != 'CAB nul')
data <- subset(data, data$CBN != 'non trouvé')
data <- subset(data, data$CBN != 'ligne vide')
data <- subset(data, data$CBN != 'BRIN A')
data <- subset(data, data$CBN != 'BRIN B')

## Getting all cbns from data
cbns <- unique(data$CBN)

## Creating intervals
first_date <- as.POSIXct((data$Date.de.passage[1]), format = "%Y-%m-%d %H:%M:%S")
begin_dates <- rep(first_date,nb_mois_donnees*30*24/interval)

for (i in 2:length(begin_dates)){
  begin_dates[i] <- begin_dates[i-1]+interval*60*60
}

## Transforming data
trans_data <- data.frame(matrix(ncol = length(cbns) , nrow = length(begin_dates)))

r <- 1
for (cbn in cbns){
  
  ds <- as.POSIXct(subset(data$Date.de.passage, data$CBN==cbn), format = "%Y-%m-%d %H:%M:%S")
  count <- rep(0,length(begin_dates))
  
  ## Counting the number of elements per interval
  j <- 1
  i <- 1
  count[1] <- 0
  done <- FALSE
  
  while(j<length(begin_dates)&!done){
    while(i<=length(ds)){
      
      if((ds[i]<=begin_dates[j])){
        #count elements within the interval
        count[j] <- count[j]+1
        i = i+1
      }
      else{
        #consider new interval
        j = j+1
      }
    }
    done <- TRUE
  }
  
  trans_data[,r] <- count
  
  r <- r+1
}

colnames(trans_data) <- cbns
row.names(trans_data) <- begin_dates



## Setting ds for model as begin_dates (intervals)
ds <- begin_dates

## Creating storage for all the predictions
predictions <- data.frame(matrix(ncol = length(cbns) , nrow = nb_intervals))

names_given <- FALSE
r <- 1 
for (cbn in cbns){
  
  ## y takes the cbn count corresponding to column r
  y <- trans_data[,r]
  
  df <- data.frame(ds, y)
  
  ## Building model, fitting it and making predictions
  ## Put yearly.seasonality to TRUE in final model
  m <- prophet(df,weekly.seasonality=TRUE, daily.seasonality=TRUE, yearly.seasonality=FALSE)
  
  future <- make_future_dataframe(m, periods = nb_intervals, freq=3600*interval)
  
  forecast <- predict(m, future)
  
  ## Creating columns with dates if not already made
  if(!names_given){
    row.names(predictions) = forecast$ds[(length(forecast$ds)-nb_intervals+1):length(forecast$ds)]
    names_given <- TRUE
  }
  
  ## Replacing negative values by zeros in the forecast
  forecast$yhat[forecast$yhat<0] <- 0
  
  ## Adding line corresponding to prediction for the cbn
  predictions[,r] = forecast$yhat[(length(forecast$yhat)-nb_intervals+1):length(forecast$yhat)]
  
  r = r+1
  
}

## Giving rows of predictions dataframe the name of related cbns
colnames(predictions) <- cbns

options(digits = 0)			# number of digits to display

## Save predictions as csv file
write.csv(predictions, "C:/Travail A3/Projet d'option/Predictions_last_version/prediction_10.csv", row.names = TRUE)

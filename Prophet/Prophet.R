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





## Analysis of predictions made compared to real data
## Extracting and transforming real data for it to match format of predictions

predicted_data <- predictions

predicted_data[predicted_data<0] <- 0
pred_row <- as.POSIXct(row.names(predicted_data), format = "%Y-%m-%d %H:%M:%S")

## Getting real data to compare with predictions obtained previously
## Extracting only days corresponding to the ones predicted
newData <- read.csv("C:/Travail A3/Projet d'option/data_cleaned.csv",sep=",", header=TRUE,dec=".")
newData <- data[5088489:5522048,]

date <- newData$Date.de.passage
CBN <- newData$CBN

real_data <- data.frame(date,CBN)

# Cleaning and extracting data
real_data <- subset(real_data, real_data$CBN != 'CAB nul')
real_data <- subset(real_data, real_data$CBN != 'non trouvé')
real_data <- subset(real_data, real_data$CBN != 'ligne vide')
real_data <- subset(real_data, real_data$CBN != 'BRIN A')
real_data <- subset(real_data, real_data$CBN != 'BRIN B')


## Transforming real data for it to match row and columns of predictions
rdata <- data.frame(matrix(ncol = length(cbns) , nrow = length(pred_row)))

r <- 1
for (cbn in cbns){
  
  ds <- as.POSIXct(subset(real_data$date, real_data$CBN==cbn), format = "%Y-%m-%d %H:%M:%S")
  count <- rep(0,length(pred_row))
  
  ## Counting the number of elements per interval
  j <- 1
  i <- 1
  count[1] <- 0
  done <- FALSE
  
  while(j<length(pred_row)&!done){
    while(i<=length(ds)){
      if((ds[i]<=pred_row[j])){
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
  
  rdata[,r] <- count
  r <- r+1
}

colnames(rdata) <- cbns
row.names(rdata) <- pred_row

write.csv(rdata, "C:/Travail A3/Projet d'option/Predictions_last_version/real_10.csv", row.names = TRUE)



## Comparison with MAE, MSE, MAPE and Accuracy

real <- as.matrix(rdata)
pred <- as.matrix(predicted_data)

options(digits = 0)			# number of digits to display

MAE = mae(real,pred)
MSE = mse(real,pred)
MAPE = mape(real,pred)
Accuracy = accuracy(real,pred)
Acc = Accuracy*100

## Compare Top 30 cbns

top_size <- 30
top_cbns_predicted <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))
top_cbns <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))
nb_tops <- rep(0, length(pred_row))

## Here, order renders the indices of rows corresponding to cbns
for(inter in 1:length(pred_row)){
  top_cbns_predicted[inter,] <- order(pred[inter,], decreasing=TRUE)[1:top_size]
  top_cbns[inter,] <- order(real[inter,], decreasing=TRUE)[1:top_size]
  nb_tops[inter] <- length(intersect(top_cbns[inter,], top_cbns_predicted[inter,]))
}

row.names(top_cbns_predicted) <- pred_row
row.names(top_cbns) <- pred_row

## Printing the average number of cbns well predicted as in the top of the defined size
print(mean(nb_tops))



## Extracting names of top predicted cbns

predicted_cbns <- data.frame(matrix(ncol=top_size, nrow=length(pred_row)))

for (i in 1:length(pred_row)){
  for (j in 1:top_size){
    predicted_cbns[i,j] <- colnames(pred[top_cbns_predicted[i,j]])
  }
}

row.names(predicted_cbns) <- pred_row



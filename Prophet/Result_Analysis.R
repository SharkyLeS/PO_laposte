library(prophet)
library(gdata)
library(Metrics)
library(matrixStats)
library(ggplot2)
library(dplyr)

rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 0)			# number of digits to display


prediction <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction.csv",sep=",", header=TRUE,dec=".")
newData <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real.csv",sep=",", header=TRUE,dec=".")

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


## Comparison with MAE, MSE, MAPE and Accuracy

real <- as.matrix(rdata)
pred <- as.matrix(prediction)

Mae = mae(pred,real)
Mse = mse(pred,real)
Accuracy = accuracy(pred,real)

print(Mae, Mse, Accuracy)

################################## TOP 10 ###########################################

##COMPARE TOP CBNS WITH REAL DATA

pred_row <- pred$X
top_size <- 10 ## Number of top cbns to extract

top_cbns_predicted <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))
top_cbns <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))

nb_tops <- rep(0, length(pred_row))


## Here, order renders the indices of rows corresponding to cbns
for(inter in 1:length(pred_row)){
  top_cbns_predicted[inter,] <- order(pred[inter,], decreasing=TRUE)[1:top_size]
  top_cbns[inter,] <- order(real[inter,], decreasing=TRUE)[1:top_size]
  nb_tops[inter] <- length(intersect(as.numeric(top_cbns[inter,]), as.numeric(top_cbns_predicted[inter,])))
}

indexes <- rep(0, length(pred_row))
for (k in 1:length(pred_row)){
  if (top_cbns[k,1]==1 && top_cbns[k,2]==2 && top_cbns[k,3]==3 && top_cbns[k,4]==4 && top_cbns[k,5]==5 && top_cbns[k,6]==6 && top_cbns[k,7]==7 && top_cbns[k,8]==8 && top_cbns[k,9]==9 && top_cbns[k,10]==10){
    indexes[k] <- k
  }
}

## Remove rows where there are no top cbns (low traffic)
indexes <- indexes[!indexes==0]

nb_tops <- nb_tops[-c(indexes)]
top_cbns <- top_cbns[-c(indexes),]
top_cbns_predicted <- top_cbns_predicted[-c(indexes),]
pred_row <- pred_row[-c(indexes)]


## Get top 10 cbn (real and pred) names
predicted_cbns <- data.frame(matrix(ncol=top_size, nrow=length(pred_row)))
real_cbns <- data.frame(matrix(ncol=top_size, nrow=length(pred_row)))

for (i in 1:length(pred_row)){
  for (j in 1:top_size){
    predicted_cbns[i,j] <- colnames(pred[top_cbns_predicted[i,j]])
  }
}


for (i in 1:length(pred_row)){
  for (j in 1:top_size){
    real_cbns[i,j] <- colnames(real[top_cbns[i,j]])
  }
}

row.names(top_cbns_predicted) <- pred_row
row.names(top_cbns) <- pred_row
row.names(predicted_cbns) <- pred_row
row.names(real_cbns) <- pred_row

## Printing the average number of cbns well predicted as in the top of the
## defined size
print(mean(nb_tops))

## Printing top cbn names
print(predicted_cbns)
print(real_cbns)

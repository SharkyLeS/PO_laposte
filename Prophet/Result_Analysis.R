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
real_data <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real.csv",sep=",", header=TRUE,dec=".")

Mae = mae(prediction,real_data)
Mse = mse(prediction,real_data)
Accuracy = accuracy(prediction,real_data)

print(Mae, Mse, Accuracy)

################################## TOP 10 ###########################################

##COMPARE TOP CBNS WITH REAL DATA

pred_row <- prediction$X
top_size <- 10 ## Number of top cbns to extract

top_cbns_predicted <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))
top_cbns <- data.frame(matrix(ncol = top_size , nrow = length(pred_row)))

nb_tops <- rep(0, length(pred_row))


## Here, order renders the indices of rows corresponding to cbns
for(inter in 1:length(pred_row)){
  top_cbns_predicted[inter,] <- order(prediction[inter,], decreasing=TRUE)[1:top_size]
  top_cbns[inter,] <- order(real_data[inter,], decreasing=TRUE)[1:top_size]
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
    predicted_cbns[i,j] <- colnames(prediction[top_cbns_predicted[i,j]])
  }
}


for (i in 1:length(pred_row)){
  for (j in 1:top_size){
    real_cbns[i,j] <- colnames(real_data[top_cbns[i,j]])
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

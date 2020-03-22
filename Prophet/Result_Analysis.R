library(prophet)
library(gdata)
library(Metrics)
library(matrixStats)
library(ggplot2)
library(dplyr)

rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 0)			# number of digits to display


pred_1 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_1.csv",sep=",", header=TRUE,dec=".")
pred_2 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_2.csv",sep=",", header=TRUE,dec=".")
pred_3 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_3.csv",sep=",", header=TRUE,dec=".")
pred_4 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_4.csv",sep=",", header=TRUE,dec=".")
pred_6 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_6.csv",sep=",", header=TRUE,dec=".")
pred_7 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_7.csv",sep=",", header=TRUE,dec=".")
pred_8 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_8.csv",sep=",", header=TRUE,dec=".")
pred_9 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_9.csv",sep=",", header=TRUE,dec=".")
pred_10 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction_10.csv",sep=",", header=TRUE,dec=".")

real_1 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_1.csv",sep=",", header=TRUE,dec=".")
real_2 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_2.csv",sep=",", header=TRUE,dec=".")
real_3 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_3.csv",sep=",", header=TRUE,dec=".")
real_4 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_4.csv",sep=",", header=TRUE,dec=".")
real_6 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_6.csv",sep=",", header=TRUE,dec=".")
real_7 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_7.csv",sep=",", header=TRUE,dec=".")
real_8 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_8.csv",sep=",", header=TRUE,dec=".")
real_9 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_9.csv",sep=",", header=TRUE,dec=".")
real_10 <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real_10.csv",sep=",", header=TRUE,dec=".")


Mae = rep(0, 9)
Mse = rep(0, 9)
Mape = rep(0, 9)
Accuracy = rep(0, 9)


pred_1 <- pred_1[,3:257]
real_1 <- real_1[,2:257]
Mae[1] = mae(pred_1,real_1)
Mse[1] = mse(pred_1,real_1)
Accuracy[1] = accuracy(pred_1,real_1)

pred_2 <- as.matrix(pred_2[,2:259])
real_2 <- as.matrix(real_2[,2:259])
Mae[2] = mae(pred_2,real_2)
Mse[2] = mse(pred_2,real_2)
Accuracy[2] = accuracy(pred_2,real_2)

pred_3 <- as.matrix(pred_3[,2:261])
real_3 <- as.matrix(real_3[,2:261])
Mae[3] = mae(pred_3,real_3)
Mse[3] = mse(pred_3,real_3)
Accuracy[3] = accuracy(pred_3,real_3)

pred_4 <- as.matrix(pred_4[,2:261])
real_4 <- as.matrix(real_4[,2:261])
Mae[4] = mae(pred_4,real_4)
Mse[4] = mse(pred_4,real_4)
Accuracy[4] = accuracy(pred_4,real_4)

pred_6 <- as.matrix(pred_6[,2:261])
real_6 <- as.matrix(real_6[,2:261])
Mae[5] = mae(pred_6,real_6)
Mse[5] = mse(pred_6,real_6)
Accuracy[5] = accuracy(pred_6,real_6)

pred_7 <- as.matrix(pred_7[,2:261])
real_7 <- as.matrix(real_7[,2:261])
Mae[6] = mae(pred_7,real_7)
Mse[6] = mse(pred_7,real_7)
Accuracy[6] = accuracy(pred_7,real_7)

pred_8 <- as.matrix(pred_8[,2:261])
real_8 <- as.matrix(real_8[,2:261])
Mae[7] = mae(pred_8,real_8)
Mse[7] = mse(pred_8,real_8)
Accuracy[7] = accuracy(pred_8,real_8)

pred_9 <- as.matrix(pred_9[,2:261])
real_9 <- as.matrix(real_9[,2:261])
Mae[8] = mae(pred_9,real_9)
Mse[8] = mse(pred_9,real_9)
Accuracy[8] = accuracy(pred_9,real_9)

pred_10 <- as.matrix(pred_10[,2:261])
real_10 <- as.matrix(real_10[,2:261])
Mae[9] = mae(pred_10,real_10)
Mse[9] = mse(pred_10,real_10)
Accuracy[9] = accuracy(pred_10,real_10)

data_given = rep(0,9)

for (i in 1:4){
  data_given[i]=i
}

for (i in 5:9){
  data_given[i]=i+1
}

recap <- data.frame(data_given,Mae,Mse,Accuracy)

plot(data_given, Mse, type="b", col="green", lwd=2, pch=15, xlab="Number of months in input", ylab="Value")
plot(data_given, Mae, type="b", col="red", lwd=2, pch=19)
plot(data_given, Accuracy*100, type="b", col="blue", lwd=1)

################################## TOP 10 ###########################################

##COMPARE TOP CBNS WITH REAL DATA

pred_row <- pred_1$X

pred <- pred_1[,2:258]
real <- real_1[,1:257]

top_size <- 10

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

indexes <- indexes[!indexes==0]

nb_tops <- nb_tops[-c(indexes)]
top_cbns <- top_cbns[-c(indexes),]
top_cbns_predicted <- top_cbns_predicted[-c(indexes),]
pred_row <- pred_row[-c(indexes)]

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

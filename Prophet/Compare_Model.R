library(forecast)
library(Metrics)
library(dplyr)

#Comparason between real data and predicted data
rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 0)			# number of digits to display

#Defining parameters
#Defining interval between two predictions (in hours)
interval <- 1
nb_periods <- 30
nb_mois_donnees <- 1
nb_intervals <- nb_periods*24/interval

predicted_data <- predictions[,22:720]
real_data <- data[566514:1120460,]

pred_colonnes <- colonnes[22:720]

real_data$CBN <- gsub("/", "|", real_data$CBN)


#Cleaning and extracting data
real_data2 <- subset(real_data, real_data$CBN != 'CAB nul')
real_data2 <- subset(real_data2, real_data2$CBN != 'non trouvé')
real_data2 <- subset(real_data2, real_data2$CBN != 'ligne vide')

#cbns <- predicted_data

#col_interval <- as.POSIXct(col.names(predicted_data), format="%Y-%m-%d %H:%M:%S")


rdata <- data.frame(matrix(ncol = length(pred_colonnes) , nrow = length(cbns)))

names_given <- FALSE
colonnes_test <- as.POSIXct(pred_colonnes, format="%Y-%m-%d %H:%M:%S")

r <- 1 
for (cbn in cbns){
  
  ds <- as.POSIXct(subset(real_data2$Date.de.passage, real_data2$CBN==cbn), format = "%Y-%m-%d %H:%M:%S")
  
  #Aggregating number of letters interval per interval
  count <- rep(0,length(colonnes_test))
  begin_dates <- rep(colonnes_test[1],length(colonnes_test))
  
  #Make it a function ?
  #Counting the number of elements per interval
  j <- 1
  i <- 2
  count[1] <- 1
  begin_date <- colonnes_test[1]
  done <- FALSE
  
  while(j<length(colonnes_test)){
    if(!done){
      while(i<=length(ds)){
        if(ds[i]<=begin_date+interval*60*60){
          #count elements within the interval
          count[j] <- count[j]+1
          i = i+1
        }
        else{
          #consider new interval
          begin_date <- begin_date+interval*60*60
          j = j+1
          begin_dates[j] <- begin_date
        }
      }
      done <- TRUE
    }
    if(j<nb_intervals){
      begin_date <- begin_date+interval*60*60
      j = j+1
      begin_dates[j] <- begin_date
    }
  }
  
  count <- count[1:length(pred_colonnes)]
  begin_dates <- begin_dates[1:length(count)]
  
  
  #Giving required names to begin_dates and count
  ds <- begin_dates
  y <- count
  
  df <- data.frame(ds, y)
  
  if(!names_given){
    colnames(rdata) <- df$ds[(length(df$ds)-length(pred_colonnes)+1):length(df$ds)]
    colonnes_real <- colnames(rdata)
    names_given <- TRUE
  }
  #Adding line corresponding to prediction for the cbn
  rdata[r,] = df$y[(length(df$y)-length(pred_colonnes)+1):length(df$y)]
  r = r+1
  
}

row.names(rdata) <- cbns


predicted_data[predicted_data<0] <- 0

write.csv(predicted_data, "C:/Travail A3/Projet d'option/test/prediction_septembre.csv", row.names = TRUE, col.names = TRUE)

##CALCUL MAE, MSE, MAPE and accuracy

real <- as.matrix.data.frame(rdata)
pred <- as.matrix.data.frame(predicted_data)

##COMPARE TOP CBNS WITH REAL DATA


MAE = mae(real,pred)
MSE = mse(real,pred)
MAPE = mape(real,pred)
Accuracy = accuracy(real,pred)
Acc = Accuracy*100

metrics_octobre <- rbind(c(MAE,MSE,MAPE,Acc))
rownames(metrics_octobre) <- c("4 months of data")
colnames(metrics_octobre) <- c("MAE","MSE","MAPE","Accuracy")


##GET 30 TOP CBNS EVERY HOUR

top_cbns_predicted <- top_n(pred, 30)

for (i in range(1,720)){
  top_cbns_predicted[,i] <- order(pred[,i], decreasing=TRUE)[1:30]
  top_cbns[,i] <- order(real[,i], decreasing=TRUE)[1:30]
  
}




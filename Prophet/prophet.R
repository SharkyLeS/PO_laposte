## Importing necessary libraries

library(prophet)
library(gdata)
library(Metrics)
library(matrixStats)

rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 15)			# number of digits to display

## Defining parameters

## Defining interval between two predictions (in hours)
interval <- 0.25
## Number of periods to be predicted onwards (in days)
nb_periods <- 30
## Number of months given as input data
nb_mois_donnees <- 1
nb_intervals <- nb_periods*24/interval

## Reading data
data <- read.csv("E://PO_LAPOSTE/PO_laposte-master/august_processed.csv",sep=",", header=TRUE,dec=".")

## Cleaning and extracting data
cbns <- unique(data$CBN)

## Creating storage for all the predictions
predictions <- data.frame(matrix(ncol = nb_intervals , nrow = length(cbns)))

names_given <- FALSE

r <- 1 
for (cbn in cbns){

## Creating ds column to be used in prohet function
ds <- as.POSIXct(subset(data$date, data$CBN==cbn), format = "%Y-%m-%d %H:%M:%S")

## Aggregating number of letters interval per interval

## Creating storages for date intervals and number of elements registered
## per interval
count <- rep(0,nb_mois_donnees*30*24/interval)
begin_dates <- rep(ds[1],nb_mois_donnees*30*24/interval)

#Make it a function ?
## Counting the number of elements per interval
j <- 1
i <- 2
count[1] <- 1
begin_date <- ds[1]
done <- FALSE

## Passing through all the data in hands
while((j<nb_mois_donnees*30*24/interval)&!done){

## If not all the dates in the given data have been considered
## check wether the date is in the tested interval or not
while(i<=length(ds)){

if(ds[i]<=begin_date+interval*60*60){
## Count elements within the interval
count[j] = count[j]+1
i = i+1
}

else{
## Consider new interval
begin_date = ds[i]
j = j+1
begin_dates[j] = begin_date
}
}
done <- TRUE
}

## Truncating count and begin_dates
## This operation is necessary because the number of intervals retained
## is lower than the theoretical one
count = count[1:j]
begin_dates = begin_dates[1:j]

## Giving required names to begin_dates and count
ds <- begin_dates
y <- count

df <- data.frame(ds, y)

## Building model, fitting it and making predictions
## Put yearly.seasonality to TRUE in final model
m <- prophet(df,weekly.seasonality=TRUE, daily.seasonality=TRUE, yearly.seasonality=FALSE)

future <- make_future_dataframe(m, periods = nb_intervals, freq=3600*interval)

forecast <- predict(m, future)

#Save plot to machine
#png(filename=paste(paste("E://PO_LAPOSTE/PO_laposte-master/plot_CBN_August/", cbn, sep=""), ".png", sep=""))
#plot(m,forecast)
#dev.off()

#prophet_plot_components(m, forecast)

## Storing results for every cbn in a global dataframe
## Caution : take care of the ds column : dates must be the same for every cbn

## Creating columns with dates if not already made
if(!names_given){
colnames(predictions) = forecast$ds[(length(forecast$ds)-nb_intervals+1):length(forecast$ds)]
names_given <- TRUE
}

## Replacing negative values by zeros in the forecast
forecast$yhat[forecast$yhat<0] <- 0

## Adding line corresponding to prediction for the cbn
predictions[r,] = forecast$yhat[(length(forecast$yhat)-nb_intervals+1):length(forecast$yhat)]

## Storing model for later use
## Changing names of df columns for easier storage
colnames(df) = c(paste("ds_",cbn,sep=""),paste("y_",cbn,sep=""))

## Do not store models (really difficult) but rather store dfs
## The cbindX functions copes with the issue of having dfs of different
## shapes by adding NAs to missing values
if(r==1){d <- df}
else{d = cbindX(d,df)}
r = r+1

}

## Giving rows of predictions dataframe the name of related cbns
row.names(predictions) <- cbns

## Calculating metrics in order to assess model's performance

## Getting real data
real_data <- read.csv("E://PO_LAPOSTE/PO_laposte-master/september_processed.csv",sep=",", header=TRUE,dec=".")

## Calculating number of parcels for each interval defined in preds,
## and this on the real data, to be used for comparison between predictions
## and reality

## Converting dates to POSIXct in real_data
real_data$date = as.POSIXct(real_data$date, format = "%Y-%m-%d %H:%M:%S")

reals <- data.frame(1:nb_intervals)
for(cbn in cbns){
real <- rep(0, nb_intervals)
real_data_cbn <- subset(real_data, real_data$CBN==cbn)
if(length(real_data_cbn$date)>0){
cols <- as.POSIXct(colnames(predictions), format = "%Y-%m-%d %H:%M:%S")

## Indicator telling if we've already seen all the data or not
l <- 1
## Executing loop on each interval
for(k in 1:length(cols)){
while((real_data_cbn$date[l]<cols[k])&(l<=length(real_data_cbn$date))){

## Counting number of values registered within the interval
real[k] = real[k]+1
l = l+1
}
if(l>length(real_data_cbn$date)){break}
}
}
reals[[paste("y_",cbn,sep="")]] = real
}

## Calculating indicators

#Maybe do this as matrices then calculate indicators for all cbns rather 
#than one by one
Mae = rep(0, length(cbns))
Mse = rep(0, length(cbns))
Mape = rep(0, length(cbns))
ACcuracy = rep(0, length(cbns))

for(line in 1:length(cbns)){
really <- reals[[paste("y_",cbns[line],sep="")]]
pred <- as.numeric(predictions[line,])
MAE = mae(pred,real)
Mae[line] = MAE
MSE = mse(pred,real)
Mse[line] = MSE
MAPE = mape(pred,real)
Mape[line] = MAPE
Accuracy = accuracy(pred,real)
ACcuracy[line] = Accuracy
#print(c("MAE",MAE,"MSE",MSE,"MAPE",MAPE,"Accuracy",Accuracy))
}

top_size <- 30
top_cbns_predicted <- data.frame(matrix(ncol = nb_intervals , nrow = top_size))
top_cbns <- data.frame(matrix(ncol = nb_intervals , nrow = top_size))
nb_tops <- rep(0, nb_intervals)

## Here, order renders the indices of rows corresponding to cbns
for(inter in 1:nb_intervals){
top_cbns_predicted[,inter] <- order(predictions[,inter], decreasing=TRUE)[1:top_size]
top_cbns[,inter] <- order(reals[inter,], decreasing=TRUE)[1:top_size]
nb_tops[inter] <- length(intersect(top_cbns[,inter], top_cbns_predicted[,inter]))
}

colnames(top_cbns_predicted) <- colnames(predictions)
colnames(top_cbns) <- colnames(predictions)

## Printing the average number of cbns well predicted as in the top of the
## defined size
print(mean(nb_tops))

## Counting number of cbns in both predictions and reals for each interval

print(c("Average_MAE",mean(Mae),"Average_MSE",mean(Mse),"Average_MAPE",mean(Mape),"Average_Accuracy",mean(ACcuracy)))

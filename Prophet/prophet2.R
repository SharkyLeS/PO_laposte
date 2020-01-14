library(prophet)

rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 15)			# number of digits to display

#Defining parameters
#Defining interval between two predictions (in hours)
interval <- 0.25
nb_periods <- 30
nb_mois_donnees <- 1
nb_intervals <- nb_periods*24/interval

data <- read.csv("E://PO_LAPOSTE/PO_laposte-master/data_18_19_clean.csv",sep=",", header=TRUE,dec=".") #read the data

#This line is put in order to get data only for August
#Later on, data cleaning must be done before, so that this line is removed
data <- data[1:451362,]

#Changing "/" to "|" in cbn names so that they can be used in storage path
data$CBN <- gsub("/", "|", data$CBN)

#Cleaning and extracting data
data2 <- subset(data, data$CBN != 'CAB nul')

cbns <- unique(data2$CBN)

#Creating storage for all the predictions
predictions <- data.frame(matrix(ncol = nb_intervals , nrow = length(cbns)))
names_given <- FALSE

#for (cbn in cbns){

#y <- subset(data2$CBN, data2$CBN==cbns[5])
ds <- as.POSIXct(subset(data2$Date.de.passage, data2$CBN==cbns[5]), format = "%Y-%m-%d %H:%M:%S")

#Aggregating number of letters interval per interval
count <- rep(0,nb_mois_donnees*30*24/interval)
begin_dates <- rep(ds[1],nb_mois_donnees*30*24/interval)

#Make it a function ?
#Counting the number of elements per interval
j <- 1
i <- 2
count[1] <- 1
begin_date <- ds[1]
done <- FALSE

while(j<nb_mois_donnees*30*24/interval){
if(!done){
while(i<=length(ds)){
if(ds[i]<=begin_date+interval*60*60){
#count elements within the interval
count[j] <- count[j]+1
i = i+1
}
else{
#consider new interval
begin_date <- ds[i]
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

#Truncating count and begin_dates
#This operation is necessary because the number of intervals retained
#is lower than the theoretical one
count <- subset(count, count!=0)
begin_dates <- begin_dates[1:length(count)]

#Giving required names to begin_dates and count
ds <- begin_dates
y <- count

df <- data.frame(ds, y)

#Building model, fitting it and making predictions
#Put yearly.seasonality to TRUE in final model
m <- prophet(df,weekly.seasonality=TRUE, daily.seasonality=TRUE, yearly.seasonality=FALSE)

future <- make_future_dataframe(m, periods = nb_intervals, freq=3600*interval)

forecast <- predict(m, future)
#tail(forecast[c('ds','yhat','yhat_lower','yhat_upper')])

#Save plot to machine
#png(filename=paste(paste("E://PO_LAPOSTE/PO_laposte-master/plot_CBN_August/", cbn, sep=""), ".png", sep=""))
plot(m,forecast)
#dev.off()

#prophet_plot_components(m, forecast)

#Storing results for every cbn in a global dataframe
#Caution : take care of the ds column : dates must be the same for every cbn
#Creating columns with dates if not already made
if(!names_given){
colnames(predictions) <- begin_dates[length(begin_dates)-nb_intervals:length(begin_dates)]
names_given <- TRUE
}
#Adding line corresponding to prediction for the cbn
predictions[r,] = forecast$yhat[(length(forecast$yhat)-nb_intervals+1):length(forecast$yhat)]

#}

#Giving rows of predictions dataframe the name of related cbns
row.names(predictions) <- cbns
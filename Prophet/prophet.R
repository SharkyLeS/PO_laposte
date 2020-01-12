library(prophet)


rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 15)			# number of digits to display

setwd("C:/Projet d'option/test")
data <- read.csv("C:/Travail A3/Projet d'option/test/AOUT.csv",sep=",", header=TRUE,dec=".") #read the data
head(data)

data2 <- subset(data, data$Date.de.passage != 0)
summary(data2)


y <- data2$CBN
ds <- as.POSIXct(data2$Date.de.passage, format = "%Y-%m-%d %H:%M:%S")

df <- data.frame(ds, y)

m <- prophet(df)

future <- make_future_dataframe(m, periods = 365)
tail(future)
tail(m)


forecast <- predict(m, future)
tail(forecast[c('ds','yhat','yhat_lower','yhat_upper')])

plot(m,forecast)

prophet_plot_components(m, forecast)
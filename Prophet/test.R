library(dplyr)
library(ggplot2)
library(dummies)
library(purrr)
library(cluster)
library(dendextend)
library(tibble)
library(tidyr)
library(lubridate)
library(broom)
library(tidyverse)
library(data.table)
library(corrplot)
library(heatmaply)


rm(list=ls())				# clear the list of objects
graphics.off()				# clear the list of graphs
options(digits = 15)			# number of digits to display

setwd("C:/Projet d'option/test")
data <- read.csv("C:/Travail A3/Projet d'option/test/JUILLET liste bac.csv",sep=",", header=TRUE,dec=".") #read the data
head(data)

data_cleanup <- subset(data, data$CAB != 0)
summary(data_cleanup)


destination <- data[,6]
date_passage <- as.POSIXct(data$Date.de.passage, format = "%Y-%m-%d %H:%M:%S")
jour <- as.numeric(format(date_passage,"%d"))
heure <- as.numeric(format(date_passage,"%H"))
destination2 <- as.numeric(destination)
contenant <- data$Contenant
new_table <- data.frame(destination2,jour,heure,contenant)
new_table

freq(new_table)
barplot(new_table, aes(jour,heure))
new_table$jour


if (new_table$jour == 23) {
	data2 <- merge(destination,heure)
}

ggplot(data2) +
  geom_count(mapping = aes ( x= heure, y = destination, color = "freq"))




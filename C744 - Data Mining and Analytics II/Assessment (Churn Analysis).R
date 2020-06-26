setwd("~/Desktop/WGU")
  
library(plyr)
library(corrplot)
library(ggplot2)
library(gridExtra)
library(ggthemes)
library(caret)
library(MASS)
library(randomForest)
library(party)
library(mclust)
  
data <- read.csv('WA_Fn-UseC_-Telco-Customer-Churn.csv')
  
######################################    DATA CLEANING   #######################################
  
sapply(data, function(x) sum(is.na(x))) #check for missing values.
cols_recode1 <- c(10:15)
  
#Change 'No internet service' to 'No'
for(i in 1:ncol(data[,cols_recode1])) {
  data[,cols_recode1][,i] <- as.factor(mapvalues(data[,cols_recode1][,i], from =c("No internet service"),to=c("No")))
}
  
#Change 'No phone service' to 'No'
data$MultipleLines <- as.factor(mapvalues(data$MultipleLines, from=c("No phone service"), to=c("No")))
  
#Group tenure into 5 groups by month
min(data$tenure)
max(data$tenure)

#Change tenure to a factor variable
data$tenureGroups <- cut(data$tenure, 
                          breaks=c(0, 12, 24, 48, 60, Inf), 
                          include.lowest=TRUE, 
                          labels=c("0-12","12-24","24-48","48-60", ">60"))
data$tenureGroups <- as.factor(data$tenureGroups)
  
#Change 0's and 1's to 'No' and 'Yes'
data$SeniorCitizen <- as.factor(mapvalues(data$SeniorCitizen,
                                             from=c("0","1"),
                                             to=c("No", "Yes")))

#Remove columns that aren't going to be used for the analysis
data$customerID <- NULL
data$tenure <- NULL


cluster <- Mclust(data[,-1])
partion <- createDataPartion
model <- glm(Churn ~ . )
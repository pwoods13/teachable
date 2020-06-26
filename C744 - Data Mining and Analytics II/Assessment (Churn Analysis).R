setwd("~/Desktop/WGU/C744 - Data Mining and Analytics II")

#install.packages('plyr')
#install.packages('corrplot')
#install.packages('ggplot2')
#install.packages('gridExtra')
#install.packages('ggthemes')
#install.packages('caret')
#install.packages('MASS')
#install.packages('randomForest')
#install.packages('party')
#install.packages('mclust')
#install.packages('FactoMineR')
#install.packages('missMDA')
#install.packages('xlsx')
  
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
library(FactoMineR)
library(missMDA)
library(xlsx)
  
data <- read.csv('WA_Fn-UseC_-Telco-Customer-Churn.csv')
  
######################################    DATA CLEANING   #######################################
  
sapply(data, function(x) sum(is.na(x))) #check for missing values.
cols_recode1 <- c(10:15)
data <- data[complete.cases(data), ]

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
#Convert character variables to factors
data$gender <- as.factor(data$gender)
data$Partner <- as.factor(data$Partner)
data$Dependents <- as.factor(data$Dependents)
data$PhoneService <- as.factor(data$PhoneService)
data$InternetService <- as.factor(data$InternetService)
data$Contract <- as.factor(data$Contract)
data$PaperlessBilling <- as.factor(data$PaperlessBilling)
data$PaymentMethod <- as.factor(data$PaymentMethod)
data$Churn <- as.factor(data$Churn)

#Remove columns that aren't going to be used for the analysis
data$customerID <- NULL
data$tenure <- NULL

#Export cleaned data set
write.xlsx(data, 
           "Clean Data.xlsx", 
           sheetName = "Clean Data", 
           col.names = TRUE, 
           row.names = FALSE,
           append = FALSE
           )

############################     Exploratory Data Analysis      #################################

numeric.var <- sapply(data, is.numeric)
corr.matrix <- cor(data[,numeric.var])
corrplot(corr.matrix, main="\n\nCorrelation Plot for Numerical Variables", method="number")
data$TotalCharges <- NULL #TotalCharges and Monthly Charges are highly correlated

p1 <- ggplot(data, aes(x=gender)) + ggtitle("Gender") + xlab("Gender") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p2 <- ggplot(data, aes(x=SeniorCitizen)) + ggtitle("Senior Citizen") + xlab("Senior Citizen") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p3 <- ggplot(data, aes(x=Partner)) + ggtitle("Partner") + xlab("Partner") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p4 <- ggplot(data, aes(x=Dependents)) + ggtitle("Dependents") + xlab("Dependents") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
  grid.arrange(p1, p2, p3, p4, ncol=2)
p5 <- ggplot(data, aes(x=PhoneService)) + ggtitle("Phone Service") + xlab("Phone Service") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p6 <- ggplot(data, aes(x=MultipleLines)) + ggtitle("Multiple Lines") + xlab("Multiple Lines") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p7 <- ggplot(data, aes(x=InternetService)) + ggtitle("Internet Service") + xlab("Internet Service") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p8 <- ggplot(data, aes(x=OnlineSecurity)) + ggtitle("Online Security") + xlab("Online Security") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
  grid.arrange(p5, p6, p7, p8, ncol=2)
p9 <- ggplot(data, aes(x=OnlineBackup)) + ggtitle("Online Backup") + xlab("Online Backup") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p10 <- ggplot(data, aes(x=DeviceProtection)) + ggtitle("Device Protection") + xlab("Device Protection") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p11 <- ggplot(data, aes(x=TechSupport)) + ggtitle("Tech Support") + xlab("Tech Support") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p12 <- ggplot(data, aes(x=StreamingTV)) + ggtitle("Streaming TV") + xlab("Streaming TV") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
  grid.arrange(p9, p10, p11, p12, ncol=2)
p13 <- ggplot(data, aes(x=StreamingMovies)) + ggtitle("Streaming Movies") + xlab("Streaming Movies") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p14 <- ggplot(data, aes(x=Contract)) + ggtitle("Contract") + xlab("Contract") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p15 <- ggplot(data, aes(x=PaperlessBilling)) + ggtitle("Paperless Billing") + xlab("Paperless Billing") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p16 <- ggplot(data, aes(x=PaymentMethod)) + ggtitle("Payment Method") + xlab("Payment Method") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
p17 <- ggplot(data, aes(x=tenureGroups)) + ggtitle("Tenure Group") + xlab("Tenure Group") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
  grid.arrange(p13, p14, p15, p16, p17, ncol=2)

#########################     Logistic Regression      ##########################
  
#Partition Data
sample <- sample.int(n = nrow(data), size = floor(.7 * nrow(data)), replace = F)
train <- data[sample, ]
test  <- data[-sample, ]
dim(train); dim(test)
  
#Fit logistic regression model
ChurnLogRegression <- glm(train$Churn ~ ., family = binomial(link = 'logit'), data = train)
summary(ChurnLogRegression)

#Analyze most impactful variables
anova(ChurnLogRegression, test="Chisq") #InternetService, Contract, and tenureGroups appear to have the greatest impact on deviance.

#Assess predictability
test$Churn <- as.character(test$Churn)
test$Churn[test$Churn=="No"] <- 0
test$Churn[test$Churn=="Yes"] <- 1
fitted.results <- predict(ChurnLogRegression, newdata=test, type = 'response')
                          #fitted.results(0.5, 1, 0))
mean(predict(ChurnLogRegression, train) == test$Churn)
misClasificError <- mean(fitted.results != test$Churn)
print(paste('Logistic Regression Accuracy', 1 - misClasificError))

#PCA 
PCA <- imputePCA(as.numeric(as.matrix(data)), graph = FALSE)


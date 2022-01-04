library(caret)
library(klaR)
load("~/JobChanges.RData")

#Tranforming variables
data$training_hours<-log(data$training_hours)                       # log training hours
data$experience<-cut(data$experience, breaks=c(0,2,5,10,20,Inf),    # splitting experience
                     labels = c("0-2", "3-5","6-10","11-20","21+"), 
                     include.lowest = TRUE)

set.seed(400)                                                       # set seed
trainRowNumbers <- createDataPartition(data$target, p=0.8, list=FALSE)
trainData <- data[trainRowNumbers,]                                 # split data 80/20
testData <- data[-trainRowNumbers,]

quantile(trainData$city_development_index)                          # check quartiles
# cutoffs according to quartiles
trainData$city_development_index<-cut(trainData$city_development_index, 
                                      breaks=c(0,0.624,0.794,0.920,1), 
                                      labels = c("Low", "Medium","High","Very High"))
testData$city_development_index<-cut(testData$city_development_index, 
                                     breaks=c(0,0.624,0.794,0.920,1), 
                                     labels = c("Low", "Medium","High","Very High"))

train_control <- trainControl(                                      # set 10-fold cv
  method = "cv", 
  number = 10,
  verboseIter = T
)
#Naïve Bayes using caret
set.seed(400)
nb <- train(y = trainData$target,
            x = trainData[,1:10],
            method = "nb",
            trControl = train_control,
            tuneGrid = expand.grid(
              usekernel = FALSE,           # not using kernel density estimator (KDE)
              fL = 1,                      # set Laplace smoothing factor to 1
              adjust = 0)                  # adjust is set to 0 as KDE is not used
)                                             

pred <- predict(nb, testData)                 # prediction on test set
confusionMatrix(pred, testData$target, positive = "1")  # confusion matrix for evaluation
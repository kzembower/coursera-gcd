## First draft of Getting and Cleaning Data -- Course Project.

## Get the data file:
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
destfile <- 'dataset.zip'

download.file(url, destfile=destfile, 'curl')

dateDownloaded <- date()
dateDownloaded

unzip(destfile)

datasetDir <- 'UCI HAR Dataset'
list.files(datasetDir)


## Read the activity labels:
act.labels <- read.table(paste(datasetDir, 'activity_labels.txt', sep='/'),
                         col.names=c('actcode', 'activity'),
                         colClasses=c('integer', 'character')
                         )

## Read the column heads:
measure.labels <-  read.table(paste(datasetDir, 'features.txt', sep='/'),
                              col.names=c('measurementcol', 'measurement'),
                              colClasses=c("integer", "character"),
                              quote="",
                         )

## Read the testing dataset
datasetDir.test <- paste(datasetDir, 'test', sep='/')
## list.files(datasetDir.test)

Xtest.txt <- read.table(paste(datasetDir.test, 'X_test.txt', sep='/'),
                        header=FALSE,
                        col.names=measure.labels$measurement)

subtest <- read.table(paste(datasetDir.test, 'subject_test.txt', sep='/'),
                        header=FALSE)
activitytest <- read.table(paste(datasetDir.test, 'y_test.txt', sep='/'),
                        header=FALSE)
## Combine columns for overall testing dataframe:
test.df <- cbind(subtest, activitytest, Xtest.txt)
colnames(test.df)[1] <- "subject"
colnames(test.df)[2] <- "activity"

## Read the training dataset
datasetDir.train <- paste(datasetDir, 'train', sep='/')
## list.files(datasetDir.train)

Xtrain.txt <- read.table(paste(datasetDir.train, 'X_train.txt', sep='/'),
                         header=FALSE,
                         col.names=measure.labels$measurement)

subtrain <- read.table(paste(datasetDir.train, 'subject_train.txt', sep='/'),
                        header=FALSE)
activitytrain <- read.table(paste(datasetDir.train, 'y_train.txt', sep='/'),
                        header=FALSE)
## Combine columns for overall training dataframe:
train.df <- cbind(subtrain, activitytrain, Xtrain.txt)
colnames(train.df)[1] <- "subject"
colnames(train.df)[2] <- "activity"

## Combine testing and training into one dataframe:
Xtall <- rbind(test.df, train.df)

## Convert the activity numeric codes into textual factors:
## levels(Xtall$activity) <- list("1" = "WALKING",
##                                   "2" = "WALKING_UPSTAIRS",
##                                   "3" = "WALKING_DOWNSTAIRS",
##                                   "4" = "SITTING",
##                                   "5" = "STANDING",
##                                   "6" = "LAYING")
##

## Trying to do it without hard coding:
Xtall$activity <- as.factor(act.labels$activity[Xtall$activity])

## Not available in R 3.0.2:
## library(dplyr)

## Find all the fields that have 'mean' in the name:
meancols <- grep(".*mean.*", colnames(Xtall), perl=TRUE)

## Find all the fields with 'std' in the name:
stdcols <- grep(".*std.*", colnames(Xtall), perl=TRUE)

## Extract the means of each measurement:
Xtall.means <- colMeans(Xtall[, 3:563])
## transpose the df:
Xtall.means <- t(Xtall.means)

## Extract only the standard deviation from each measurement:
Xtall.sd <- apply(Xtall[, 3:563], 2, sd)
## transpose the df:
Xtall.sd <- t(Xtall.sd)

Xtall.summary <- merge(Xtall.means, Xtall.sd) 

write.table(Xtall.summary, file="project.summary.txt", rownames=FALSE)

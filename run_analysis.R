setwd("C:/RAM/DSP/R/Getting-and-Cleaning-Data-Course-Project")

 # Download the file and put the file in the data folder
 if(!file.exists("./data")){dir.create("./data")}
 download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./data/Dataset.zip")

# Unzip the file
 unzip(zipfile="./data/Dataset.zip",exdir="./data")


 path_rf <- file.path("./data" , "UCI HAR Dataset")
 files<-list.files(path_rf, recursive=TRUE)
# files

# a) Read Train & Test files 
# b) Merges the training and the test sets to create one data set.
subTrainData <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subTestData  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
actTrainData <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
actTestData  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
featTrainData <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
featTestData  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)

subData <- rbind(subTrainData, subTestData)
actData<- rbind(actTrainData, actTestData)
featData<- rbind(featTrainData, featTestData)

names(subData)<-c("subject")
names(actData)<- c("activity")
featDataNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(featData)<- featDataNames$V2

subActData <- cbind(subData, actData)
Data <- cbind(featData, subActData)

# Extract only the measurements on the mean and standard deviation for each measurement. 
featSubData<-featDataNames$V2[grep("mean\\(\\)|std\\(\\)", featDataNames$V2)]
selCols<-c(as.character(featSubData), "subject", "activity" )
Data<-subset(Data,select=selCols)

# str(Data)
# Use descriptive activity names to name the activities in the data set
actLabls <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
Data$activity <- factor(Data$activity, levels = actLabls[,1], labels = actLabls[,2])
Data$subject <- as.factor(Data$subject)


# Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# prepare tidy.set
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

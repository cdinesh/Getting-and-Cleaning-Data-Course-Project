##########################################################################################################

## Coursera Getting and Cleaning Data Course Project
## Dinesh Choudhari
## 02/28/2016

# run_analysis.r File Description:

# This scripts get and clean the Human Activity Recongination Data from UCI website 
# Note. This scripts first checks and create appropriate directory in working directory 
# to download and unzip dataset.

# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

##########################################################################################################

# Set working directory
setwd("~/Desktop/Coursera")

# Check and create data directory and download files
if(!file.exists("./HARdata")){dir.create("./HARdata")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./HARdata/Dataset.zip",method="curl")

# Unzip and extract files from "UCI HAR dataset" folder
unzip(zipfile="./HARdata/Dataset.zip",exdir="./HARdata")
path_rf <- file.path("./HARdata" , "UCI HAR Dataset")

# check the list of files in the unzipped folder.
files<-list.files(path_rf, recursive=TRUE)

# read the file data to appropriate descriptive variables -- See codebook.Rmd for futher details.
# Test and Train Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Test and Train subject files.
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Test and Train Feature files.
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

# 1. Below code is the actual steps that is required to merge the train and test data to create single dataset.
# Rbind data tables
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#Variable Names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#2. Extracts only the measurements on the mean and standard deviation for each measurement.
# Takes names of features with mean() and std()
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# Data frame data by selected names fo Feature from above
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#3. Uses descriptive activity names to name the activities in the data set
#Descriptive activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

#4. Appropriately labels the data set with descriptive variable names.

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean) 
Data2<-Data2[order(Data2$subject,Data2$activity),] 

#Write second tidy data set to file tidydata.txt
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


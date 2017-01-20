############################################################################################################
## The following script will:                                                                             ##
## 1. Downloads & extracts (if neccesary) the data set.                                                   ##
## 2. Merge the training and the test sets to create one data set.                                        ##
## 3. Extract only the measurements on the mean and standard deviation for each measurement.              ##
## 4. Use descriptive activity names to name the activities in the data set                               ##
## 5. Appropriately label the data set with descriptive variable names.                                   ##
## 6. Create a second tidy data set with the average of each variable for each activity and each subject. ##
############################################################################################################

# Clean up workspace
rm(list=ls())

# Set the URL and location to save the dataset
URL1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file1 <- file.path(getwd(),"Dataset.zip")

# Check if the dataset has been downloaded and if not get it
if (!file.exists(file1)){
download.file(URL1,file1)
}
# If the dataset hasn't been extracted do it
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Get the activity labels and the field names
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
labels[,2] <- as.character(labels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Clean up the field names to make them more readable
mean_sdev <- grep(".*mean.*|.*std.*", features[,2])
mean_sdev.names <- features[mean_sdev,2]
mean_sdev.names <- gsub("\\()","",mean_sdev.names)
mean_sdev.names <- gsub("\\-","",mean_sdev.names)
mean_sdev.names <- gsub("[Mm]ean","Mean",mean_sdev.names)
mean_sdev.names <- gsub("[Ss]td","StdDev",mean_sdev.names)

# load in the training data for fields matching "mean" or "std"
training <- read.table("UCI HAR Dataset/train/X_train.txt")[mean_sdev]
trainingActs <- read.table("UCI HAR Dataset/train/y_train.txt")
trainingSubs <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingSubs,trainingActs,training)

# Same again for test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[mean_sdev]
testActs <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubs <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubs,testActs,test)

# merge the two datasets together
data <- rbind(training,test)
colnames(data) <- c("subjectID", "activity", mean_sdev.names)

# Calculate the mean for each field for each subject & activity combination
tidydata <- aggregate(data,by = list(data$activity,data$subjectID),mean)

# Replace activityIDs with activity labels
tidydata$activity <- factor(tidydata$activity, levels = labels[,1], labels = labels[,2])

# get rid of the two grouping variables at the start of the new dataset - I'm sure there's better way but this works...
drops <- c("Group.1","Group.2")
tidydata <- tidydata[ , !(names(tidydata) %in% drops)]

# Output the final tidydata dataset
write.table(tidydata, './tidydata.txt',row.names=FALSE)
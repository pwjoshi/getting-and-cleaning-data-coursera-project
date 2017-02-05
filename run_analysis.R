library(reshape2)
library(RCurl)

# set working directory 
setwd("C:\\Coursera\\project")

sUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
sFilename <- "getdata_dataset.zip"
sMethod <- "libcurl"

if (!file.exists(sFilename)){
  download.file(sUrl, sFilename, sMethod, quiet = TRUE, mode = "wb", cacheOK = TRUE)
  sprintf("Download completed : %s", sFilename)
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(sFilename) 
  sprintf("Unzipping : %s", sFilename)
}

sProjectWD <- getwd()
sProjectName <- "UCI HAR Dataset"
sProjectHome <- paste(sProjectWD, sProjectName, sep="/")
sProjectOutputFile <- "tidy.txt"

setwd(sProjectHome)
getwd() 

# Load activity labels
actLabels <- read.table("activity_labels.txt")
actLabels[,2] <- as.character(activityLabels[,2])

# Load features
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

# Mean and Standard Deviation data extract  
sFeatureExtract <- grep(".*mean.*|.*std.*", features[,2])
sFeatureExtract.names <- features[sFeatureExtract,2]
sFeatureExtract.names = gsub('-mean', 'Mean', sFeatureExtract.names)
sFeatureExtract.names = gsub('-std', 'Std', sFeatureExtract.names)
sFeatureExtract.names <- gsub('[-()]', '', sFeatureExtract.names)

# Read the Training sets/labels, activities, and subject
# merge into one Training data 
trnSetLabel <- read.table("train/X_train.txt")[sFeatureExtract]
trnActivities <- read.table("train/Y_train.txt")
trnSubjects <- read.table("train/subject_train.txt")
trnData <- cbind(trnSubjects, trnActivities, trnSetLabel)

# Read the Test sets/labels, activities, and subject
# merge into one Test data 
tstSetLabel <- read.table("test/X_test.txt")[sFeatureExtract]
tstActivities <- read.table("test/Y_test.txt")
tstSubjects <- read.table("test/subject_test.txt")
tstData <- cbind(tstSubjects, tstActivities, tstSetLabel)

# Merge the training and the test sets to create one data set
mData <- rbind(trnData, tstData)
colnames(mData) <- c("subject", "activity", sFeatureExtract.names)

# Convert activities and subject into categorical factors  
mData$activity <- factor(mData$activity, levels = actLabels[,1], labels = actLabels[,2])
mData$subject <- as.factor(mData$subject)

# Transform data from wide to long format (molten data) for easy to work with using melt()
mData.wtol <- melt(mData, id = c("subject", "activity"))

# Re-shape the molten data a data frame usng dcast  
mData.mean <- dcast(mData.wtol, subject + activity ~ variable, mean)

# Create a project output dataset file -- tidy.txt    
write.table(mData.mean, sProjectOutputFile, row.names = FALSE, quote = FALSE)





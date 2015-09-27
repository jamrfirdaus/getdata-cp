library(reshape2)

# Download and unzip the dataset
filename <- "UCI_HAR_Dataset.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists(filename)){download.file(fileURL, filename, method="curl")}  
if (!file.exists("UCI HAR Dataset")){unzip(filename)}

# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names.
# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[ , 2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[ , 2])

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# Extract only the data on mean and standard deviation
meansd <- grep(".*mean.*|.*std.*", features[ , 2])
meansd.names <- features[meansd, 2]
meansd.names = gsub('-mean', 'Mean', meansd.names)
meansd.names = gsub('-std', 'Std', meansd.names)
meansd.names <- gsub('[-()]', '', meansd.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[meansd]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[meansd]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# 1. Merges the training and the test sets to create one data set.
# Merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", meansd.names)

# Turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[ , 1], labels = activityLabels[ , 2])
allData$subject <- as.factor(allData$subject)

# 5. Independent tidy data set with the average of each variable for each activity and each subject.
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

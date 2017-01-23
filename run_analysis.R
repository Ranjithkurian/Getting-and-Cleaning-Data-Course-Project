# Getting-and-Cleaning-Data-Course-Project
#download the file
if(!file.exists("data")) {dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filepath <- file.path(getwd(),"/data/Dataset.zip")
download.file(fileUrl,filepath)

#unzip the file
unzip(zipfile="data/Dataset.zip",exdir = "./data")

#get the list of files
path <- file.path("./data","UCI HAR Dataset")
files <- list.files(path,recursive = TRUE)
files

#we will use Activity, Subject and Features as part of descriptive variable names for data in data frame

#Read the Activity files
dataActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files
dataSubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

#Read Fearures files
dataFeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#If interested you can look at the properties of the above varibles one after the other 
  #str(dataActivityTest)
  #str(dataActivityTrain)
  #str(dataSubjectTrain)
  #str(dataSubjectTest)
  #str(dataFeaturesTest)
  #str(dataFeaturesTrain)

#1)Merges the training and the test sets to create one data set

#Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Merge columns to get the data frame
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#2)Extracts only the measurements on the mean and standard deviation for each measurement

#pull all the variables that contains Mean or Std
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#subset the datafram
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

str(Data)

#3)Uses descriptive activity names to name the activities in the data set

#Read descriptive activity names from "activity_labels.txt"

activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

head(activityLabels)

# Create column names for activity labels
colnames(activityLabels)<- c("activity","activityname")

# Add the activity label to the dataset using a merge on activityid
Data <- merge(x=Data, y=activityLabels, by="activity")

Data <- select(Data,-activity)

#4)Appropriately labels the data set with descriptive variable names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

#5)From the data set in step 4, creates a second, 
#independent tidy data set with the average of each variable for each activity and each subject.

# Create a datafram table (Dplyr)
tidy <- tbl_df(Data)

# Group the data by subject and activity
tidygroup <-group_by(tidy, subject, activityname)

# Calculate the mean for all features using a Dplyr function
tidymean <- summarise_each(tidygroup, funs(mean))


# Check the first 10 rows and 6 columns
tidymean[1:10, 1:6]

# Create tidy dataset from step 5
write.table(tidymean, file="tidy.txt", row.names=FALSE, col.names=TRUE, quote=TRUE)

## Merges the training and test sets to create one set

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "UCI HAR Dataset.zip")
unzip("UCI HAR Dataset.zip") # automatically creates the "UCI HAR Dataset
setwd("UCI HAR Dataset")

activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
X_train <- read.table("train/X_train.txt") # Training set.
y_train <- read.table("train/y_train.txt") # Training labels.
X_test  <- read.table("test/X_test.txt") # Test set.
y_test  <- read.table("test/y_test.txt") # Test labels.
subject_train <- read.table(file.path("train","subject_train.txt"))
subject_test  <- read.table(file.path("test","subject_test.txt"))

# setup for merge
measures <- bind_rows(mget(ls(pattern = "^X_")))
activity <- bind_rows(mget(ls(pattern = "^y_")))
subject  <- bind_rows(mget(ls(pattern = "^subject_")))

# get mean and standard deviation for each feature
cols          <- grep("(mean\\(\\)|std\\(\\))", features$V2)
measures.cols <- measures[, cols]
measures.names <- grep("(mean\\(\\)|std\\(\\))", features$V2, value = TRUE)
names(measures.cols) <- gsub("[(),-]", "", measures.names) # remove special chars
#get labels for activities
activities.f <- activity_labels$V2[activity$V1] # R automatically casts to factor
ds <- bind_cols(as.data.frame(activities.f), subject, measures.cols)

# Task 4. label dataset
ds <- rename(ds, activity = activities.f, subject = V1) %>% mutate(subject = as.factor(subject))
ds2 <- mutate(ds, subject = as.factor(subject)) %>% 
  group_by(activity, subject) %>% 
  summarize_each(funs(mean)) %>% 
  ungroup
write.table(ds2, "tidy_dataset.txt", row.names = FALSE)



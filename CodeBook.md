# Analysis description

## Getting the data
Function `ensureData` checks if the data is already available, if not, it downloads it from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
then merges the training and test datasets. #Step1, #Step2

## Data projection
Function `LoadUciHarDataSet` does 3 tasks:
* extracts only the measurements on the mean and standard deviation for each measurement
* inline the category labels and the subjects' ids
* normalizing column names. E.g. `tBodyGyro.std.Z`

## Deriving new dataset
Function `CalculateAveragesForSubjectAndCategory` simply groups by subject and category and calculates the mean for every variable
The columns' names in the new dataset are suffixed by `'.avg'`

## Exporting the new dataset
Function `GeneratePartialUciHarDataSet` saves the dataset into a file called 'sensorVariableAverages-BySubjectAndActivity.csv'

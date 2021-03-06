library(data.table)

# TOC:
#   * Config
#   * Utility methods
#   * Entry point



# --------------------------------------------------------------
# Config
# --------------------------------------------------------------
dataRoot = "UCI HAR Dataset"
mergeRoot = file.path(dataRoot,"merged");
testRoot =  file.path(dataRoot, "test");
trainRoot =  file.path(dataRoot,"train");

# --------------------------------------------------------------
# Utility methods
# --------------------------------------------------------------

#' Ensures that the data is available for analysis
#' For more information about the data @seealso http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
ensureData = function(){
  if(!dir.exists(dataRoot)){
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "data.zip");
    unzip("data.zip");
    unlink("data.zip");
    mergeData()
  }
}

#' Merging Train and Test data
#' 
#'
#'
#' @examples
mergeData = function(){

  if(dir.exists(mergeRoot)){
    unlink(mergeRoot, recursive = TRUE);
  }
  if(!dir.exists(mergeRoot)){
    dir.create(mergeRoot)
  }
  
  apply(FUN = function(d){
    dp = file.path(mergeRoot,d)
    if(!dir.exists(dp)){
      dir.create(dp, recursive = FALSE)
    }
  }, MARGIN = 1, X = array(list.dirs(path = trainRoot, full.names=FALSE, recursive = TRUE)))
  
  # This assumes train and test have identical structure.
  for(ft in list.files(path = trainRoot, recursive = TRUE)){
    fp = gsub('_train.txt', '_merged.txt', file.path(mergeRoot, ft))
    file.create(fp)
    writeLines(readLines(file.path(trainRoot, ft)), con = fp)
    writeLines(readLines(file.path(testRoot, gsub('_train.txt','_test.txt',ft))), con = fp)
  }
}



#' Loads the partial UCI HAR dataset, containing only the means, standard deviations, subjects and activity labels.
#' @see http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#'
#' @return
#' @export
#'
#' @examples
LoadUciHarDataSet <- function(){
   rowLimit = -1

   ensureData()
      
   #Setup measurements
   featureVector = read.delim(file.path(dataRoot,"features.txt"), sep = "", header = FALSE)$V2
   dataX = read.table(file.path(mergeRoot, "X_merged.txt"), sep = "", header = FALSE,  col.names = featureVector, nrows = rowLimit)
   columns =  subset(names(dataX), grepl("mean[.]", names(dataX)) | grepl("std", names(dataX)))
   dataX = subset(dataX, select=columns)
   
   #Setup labels
   dataY = read.table(file.path(mergeRoot,"y_merged.txt"), header = FALSE, col.names = c("category"), colClasses = "factor", nrows=rowLimit)
   activityLabels = read.table(file.path(dataRoot,"activity_labels.txt"), header = FALSE)$V2
   dataY$category  <- `levels<-`(dataY$category, activityLabels)
  
   #Setup subjects
   subjects = read.table(file.path(mergeRoot,"subject_merged.txt"), header = FALSE, col.names = c("subjectId"), nrows=rowLimit)
   
   #Join them together
   newData = cbind(dataX, dataY, subjects)
   setnames(newData, names(newData), gsub("[.]+",".", names(newData)))
   newData
}


#' Generates a dataset based on the UCI HAR Dataset that contains the average for every mean and std variable grouped by Subject and Activity
#'
#' @param uciHarDataFrame The UCI HAR data containing only numerical columns plus "subjectId" and "category"
#'
#' @return The grouped and averaged
#' @export
#'
#' @examples
CalculateAveragesForSubjectAndCategory <- function(uciHarDataFrame){
  dt = data.table(uciHarDataFrame);
  newData = dt[, lapply(.SD, mean), by=list(category, subjectId)]
  colNames = names(newData)[names(newData)!="subjectId"& names(newData)!="category"]
  newColnames = paste(colNames,".avg", sep = "")
  setnames(newData, colNames, newColnames)
  newData
}

# ==========================================================================================
#   ENTRY POINT
# ==========================================================================================
#' Generates and saves a dataset based on the UCI HAR Dataset that contains the average for every mean and std variable grouped by Subject and Activity
#'
#' @return Name of the file containing the partial dataset
#'
GeneratePartialUciHarDataSet = function(){
  fileName = "sensorVariableAverages-BySubjectAndActivity.txt";
  data = LoadUciHarDataSet()
  data_averges = CalculateAveragesForSubjectAndCategory(data)
  write.table(data_averges, fileName,row.names = FALSE)
  fileName
}
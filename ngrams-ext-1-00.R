## Prototype AdWords Search Term phrase part analysis 1.00
## Importing AdWords CSV.
## Processing for sharing.

library(data.table)
library(reshape2)
library(plyr)
library(dplyr)

## PROCESS SUMMARY
# Download AdWords Report.
#   Columns: "Account", "Device", "Network..with.search.partners.", "Search.term", "Match.type", "Clicks", "Impressions", "Cost", "Avg..position", "Added.Excluded", "Converted.clicks", "Campaign", "Ad.group", "Keyword"
# Process/clean AdWords search term report:
#   Open Windows Powershell. Navigate to the appropriate directory.
#   Use following command to convert the file to ASCII to deal with unicode characters:
#   Get-Content [old file]|Set-Content [new file] -encoding ASCII
# Create lists of phrase parts.
#   Create three text files with single work, two word and three word combinations and frequency counts
#   Columns as follows for phrase parts and frequency respectively: V1  V2
# Change settings and file references below.

## General settings.
workingDirectory <- "C://directory//path" # Place all data files here #
adwordsFile <- "example_set.csv" # Processed search term report
labelsFile <- "label_file.csv" # CSV file. Column heads: Campaign, Labels.
twoWordList <- "ngram2_source.txt"
threeWordList <- "ngram3_source.txt"
dateString <- format(Sys.time(), "%Y%m%d")

## General Comments on data:
# The numbers provided by AdWords need be be processed to coerce to int/number, due to four digital and up numbers exported with ','
# Dates need to be processed to change from chr to date

## Setting up the working directory for all data file references.
# Ensure all data files for use are in the working directory.
setwd(workingDirectory)
work_dir <- getwd()

## Function for exporting tables to CSVs. 
##Directory path other than work directory and extension needs to be defined 'x', 'y' is the table to be exported.
file_output <- function (x, y){
  path <- paste(work_dir, x, sep ="")
  write.table(y, file = path, sep = ",", row.names = FALSE)
}

## Function import Adwords file. Define file name and remove the 'Total' row.
## Non-latin characters. This was dealt with through converting to ASCII via powershell.
## Get-Content [old file]|Set-Content [new file] -encoding ASCII
adwords_import <- function(x) {
  wip <- read.csv(x, as.is=TRUE, sep="\t", quote="", skip=5, fill=TRUE, flush=TRUE)
  wip <- subset(wip, wip$Account !="Total")
  return(wip)
}

## Function to clean up columns imported as strings due to adwords/MS csv ',' weirdness
chr_number <- function(x, y) {
  x[,y] <- as.numeric(gsub("[^0-9\\.]","", x[,y]))
}

## This is formated for testing purposes, using static file reference.
searchTerm.work_file <- adwords_import(adwordsFile)

## Convert column to numeric.
searchTerm.work_file[, "Cost"] <- chr_number(searchTerm.work_file, "Cost")

## AdWords: need to add labels based on a campaign name match as per external array.
## Loading label array and using the native match function.
adwords.labels <- read.csv(labelsFile, header = TRUE, as.is=TRUE, sep=",", quote="\"")
searchTerm.work_file$Labels <- adwords.labels$Labels[match(searchTerm.work_file$Campaign,adwords.labels$Campaign)]
head(searchTerm.work_file)

## Load ngrams
ngram2 <- read.csv(twoWordList, sep = "\t", head = FALSE)
ngram3 <- read.csv(threeWordList, sep = "\t", head = FALSE)

## Convert data frame to data table
searchTerm.work_file <- data.table(searchTerm.work_file)
labelNgrams.work_file2 <- data.frame()

## Loops, because I just plain hate myself.
for(i in ngram2$V1){
  tryCatch({
    wip <- aggregate(cbind(Impressions, Clicks, Cost, Converted.clicks) ~ Labels + Campaign + Keyword + Search.term, data = searchTerm.work_file[Search.term  %like%  paste('^',i,'$', sep = "") | Search.term  %like%  paste('^',i,'\\s', sep = "") | Search.term  %like%  paste('\\s',i,'$', sep = "")], sum)
    wip[, "ngram"] <- i
    labelNgrams.work_file2 <- rbind(labelNgrams.work_file2, wip)
  }, error = function(e){})
}

## Add performance columns
labelNgrams.work_file2$ctr <- labelNgrams.work_file2$Clicks/labelNgrams.work_file2$Impressions
labelNgrams.work_file2$cpc <- labelNgrams.work_file2$Cost/labelNgrams.work_file2$Clicks
labelNgrams.work_file2$cpa <- labelNgrams.work_file2$Cost/labelNgrams.work_file2$Converted.clicks
labelNgrams.work_file2$cvr <- labelNgrams.work_file2$Converted.clicks/labelNgrams.work_file2$Clicks

## Data Export
file_output(paste0("//ngrams_",dateString, "2word.csv"), labelNgrams.work_file2)

labelNgrams.work_file3 <- data.frame()

## Loops, because I just plain hate myself.
for(i in ngram3$V1){
  tryCatch({
    wip <- aggregate(cbind(Impressions, Clicks, Cost, Converted.clicks) ~ Labels + Campaign + Keyword + Search.term, data = searchTerm.work_file[Search.term  %like%  paste('^',i,'$', sep = "") | Search.term  %like%  paste('^',i,'\\s', sep = "") | Search.term  %like%  paste('\\s',i,'$', sep = "")], sum)
    wip[, "ngram"] <- i
    labelNgrams.work_file3 <- rbind(labelNgrams.work_file3, wip)
  }, error = function(e){})
}

## Add performance columns
labelNgrams.work_file3$ctr <- labelNgrams.work_file3$Clicks/labelNgrams.work_file3$Impressions
labelNgrams.work_file3$cpc <- labelNgrams.work_file3$Cost/labelNgrams.work_file3$Clicks
labelNgrams.work_file3$cpa <- labelNgrams.work_file3$Cost/labelNgrams.work_file3$Converted.clicks
labelNgrams.work_file3$cvr <- labelNgrams.work_file3$Converted.clicks/labelNgrams.work_file3$Clicks

## Data Export
file_output(paste0("//ngrams_",dateString, "3word.csv"), labelNgrams.work_file3)
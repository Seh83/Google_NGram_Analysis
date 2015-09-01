# Phrase Part Analysis

A quick and dirty script written for R for searching an AdWords file for a range of phrase parts and attributing performance metrics to them.

The script references a number of example files for demonstration and to provide a template for file format. There are a number of processes that can be used to extract n-grams from a list of search terms, though this is not covered in this code.

Incompatible characters within the search term file are dealt with in pre-processing.

# Process Summary

## Download AdWords Report.
Columns: "Account", "Device", "Network..with.search.partners.", "Search.term", "Match.type", "Clicks", "Impressions", "Cost", "Avg..position", "Added.Excluded", "Converted.clicks", "Campaign", "Ad.group", "Keyword"

## Process/clean AdWords search term report:
Open Windows Powershell. Navigate to the appropriate directory.

Use following command to convert the file to ASCII to deal with unicode characters:

Get-Content [old file]|Set-Content [new file] -encoding ASCII

## Create lists of phrase parts.
Process is integrated with the main file.

## Exploratory Graphs
Example graphs have been included in the code for visualising distributions and significant points within each group.

# Example Data Files
example_set.csv: Example adwords search term report

label_file.csv: Campaign name and label reference. Used for grouping campaigns for simularity.

# Working Files

ngrams-ext-1-00.R
The main file that takes the search term report and produces a number of csv exports and data frames used for analysis.

ngram-outlier-influence-0-01.R
Most of the analysis and graphing is done in this file. The data frames produced in the ngrams-ext-1-00.R file need to be available in the work space for this one to work. Some of the tools used are included as an example, and some of the techniques are not being applied strictly appropriately.

overview.RMD
An R markdown file for producing a HTML document running through the example file as per this repository.

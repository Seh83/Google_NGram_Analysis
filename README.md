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
Create three text files with single work, two word and three word combinations and frequency counts

Columns as follows for phrase parts and frequency respectively: V1  V2

# Example Data Files
example_set.csv: Example adwords search term report

label_file.csv: Campaign name and label reference

ngram2_source.txt: List of two word combinations and frequency count.

ngram3_source.txt: List of three word combinations and frequency count.

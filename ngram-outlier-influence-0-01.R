## Assessing for the outliers.

# Analysis packages
library(car)
library(gvlma)
library(MASS)
library(QuantPsyc)
library(Hmisc)
library(corrplot)

## Function for exporting tables to CSVs. 
##Directory path other than work directory and extension needs to be defined 'x', 'y' is the table to be exported.
file_output <- function (x, y){
  path <- paste(work_dir, x, sep ="")
  write.table(y, file = path, sep = ",", row.names = FALSE)
}

## This is going to be based on a simple general linear model
is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))

fitSet02.df<- aggregate(cbind(Impressions, Cost, Clicks, Converted.clicks) ~ ngram + Campaign + Labels, data = labelNgrams.work_file2, sum)
fitSet03.df<- aggregate(cbind(Impressions, Cost, Clicks, Converted.clicks) ~ ngram + Campaign + Labels, data = labelNgrams.work_file2, sum)

fitSet02.df$cvr <- fitSet02.df$Converted.clicks/fitSet02.df$Clicks
fitSet03.df$cvr <- fitSet03.df$Converted.clicks/fitSet03.df$Clicks

fitSet02.df[is.nan(fitSet02.df)] <- 0
fitSet03.df[is.nan(fitSet03.df)] <- 0

fitSet02.df$cvr[is.infinite(fitSet02.df$cvr)] <- 0
fitSet03.df$cvr[is.infinite(fitSet03.df$cvr)] <- 0

fitSet02.df[is.na(fitSet02.df)] <- 0
fitSet03.df[is.na(fitSet03.df)] <- 0

## Analysing one set of data as per the new sets created above.
## This is using the two word gram data frame as per above.
fitSet02.df$Campaign <- as.factor(fitSet02.df$Campaign)
fitSet02.dt <- data.table(fitSet02.df)
fit <- lm(Converted.clicks ~ Campaign * Clicks, data = fitSet02.dt, weight = Cost)

# Assessing Outliers
outlierTest(fit) # Bonferonni p-value for most extreme obs
rows01 <- c(126, 161, 123, 138, 74)
data01 <- fitSet02.dt[c(126, 161, 123, 138, 74),]
data01$Observation <- rows01
data01

labelNgrams.work_file2 <- data.table(labelNgrams.work_file2)
kable(head(arrange(labelNgrams.work_file2[ngram %like% "name word" | ngram %like% "next other" | ngram %like% "word uno" | ngram %like% "test string" | ngram %like% "text word", c(3:8,13), with = FALSE], desc(Clicks)), 10), digits=2)

summary2Camp <- aggregate(cbind(Converted.clicks, Clicks) ~ ngram + Campaign, data = labelNgrams.work_file2[ngram %like% "name word" | ngram %like% "next other" | ngram %like% "word uno" | ngram %like% "test string" | ngram %like% "text word"], sum)

summary2Camp$cvr <- summary2Camp$Converted.clicks/summary2Camp$Clicks
summary2Camp$cvr[is.infinite(summary2Camp$cvr)] <- NA 

summary2DCam <- dcast(summary2Camp, ngram ~ Campaign, value.var = 'Clicks', fun.aggregate = sum)
summary2DCam

summary2DCav <- dcast(summary2Camp, ngram ~ Campaign, value.var = 'cvr')
summary2DCav

# Cook's D plot
# identify D values > 4/(n-k-1) 
cutoff <- 4/((nrow(fitSet02.df)-length(fit$coefficients)-2)) 
plot(fit, which = 4, cook.levels = cutoff)

rows02 <- c(28, 74, 123)
data02 <- fitSet02.dt[c(28, 74, 123),]
data02$Observation <- rows02
data02

# Influence Plot 
influencePlot(fit, id.method = "note.worthy", main = "Influence Plot", sub = "Circle size is proportial to Cook's Distance", id.cex = 1, id.n = 2)

rows03 <- c(28, 74, 96, 123)
data03 <- fitSet02.dt[c(28, 74, 96, 123),]
data03$Observation <- rows03
data03

## Produce a table of extreme rows using Mahalanobis Disance and Cook's D.
for(i in c("Campaign 01", "Campaign 02", "Campaign 03", "Campaign 04")) {
## Calculate overall Mahalonbis Distance for clicks and conversion numbers to identify outlying values.
sx <- cov(fitSet02.dt[Campaign == i,6:7, with = FALSE])
m1 <- mahalanobis(fitSet02.dt[Campaign == i,6:7, with = FALSE], colMeans(fitSet02.dt[Campaign == i, 6:7, with = FALSE]), sx)

## Caculate and add Cook's Distance as per the fited model.
d1 <- cooks.distance(fit)
wip <- cbind(fitSet02.dt[Campaign == i,], m1, d1)

## Print the rows reaching a certain threshold.
wip <- na.omit(wip[d1 > 4/nrow(wip), ])

plot <- ggplot(wip, aes(x = Clicks, y = Converted.clicks)) + geom_point() + geom_text(aes(label = ifelse((d1 > 4/nrow(wip)), ngram, "")), hjust = 1, vjust = 1) + ggtitle(paste("Clicks to Converted Clicks for ",i," with Cook's Distance", sep = ""))

print(plot)

print(arrange(wip, desc(d1)))

}

## Export file for review.
file_output("//fitSet02adf.csv", fitSet02a.dt)

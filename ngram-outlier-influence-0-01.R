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
fitSet02.dt[c(74,126,161,138,123),]

## Plots
qqPlot(fit, main="QQ Plot") #qq plot for studentized resid 
leveragePlots(fit) # leverage plots

# Influential Observations
# added variable plots 
avPlots(fit, id.n = 4)

# Cook's D plot
# identify D values > 4/(n-k-1) 
cutoff <- 4/((nrow(fitSet02.df)-length(fit$coefficients)-2)) 
plot(fit, which = 4, cook.levels = cutoff)
fitSet02.dt[c(74,123,126),]

# Influence Plot 
influencePlot(fit, id.method = "note.worthy", main = "Influence Plot", sub = "Circle size is proportial to Cook's Distance", id.cex = 1, id.n = 2)
fitSet02.dt[c(28,74,96,123,126),]

# Another lot of plots
infIndexPlot(fit, vars=c("Cook", "Studentized", "Bonf", "hat"), main = "Diagnostic Plots",  id.method = cooks.distance(fit), id.n = 4)

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

plot <- ggplot(wip, aes(x = Clicks, y = Converted.clicks, size = d1)) + geom_point() + geom_text(aes(label = ifelse((d1 > 4/nrow(wip)), ngram, "")), hjust = 1, vjust = 1) + ggtitle(paste("Clicks to Converted Clicks for ",i," with Mahalanobis Distance", sep = ""))

print(plot)
print(wip)
}

## Export file for review.
file_output("//fitSet02adf.csv", fitSet02a.dt)

library(reshape2)
library(plyr)

source("../../useful_scripts/round_columns.R")

df <- read.csv("../../cleaning/population/population_cleaned.csv",
                colClasses=c("cve"="character"))

#Select a subset of indicators
#"Average degree of schooling of the population 15 years and over"
#"Households"
#"Male-female ratio"
#"Percentage of population 15 to 29 years"
#"Percentage of population 60 or more years"
#"Total population"
#"Total population men"
#"Total population women"

#subset_indicators <-
#            c("Total population men",
#              "Total population women")

# #Filter rows 
#df <- df[df$indicator %in% subset_indicators,]

#Re factor variable
#df$indicator <- as.factor(as.character(df$indicator))

#Re level variable
levels(df$indicator) <- gsub(" ", "_", tolower(levels(df$indicator)),
                             fixed=TRUE)

#Reshape data
d_ <- dcast(df, cve + year ~  indicator, value.var="measurement")


#Round columns to two decimal places
idx <- 3:ncol(d_)
d_ <- round_cols(d_, idx)

#Order
d_ <- d_[order(d_$cve, d_$year),]

#Save csv
write.csv(d_, "population_features.csv", row.names=FALSE, na = "")
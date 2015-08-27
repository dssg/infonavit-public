library(reshape2)
library(plyr)

round_decimal <- function(number, decimals){
    as.numeric(format(round(number, decimals), nsmall=decimals))
}

df <- read.csv(paste0("../../preprocessing/natality_mortality_nupciality/",
                      "nmn_preprocessed.csv"), colClasses=c("cve"="character"))

#Drop state statistics
muns <-  !grepl("[0-9]{2}000", df$cve)
df <- df[muns,]

#Melt data to have yearly observations
m <- melt(df, id.vars = c("cve", "indicator"))

#Convert indicators to columns
d <- dcast(m, cve + variable ~ indicator)

#Rename columns
names(d)[names(d) == "variable"] <- "year"
d$year <- as.numeric(substr(d$year, 2, 5))

#Subset for observations between 1995 and 2015
d <- subset(d, year >= 1995 & year <= 2015)

#Write csv file
write.csv(d, "nmn_features.csv", row.names=FALSE, na="")
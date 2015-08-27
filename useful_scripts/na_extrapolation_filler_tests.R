library(reshape2)
library(plyr)
library(doMC)
library(ggplot2)
doMC::registerDoMC(cores=8)

source("na_extrapolation_filler.R")

df <- read.csv("../cleaning/population/population_cleaned.csv",
                colClasses=c("cve"="character",
                             "cve_ent"="character",
                             "cve_mun"="character"))


subset_indicators <- c("Total population")
df <- df[df$indicator %in% subset_indicators,]


#Drop type_level columns
df$type_level_1 <- NULL
df$type_level_2 <- NULL
df$type_level_3 <- NULL
#Drop id columns
df$cve_ent <- NULL
df$cve_mun <- NULL
df$nom_mun <- NULL
df$nom_ent <- NULL
df$indicator_id <- NULL


#Re level variable
levels(df$indicator) <- gsub(" ", "_", tolower(levels(df$indicator)),
                             fixed=TRUE)

extrapolation <- function(df){
    fill_nas_linear_extrapolation(df, "year", "measurement", 2008:2015)
}

estimations <- ddply(df, .(cve, indicator), extrapolation, .parallel=TRUE)


#Reshape data
d_ <- dcast(estimations, cve + year ~  indicator, value.var="measurement")
census <- dcast(df, cve + year ~  indicator, value.var="measurement")

#Rename columns
names(d_)[names(d_) == "x"] <- "year"

#Order
d_ <- d_[order(d_$cve, d_$year),]

#Plot actual data vs extrapolated data
#First subset the data from one municipality
d_$type <- "extrapolation"
census$type <- "census"

estimation <- subset(d_, cve == "01002")
census_data <- subset(census, cve == "01002")
estimation$cve <- NULL
census_data$cve <- NULL

plot_data <- rbind(estimation, census_data)

ggplot(plot_data, aes(x=year,
                      y=total_population,
                      color=type)) + geom_point(shape=1)
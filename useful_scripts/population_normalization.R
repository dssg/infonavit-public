library(plyr)

normalize_ver_population <- function(df, columns, factor){
    #Load population data
    population <- read.csv(paste0("../../feature-engineering/population/",
                "population_features.csv"),
                colClasses=c("cve"="character"))
    #Subset columns
    population <- population[, c("cve", "year", "total_population_estimation")]

    #Normalize using population data
    df <- join(df, population, by=c("cve", "year"), match="first")
    df[, columns] <- factor * (df[, columns] / df$total_population_estimation)

    #Drop population column
    df$total_population_estimation <- NULL

    df
}
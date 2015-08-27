#library(mi)
library(reshape2)
library(plyr)
library(doMC)
doMC::registerDoMC(cores=25)
#doMC::registerDoMC(cores=4)

source("../../useful_scripts/na_extrapolation_filler.R")

#Load the data
#df <- read.csv("/mnt/scratch/mun_features.csv", colClasses=c("cve"="character"))
df <- read.csv("mun_features.csv", colClasses=c("cve"="character"))

extrapolation <- function(df){
    fill_nas_linear_extrapolation(df, "year", "value", 1995:2015)
}

#Create df for factor vars
factor_idx <- "factor" == lapply(df, class)
factor_idx[1] <- TRUE
factor_idx[2] <- TRUE
df_factor <- df[, factor_idx]
#Create df for non factor var
non_factor_idx <- "factor" != lapply(df, class)
non_factor_idx[1] <- TRUE
non_factor_idx[2] <- TRUE
df_non_factor <- df[, non_factor_idx]

#df_non_factor <- subset(df_non_factor, cve=="01001" | cve=="01002")

#Perform extrapolation on non-factor vars
md <- melt(df_non_factor, id.vars=c("cve", "year"))
est <- ddply(md, .(cve, variable), extrapolation, .parallel=TRUE)
df_est <- dcast(est, cve + year ~  variable, value.var="value")

##Append mun to each column for identification
names(df_est) <- paste0("mun_", names(df_est))

#Write csv file
#write.csv(df_est, "/mnt/scratch/mun_features_extrapolation.csv")
#df_est <- read.csv("mun_features_extrapolation.csv",
#                    colClasses=c("cve"="character"))

#Join with the factor vars
df_all_vars <- join(df_est, df_factor, by=c("cve", "year"), match = "first")

write.csv(df_all_vars, "mun_features_extrapolation_all_vars.csv", row.names=FALSE)
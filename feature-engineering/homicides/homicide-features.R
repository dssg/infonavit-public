library(reshape2)

df <- read.csv("../../preprocessing/homicides/homicides_preprocessed.csv",
                colClasses=c("cve"="character",
                             "cve_ent"="character",
                             "cve_mun"="character"))

#Calculate rates
#df$homicide_rate <- (df$total_homicides / df$total_population) * 100000
#df$male_homicide_rate <- (df$male_homicides / df$male_population) * 100000
#df$female_homicide_rate <- (df$female_homicides / df$female_population) * 100000

#Subset columns to get only cve and rates
#df <- df[,c(1,5,12,13,14)]

df <- df[, -c(2,3,4)]

#Order data frame
df <- df[order(df$cve, df$year),]

#Write file
write.csv(df, "homicide_features.csv", row.names=FALSE)
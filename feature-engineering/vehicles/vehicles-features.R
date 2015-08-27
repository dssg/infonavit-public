library(reshape2)
library(plyr)

df <- read.csv("../../preprocessing/vehicles/vehicles_preprocessed.csv",
                colClasses=c("cve"="character",
                             "cve_ent"="character",
                             "cve_mun"="character"))
#Re-level indicators
levels(df$indicator) <- c("passenger_buses", "motor_vehicles",
                          "motorcycles", "vehicles", "trucks_and_vans")

#Drop state statistics
df <- subset(df, nom_mun != "Estatal")

#Drop useless columns
df$cve_ent <- NULL
df$cve_mun <- NULL
df$nom_mun <- NULL
df$nom_ent <- NULL
df$indicator_id <- NULL

#Melt data to have yearly observations
m <- melt(df, id.vars = c("cve", "indicator"))

#Convert indicators to columns
d <- dcast(m, cve + variable ~ indicator)

#Rename columns
names(d)[names(d) == "variable"] <- "year"
d$year <- as.numeric(substr(d$year, 2, 5))

#Round to two decimals
#Write csv file
write.csv(d, "vehicles_features.csv", row.names=FALSE, na="")
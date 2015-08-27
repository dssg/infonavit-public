library(reshape2)
library(plyr)

df <- read.csv(paste0("../../preprocessing/natural_disasters/",
                "natural_disasters_preprocessed.csv"),
                colClasses=c("cve"="character"))

#Remove some columns
df$EffectOtherLosses <- NULL
df$EffectLossesValueLocal <- NULL
df$EffectRoads <- NULL
df$EffectFarmingAndForest <- NULL
df$EffectLiveStock <- NULL
df$EffectEducationCenters <- NULL
df$EffectMedicalCenters <- NULL

#NA means - There was an effect but it's magnitude is unknown
#         - Or there's no information about the effect
#Replace it with zeros
df[is.na(df)] <- 0

#Lowercase events
df$EventId <- tolower(df$EventId)

#Filter by events with ocurrence higher than the median
#table(df$EventId) > median(table(df$EventId))

#Agreggate data and sum
ag <- aggregate( . ~ cve + year + EventId , df, FUN=sum)

#Reshape data
md <- melt(ag, id.vars=c("cve", "year", "EventId"))

#This produces 300+ features
#cd <- dcast(md, cve + year ~ EventId + variable)

cd <- dcast(md, cve + year ~ variable, fun.aggregate=sum)

#Rename columns


#Fill missing years with zeros
year_range <- 1995:2015
missing_rows <- data.frame()
for (current_cve in unique(cd$cve)){
    #print(current_cve)
    #Get years that match current cve
    years <- subset(cd, cve == current_cve)$year
    #Get missing years
    missing_years <- setdiff(year_range, years)
    #Create rows for missing years
    new_rows <- data.frame(year=missing_years)
    new_rows$cve <- current_cve
    #Append to dataframe
    missing_rows <- rbind(missing_rows, new_rows)
}

#Rbind rows and fill NAs with zeros
cd <- rbind.fill(cd, missing_rows)
cd[is.na(cd)] <- 0

#Sort by cve, year
cd <- cd[order(cd$cve, cd$year),]

names(cd) <- tolower(names(cd))

#Write file
write.csv(cd, "natural_disasters_features.csv", row.names=FALSE)
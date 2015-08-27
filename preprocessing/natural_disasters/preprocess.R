df <- read.csv("disaster.csv",
            colClasses=c("GeographyCode"="character"),
            #-1 means there was an effect but it's unknown
            #-2 means theres no information about the effect
            na.strings=c("-1", "-2"))

#Drop columns
df$DisasterId <- NULL
df$DisasterSerial <- NULL
df$DisasterSiteNotes <- NULL
df$DisasterSource <- NULL

df$GeographyId <- NULL
df$RegionId <- NULL
df$DisasterLongitude <- NULL
df$DisasterLatitude <- NULL

#Remove all record columns
df <- df[,-which(grepl("Record", names(df)))]
#Remove all sector columns
df <- df[,-which(grepl("Sector", names(df)))]

df$EventNotes <- NULL
df$EventDuration <- NULL
df$EventMagnitude <- NULL
df$CauseNotes <- NULL
df$CauseId <- NULL

df$EffectNotes <- NULL


#Rename column
names(df)[names(df)=="GeographyCode"] <- "cve"

#Create year column
df$year <- as.numeric(substr(df$DisasterBeginTime, 1,4))
df$DisasterBeginTime <- NULL

#Remove rows with weird EventId
event_ids <- unique(levels(df$EventId))
idx <- grepl("[0-9]", event_ids)
weird_event_ids <- event_ids[idx]
df <- subset(df, !(EventId %in% weird_event_ids))
#Checar tabla Event para obtener descripcion

#Remove columns ending with Q
#Those columns replace -1 and -2 with 0
df <- df[,-which(grepl("Q$", names(df)))]


#Some year values are incorrect (11 and 201)
#remove rows with year values lower than 1970
df <- subset(df, year>=1970)

#Write the file
write.csv(df, "natural_disasters_preprocessed.csv", row.names=FALSE)
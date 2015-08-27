#Read the preprocessed population file
df <- read.csv("../../preprocessing/population/population_preprocessed.csv",
                colClasses=c("cve"="character",
                             "cve_ent"="character",
                             "cve_mun"="character"))
df$indicator_id <- as.integer(df$indicator_id)

#Print number of NAs in each column
apply(df, 2, function(x) sum(is.na(x)))

#We are missing some indicator is
unique(df[is.na(df$indicator_id), "indicator"])
#The only missing id is
#Population covered by health services through Popular Insurance
#Ok to delete

#Measurement has 143314 NAs, let's check...
rows_nas <- subset(df, is.na(measurement))
summary(rows_nas)

#Summarize missing values
table(rows_nas$nom_ent, rows_nas$indicator)

#Let's check which indicators are missing
missing_indicator_ids <- unique(rows_nas$indicator_id)

#Get indicators name
names <- unique(rows_nas[rows_nas$indicator_id %in% missing_indicator_ids,
                c("indicator", "indicator_id")])

#Population id = 1002000001
#Check where we are missing population info
missing_population <- rows_nas[rows_nas$indicator_id == 1002000001,]
dim(missing_population)
#Only in Chiapas and in 1995, it's safe to delete

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

#Save new file
cc <- df[complete.cases(df),]
write.csv(cc, "population_cleaned.csv", row.names=FALSE)
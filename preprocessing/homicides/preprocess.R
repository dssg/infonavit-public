library(stringr)

df <- read.csv("homicides1990-2010.csv")

#Drop state abbreviation
df$StateAbbrev <- NULL

#Generate cve_ent and cve
cve <- str_pad(df$id, 5, pad="0")
cve_mun <- substr(cve, 3, 5)

df <- cbind(cve_mun, df)
df <- cbind(cve, df)
#Remove old column
df$id <- NULL

#Add padding to StateCode
df$StateCode <- str_pad(df$StateCode, 2, pad="0")


colnames(df) <- c("cve", "cve_mun", "cve_ent", "nom_mun",
                  "year", "total_homicides",
                  "male_homicides", "female_homicides",
                  "total_population", "male_population",
                  "female_population")

write.csv(df, "homicides_preprocessed.csv", row.names=FALSE)
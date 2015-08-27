#Load files
df <- read.csv("population_2010_preprocessed.csv",
                colClasses=c("cve"="character",
                                      "cve_ent"="character",
                                      "cve_mun"="character"))

df <- rbind(df, read.csv("population_2005_preprocessed.csv",
                         colClasses=c("cve"="character",
                                      "cve_ent"="character",
                                      "cve_mun"="character")))

df <- rbind(df, read.csv("population_2000_preprocessed.csv",
                         colClasses=c("cve"="character",
                                      "cve_ent"="character",
                                      "cve_mun"="character")))

df <- rbind(df, read.csv("population_1995_preprocessed.csv",
                         colClasses=c("cve"="character",
                                      "cve_ent"="character",
                                      "cve_mun"="character")))

#Write new file
write.csv(df, "population_preprocessed.csv",row.names=FALSE)

args <- commandArgs(TRUE)
df <- read.csv(args[1],
                colClasses=c("cve"="character",
                             "cve_ent"="character",
                             "cve_mun"="character"))
ind <- read.csv(args[2])

df$indicator <- ind$indicator_english[match(df$indicator_id,
                                            ind$indicator_id)]
write.csv(df, args[1], row.names=FALSE)
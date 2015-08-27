library(reshape2)

#Load file
df <- read.csv("../../preprocessing/infonavit_ecuve/ecuve.csv",
                colClasses=c("cve"="character",
                             "id_rng"="character"))

#Delete columns with identifiers (just keep cve)
cve <- df$cve
df[,1:11] <- list(NULL)
df <- cbind(cve, df)

#Delete some columns
df$id_fchinf <- NULL
df$ct_fchpo <- NULL #This has some weird values (1900)

#Create columns for year
#Note:
#fh_inf and id_fchinf match in every year
#But in ~9% of the cases fh_inf is ahead one month to id_fchinf
df$year <- as.numeric(substr(df$fh_inf, 1, 4))
df$fh_inf <- NULL

#Drop factor variables (for now)
df <- df[,-which(grepl("id_", names(df)))]

#Reshape the data
md <- melt(df, id.vars=c("cve", "year"))
cd <- dcast(md, cve + year ~ variable, median)

#Important: there is data only for ~1400 municipalities
#Save the file
write.csv(cd, "ecuve_features.csv", row.names=FALSE)
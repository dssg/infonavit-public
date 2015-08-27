library(RPostgreSQL)
library(reshape2)
library(plyr)
library(doMC)
library(dummies)
library(mi)
doMC::registerDoMC(cores=8)

source("../../useful_scripts/round_columns.R")


df <- read.csv("mun_features_extrapolation_all_vars.csv",
                colClasses=c("cve"="character"))

#Since training only for year>=2008
df <- subset(df, year >= 2008)

#Removing municipalities where infonavit does not have loans
auth <- read.csv("../../auth/auth.csv", header = TRUE)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
    host = "dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com",
    dbname = "infonavit",
    user = toString(auth[2,2]),
    password = toString(auth[2,3]))

query <- paste0("SELECT DISTINCT var26 AS cve FROM loans, master_loan_features_version3",
                " WHERE var41=cv_credito AND year_granted >= 2008")
cves_with_loans <- dbGetQuery(con, query)$cve
dbDisconnect(con)

cves_with_loans <- read.csv("cves_with_loans_v3_2008.csv")$x
#write.csv(cves_with_loans, "cves_with_loans_v3_2008.csv")



#Filter for correct cves
correct_cves <- read.csv("../../preprocessing/municipalities_and_states/municipalities_preprocessed.csv",
                         colClasses="character")

cves_with_loans_and_correct <- cves_with_loans %in% correct_cves

length(cves_with_loans_and_correct) == length(cves_with_loans)

df <- subset(df, cve %in% cves_with_loans)

#Save features list
#write.csv(names(df), "mun_features_list.csv")

#Normalize some features by population/households
norm <- read.csv("mun_features_list.csv")
norm$X <- NULL

#Melt data
md <- melt(df, id.vars=c("cve", "year"), variable.name="feature_name")

#Join with feature to normalize
md <- join(md, norm, by="feature_name", match = "all")

#Create normalization df
norm_vals <- df[,c("cve", "year", "pop_total_population",
                   "pop_total_population_men",
                   "pop_total_population_women", "pop_households")]

#Join with normalization vals
md <- join(md, norm_vals, by=c("cve", "year"), match = "all")

#Modify normalization name to match column names
md$normalization <- paste0("pop_", md$normalization)

assign_norm_val <- function(row){
    norm_col <- row$normalization
    #Four cases
    #Case 2 - No data for normalization
    if (norm_col == "pop_no"){
        val <- 1
    #Case 3 - Available data for normalization (population)
    #Divide population per 1000 to avoid small numbers
    }else if (grepl("pop_total_population", norm_col)){
        val <- row[[norm_col]] / 1000
    #Case 4 - Available data for normalization (households)
    #Case 1 - No need for normalization
    #Just get the value and assign (even if its NA)
    }else{
        val <- row[[norm_col]]
    }
    val
}



md <- adply(.data=md, .margins=1,
             .fun=assign_norm_val,
             .parallel=TRUE)

write.csv(md, "melted.csv")

#Normalize values
#All values were coerced as
#chars
norm_value <- function(row){
    val <- row$value
    #Three cases
    #Case 1 - Value is NA
    if(is.na(val)){
        return(NA)
    #Case 2 - Value is numeric
    }else if (grepl("-?[0-9]+\\.?[0-9]*", val)){
        return(toString(as.numeric(row$value) / row$V1))
    #Case 3 - Value is factor
    }else{
        return(toString(row$value))
    }
}

md_norm <- adply(.data=md, .margins=1,
             .fun=norm_value,
             .parallel=TRUE)

write.csv(md_norm, "melted_norm.csv")

#Reshape the data
df_norm <- dcast(md_norm, cve + year ~ feature_name, value.var="V1")

#Cast to numeric some columns
idx <- !grepl("^(region|geo|cve|year)", names(df_norm))
df_norm[,idx] <- apply(df_norm[,idx], 2, as.numeric)

write.csv(df_norm, "mun_all_features_norm.csv")

#Get only 3 significant figuras
df_norm[,idx] <- apply(df_norm[,idx], 2, signif, 3)

#write.csv(df_norm, "mun_all_features_norm_3_signif.csv")
#df_norm <- read.csv("mun_all_features_norm_3_signif.csv")
#df_norm$X <- NULL

#Add dummy vars
region_dummies <- dummy("region_region", df_norm, sep="_")
geo_dummies <- dummy("geo_geo_zone", df_norm, sep="_")

df_norm_dummies <- cbind(df_norm, region_dummies, geo_dummies)
df_norm_dummies$region_region <- NULL
df_norm_dummies$geo_geo_zone <- NULL

#write.csv(df_norm_dummies, "mun_all_features_norm_3_signif_dummies.csv")
#df_norm_dummies <- read.csv("mun_all_features_norm_3_signif_dummies.csv")
#df_norm_dummies$X <- NULL

#Count NAs
#apply(df_norm_dummies, 2, function(x) sum(is.na(x)))

#Fill natural disasters NAs with 0s
#subset(df_norm_dummies, is.na(nat_effectpeoplemissing))
idx <- grepl("^nat", names(df_norm_dummies))
df_norm_dummies[, idx][is.na(df_norm_dummies[, idx])] <- 0


#There are NAs for cve 23009 (Tulum), such municipality
#was created in 2008, we only have data for 2010, just use the same
#values
pop_2010 <- read.csv(file.path("..", "..", "feature-engineering",
                               "population", "population_features.csv"),
                     colClasses=c("cve"="character"))
tulum <- subset(pop_2010, cve == "23009")
names(tulum)[3:ncol(tulum)] <- paste0("pop_", names(tulum)[3:ncol(tulum)])
names(tulum)[57] <- paste0("pop_poblaci..n_de_5_y_m..s_a..",
                           "os_que_no_especific.._si_habla_lengua_ind..gena")

#Normalize tulum values
#Melt data
md <- melt(tulum, id.vars=c("cve", "year"), variable.name="feature_name")

#Join with feature to normalize
md <- join(md, norm, by="feature_name", match = "all")

#Create normalization df
norm_vals <- tulum[,c("cve", "year", "pop_total_population",
                   "pop_total_population_men",
                   "pop_total_population_women", "pop_households")]
#Join with normalization vals
md <- join(md, norm_vals, by=c("cve", "year"), match = "all")
#Modify normalization name to match column names
md$normalization <- paste0("pop_", md$normalization)

#Assign norm_val
md <- adply(.data=md, .margins=1,
             .fun=assign_norm_val,
             .parallel=TRUE)

md <- adply(.data=md, .margins=1,
             .fun=norm_value,
             .parallel=TRUE)

tulum_norm <- dcast(md, cve + year ~ feature_name, value.var="V1")

#Significant figures
idx <- !grepl("^(region|geo|cve|year)", names(tulum_norm))
tulum_norm[,idx] <- apply(tulum_norm[,idx], 2, as.numeric)
tulum_norm[,idx] <- apply(tulum_norm[,idx], 2, signif, 3)
#Replicate for years between 2008 and 2015
years <- 2008:2015
tulum_norm <- as.data.frame(lapply(tulum_norm, rep, length(years)))
tulum_norm$year <- years
tulum_norm$cve <- NULL
tulum_norm$year <- NULL

#Replace tulum data in all muns dataset
idx <- grepl("^pop", names(df_norm_dummies))
df_norm_dummies[df_norm_dummies$cve == "23009", idx] <- tulum_norm

#Replace the rest of nas with column medians
idx <- which(apply(df_norm_dummies, 2, function(x) sum(is.na(x))) > 0)
idx <- as.numeric(idx)
for(col_idx in idx){
    df_norm_dummies[, col_idx][is.na(df_norm_dummies[, col_idx])] <- median(df_norm_dummies[, col_idx], na.rm=TRUE)
}

#apply(df_norm_dummies, 2, function(x) sum(is.na(x)))

#Add mun prefix to all columns
names(df_norm_dummies) <- paste0("mun_", names(df_norm_dummies))
#Write csv file
write.csv(df_norm_dummies, "master_muns_features.csv", row.names=FALSE)
library(RPostgreSQL)
library(reshape2)

# #Database connection
# auth <- read.csv('../../auth/auth.csv', header = TRUE)
# drv <- dbDriver('PostgreSQL')
# con <- dbConnect(drv,
#         host="dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com",
#         dbname="infonavit",
#         user = toString(auth[2,2]),
#         password = toString(auth[2,3]))

# #Load query sas string
# query <- readChar("mun_aban_count.sql",
#                  file.info("mun_aban_count.sql")$size)

# #Execute query
# df <- dbGetQuery(con, query)
# #Close db connection
# dbDisconnect(con)

#Or load copy
df <- read.csv("mun_abandonment_count.csv")

#Write data
write.csv(df, "mun_abandonment_count.csv", row.names=FALSE)

#Rename columns
names(df)[names(df) == "var11"] <- "year"
names(df)[names(df) == "var26"] <- "cve"

#Remove rows with cve==00000
df <- df[df$cve != "00000",]
#Remove rows with cve==XX000
#Remove rows with year==0
df <- df[df$year != 0,]


##Ranks
#Municipality with most abandonment, absolute number. abs_rank
#Municipality with most relative abandonment: 
#   n of abandon houses in the municipality / houses in that municipality.
#   n of abandon houses in the municipality / n abandon houses in the country.
#   n of abandon houses in the municipality / n houses in the country.

#Get years in the dataset
years <- unique(df$year)



#Define ranking metrics
df["abs"]              <- df["mun_aban_count"]
df["rel_mun"]          <- df["mun_aban_count"] / df["mun_count"]
df["rel_aban_country"] <- df["mun_aban_count"] / df["anual_aban_count"]
df["rel_country"]      <- df["mun_aban_count"] / df["anual_count"]

metric_names <- c("abs", "rel_mun", "rel_aban_country", "rel_country")

#Iterate for each rank
for (i in 1:4){
    #Get current metric and name
    current_name <- metric_names[i]
    #Iterate over years
    for (year in years){
        #Get indexes for year
        idx <- which(df$year == year)
        #Subset rows for that year
        sub_df <- df[idx,]
        #Fill values
        df[idx, paste0("rank_",current_name)] <- rank(-sub_df[current_name],
                                      ties.method="first")
    }
}

#Write data
write.csv(df, "mun_rankings.csv", row.names=FALSE)
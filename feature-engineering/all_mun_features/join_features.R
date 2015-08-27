library(mefa)
library(plyr)

#Load municipalities list with cves
df <- read.csv(paste0("../../preprocessing/municipalities_and_states/",
              "municipalities_preprocessed.csv"),
              colClasses="character")

#Repeat each row for 2008-2015 and add year column
rows <- dim(df)[1]
yr_range <- 1995:2015
years <- rep(yr_range, rows)
df <- rep(df, each=length(yr_range))
df$year <- years

#Load ecuve regions
rgn <- read.csv(paste0("../../feature-engineering/municipalities/",
                "mun_regions.csv"),
                colClasses="character")
rgn$mun_nom <- NULL
#Rename cols to have a prefix
names(rgn)[2:length(rgn)] <-  paste("region",names(rgn), sep="_")[2:length(rgn)]

df <- join(df, rgn, by="cve", match = "first")

#Load geographic regions
geo <- read.csv(paste0("../../feature-engineering/municipalities/",
                "states_geo_zones.csv"),
                colClasses="character", skip=1)
geo$nom_ent <- NULL
names(geo)[2:length(geo)] <-  paste("geo",names(geo), sep="_")[2:length(geo)]

df <- join(df, geo, by="cve_ent", match = "first")

#Population data
population <- read.csv(paste0("../../feature-engineering/population/",
                "population_features.csv"),
                colClasses=c("cve"="character"))

names(population)[3:length(population)] <-  paste("pop",
                names(population), sep="_")[3:length(population)]

df <- join(df, population, by=c("cve", "year"), match = "first")

#Homicide rate is available from 1990 until 2010 (yearly)
homicide <- read.csv(paste0("../../feature-engineering/homicides/",
                "homicide_features.csv"),
                colClasses=c("cve"="character"))
homicide$cve_ent <- NULL
homicide$cve_mun <- NULL
homicide$nom_mun <- NULL
homicide$total_population <- NULL
homicide$male_population <- NULL
homicide$female_population <- NULL

names(homicide)[3:length(homicide)] <-  paste("hom",
                names(homicide), sep="_")[3:length(homicide)]

df <- join(df, homicide, by=c("cve", "year"), match = "first")

#Natural disasters data available from 1970 to 2013 (yearly)
natural <- read.csv(paste0("../../feature-engineering/natural_disasters/",
                "natural_disasters_features.csv"),
                colClasses=c("cve"="character"))

names(natural)[3:length(natural)] <-  paste("nat",
                names(natural), sep="_")[3:length(natural)]

df <- join(df, natural, by=c("cve", "year"), match = "first")


#Load vehicles registry features
vehicles <- read.csv(paste0("../../feature-engineering/vehicles/",
                "vehicles_features.csv"),
                colClasses=c("cve"="character"))

names(vehicles)[3:length(vehicles)] <-  paste("car",
                names(vehicles), sep="_")[3:length(vehicles)]

df <- join(df, vehicles, by=c("cve", "year"), match = "first")


#Load natality, mortality and nupciality data
nmn <- read.csv(paste0("../../feature-engineering/",
                "natality_mortality_nupciality/nmn_features.csv"),
                colClasses=c("cve"="character"))

names(nmn)[3:length(nmn)] <-  paste("nmn",
                names(nmn), sep="_")[3:length(nmn)]

df <- join(df, nmn, by=c("cve", "year"), match = "first")

 
##Drop some ids and mun name
df$nom_mun <- NULL
df$cve_ent <- NULL
df$cve_mun <- NULL

#Write file
write.csv(df, "mun_features.csv", row.names=FALSE, na="")
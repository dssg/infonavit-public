library(reshape2)

zipfilenames <- list.files("data")
filenames <- sub("english_tsv.zip", "english_valor.tsv",
                 zipfilenames, fixed=TRUE)
zipfilenames <- paste0("data/", zipfilenames)

#Group zip file and file to extract
groups <- data.frame(zipfilenames, filenames)
groups$zipfilenames <- as.character(groups$zipfilenames)
groups$filenames <- as.character(groups$filenames)

#Read the data
df <- data.frame()
for (i in 1:nrow(groups)){
    data <- read.table(unzip(groups[i,1], groups[i,2], exdir="tmp"),
                        skip=4,
                        sep="\t",
                        header=TRUE,
                        colClasses=c("Cve_Entidad"="character",
                                     "Cve_Municipio"="character"))

    df <- rbind(df, data)
}

#Remove tmp folder
unlink("tmp", recursive=TRUE)

#Drop useless columns
df$Tema_nivel_1 <- NULL
df$Tema_nivel_2 <- NULL
df$Tema_nivel_3 <- NULL
df$UnidadMedida <- NULL
df$X <- NULL

#Get NA percentages
nas_p <- apply(df, 2, function(x) sum(is.na(x)))/dim(df)[1]
#Columns with 100% of NAs
col_names <- names(nas_p[nas_p == 1])
#Drop columns with 100% NAs
df[,col_names] <- list(NULL)


#Rename some columns
names(df)[names(df) == "Cve_Entidad"] <- "cve_ent"
names(df)[names(df) == "Desc_Entidad"] <- "nom_ent"
names(df)[names(df) == "Cve_Municipio"] <- "cve_mun"
names(df)[names(df) == "Desc_Municipio"] <- "nom_mun"
names(df)[names(df) == "Id_Indicador"] <- "indicator_id"
names(df)[names(df) == "Indicador"] <- "indicator"

#Add cve column
cve <- paste0(df$cve_ent, df$cve_mun)
df <- cbind(cve, df)

#Rename year columns
colnames(df)[8:42] <- gsub("X", "Y", colnames(df)[8:42], fixed=TRUE)

#Write file
write.csv(df, "vehicles_preprocessed.csv", row.names=FALSE)
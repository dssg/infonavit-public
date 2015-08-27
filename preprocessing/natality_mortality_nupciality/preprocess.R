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


#Remove columns full of nas
percentages <- apply(df, 2, function(x) sum(is.na(x)))/dim(df)[1]
rounded <- round(percentages, digits = 0)
idx <- names(rounded)[rounded == 0]
df <- df[,idx]

#Create cve columns
cve <- paste0(df$Cve_Entidad, df$Cve_Municipio)
df <- cbind(cve, df)

#Remove columns
df$Cve_Entidad <- NULL
df$Cve_Municipio <- NULL
df$Desc_Entidad <- NULL
df$Desc_Municipio <- NULL
df$Tema_nivel_1 <- NULL
df$Tema_nivel_2 <- NULL
df$Tema_nivel_3 <- NULL
df$Id_Indicador <- NULL
df$UnidadMedida <- NULL

#Rename column
names(df)[names(df) == "Indicador"] <- "indicator"

#Relevel indicators
levels(df$indicator) <-  gsub(" ", "_", tolower(levels(df$indicator)),
                             fixed=TRUE)


#Write csv file
write.csv(df, "nmn_preprocessed.csv", row.names=FALSE)
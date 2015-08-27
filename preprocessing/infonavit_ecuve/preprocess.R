#Define colClasses to prevent padding zeros being deleted
col_classes <- c("CV_RGNICVV"="character",
                 "CV_NSS"="character",
                 "CV_AVALUO"="character",
                 "CV_CONVIVENCIA"="character",
                 "CV_CREDITO"="character",
                 "CV_MNC"="character",
                 "CV_PAQUETE"="character",
                 "CV_OFR"="character",
                 "CV_ENTFDR"="character")

na_values <- c("-99", "NULL")

#Uncompress files
e2010 <- unzip("ECUVE_2010_RAW.csv.zip", "ECUVE_2010_RAW.csv")
e2011 <- unzip("ECUVE_2011_RAW.csv.zip", "ECUVE_2011_RAW.csv")
e2012 <- unzip("ECUVE_2012_RAW.csv.zip", "ECUVE_2012_RAW.csv")
e2013 <- unzip("ECUVE_2013_RAW.csv.zip", "ECUVE_2013_RAW.csv")
e2014 <- unzip("ECUVE_2014_RAW.csv.zip", "ECUVE_2014_RAW.csv")
e2015 <- unzip("ECUVE_2015_RAW.csv.zip", "ECUVE_2015_RAW.csv")

#Load files for each year
df2010 <- read.csv(e2010, colClasses=col_classes,
                    na.strings=na_values)
df2011 <- read.csv(e2011, colClasses=col_classes,
                    na.strings=na_values)
df2012 <- read.csv(e2012, colClasses=col_classes,
                    na.strings=na_values)
df2013 <- read.csv(e2013, colClasses=col_classes,
                    na.strings=na_values)
df2014 <- read.csv(e2014, colClasses=col_classes,
                    na.strings=na_values)
df2015 <- read.csv(e2015, colClasses=col_classes,
                    na.strings=na_values)

#Delete files
unlink("ECUVE_2010_RAW.csv")
unlink("ECUVE_2011_RAW.csv")
unlink("ECUVE_2012_RAW.csv")
unlink("ECUVE_2013_RAW.csv")
unlink("ECUVE_2014_RAW.csv")
unlink("ECUVE_2015_RAW.csv")

#Rename columns with dots
names(df2012) <- gsub("\\.+", "_", names(df2012))
names(df2013) <- gsub("\\.+", "_", names(df2013))
names(df2014) <- gsub("\\.+", "_", names(df2014))

#Remove extra columns in df2012
df2012$MUNICIPIO <- NULL
df2012$ENTIDAD_FEDERATIVA <- NULL

#Remove columns that start with FILTRO
df2012 <- df2012[,-which(grepl("FILTRO", names(df2012)))]
df2013 <- df2013[,-which(grepl("FILTRO", names(df2013)))]
df2014 <- df2014[,-which(grepl("FILTRO", names(df2014)))]


#Merge them in one dataset
df <- rbind(df2010, df2011, df2012, df2013, df2014, df2015)

#Lowercase names
names(df) <- tolower(names(df))

#Change the inegi code column to match the rest of the data
names(df)[names(df)=="cv_mnc"] <- "cve"

#Parse factor variables

#Área construida
# ID_ARACNS   TX_ARACNS
# -99 Desconocido
# 1   Menor de 41.47 m^2
# 2   De 41.47 m^2 a 45.64 m^2 NO ENTRY WITH THIS VALUE
# 3   De 45.64 m^2 a 74.48 m^2
# 4   De 74.48 m^2 a 99.86 m^2
# 5   Más de 99.86 m^2
df$id_aracns <- as.factor(df$id_aracns)
levels(df$id_aracns) <- c("41m2", "74m2", "99m2", "+99m2")

#Clasificacion vivienda
# ID_CLSVVN   TX_CLSVVN
# -99 DESCONOCIDO
# 1   ECONOMICA
# 2   POPULAR
# 3   TRADICIONAL
# 4   MEDIA
# 5   RESIDENCIAL
# 6   RESIDENCIAL PLUS
df$id_clsvvn <- as.factor(df$id_clsvvn)
levels(df$id_clsvvn) <- c("economica", "popular", "tradicional", "media",
                            "residencial", "residencial plus") 

#Tipo de credito
#ID_TPOCRD  TX_TPOCRD
# -99 Desconocido
# 2   Adquisición de Vivienda Nueva o Usada
# 3   Construcción de Vivienda
# 4   Ampliación de Vivienda
# 5   Pago de pasivo
df$id_tpocrd <- as.factor(df$id_tpocrd)
levels(df$id_tpocrd) <- c("new_or_old_house", "house_building",
                             "house_enlargement", "passive_payment")

#Rango salarial
# ID_RNG  TX_RNG
# -99 Desconocido
# 1   Menor a 2
# 2   De 2 a 3.99
# 3   De 4 a 6.99
# 4   De 7 a 11
# 5   Más de 11
df$id_rng <- as.factor(df$id_rng)
levels(df$id_rng) <- c("2", "4", "7", "11", "+11")

#Region ICVV
# CV_RGNICVV  TX_RGN
# 1   Centro              
# 2   Fronteriza          
# 3   Golfo               
# 4   Grandes Ciudades    
# 5   Norte               
# 6   Península Yucatán   
# 7   Sur                 
# 8   Turística  
df$cv_rgnicvv <- as.factor(df$cv_rgnicvv)
levels(df$cv_rgnicvv) <- c("center", "border", "gulf", "big_city",
                        "north", "yucatan_peninsula", "south", "tourism")         

#Write to a single file
write.csv(df, "ecuve.csv", row.names=FALSE, na="")
library(reshape2)

preprocess_population_files <- function(zipfilenames, filenames, year,
    lines_to_skip=0){
    #Group zip file and file to extract
    groups <- data.frame(zipfilenames, filenames)
    groups$zipfilenames <- as.character(groups$zipfilenames)
    groups$filenames <- as.character(groups$filenames)

    #Read data
    df <- data.frame()
    for (i in 1:nrow(groups)){
        data <- read.table(unzip(groups[i,1], groups[i,2], exdir="tmp"),
                          skip=lines_to_skip, sep="\t", header=TRUE, colClasses="character")
        df <- rbind(df, data)
    }

    #Drop columns with all empty strings
    df <- df[,colSums(df == "") < nrow(df)]

    #Generate CVE
    cve <- paste(df$Cve_Entidad, df$Cve_Municipio, sep="")
    df <- cbind(cve, df)
    
    #Drop UnidadMedida (only present in 2010 census)
    df$UnidadMedida <- NULL
    df$Tema_nivel_1 <- NULL
    df$Tema_nivel_2 <- NULL
    df$Tema_nivel_3 <- NULL
    
    #Rename columns
    colnames(df) <- c("cve", "cve_ent", "nom_ent", "cve_mun",
                      "nom_mun", "indicator_id", "indicator",
                      "measurement")
    
    #Fix column type
    df$measurement <- as.numeric(df$measurement)
    
    #Add year
    df$year <- year
    
    #Write preprocessed csv
    write.csv(df, paste("population", year, "preprocessed.csv", sep="_"),
              row.names=FALSE)
    
    #Remove tmp folder
    unlink("tmp", recursive=TRUE)
}

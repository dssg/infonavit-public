library(reshape2)
source("preprocess_population_files.R")

#2010
zipfilenames <- list.files("2010")
filenames <- sub("tsv.zip", "valor.tsv", zipfilenames, fixed=TRUE)
zipfilenames <- paste("2010/", zipfilenames, sep="")
preprocess_population_files(zipfilenames, filenames, 2010, 4)

#2005
zipfilenames <- list.files("2005")
filenames <- paste(substr(zipfilenames, 0, 11), "Valor.tsv", sep="")
zipfilenames <- paste("2005/", zipfilenames, sep="")
preprocess_population_files(zipfilenames, filenames, 2005)

#2000
zipfilenames <- list.files("2000")
filenames <- paste(substr(zipfilenames, 0, 11), "Valor.tsv", sep="")
zipfilenames <- paste("2000/", zipfilenames, sep="")
preprocess_population_files(zipfilenames, filenames, 2000)

#1995
zipfilenames <- list.files("1995")
filenames <- paste(substr(zipfilenames, 0, 11), "Valor.tsv", sep="")
zipfilenames <- paste("1995/", zipfilenames, sep="")
preprocess_population_files(zipfilenames, filenames, 1995)

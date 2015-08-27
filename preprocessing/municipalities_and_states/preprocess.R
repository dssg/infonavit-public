removeAccents <- function(str){
    gsub("`|\\'", "", iconv(str, to="ASCII//TRANSLIT"))
}

states <- read.csv("states.csv", colClasses="character")
municipalities <- read.csv("municipalities.csv", colClasses="character")

colnames(states) <- tolower(colnames(states))
colnames(municipalities) <- tolower(colnames(municipalities))

#Lower case and remove accents
states$nom_ent <- tolower(removeAccents(states$nom_ent))
municipalities$nom_mun <- tolower(removeAccents(municipalities$nom_mun))

#Remove ~ (due to the use of ñ)
municipalities$nom_mun <- gsub("~", "", municipalities$nom_mun)

#Chanche column name
names(municipalities)[names(municipalities) == "concat"] <- "cve"

write.csv(states, "states_preprocessed.csv", row.names=FALSE)
write.csv(municipalities, "municipalities_preprocessed.csv", row.names=FALSE)
df2010 <- read.csv("population_2010_preprocessed.csv")
df2005 <- read.csv("population_2005_preprocessed.csv")
df2005$indicator_id <- as.integer(df2005$indicator_id)
df2010$indicator_id <- as.integer(df2010$indicator_id)

indicators <- unique(df2010[,c("indicator_id", "indicator")])
indicators_spanish <- unique(df2005[,c("indicator_id", "indicator")])

df <- merge(indicators, indicators_spanish, by="indicator_id", all.x=TRUE)
names(df)[names(df) == "indicator.x"] <- "indicator_english"
names(df)[names(df) == "indicator.y"] <- "indicator_spanish"

write.csv(df, "indicators_translation.csv")

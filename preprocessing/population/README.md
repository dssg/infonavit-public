#Population

Many of our data is in absolute numbers (e.g. schools in X municipality). It's important to take into account the population of each municipality to compare them accordingly.

Our [population data](http://www3.inegi.org.mx/sistemas/descarga/) comes from INEGI, which has done the census every 5 years since 1995.

A copy of the original data (compressed) is available on this folder.

In order to have better data for our analysis, the census data was preprocessed to generate one file for each municipality (the original data contains one file per state), to translate column names and row values.

Also a new column `cve` was created, that column serves as an identifier for each population in Mexico.

In order to generate the preprocessed files from source, execute the following command (R is required):

`Rscript preprocess_all.R`


That will generate one file for each year the census has been done. The indicators are available in English for the 2010 version. A table (id,indicator Spanish, indicator English) can be generated using the following command (the previous command is required to be ran before):

`Rscript translate_indicators.R`

To merge the data in a single file:

`Rscript merge_all.R`

To replace the indicators in the previous file  for their English versions:

`Rscript replace_indicators.R population_preprocessed.csv indicators_translation.csv`
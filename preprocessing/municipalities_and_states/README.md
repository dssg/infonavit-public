#State and municipalities codes in Mexico

INEGI assigns codes for each state and municipality in Mexico. Many of the datasets contain those codes but others contain only names.

In order to convert from code to name (or viceversa) two files are generated using INEGI's data.

The source files are available [here](http://www.inegi.org.mx/geo/contenidos/geoestadistica/m_geoestadistico_2014.aspx):

Marco Geoestadístico 2014 versión 6.2 (DENUE 01/2015)

* Áreas Geoestadísticas Estatales (7.6 MB)
* Áreas Geoestadísticas Municipales (37.8 MB)

Some cleaning was done in both files, producing the `states_preprocessed.csv` and `municipalities_preprocessed.csv`

* Accents were deleted
* Lowercase strings
* ñ converted to n


In order to produce the files from source the follow needs to be done (R installation is required):

`bash preproces_files.sh`

The `create_states.sql`, `create_municipalities.sql`, `load_states.sh` and `load_municipalities.sh` are used to upload the data to a remote database.

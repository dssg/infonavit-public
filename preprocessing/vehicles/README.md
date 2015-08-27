##Vehicle registry

To get the data, open the data source URL and go to:

`Indicadores/Por fuente-proyecto/Registros administrativos/Estadísticas de Vehículos de Motor Registrados`

There are several versions for the same dataset, the English tsv version was used for this project.

To produce the preprocessed version from raw data, store the zip files inside a `data` folder and run:

`Rscript preprocess.R`

Data source: [INEGI](http://www3.inegi.org.mx/sistemas/descarga/)
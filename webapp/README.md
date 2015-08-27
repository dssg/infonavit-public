#Prototype

Instructions for running the prototype can be found in the root README file.

##Notes

###About the map

The map displayed in the prototype uses a public [CartoDB visualization](https://edublancas.cartodb.com/viz/f92a1568-3542-11e5-a2b8-0e5e07bb5d8a/map)*. Right now, the visualization is hosted in one of the team member's account, but it can easily be changed following the next steps:

1. [Download the colonia shapefiles.](http://www.numeroslocos.com/2013/07/10/shapefile/)
2. Upload the data to a CartoDB visualization**
3. Modify the static/map_handler.js file (lines 43 and 47)

Line 43:
`var query = "SELECT * FROM new_table_name WHERE objectid="+objectid;`

Line 47:
`var sql = new cartodb.SQL({ user: 'new_username' });`

*The data is hosted in CartoDB but includes only a public dataset from INEGI, no sensitive data was uploaded.

**Although CartoDB accepts shapefiles, it threw an error when uploading the dataset, in such case, first convert the original shapefiles to geojson. [Instructions here.](http://ben.balter.com/2013/06/26/how-to-convert-shapefiles-to-geojson-for-use-on-github/)
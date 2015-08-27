#!/bin/bash 
subdir=$1

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

        echo "subdir: $subdir"
        cd "$subdir"
        #replace all spaces with underscores
        for name in *\ *; do mv  "$name" "${name// /_}"; done

        #convert roads
        roads=`ls *.shp | grep -i "Eje_de_calle"`
        ogr2ogr -f "ESRI Shapefile" roads.shp "$roads" -t_srs "$PROJECTION" -overwrite -lco ENCODING=latin1

        #convert urbana
        urbana=`ls *.shp | grep -i "Localidad_urbana"`
        ogr2ogr -f "ESRI Shapefile" urbana.shp "$urbana" -t_srs "$PROJECTION" -overwrite -lco ENCODING=latin1 -nlt MULTIPOLYGON

        #convert denue
        denue=`ls *.shp | grep -i "DENUE"`
        ogr2ogr -f "ESRI Shapefile" denue.shp "$denue" -t_srs "$PROJECTION" -overwrite -lco ENCODING=latin1

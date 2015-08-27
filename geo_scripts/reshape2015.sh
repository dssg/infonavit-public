#!/bin/bash  
subdir=$1

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

        echo "subdir: $subdir"
        cd "$subdir"
        #replace all spaces with underscores
#        for name in *\ *; do mv  "$name" "${name// /_}"; done


        #convert denue
        denue=`ls *.shp | grep -v "zip" |grep  "DENUE"`
        ogr2ogr -f "ESRI Shapefile" denue.shp "$denue" -t_srs "$PROJECTION" -overwrite -lco ENCODING=latin1



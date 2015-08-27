#!/bin/bash  
subdir=$1

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
	
        echo "subdir: $subdir"
        cd "$subdir"
	cd "DENUE"
	cd "shp"
	#replace all spaces with underscores
#        for name in *\ *; do mv  "$name" "${name// /_}"; done
        find -name "* *" -type f | rename 's/ /_/g'

        #convert denue
        denue=`ls *.shp`
        ogr2ogr -f "ESRI Shapefile" denue_converted.shp "$denue" -t_srs "$PROJECTION" -overwrite -lco ENCODING=latin1



#/bin/bash -x
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/scratch/denue_01_2015"
#PROCS=$2
PROCS=6

#change to working dir
cd $DIR


for name in *\ *; do mv "$name" "${name// /_}"; done

#extract all files
find $DIR/* -maxdepth 0 -type d | xargs --max-procs=$PROCS -n 1 -i /bin/bash -x -c 'cd $0;pwd; ls | xargs -n1 unzip ' {}


sleep 1
find $DIR/* -maxdepth 0 -type d | xargs --max-procs=$PROCS -n 1 -i /home/kackermann/infonavit/geo_scripts/reshape2015.sh {} 2>&1 | grep -v "of field latitud of feature" | grep -v "of field longitud of feature"



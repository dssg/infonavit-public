#/bin/bash 
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/scratch/denue_07_2010"
#PROCS=$2
PROCS=6

#change to working dir
cd $DIR

#extract all files
ls | xargs --max-procs=$PROCS -n 1 -i unzip {}

for name in *\ *; do mv "$name" "${name// /_}"; done

sleep 1

find $DIR/* -maxdepth 0 -type d | xargs --max-procs=$PROCS -n 1 -i /home/kackermann/infonavit/geo_scripts/reshape.sh {}



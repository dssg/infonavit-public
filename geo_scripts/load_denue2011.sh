#/bin/bash -x
# Klaus Ackermann
# Edited by Andy Keller
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/data/infonavit/DENUE_MARZO-2011"
#PROCS=$2
PROCS=6

#change to working dir
cd $DIR

#find -name "* *" -type f | rename 's/ /_/g'
#for name in *\*; do mv "$name" "${name// /_}"; done

# extract all files
# find $DIR/* -maxdepth 0 -type d | xargs --max-procs=$PROCS -n 1 -i /bin/bash -x -c 'cd $0;pwd; ls *.zip | xargs -n1 unzip ' {}

sleep 1

find $DIR/* -maxdepth 0 -type d | xargs --max-procs=$PROCS -n 1 -i /home/tkeller/infonavit/geo_scripts/reshape2011.sh {}



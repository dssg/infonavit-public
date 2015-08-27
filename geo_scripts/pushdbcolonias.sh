#!/bin/bash -x
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/data/infonavit/shapefiles/Colonias"
#PROCS=$2
PROCS=1

#change to working dir
cd $DIR

USERNAME=infonavit

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"




shp2pgsql -d -I -s 4326 -W "latin1" Colonias.shp colonias | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit | grep -v "INSERT 0 1"


$RUN_ON_MYDB <<SQL
drop table if exists colonias_centroid;
create table colonias_centroid as 
select gid,postalcode,st_name,mun_name,sett_name,sett_type,ST_SetSRID(ST_Centroid(geom),4326) as geom
	from colonias;
ALTER TABLE colonias_centroid ADD PRIMARY KEY (gid);
CREATE INDEX idx_colonias_centroid_geom ON colonias_centroid USING GIST(geom);
SQL


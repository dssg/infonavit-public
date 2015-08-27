#!/bin/bash -x
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/scratch/denue_07_2010"
#PROCS=$2
PROCS=1

#change to working dir
cd $DIR


USERNAME=infonavit

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# create the urban table
$RUN_ON_MYDB <<SQL
SELECT DropGeometryColumn('','urban2010','geom');
DROP TABLE if exists "urban2010tmp";
CREATE TABLE "urban2010tmp" (gid serial,
	"__oid" int2,
	"cvegeo" varchar(9),
	"geografico" varchar(9),
	"fechaact" varchar(7),
	"geometria" varchar(4),
	"institucio" varchar(5),
	"nomloc" varchar(50));
ALTER TABLE "urban2010tmp" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','urban2010tmp','geom','4326','MULTIPOLYGON',2);
SQL


sleep 1

#extract all files
#use the first file to create the table
#load all files except the last
find $DIR  -type f -name urbana.shp | sort | sed '$d' | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -s 4326 -W "latin1" $0 urban2010tmp | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"

#add the last and create the index
find $DIR  -type f -name urbana.shp | sort | tail -n 1 | xargs --max-procs=$PROCS -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -I -s 4326 -W "latin1" $0 urban2010tmp | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"


$RUN_ON_MYDB <<SQL
DROP TABLE if exists "urban2010";
create table urban2010 as
SELECT gid,__oid,cvegeo,geografico,fechaact,geometria,institucio,nomloc,ST_Multi(ST_Union(ST_Buffer(ST_SnapToGrid(geom,0.0000001),0.0))) AS geom
from urban2010tmp
group by gid,__oid,cvegeo,geografico,fechaact,geometria,institucio,nomloc;

ALTER TABLE "urban2010" ADD PRIMARY KEY (gid);
CREATE INDEX idx_urban2010_geom ON urban2010 USING GIST(geom);
SQL


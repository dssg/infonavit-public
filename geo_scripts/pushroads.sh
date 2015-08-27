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

# create the roads table
$RUN_ON_MYDB <<SQL
SELECT DropGeometryColumn('','roads2010','geom');
DROP TABLE if exists "roads2010";
CREATE TABLE "roads2010" (gid serial,
	"__oid" int4,
	"cvegeo" varchar(9),
	"cvevial" varchar(5),
	"geografico" varchar(8),
	"destino" varchar(100),
	"fechaact" varchar(7),
	"geometria" varchar(5),
	"institucio" varchar(20),
	"nomvial" varchar(100),
	"sentido" varchar(12),
	"tipovial" varchar(23));
ALTER TABLE "roads2010" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','roads2010','geom','4326','MULTILINESTRING',2);
SQL


sleep 1

#extract all files
#use the first file to create the table
#load all files except the last
find $DIR  -type f -name roads.shp | sort | sed '$d' | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -s 4326 -W "latin1" $0 roads2010 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"

#add the last and create the index

find $DIR  -type f -name roads.shp | sort | tail -n 1 | xargs --max-procs=$PROCS -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -I -s 4326 -W "latin1" $0 roads2010 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"


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
SELECT DropGeometryColumn('','denue2010','geom');
DROP TABLE if exists"denue2010";
CREATE TABLE "denue2010" (gid serial,
	"nom_estab" varchar(75),
	"nom_propie" varchar(75),
	"clase_act" varchar(6),
	"desc_act" varchar(160),
	"pers_ocup" varchar(18),
	"calle" varchar(75),
	"numero_ext" varchar(8),
	"edificio" varchar(12),
	"numero_int" varchar(8),
	"colonia" varchar(75),
	"centro_com" varchar(75),
	"num_local" varchar(5),
	"cod_postal" varchar(5),
	"entidad" varchar(31),
	"municipio" varchar(40),
	"localidad" varchar(90),
	"ageb" varchar(4),
	"manzana" varchar(3),
	"telefono" varchar(14),
	"correoelec" varchar(68),
	"www" varchar(70),
	"tipo_estab" varchar(11),
	"latitud" varchar(12),
	"longitud" varchar(12),
	"__oid" int4);
ALTER TABLE "denue2010" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','denue2010','geom','4326','POINT',2);
SQL


sleep 1

#extract all files
#use the first file to create the table
#load all files except the last
find $DIR  -type f -name denue.shp | sort | sed '$d' | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -s 4326 -W "latin1" $0 denue2010 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"

#add the last and create the index
find $DIR  -type f -name denue.shp | sort | tail -n 1 | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -I -s 4326 -W "latin1" $0 denue2010 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"


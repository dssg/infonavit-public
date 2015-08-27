#!/bin/bash -x
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/data/infonavit/DENUE_JUNIO-2012"
#PROCS=$2
PROCS=1

#change to working dir
cd $DIR


USERNAME=infonavit

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# create the urban table
$RUN_ON_MYDB <<SQL
SELECT DropGeometryColumn('','denue2012','geom');
DROP TABLE if exists denue2012;
CREATE TABLE denue2012 (gid serial,
"d_llave" int4,
"nic" varchar(9),
"nop" varchar(11),
"cve_ent" varchar(2),
"entidad" varchar(40),
"cve_mun" varchar(3),
"municipio" varchar(100),
"cve_loc" varchar(4),
"localidad" varchar(100),
"ageb" varchar(4),
"manzana" varchar(3),
"nom_estab" varchar(150),
"nom_propie" varchar(150),
"tipo_calle" varchar(40),
"calle" varchar(100),
"tipo_vial1" varchar(40),
"calle_1" varchar(100),
"tipo_vial2" varchar(40),
"calle_2" varchar(100),
"tipo_vial3" varchar(40),
"calle_3" varchar(100),
"numero_ext" varchar(35),
"edificio" varchar(35),
"numero_int" varchar(35),
"tipo_asent" varchar(25),
"colonia" varchar(75),
"cod_postal" varchar(5),
"telefono1" varchar(20),
"telefono2" varchar(20),
"ext_tel1" varchar(6),
"ext_tel2" varchar(6),
"fax" varchar(20),
"clase_act" varchar(25),
"desc_act" varchar(100),
"centro_com" varchar(75),
"num_local" varchar(35),
"correoelec" varchar(75),
"www" varchar(75),
"correoele2" varchar(75),
"tipo_estab" varchar(1),
"tipo_ue" varchar(1),
"est_perocu" int2,
"des_perocu" varchar(20),
"estatus" varchar(1),
"alta" varchar(15),
"latitud" numeric,
"longitud" numeric);
ALTER TABLE denue2012 ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','denue2012','geom','4326','POINT',2);
SQL


sleep 1

#extract all files
#use the first file to create the table
#load all files except the last
find $DIR  -type f -name denue_converted.shp | sort | sed '$d' | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -s 4326 -W "latin1" $0 denue2012 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"

#add the last and create the index
find $DIR  -type f -name denue_converted.shp | sort | tail -n 1 | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -I -s 4326 -W "latin1" $0 denue2012 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"


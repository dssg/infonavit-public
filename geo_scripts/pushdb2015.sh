#!/bin/bash -x
# Klaus Ackermann
# conversion of denue files

PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

#DIR=$1
DIR="/mnt/scratch/denue_01_2015"
#PROCS=$2
PROCS=1

#change to working dir
cd $DIR


USERNAME=infonavit

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# create the urban table
$RUN_ON_MYDB <<SQL
SELECT DropGeometryColumn('','denue2015','geom');
DROP TABLE if exists"denue2015";
CREATE TABLE denue2015
(
  gid serial NOT NULL,
  id integer,
  nom_estab character varying(150),
  raz_social character varying(150),
  codigo_act character varying(25),
  nombre_act character varying(250),
  per_ocu character varying(20),
  tipo_vial character varying(40),
  nom_vial character varying(100),
  tipo_v_e_1 character varying(40),
  nom_v_e_1 character varying(100),
  tipo_v_e_2 character varying(40),
  nom_v_e_2 character varying(100),
  tipo_v_e_3 character varying(25),
  nom_v_e_11 character varying(75),
  numero_ext character varying(35),
  letra_ext character varying(35),
  edificio character varying(35),
  edificio_e character varying(35),
  numero_int character varying(35),
  letra_int character varying(35),
  tipo_asent character varying(25),
  nomb_asent character varying(75),
  tipocencom character varying(30),
  nom_cencom character varying(75),
  num_local character varying(35),
  cod_postal character varying(5),
  cve_ent character varying(2),
  entidad character varying(40),
  cve_mun character varying(3),
  municipio character varying(100),
  cve_loc character varying(4),
  localidad character varying(100),
  ageb character varying(4),
  manzana character varying(3),
  telefono character varying(20),
  correoelec character varying(75),
  www character varying(75),
  tipounieco character varying(8),
  latitud numeric,
  longitud numeric,
  fecha_alta character varying(15),
  geom geometry(Point,4326),
  CONSTRAINT denue2015_pkey PRIMARY KEY (gid)
)
SQL


sleep 1

#extract all files
#use the first file to create the table
#load all files except the last
find $DIR  -type f -name denue.shp | sort | sed '$d' | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -s 4326 -W "latin1" $0 denue2015 | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"

#add the last and create the index
find $DIR  -type f -name denue.shp | sort | tail -n 1 | xargs -n 1 -i sh -c 'echo "File:"$0; shp2pgsql -a -I -s 4326 -W "latin1" $0 denue2015| psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit ' {} | grep -v "INSERT 0 1"


#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial cuvs_ruv data
$RUN_ON_MYDB <<SQL
drop table if exists cuvs;
SQL

TABLE=$(cat create_cuvs.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy cuvs (latitud,longitud,cuv,numerorecamaras,areaterreno,m2construccion,tipologia,nombreestado,nombremunicipio,colonia,porcentajeravancevivienda,fechadtu) FROM /mnt/data/infonavit/data/CUVS_RUV_sqlformat.csv WITH CSV HEADER DELIMITER ',';

ALTER TABLE cuvs ALTER COLUMN cuv TYPE BIGINT USING Cast(cuv as bigint);

create index idx_cuvs_cuv on cuvs(cuv);
SQL



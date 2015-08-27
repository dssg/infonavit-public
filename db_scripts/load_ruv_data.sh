#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial ruv data
$RUN_ON_MYDB <<SQL
drop table if exists ruv;
SQL

TABLE=$(cat create_ruv.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy ruv (cv_cuv,in_clasificado,tx_nodo,tx_oferta,fh_habitabilidad,in_zona_riesgo,cv_tipo_vivienda,fh_pago_registro,cv_codigo_postal,cv_municipio,tx_municipio) FROM /mnt/data/infonavit/new_data_june2/REGISTRORUV_UTF8_PIPES.txt WITH CSV HEADER DELIMITER '|';

ALTER TABLE ruv ALTER COLUMN cv_cuv TYPE bigint using CAST((CASE WHEN trim(cv_cuv)<>'' then trim(cv_cuv) else NULL END) as bigint);
create index idx_ruv_cuv on ruv(cv_cuv);

SQL



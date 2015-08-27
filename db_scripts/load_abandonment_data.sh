#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial abandonment data
$RUN_ON_MYDB <<SQL
drop table if exists abandonment;
SQL

TABLE=$(cat create_abandonment.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy abandonment (cv_credito,nu_omisos,cv_estatus_contable,cv_regimen,cv_pool_describe,tx_situacion_vivienda,fh_periodo) FROM /mnt/data/infonavit/new_data_june2/CARTERA_ABANDONADA_UTF8_PIPES.txt WITH CSV HEADER DELIMITER '|';

SQL



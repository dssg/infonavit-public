#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial municipalities data
$RUN_ON_MYDB <<SQL
drop table if exists dates;
SQL

TABLE=$(cat create_dates.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy dates (cv_credito,nu_anio_ejercicio,tx_situacion_vivienda,fec_ini,fec_liq) FROM dates.csv WITH CSV HEADER DELIMITER ',';

SQL

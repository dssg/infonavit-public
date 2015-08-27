#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial abandonment_timeline data
$RUN_ON_MYDB <<SQL
drop table if exists abandonment_timeline;
SQL

TABLE=$(cat create_abandonment_timeline.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy abandonment_timeline (nu_omisos,im_saldo,fh_periodo,delegacion,cv_credito,rango_omisos,cv_estatus_contable,cv_regimen,tx_situacion_vivienda) FROM ABANDONED_TIMELINE.txt WITH CSV HEADER DELIMITER '|';

SQL



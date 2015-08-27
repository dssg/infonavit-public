#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial cuvs_ruv data
$RUN_ON_MYDB <<SQL
drop table if exists risk_index;
SQL

TABLE=$(cat create_risk_index.sql )
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy risk_index (cv_credito,nu_ano_ejercicio,indece_de_riesgo) FROM /mnt/data/infonavit/risk/index_risk_clean.csv WITH CSV HEADER DELIMITER ';' NULL AS ' ';

SQL



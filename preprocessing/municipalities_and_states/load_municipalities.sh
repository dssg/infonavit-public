#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial municipalities data
$RUN_ON_MYDB <<SQL
drop table if exists municipalities;
SQL

TABLE=$(cat create_municipalities.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy municipalities (cve_ent,cve_mun,nom_mun,cve) FROM municipalities_preprocessed.csv WITH CSV HEADER DELIMITER ',';

SQL



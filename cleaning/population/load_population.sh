#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial population data
$RUN_ON_MYDB <<SQL
drop table if exists population;
SQL

TABLE=$(cat create_population.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy population (cve,cve_ent,nom_ent,cve_mun,nom_mun,type_level_1,type_level_2,type_level_3,indicator_id,indicator,measurement,year) FROM population_cleaned.csv WITH CSV HEADER DELIMITER ',';

SQL



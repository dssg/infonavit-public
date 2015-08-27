#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial homicides data
$RUN_ON_MYDB <<SQL
drop table if exists homicides;
SQL

TABLE=$(cat create_homicides.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy homicides (cve,cve_ent,nom_ent,year,total_homicides,male_homicides,female_homicides,total_population,male_population,female_population) FROM homicides_preprocessed.csv WITH CSV HEADER DELIMITER ',';

SQL



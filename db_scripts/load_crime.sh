#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial crime data
$RUN_ON_MYDB <<SQL
drop table if exists crime;
SQL

TABLE=$(cat create_crime.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy crime (year,state,municipality,property_crimes,sexual_assault,homicide,injuries,other,kidnapping,robbery,cattle_raiding,highway_robbery,bank_robbery,code) FROM /mnt/data/infonavit/crime_data/crime_geocoded.csv WITH CSV HEADER DELIMITER ',';

SQL



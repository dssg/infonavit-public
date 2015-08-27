#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial states data
$RUN_ON_MYDB <<SQL
drop table if exists states;
SQL

TABLE=$(cat create_states.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy states (cve_ent,nom_ent) FROM states_preprocessed.csv WITH CSV HEADER DELIMITER ',';

SQL



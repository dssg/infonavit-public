#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial population_features data
$RUN_ON_MYDB <<SQL
drop table if exists population_features;
SQL

TABLE=$(cat create_population_features.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy population_features (cve,cve_ent,cve_mun,nom_mun,avg_degree_schooling_15_over_2000,avg_degree_schooling_15_over_2005,avg_degree_schooling_15_over_2010,households_2000,households_2005,households_2010,male_female_ratio_1995,male_female_ratio_2000,male_female_ratio_2005,male_female_ratio_2010,percentage_population_15_29_1995,percentage_population_15_29_2000,percentage_population_15_29_2005,percentage_population_15_29_2010,percentage_population_60_over_1995,percentage_population_60_over_2000,percentage_population_60_over_2005,percentage_population_60_over_2010,total_population_1995,total_population_2000,total_population_2005,total_population_2010,total_population_men_1995,total_population_men_2000,total_population_men_2005,total_population_men_2010,total_population_woman_1995,total_population_woman_2000,total_population_woman_2005,total_population_woman_2010) FROM population_features.csv WITH CSV HEADER DELIMITER ',';

SQL



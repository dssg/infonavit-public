#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

echo "Dropping sub tables"
# Drop all the sub feature tables
$RUN_ON_MYDB <<SQL
DROP TABLE IF EXISTS clean_loans_by_year;
DROP TABLE IF EXISTS personal_features;
DROP TABLE IF EXISTS loan_features;
DROP TABLE IF EXISTS colonia_features;
DROP TABLE IF EXISTS house_features;
DROP TABLE IF EXISTS location_features;
DROP TABLE IF EXISTS location_naics_features;
DROP TABLE IF EXISTS feature_geo_distance_denue_by_year_with_past;
DROP TABLE IF EXISTS feature_geo_distance_denue_naics_by_year_with_past;
SQL

echo "Creating clean_loans_by_year"
# Recreate the sub_tables
$RUN_ON_MYDB -f create_clean_loans_by_year.sql

echo "Creating colonia_features"
$RUN_ON_MYDB -f create_colonia_features.sql

echo "Creating feature_geo_distance_denue_by_year_with_past"
$RUN_ON_MYDB -f create_feature_geo_distance_denue_by_year_with_past.sql

echo "Creating create_feature_geo_distance_denue_naics_by_year_with_past"
$RUN_ON_MYDB -f create_feature_geo_distance_denue_naics_by_year_with_past.sql

echo "Creating create_location_features"
$RUN_ON_MYDB -f create_location_features.sql

echo "Creating location_naics_features"
$RUN_ON_MYDB -f create_location_naics_features.sql

echo "Creating personal_features"
$RUN_ON_MYDB -f create_personal_features.sql

echo "Creating house_features"
$RUN_ON_MYDB -f create_house_features.sql

#no idea why a different call is neccesary
echo "Creating loan_features"
$RUN_ON_MYDB -f create_loan_features.sql

echo "Dropping master_loan_features"
# Drop the master features table
$RUN_ON_MYDB <<SQL
DROP TABLE IF EXISTS master_loan_features_version4;
SQL
echo "Creating master_loan_features"
# Create the master features table
$RUN_ON_MYDB -f create_master_loan_features.sql

$RUN_ON_MYDB <<SQL
DELETE FROM master_loan_features_version4 WHERE cur_year > abandon_year;
SQL

$RUN_ON_MYDB <<SQL
CREATE INDEX master_year_credit_past_idx_4 ON master_loan_features_version4 (cv_credito, cur_year, past);
SQL
$RUN_ON_MYDB <<SQL
CLUSTER master_loan_features_version4 USING master_year_credit_past_idx_4;
SQL

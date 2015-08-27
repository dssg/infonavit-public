#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"


$RUN_ON_MYDB <<SQL
CLUSTER personal_features USING idx_personal_features_cv_credito_pf_cur_year_pf_past_pf;
ANALYZE personal_features;
SQL

$RUN_ON_MYDB <<SQL
CLUSTER loan_features USING idx_loan_features_cv_credito_lf_cur_year_lf_past_lf;
ANALYZE loan_features;
SQL

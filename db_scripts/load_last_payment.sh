#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the deaths table
$RUN_ON_MYDB <<SQL
drop table if exists last_payments;
SQL

#TABLE=$(cat create_last_payments.sql)
#$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
CREATE TABLE last_payments AS (
WITH summary AS (
    SELECT cv_credito, 
    	   year, 
	   month, 
	   pe_total, 
	   tp_neg_bool,
           ROW_NUMBER() OVER (PARTITION BY cv_credito 
	                      ORDER BY year desc, month desc) AS rn
    FROM payments_clean
    WHERE pe_total > 0 and tp_neg_bool != 1) 
SELECT summary.cv_credito, summary.year, summary.month
	FROM summary
	WHERE rn = 1);
SQL

#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the deaths table
$RUN_ON_MYDB <<SQL
drop table if exists loans_with_durations;
SQL



$RUN_ON_MYDB <<SQL
CREATE TABLE loans_with_durations AS (
select l.*,
	p.pf_max,
	p.tp_neg_bool,
	p.year,
	p.month,
	--r.indece_de_riesgo,
	lp.year as lp_year,
	lp.month as lp_month,
	--e.ct_ecuve as e_score,
	CASE WHEN (l.var42 IS NOT NULL) THEN
		cast(lp.year - l.var11 as double precision) + cast(lp.month as double precision) / 12.0 
	     WHEN (l.var42 IS NULL AND p.pf_max > 0.0 AND p.tp_neg_bool != 1) THEN
	     	cast(2015 - l.var11 as double precision)
	     WHEN (l.var42 IS NULL AND p.pf_max = 0.0 AND p.tp_neg_bool != 1) THEN
		  cast(lp.year - l.var11 as double precision) + cast(lp.month as double precision) / 12.0 
	END as duration
FROM loans l
	      	--JOIN risk_index r ON (l.var41 = cast(r.cv_credito as bigint))
		   JOIN last_payments lp ON (l.var41 = lp.cv_credito)
		   JOIN payments_clean p ON (l.var41 = p.cv_credito and p.year = lp.year and p.month = lp.month)
		   WHERE l.var11 != 0);
SQL

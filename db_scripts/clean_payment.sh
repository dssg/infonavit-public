#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial cuvs_ruv data
$RUN_ON_MYDB <<SQL
DROP TABLE IF EXISTS payments_clean;
create table payments_clean as
with subwindow as (
	select 		
		CAST(cv_credito as bigint) as cv_credito, nu_ano_ejercicio,tx_situacion_vivienda,year,month,
		sum(pe) over w as pe_total,
		max(pf) over w as pf_max,
		sum(CASE WHEN tp = 1 THEN pe ELSE 0 END)  over w   as pe_tp_1,
		sum(CASE WHEN (tp=2 or tp=3)  THEN pe ELSE 0 END)  over w   as pe_tp_2,
		sum(CASE WHEN tp < 1 THEN pe ELSE 0 END)  over w  as pe_neg,
		SUM(CASE WHEN tp = 1 THEN 1 ELSE 0 END)  over w  as tp_1_count,
		SUM(CASE WHEN (tp=2 or tp=3)  THEN 1 ELSE 0 END)  over w  as tp_2_count,  
		SUM(CASE WHEN tp <= 0 THEN 1 ELSE 0 END)  over w as tp_neg_count,
		CASE WHEN (SUM(CASE WHEN tp = 1 THEN 1 ELSE 0 END)  over w)>0 THEN 1 ELSE 0 END as tp_1_bool,
		CASE WHEN (SUM(CASE WHEN (tp=2 or tp=3) THEN 1 ELSE 0 END)  over w)>0 THEN 1 ELSE 0 END as tp_2_bool,
		CASE WHEN (SUM(CASE WHEN tp <= 0 THEN 1 ELSE 0 END)  over w)>0 THEN 1 ELSE 0 END as tp_neg_bool,
		min(pro) over w as pro_min,
		ROW_NUMBER() over w as rn

	from payments
	where pe is not null -- filter out empty rows
	window w AS (partition by cv_credito, year, month order by tp desc range between unbounded preceding and unbounded following)	
)
select cv_credito,nu_ano_ejercicio,tx_situacion_vivienda,year,month, pe_total, pf_max,pe_tp_1,pe_tp_2, pe_neg, tp_1_count, tp_2_count, tp_neg_count, tp_1_bool,tp_2_bool,tp_neg_bool, pro_min from subwindow where rn=1;

CREATE INDEX idx_payments_clean_cvym
  ON payments_clean
    USING btree
      (cv_credito, year, month);
ALTER TABLE payments_clean CLUSTER ON idx_payments_clean_cvym;
ANALYZE payments;

SQL






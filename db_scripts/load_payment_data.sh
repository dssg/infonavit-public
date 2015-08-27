#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial cuvs_ruv data
$RUN_ON_MYDB <<SQL
drop table if exists payments;
SQL

TABLE=$(cat create_payments.sql)
$RUN_ON_MYDB -c "$TABLE"

$RUN_ON_MYDB <<SQL
\copy payments(cv_credito,nu_ano_ejercicio,tx_situacion_vivienda,year,month,pe,pf,tp,pro,reest,mora,deuda) FROM /mnt/data/infonavit/payments/payments_all_years.csv DELIMITER ';'  NULL AS '';
SQL

#\copy payments(cv_credito,nu_ano_ejercicio,tx_situacion_vivienda,year,month,pe,pf,tp,pro,reest,mora,deuda) FROM /mnt/data/infonavit/payments/payments_test.csv DELIMITER ';'  NULL AS '';

#cd /mnt/data/infonavit/payments/
#ls payments_split.* | xargs -i -n 1 psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit -c "\\copy payments(cv_credito,nu_ano_ejercicio,tx_situacion_vivienda,year,month,pe,pf,tp,pro,reest,mora,deuda) FROM "{}" DELIMITER ';'  NULL AS ''"

$RUN_ON_MYDB <<SQL
create index idx_payments_cvym on payments(cv_credito,year,month);
CLUSTER payments USING idx_payments_cvym;
ANALYZE payments;
SQL



#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial ruv data
$RUN_ON_MYDB <<SQL
drop table if exists subcuenta;
SQL

TABLE=$(cat create_subcuenta.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy subcuenta (cv_credito, im_saldo_subcuenta, tx_oferente, cv_oferente, tx_tipo_credito) FROM /mnt/data/infonavit/subcuenta/SUBCUENTA_OFERENTES.txt WITH CSV HEADER DELIMITER '|';


create index idx_subcuenta_cv_credito on subcuenta(cv_credito);


drop table if exists subcuenta_clean;
create table subcuenta_clean as 
with duplicates as (

	select cv_credito, im_saldo_subcuenta, tx_oferente, cv_oferente,tx_tipo_credito,count(*) over w as ct, row_number() over w as rn
	from subcuenta
	window w as (partition by cv_credito range between unbounded preceding and unbounded following)


)
select cv_credito, im_saldo_subcuenta, tx_oferente, cv_oferente,tx_tipo_credito from duplicates where ct=1; 

ALTER TABLE subcuenta_clean ADD PRIMARY KEY (cv_credito);

SQL


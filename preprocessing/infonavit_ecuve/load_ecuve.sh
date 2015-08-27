#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial ecuve data
$RUN_ON_MYDB <<SQL
drop table if exists ecuve;
SQL

TABLE=$(cat create_ecuve.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy ecuve (id_ecuve,cv_rgnicvv,cv_nss,id_vivienda,cv_avaluo,cv_convivencia,cv_credito,cve,cv_paquete,cv_ofr,cv_entfdr,fh_inf,id_tpovvn,id_clsvvn,id_rng,id_tpocrd,id_fchinf,id_aracns,ct_pnthsp,ct_pntprq,ct_pntmrc,ct_pntesc,ct_pnteqp,ct_pntref,ct_pnttrn,ct_pntvld,ct_suphab,ct_gbs,ct_pnticv,ct_pntisa,ct_hogdig,ct_cldvvn,ct_pntaga,ct_pntenr,ct_pntcmd,ct_ecuve,ct_fchpo) FROM ecuve.csv WITH CSV HEADER DELIMITER ',';

SQL
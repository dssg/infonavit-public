#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the deaths table
$RUN_ON_MYDB <<SQL
drop table if exists deaths;
SQL

TABLE=$(cat create_deaths.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy deaths (id_given,ent_regis,mun_regis,ent_resid,mun_resid,tloc_resid,ent_ocurr,mun_ocurr,tloc_ocurr,causa_def,lista_mex,sexo,edad,dia_ocurr,mes_ocurr,anio_ocur,dia_regis,mes_regis,anio_regis,dia_nacim,mes_nacim,anio_nacim,ocupacion,escolarida,edo_civil,presunto,ocurr_trab,lugar_ocur,necropsia,asist_medi,sitio_ocur,cond_cert,nacionalid,derechohab,embarazo,rel_emba,horas,minutos,capitulo,grupo,lista1,gr_lismex,vio_fami,area_ur,edad_agru,complicaro,dia_cert,mes_cert,anio_cert,maternas,lengua,cond_act,par_agre,ent_ocules,mun_ocules,dis_re_oax) FROM /mnt/data/infonavit/deaths/defun13.csv WITH CSV HEADER DELIMITER ',';

SQL

#!/bin/bash -x
# conversion of denue files



USERNAME=infonavit

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# create the urban table
$RUN_ON_MYDB <<SQL
ALTER table denue2015 rename column codigo_act to clase_act;

SQL




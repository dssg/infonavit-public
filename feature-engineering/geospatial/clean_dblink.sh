#!/bin/bash -x
# The username is required as parameter

USERNAME="infonavit"

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"


#terminate all db_link conections if the script was interrupted
$RUN_ON_MYDB <<SQL
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'infonavit'
  AND client_addr is null;
SQL

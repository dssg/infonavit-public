#!/bin/bash -x
# The username is required as parameter

USERNAME="infonavit"

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the deaths table
$RUN_ON_MYDB <<SQL
drop table if exists feature_geo_distance_denue2010;
SQL

TABLE=$(cat create_feature_geo_distance_denue2010.sql )
$RUN_ON_MYDB -c "$TABLE"

STATEMENT=$(cat distance_query.sql)

sleep 5

$RUN_ON_MYDB <<SQL
SELECT parallelsql
(	'infonavit',				--database
	'colonias_centroid',			--table
	'map.gid',				--variable to partition by processes	
        '$STATEMENT',				--the statement to executed in parallel 
	'feature_geo_distance_denue2010',	--result table, has to be created first
	'map',					--table alias used for split column
	24,					--number of cores
	'1=1'					--replace string in the query
);			
SQL

#terminate all db_link conections if the script was interrupted
$RUN_ON_MYDB <<SQL
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'infonavit'
  AND client_addr is null;
SQL

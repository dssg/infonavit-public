#!/bin/bash -x
# The username is required as parameter

USERNAME="infonavit"

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL
drop table if exists feature_geo_distance_denue_by_year;
SQL


$RUN_ON_MYDB <<SQL
create table feature_geo_distance_denue_by_year as
select 2010 as year,* from feature_geo_distance_denue2010
union all
select 2011 as year,* from feature_geo_distance_denue2011
union all
select 2012 as year,* from feature_geo_distance_denue2012
union all
select 2013 as year,* from feature_geo_distance_denue2013
union all
select 2014 as year,* from feature_geo_distance_denue2015
union all
select 2015 as year,* from feature_geo_distance_denue2015;
alter table feature_geo_distance_denue_by_year add primary key (year,coloniaid);
SQL

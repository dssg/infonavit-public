#!/bin/bash -x

RUN_ON_MYDB="psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL
insert into feature_geo
select loc.id as loanid, mapgid, distance from 
	feature_geometry_only_comb
 ab join loans_loc loc on ab.geom=loc.geom
SQL






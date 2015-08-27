#!/bin/bash -x

RUN_ON_MYDB="psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL
drop table if exists feature_geometry_only_2;
create table feature_geometry_only_2 as
with points as (
SELECT *,
        ROW_NUMBER() OVER (PARTITION BY id order by distance) as rn
        from
        (
		select  error.id,
			error.geom,
			map.gid as mapgid,
			ST_Distance_Spheroid(error.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]') as distance   
                from 
                        geom_outside as error,
                        urban2010 as map
                Where                
			error.id >= 119309 and error.id <= 238619 and
                        ST_DWithin(error.geom,map.geom,0.5) 
                        
        ) sub
)
select id,geom,mapgid,distance from points where rn=1
SQL






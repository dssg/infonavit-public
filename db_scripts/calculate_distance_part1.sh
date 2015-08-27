#!/bin/bash -x


RUN_ON_MYDB="psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL
-- find all location that are allready inside an urban zone
drop table if exists feature_geo;
create table feature_geo as
select 
	loc.id as loanid, 
	map.gid as mapgid,
	0.0  as distance_urban
from
     urban2010 as map,
     loans_loc as loc
where
     ST_Within(loc.geom,map.geom) and loc.hotspot=1
group by
        loc.id, map.gid;
--limit 10;

delete from feature_geo where loanid=5633823;
ALTER TABLE feature_geo add CONSTRAINT feature_geo_pkey PRIMARY KEY (loanid);

-- find the non matching points and add them to the table
-- first create a table with geometries as we have many location for similar houses
DROP TABLE IF EXISTS geom_outside;
CREATE TABLE geom_outside
(
  id serial PRIMARY KEY,	
  geom geometry(Point,4326)
);


insert into geom_outside(geom)
select loc.geom
from 
        loans_loc as loc left outer join feature_geo as f_geo 
        ON loc.id = f_geo.loanid
where 
        f_geo.loanid is null and loc.hotspot=1
        group by loc.geom;

CREATE INDEX idx_outside_geom ON geom_outside USING GIST(geom);
SQL






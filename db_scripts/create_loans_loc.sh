#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL
drop table if exists tmp_mean_locs;

CREATE TABLE tmp_mean_locs AS (
    SELECT *, 
        avg(c.latitud) OVER w as mean_lat,  
        avg(c.longitud) OVER w as mean_long
    FROM loans l LEFT OUTER JOIN cuvs c
    ON l.var40 = c.cuv
    where var16!='Y'
    WINDOW w AS (PARTITION BY l.var32, l.var34, l.var36));


drop table if exists tmp_to_remove;

create table tmp_to_remove as
select * from 
(select id, count(*) from tmp_mean_locs tmp group by id) sub where count > 1;

drop table if exists ids_to_remove;

create table ids_to_remove as select id from tmp_to_remove;

DELETE FROM tmp_mean_locs where id in (select id from ids_to_remove);

drop table if exists tmp_to_remove;
drop table if exists ids_to_remove;

drop table if exists tmp_loc_fix;

CREATE TABLE tmp_loc_fix 
  AS (
  WITH sub AS (
    SELECT t.id, 
      t.longitud, 
      t.latitud,
      t.var32,
      t.var34,
      t.var36,
      sqrt((t.longitud - t.mean_long)^2.0 + (t.latitud - t.mean_lat)^2.0),
      ROW_NUMBER() OVER(PARTITION BY t.var32,
              t.var34, 
              t.var36
              ORDER BY 
              sqrt((t.longitud - t.mean_long)^2.0 + (t.latitud - t.mean_lat)^2.0)) as rk
      FROM tmp_mean_locs t
      WHERE t.longitud is not NULL 
        and t.latitud is not NULL
        and t.var36 is not NULL)
  SELECT sub.* 
    FROM sub
  WHERE sub.rk = 1
);

drop table if exists loans_loc;

CREATE TABLE loans_loc AS (
  SELECT l.*, c.latitud, c.longitud
  FROM loans l INNER JOIN cuvs c
  ON l.var40 = c.cuv);


drop table if exists tmp_to_remove;

create table tmp_to_remove as
select * from 
(select id, count(*) from loans_loc tmp group by id) sub where count > 1;

drop table if exists ids_to_remove;

create table ids_to_remove as select id from tmp_to_remove;

DELETE FROM loans_loc where id in (select id from ids_to_remove);

drop table if exists tmp_to_remove;
drop table if exists ids_to_remove;


insert into loans_loc 
select sub.*, tmp.latitud, tmp.longitud
from 
  (select l_sub.* from 
  loans l_sub left outer join loans_loc loc on l_sub.id=loc.id
  where loc.id is null) as sub
join tmp_loc_fix as tmp 
ON trim(upper(sub.var32)) = trim(upper(tmp.var32))
AND trim(upper(sub.var34)) = trim(upper(tmp.var34))
AND trim(upper(sub.var36)) = trim(upper(tmp.var36));
SQL


$RUN_ON_MYDB <<SQL
drop table if exists tmp_drop_ids;

create table tmp_drop_ids as 
select id from (select id, count(*) from loans_loc tmp group by id) sub where count > 1;

DELETE FROM loans_loc where id in (select id from tmp_drop_ids);

drop table if exists tmp_drop_ids;
SQL


$RUN_ON_MYDB <<SQL
ALTER TABLE loans_loc ADD COLUMN geom geometry(POINT,4326);
UPDATE loans_loc SET geom = ST_SetSRID(ST_MakePoint(longitud,latitud),4326);
CREATE INDEX idx_loans_loc_geom ON loans_loc USING GIST(geom);
SQL


#!/bin/bash -x
# The username is required as parameter

USERNAME="infonavit"

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

$RUN_ON_MYDB <<SQL

drop table if exists loans_loc_tmp;
create table loans_loc_tmp as
select 
	loans.id as loanid,var26,var32,var34,var35,var36, 
	cuvs.gid as cuvid, cuv as cv_cuv, latitud, longitud, nombreestado, nombremunicipio, colonia,
	ruv.gid as ruvid, tx_oferta, cv_codigo_postal, cv_municipio, tx_municipio

	from loans 
		join cuvs on loans.var40=cuv  
		join ruv on loans.var40= ruv.cv_cuv;

delete from loans_loc_tmp where loanid in (select loanid as ct from loans_loc_tmp group by loanid
having count(*)>1) ;


SQL


$RUN_ON_MYDB <<SQL
ALTER TABLE loans_loc_tmp ADD COLUMN geom geometry(POINT,4326);
UPDATE loans_loc_tmp SET geom = ST_SetSRID(ST_MakePoint(longitud,latitud),4326);
CREATE INDEX idx_loans_loc_tmp_geom ON loans_loc_tmp USING GIST(geom);


drop table if exists loans_loc;
create table loans_loc as
select 
        map.gid as coloniaid, postalcode, st_name,mun_name,sett_name,sett_type,loc.*
from
        colonias map, loans_loc_tmp loc
where
        ST_Contains(map.geom,loc.geom);


CREATE INDEX idx_loans_loc_geom ON loans_loc USING GIST(geom);

SQL


#create a tmp table containing all non matching loanids where lat long was avaliable
$RUN_ON_MYDB <<SQL
drop table if exists public.joinerror;
CREATE TABLE public.joinerror AS
select loc.loanid, loc.geom
from 
        loans_loc_tmp as loc left outer join loans_loc as admloc 
        ON loc.loanid=admloc.loanid 
where 
        admloc.coloniaid is null; 


DROP INDEX IF EXISTS idx_error_geom;
CREATE INDEX idx_error_geom ON public.joinerror USING GIST(geom);
SQL


#create a tmp table for calculating distances for non matching points
$RUN_ON_MYDB <<SQL
drop table if exists tmp_col_match;
create table tmp_col_match as
select loanid, closest.gid as coloniaid, closest.distance
	from joinerror loc, LATERAL 
         (select  map.gid , ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]') as distance  --subselect the closest distance for colonia 
                from
                        colonias as map
                Where
                        ST_DWithin(loc.geom,map.geom,0.01) --low search radius to find the 
                order by ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]')
                limit 1) as closest 
SQL

#
$RUN_ON_MYDB <<SQL
create index idx_joinerror_loanid6 on joinerror(loanid);
create index idx_tmp_col_match_var26 on tmp_col_match(loanid);

drop table if exists to_delete_tmp;
create table to_delete_tmp as
select tmp.loanid from joinerror loc left join tmp_col_match tmp on loc.loanid=tmp.loanid 
	where tmp.loanid is not null;

DELETE from joinerror loc where loc.loanid in (select * from to_delete_tmp);


INSERT INTO tmp_col_match 
select loanid, closest.gid as coloniaid, closest.distance
	from joinerror loc, LATERAL 
         (select  map.gid , ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]') as distance  --subselect the closest distance for colonia 
                from
                        colonias as map
                Where
                        ST_DWithin(loc.geom,map.geom,0.05) --increased search radius to find the 
                order by ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]')
                limit 1) as closest; 


		
drop table if exists to_delete_tmp;
create table to_delete_tmp as
select tmp.loanid from joinerror loc left join tmp_col_match tmp on loc.loanid=tmp.loanid 
where tmp.loanid is not null;		
		
DELETE from joinerror loc where loc.loanid in (select * from to_delete_tmp);


		
INSERT INTO tmp_col_match 
select loanid, closest.gid as coloniaid, closest.distance
        from joinerror loc, LATERAL 
         (select  map.gid , ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]') as distance  --subselect the closest distance for colonia 
                from
                        colonias as map
                Where
                        ST_DWithin(loc.geom,map.geom,0.1) --increased search radius to find the 
                order by ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]')
                limit 1) as closest;





drop table if exists to_delete_tmp;
create table to_delete_tmp as
select tmp.loanid from joinerror loc left join tmp_col_match tmp on loc.loanid=tmp.loanid 
where tmp.loanid is not null;
	
		
DELETE from joinerror loc where loc.loanid in (select * from to_delete_tmp);

INSERT INTO tmp_col_match 
select loanid, closest.gid as coloniaid, closest.distance
        from joinerror loc, LATERAL 
         (select  map.gid , ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]') as distance  --subselect the closest distance for colonia 
                from
                        colonias as map
                Where
                        ST_DWithin(loc.geom,map.geom,1) --increased search radius to find the 
                order by ST_Distance_Spheroid(loc.geom,map.geom,'SPHEROID["WGS 84",6378137,298.257223563]')
                limit 1) as closest; 


SQL

#combine all loans that are inside the colonia and within 5km into one big table to be used for matching of the other
#loans by using text matching 1946280
$RUN_ON_MYDB <<SQL
drop table if exists colonia_loans_base;
create table colonia_loans_base as
select  
	coloniaid, postalcode, st_name,mun_name,sett_name,sett_type,
	loanid,loc.var26,loc.var32,loc.var34,loc.var35,loc.var36,l.var11,cv_credito, im_saldo_subcuenta, tx_oferente, cv_oferente,tx_tipo_credito 
        cuvid, cv_cuv, latitud, longitud, nombreestado, nombremunicipio, colonia,
        ruvid, tx_oferta, cv_codigo_postal, cv_municipio, tx_municipio, 0 as distance

	from loans_loc loc 
		join loans l on loc.loanid=l.id
		left outer join subcuenta_clean sub on l.var41=sub.cv_credito 


union all

select 
	coloniaid, postalcode, st_name,mun_name,sett_name,sett_type,
	matched.loanid,loc.var26,loc.var32,loc.var34,loc.var35,loc.var36,l.var11,cv_credito, im_saldo_subcuenta, tx_oferente, cv_oferente,tx_tipo_credito 
        cuvid, cv_cuv, latitud, longitud, nombreestado, nombremunicipio, colonia,
        ruvid, tx_oferta, cv_codigo_postal, cv_municipio, tx_municipio, distance


	from tmp_col_match matched
		join colonias map on matched.coloniaid=map.gid
		join loans_loc_tmp loc on matched.loanid=loc.loanid
		join loans l on matched.loanid=l.id
		left outer join subcuenta_clean sub on l.var41=sub.cv_credito
	where distance < 5000; 
SQL


#seperate all non matching loans into a new table
$RUN_ON_MYDB <<SQL
drop table if exists loans_to_match_tmp;
create table loans_to_match_tmp as
select l.* 
	from loans l
		left outer join colonia_loans_base c on l.id=c.loanid
	where c.loanid is null;

drop table if exists loans_to_match;
create table loans_to_match as
select l.*, sub.im_saldo_subcuenta, sub.tx_oferente, sub.cv_oferente,sub.tx_tipo_credito from loans_to_match_tmp l
	        left outer join subcuenta_clean sub on l.var41=sub.cv_credito;



create index idx_loans_to_match_var11 on loans_to_match(var11);
create index idx_loans_to_match_var26 on loans_to_match(var26);
create index idx_loans_to_match_var32 on loans_to_match(var32);
create index idx_loans_to_match_var34 on loans_to_match(var34);
create index idx_loans_to_match_var35 on loans_to_match(var35);
create index idx_loans_to_match_var36 on loans_to_match(var36);
create index idx_loans_to_match_cv_oferente on loans_to_match(cv_oferente);

create index idx_colonia_loans_base_var11 on colonia_loans_base(var11);
create index idx_colonia_loans_base_var26 on colonia_loans_base(var26);
create index idx_colonia_loans_base_var32 on colonia_loans_base(var32);
create index idx_colonia_loans_base_var34 on colonia_loans_base(var34);
create index idx_colonia_loans_base_var35 on colonia_loans_base(var35);
create index idx_colonia_loans_base_var36 on colonia_loans_base(var36);
create index idx_colonia_loans_base_cv_oferente on colonia_loans_base(cv_oferente);

		
create index idx_loans_to_match_composite on loans_to_match(var11,var26,var32,var34,var35,var36);
create index idx_colonia_loans_base_composite on colonia_loans_base(var11,var26,var32,var34,var35,var36);

SQL

#start matching the missed loans to the colonia_loans_base
$RUN_ON_MYDB <<SQL

--matches 18188 rows
drop table loans_matched_with_base;
create table loans_matched_with_base as 
with matches as (
select l.id as loanid,coloniaid,row_number() over w as rn
 from loans_to_match l join colonia_loans_base c on 
	l.var11 = c.var11 and 
	l.var26 = c.var26 and 
	l.var32 =c .var32 and 
	l.var34=c.var34 and 
	l.var35=c.var35 and 
	l.var36=c.var36 and
	l.cv_oferente=c.cv_oferente
	
  window w as (partition by l.id) )

select * from matches where rn=1;

DELETE from loans_to_match l where l.id in (select loanid from loans_matched_with_base);

--alow the year to be off by 1 year 6125 rows
insert into loans_matched_with_base
with matches as (
select l.id as loanid,coloniaid,row_number() over w as rn
 from loans_to_match l join colonia_loans_base c on 
	abs(l.var11-c.var11)<=1 and
	l.var26 = c.var26 and 
	l.var32 =c .var32 and 
	l.var34=c.var34 and 
	l.var35=c.var35 and 
	l.var36=c.var36 and
	l.cv_oferente=c.cv_oferente
	
  window w as (partition by l.id) )

select * from matches where rn=1;

--further restriction removed, no matching street name: 157732
insert into loans_matched_with_base
with matches as (
select l.id as loanid,coloniaid,row_number() over w as rn
 from loans_to_match l join colonia_loans_base c on 
	abs(l.var11-c.var11)<=1 and
	l.var26 = c.var26 and 
	l.var32 =c .var32 and 
	l.var34=c.var34 and 
	l.var36=c.var36 and
	l.cv_oferente=c.cv_oferente
	
  window w as (partition by l.id) )

select * from matches where rn=1; 

--removed colonia as it is mostly empty or does not appear to have usefull information 450333, maybe same year
insert into loans_matched_with_base
with matches as (
select l.id as loanid,coloniaid,row_number() over w as rn
 from loans_to_match l join colonia_loans_base c on 
	abs(l.var11-c.var11)<=1 and
	l.var26 = c.var26 and 
	l.var32 =c .var32 and 
	l.var34=c.var34 and 
	l.cv_oferente=c.cv_oferente
	
  window w as (partition by l.id order by l.var11,c.var11) ) 

select * from matches where rn=1; 

--final match
drop table feature_loans_colonia;
create table feature_loans_colonia as 
select loanid, coloniaid from colonia_loans_base 

union  

select loanid, coloniaid from loans_matched_with_base

SQL




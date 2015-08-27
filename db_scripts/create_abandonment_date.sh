#!/bin/bash -x
# The username is required as parameter

USERNAME="infonavit"

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

echo "Step 1"
#create the initial table
$RUN_ON_MYDB <<SQL

drop table if exists abandonment_date;
create table abandonment_date as 
select * from abandonment a,LATERAL ( 
select 	
	nu_ano_ejercicio as loan_grant_year,
	first_value(year) over w as abandon_year, 
	first_value(month) over w as abandon_month
from payments_clean pay
where a.cv_credito=pay.cv_credito and (pro_min<>0)
window w as (partition by cv_credito order by year,month range between unbounded preceding and unbounded following)
limit 1
)paywindow


SQL


echo "Step 2"
#for all non matching extension periods use nu_omisos -1 year to get the start date
#removed all loans from abandonment that had nu_omisos 
$RUN_ON_MYDB <<SQL

drop table if exists abandonment_date_tmp;
create table  abandonment_date_tmp as
select a.*,subwindow.* from abandonment a
        left outer join abandonment_date ad on a.gid=ad.gid
        ,LATERAL ( 

select  nu_ano_ejercicio as loan_grant_year,
        last_value(year) over w as abandon_year,
        last_value(month) over w as abandon_month
from payments_clean pay
where a.cv_credito=pay.cv_credito and pe_total<>0 and (24184-a.nu_omisos)>(year*12+month+1)
window w as (partition by cv_credito order by year,month range between unbounded preceding and unbounded following)
limit 1
)subwindow 
where ad.gid is null and a.nu_omisos<>0;

INSERT INTO abandonment_date
select * from abandonment_date_tmp;

SQL

echo "Step 3"
$RUN_ON_MYDB <<SQL


--all loans that had no extension period, numero omisos was 0. 
-- We set the abandonment date to be one month after the last non-zero payment

drop table if exists abandonment_date_tmp;
create table  abandonment_date_tmp as
select a.*,subwindow.* from abandonment a
        left outer join abandonment_date ad on a.gid=ad.gid
        ,LATERAL ( 

select  nu_ano_ejercicio as loan_grant_year,
	case when mod((last_value(year) over w )*12+(last_value(month) over w)+1,12) = 0 then 
	div((last_value(year) over w )*12+(last_value(month) over w)+1,12)-1 
	else
	div((last_value(year) over w )*12+(last_value(month) over w)+1,12) end as abandon_year,

        case when mod((last_value(year) over w )*12+(last_value(month) over w)+1,12) = 0 then 12 
        else mod((last_value(year) over w )*12+(last_value(month) over w)+1,12)  end as abandon_month
from payments_clean pay
where a.cv_credito=pay.cv_credito and pe_total<>0 
window w as (partition by cv_credito order by year,month range between unbounded preceding and unbounded following)
limit 1
)subwindow 
where ad.gid is null and a.nu_omisos=0; 	

INSERT INTO abandonment_date
select * from abandonment_date_tmp;
SQL

echo "Step 4"
$RUN_ON_MYDB <<SQL

drop table if exists abandonment_date_tmp;
create table  abandonment_date_tmp as
select a.*,subwindow.loan_grant_year,subwindow.abandon_year,subwindow.abandon_month from abandonment a
        left outer join abandonment_date ad on a.gid=ad.gid,
LATERAL ( 

select  nu_ano_ejercicio as loan_grant_year,
	2009 as abandon_year,
        8 as abandon_month,

        sum(pe_total) over w as total_payment
from payments_clean pay
where a.cv_credito=pay.cv_credito 
window w as (partition by cv_credito order by year,month range between unbounded preceding and unbounded following)
limit 1
)subwindow      
where ad.gid is null and total_payment=0;

INSERT INTO abandonment_date
select * from abandonment_date_tmp;

SQL
echo "Step 5"
$RUN_ON_MYDB <<SQL

	-- all loans not covered previously (think these are loans with no extension period, some payments, no payments before numero omisos date)
	-- So we presume this means they abandoned before 2010, hence we will set the date to 2009, month 08 as in a previous case

drop table if exists abandonment_date_tmp;
create table  abandonment_date_tmp as
select a.*,subwindow.* from abandonment a
        left outer join abandonment_date ad on a.gid=ad.gid,
LATERAL ( 

select  nu_ano_ejercicio as loan_grant_year,
	2009 as abandon_year,
        8 as abandon_month

from payments_clean pay
where a.cv_credito=pay.cv_credito 
window w as (partition by cv_credito order by year,month range between unbounded preceding and unbounded following)
limit 1
)subwindow      
where ad.gid is null;

INSERT INTO abandonment_date
select * from abandonment_date_tmp;

DELETE from abandonment_date where abandon_year<loan_grant_year;

SQL




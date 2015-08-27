--creates: clean_loans
--creates: temp_clean_loans_[four others] which union to clean_loans... then some modifications after they are all together
--creates: loan_deflate table for deflation values from 1996 to 2014
--creates: saves a few pre-cleaned files before the main one (temp_deflate, copy_temp_clean_loans)
---uses & merges: loans, risk_index (new one), subcuenta (new one)

--Basic Steps:
--Renames and cleans original loan dataset
--Merges with the updated risk index and subaccount tables
--Merges and cleans joint loans/loans with matching house id's
--deflates all financial variables originally in pesos




--create temp from loans for the variables needed
drop table if exists temp_clean_loans;
create table temp_clean_loans as select id, var1, var2, var3, var4, var5, var6, var7, var11, var13, var14, var15, var16, var17, var18, var19, var20, var25, var26, var28, var29, var32, var33, var34, var35, var36, var40, var41, var42 from loans;    


--age, shouldn't be under 18
alter table temp_clean_loans rename column var1 to age_1;
delete from temp_clean_loans where age_1<17;
--285 rows

--loan type, really no info for joint 'apo' loan type so delete
delete from temp_clean_loans where upper(trim(var25)) = 'APO';
--31,936
alter table temp_clean_loans drop column var25;

--daily wage
alter table temp_clean_loans rename column var2 to daily_wage_2;

--voluntary contribution
alter table temp_clean_loans rename column var3 to voluntary_pesos_3;


--acquisitive, in most multiples of min salary and pesos
alter table temp_clean_loans rename column var4 to acquisitive_vsm_4;
drop table if exists temp_clean_loans_a;
create table temp_clean_loans_a as select *, acquisitive_vsm_4*var14 as acquisitive_pesos_4 from temp_clean_loans;
drop table temp_clean_loans;

--gender
alter table temp_clean_loans_a rename column var5 to gender_5;

--max credit in vsm and pesos
delete from temp_clean_loans_a where var6>400;
--47,847 rows

alter table temp_clean_loans_a rename column var6 to max_credit_vsm_6;
create table temp_clean_loans as select *, max_credit_vsm_6*var14 as max_credit_pesos_6 from temp_clean_loans_a;
drop table temp_clean_loans_a;

--marital status
create table temp_clean_loans_a as select *, case when trim(upper(var7)) = 'C' then 1 when trim(upper(var7)) = 'S' then 0 else null end as married_7 from temp_clean_loans;
alter table temp_clean_loans_a drop column var7;
drop table temp_clean_loans;


--credit authorized
delete from temp_clean_loans_a where var13>400;
alter table temp_clean_loans_a rename column var13 to credit_vsm_13;

--min wage
alter table temp_clean_loans_a rename column var14 to min_wage_14;

--credit authorized pesos
alter table temp_clean_loans_a rename column var15 to credit_pesos_15;

--state
alter table temp_clean_loans_a rename column var17 to state_17;

--subsidy state
alter table temp_clean_loans_a rename column var19 to subsidy_state_19;

--subsidy "fonhapo"
alter table temp_clean_loans_a rename column var18 to subsidy_fonhapo_18;

--joint loans
create table temp_clean_loans as select *, case when trim(upper(var16)) = 'I' then 0 when trim(upper(var16)) = 'C'then 2 when trim(upper(var16)) = 'Y' then 1 else null end as joint_loan_16 from temp_clean_loans_a;
drop table temp_clean_loans_a;
alter table temp_clean_loans drop column var16;


--start year
delete from temp_clean_loans where var11=0;
alter table temp_clean_loans rename column var11 to start_year_11; 
--19 rows

--interest rate
--not as many zeros 2010-2013
alter table temp_clean_loans rename column var20 to interest_rate_20;

--municipality key
alter table temp_clean_loans rename column var26 to municipality_key_26;

--municipality
alter table temp_clean_loans rename column var32 to municipality_32;

--building type
alter table temp_clean_loans rename column var28 to building_type_28;
--below we make 0,5,and 6 nulls since they don't represent any information


--cost of home
delete from temp_clean_loans where var29=0;
delete from temp_clean_loans where var29>5000000;
--25
--887
alter table temp_clean_loans rename column var29 to price_29;

--home classification
create table temp_clean_loans_a as select *, case when trim(upper(var33)) = 'CE' then 1 when trim(upper(var33)) = 'VE'then 2 when trim(upper(var33)) = 'VT' then 3 else null end as home_type_33 from temp_clean_loans;
alter table temp_clean_loans_a drop column var33;
drop table temp_clean_loans;

--postal code
alter table temp_clean_loans_a rename column var34 to postal_code_34;

--address
alter table temp_clean_loans_a rename column var35 to address_35;

--colonia
alter table temp_clean_loans_a rename column var36 to colonia_36;

--home key identifier
create table temp_clean_loans as select *, case when var40<43 then null else var40 end as home_id_40 from temp_clean_loans_a;
drop table temp_clean_loans_a;
alter table temp_clean_loans drop column var40;

--unique credit identifier
alter table temp_clean_loans rename column var41 to credit_id_41;

--abandoned
create table temp_clean_loans_a as select *, case when trim(upper(var42)) = 'ABANDONADA' then 1 else 0 end as abandoned_42 from temp_clean_loans;

drop table temp_clean_loans;
alter table temp_clean_loans_a drop var42;
--------
--MERGE SUBCUENTA FILE

drop table if exists subcuenta_int;
create table subcuenta_int as select im_saldo_subcuenta,tx_oferente,cv_oferente, tx_tipo_credito, cast(cv_credito as bigint) as cv_credito from subcuenta;
create table temp_clean_loans as select * from temp_clean_loans_a left join subcuenta_int on temp_clean_loans_a.credit_id_41= subcuenta_int.cv_credito;
drop table temp_clean_loans_a;

alter table temp_clean_loans rename column im_saldo_subcuenta to subcuenta_pesos;

alter table temp_clean_loans rename column tx_oferente to developer;

alter table temp_clean_loans rename column cv_oferente to developer_id;

alter table temp_clean_loans rename column tx_tipo_credito to credit_type;
alter table temp_clean_loans drop column cv_credito;

delete from temp_clean_loans where upper(trim(credit_type)) <> 'INFONAVIT';
--109,713
--these loans are saved in the table cofinanced_abandoned

alter table temp_clean_loans drop column credit_type;


--MERGE RISK INDEX
drop table if exists risk_index_int;
create table risk_index_int as select indece_de_riesgo, cast(cv_credito as bigint) as cv_credito from risk_index;

create table temp_clean_loans_a as select * from temp_clean_loans left join risk_index_int on temp_clean_loans.credit_id_41= risk_index_int.cv_credito;
alter table temp_clean_loans_a drop column cv_credito;
drop table temp_clean_loans;
alter table temp_clean_loans_a rename column indece_de_riesgo to risk_index;

-------
--More alterations after the merged tables

create table temp_clean_loans as select *, case when developer_id = 0 then null else developer_id end as dev_id from temp_clean_loans_a;
alter table temp_clean_loans drop column developer_id;
alter table temp_clean_loans rename column dev_id to developer_id;
drop table temp_clean_loans_a;

--temp_clean_loans has the latest cleaned data set 


-----
--drop the loans with matching house_id's but different house prices


--match joint loans, some deletions for cleaning


drop table if exists joint_loans;
create table joint_loans as
with subwindow as (
	select *,
	row_number() over w as rn,
	sum(abandoned_42) over w as abandoned,
	sum(joint_loan_16) over w as jt,
	count(*) over w as ct
	from temp_clean_loans
	where home_id_40 is not null
	window w as (partition by home_id_40, start_year_11 range between unbounded preceding and unbounded following)
)
select * from subwindow where rn=1 and ct >= 2;


drop table if exists joint_loans_a;
create table joint_loans_a as
with subwindow as (
	select *,
	row_number() over w as rn,
	sum(abandoned_42) over w as abandoned,
	sum(joint_loan_16) over w as jt,
	count(*) over w as ct
	from temp_clean_loans
	where home_id_40 is not null
	window w as (partition by home_id_40, start_year_11, price_29 range between unbounded preceding and unbounded following)
)
select * from subwindow where rn=1 and ct >= 2;

--about 8,000 loans with same home_id but different sales price (550 of those are abandoned)


--matching home_id's, other things not matching
drop table if exists temp_joint_a;
drop table if exists temp_joint_b;
create table temp_joint_a as select home_id_40 as home_id from joint_loans_a where ct=2 and jt=3;
create table temp_joint_b as select home_id_40 from joint_loans where ct=2 and jt=3;

drop table if exists temp_joint_unmatches;

create table temp_joint_unmatches as select temp_joint_b.home_id_40, temp_joint_a.home_id from temp_joint_b left join temp_joint_a on temp_joint_b.home_id_40= temp_joint_a.home_id where temp_joint_a.home_id is null;

alter table temp_joint_unmatches drop column home_id;
alter table temp_joint_unmatches rename column home_id_40 to home_id;

--drop the loans with matching house_id's but different house prices
create table temp_clean_loans_a as select * from temp_clean_loans left join temp_joint_unmatches on temp_clean_loans.home_id_40 = temp_joint_unmatches.home_id where temp_joint_unmatches.home_id is null;
drop table temp_clean_loans;
alter table temp_clean_loans_a drop column home_id;


--temp_clean_loans_a is latest dataset

drop table if exists temp_joint_unmatches, temp_joint_a, temp_joint_b, joint_loans, joint_loans_b;


--check if any loans have unmatching years
--delete houses with the same home_id, more than 2 of these matching, or different years for these loans


drop table if exists joint_loans_b;
create table joint_loans_b as
with subwindow as (
	select *,
	row_number() over w as rn,
	sum(abandoned_42) over w as abandoned,
	sum(joint_loan_16) over w as jt,
	count(*) over w as ct,
	max(start_year_11) over w as max_year,
	min(start_year_11) over w as min_year
	from temp_clean_loans_a
	where home_id_40 is not null
	window w as (partition by home_id_40 range between unbounded preceding and unbounded following)
)
select * from subwindow where rn=1 and ct >= 2;




--create table with house id's for the above two bad cases and these are all for joint loans (so jt=3)
create table temp_joint_delete as select home_id_40 from joint_loans_b where ct>2 or (ct=2 and max_year-min_year>0); 
alter table temp_joint_delete rename column home_id_40 to home_id;

--delete these house id rows from the overall table
create table temp_clean_loans as select * from temp_clean_loans_a left join temp_joint_delete on temp_clean_loans_a.home_id_40 = temp_joint_delete.home_id where temp_joint_delete.home_id is null;  
drop table temp_clean_loans_a;
alter table temp_clean_loans drop column home_id;
drop table temp_joint_delete;

--latest: temp_clean_loans

drop table if exists joint_loans, joint_loans_a, joint_loans_b;
--check the joint loans now/same home_id
drop table if exists joint_loans;
create table joint_loans as
with subwindow as (
	select *,
	row_number() over w as rn,
	sum(abandoned_42) over w as abandoned,
	sum(joint_loan_16) over w as jt,
	count(*) over w as ct,
	max(start_year_11) over w as max_year,
	min(start_year_11) over w as min_year,
	max(price_29) over w as max_price,
	min(price_29) over w as min_price,
	max(municipality_key_26) over w as max_mun,
	min(municipality_key_26) over w as min_mun
	from temp_clean_loans
	where home_id_40 is not null
	window w as (partition by home_id_40 range between unbounded preceding and unbounded following)
)
select * from subwindow where rn=1 and ct >= 2;


--create table with house id's for the additional bad cases
create table temp_joint_delete as select home_id_40 from joint_loans where ct=2 and max_price-min_price>0;
alter table temp_joint_delete rename column home_id_40 to home_id;

--delete these house id rows from the overall table
create table temp_clean_loans_a as select * from temp_clean_loans left join temp_joint_delete on temp_clean_loans.home_id_40 = temp_joint_delete.home_id where temp_joint_delete.home_id is null;  
drop table temp_clean_loans;
alter table temp_clean_loans_a drop column home_id;
drop table temp_joint_delete;
drop table joint_loans;


--latest: temp_clean_loans_a



--convert some things to nulls
create table temp_clean_loans as select *, 
case when (building_type_28>4 or building_type_28<1) then null else building_type_28 end as building_type
from temp_clean_loans_a;

alter table temp_clean_loans drop column building_type_28;
alter table temp_clean_loans rename column building_type to building_type_28;
drop table temp_clean_loans_a;

--latest: temp_clean_loans

--finally matching these loans now
drop table if exists temp_clean_loans_a;
create table temp_clean_loans_a as
with subwindow as (
			select
			row_number() over w as rn,
			sum(joint_loan_16) over w as jt,
			count(*) over w as ct,
			id,
			avg(age_1) over w as age_1,
			sum(daily_wage_2) over w as daily_wage_2,
			sum(voluntary_pesos_3) over w as voluntary_pesos_3,
			sum(acquisitive_vsm_4) over w as acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			sum(max_credit_vsm_6) over w as max_credit_vsm_6,
			start_year_11,
			sum(credit_vsm_13) over w as credit_vsm_13,
			min_wage_14, 
			sum(credit_pesos_15) over w as credit_pesos_15,
			state_17,
			sum(subsidy_fonhapo_18) over w as subsidy_fonhapo_18,
			sum(subsidy_state_19) over w as subsidy_state_19,
			avg(interest_rate_20) over w as interest_rate_20,
			municipality_key_26,
			building_type_28,
			price_29,
			municipality_32,
			postal_code_34,
			address_35,
			colonia_36,
			credit_id_41,
			sum(acquisitive_pesos_4) over w as acquisitive_pesos_4,
			sum(max_credit_pesos_6) over w as max_credit_pesos_6,
			max(married_7) over w as married_7,
			max(joint_loan_16) over w as joint_loan_16,
			max(home_type_33) over w as home_type_33,
			max(abandoned_42) over w as abandoned_42, 
			max(risk_index) over w as risk_index,
			sum(subcuenta_pesos) over w as subcuenta_pesos,
			developer,
			case when developer_id is not null then developer_id else (max(developer_id) over w) end as developer_id,
			home_id_40
			from temp_clean_loans
			where home_id_40 is not null 
			window w as (partition by home_id_40 order by joint_loan_16 desc range between unbounded preceding and unbounded following)
)

select * from subwindow where rn=1;


-- delete rows where it is not null home_id, but is joint loan and wasn't matched
delete from temp_clean_loans_a where ct=1 and joint_loan_16>0 and home_id_40 is not null;

--MERGED DATASET WITH home key that is not null (and checked there is 'usable' location information)
--delete the ones with no location information
drop table if exists temp_clean_loans_withHomeKey;
create table temp_clean_loans_withHomeKey as select * from temp_clean_loans_a where postal_code_34 is not null or (trim(address_35) != '') or colonia_36 is not null;
alter table temp_clean_loans_withHomeKey drop column rn, drop column jt, drop column ct;



--latest: temp_clean_loans_withHomeKey has merged joint loans with matching home_id's and deleted rows with no usable location information

--also delete the rows with no usable information from temp_clean_loans

drop table if exists temp_clean_loans_a;
create table temp_clean_loans_a as select * from temp_clean_loans where postal_code_34 is not null or (trim(address_35) != '') or colonia_36 is not null;
drop table temp_clean_loans;
--latest: temp_clean_loans_a (includes with null and not null home id's)


---KEEP A COPY OF SOME THINGS
create table copy_temp_clean_loans as select * from temp_clean_loans_a; -- the temp_clean_loans file with usuable location data & nothing merged
----------



--table of loans with null home key but not labeled as not being a joint loan
drop table if exists temp_nullHomeKey_notJoint;
create table temp_nullHomeKey_notJoint as select * from temp_clean_loans_a where home_id_40 is null and joint_loan_16=0;
--select count(*) from temp_nullHomeKey_notJoint
--2,012,008

--table of loans with null home key but are labeled as being a joint loan
drop table if exists temp_nullHomeKey_Joint;
create table temp_nullHomeKey_Joint as select * from temp_clean_loans_a where home_id_40 is null and joint_loan_16<>0;


drop table if exists match_nullHomeKey_Joint;
create table match_nullHomeKey_Joint as
with subwindow as (
			select
			*,
			row_number() over w as rn,
			sum(joint_loan_16) over w as jt,
			count(*) over w as ct,
			sum(abandoned_42) over w as abandoned,
			--(sum(subaccount_3) over w) + (sum(subcuenta_pesos) over w) + (sum(credit_pesos_15) over w) as total_credit
			
			price_29-(sum(credit_pesos_15) over w) as price_credit_difference 
			
			from temp_nullHomeKey_Joint
			window w as (partition by start_year_11, price_29, postal_code_34, municipality_key_26,colonia_36, developer_id range between unbounded preceding and unbounded following)
)

select * from subwindow;





drop table if exists temp_clean_loans_nullHomeKey_Joint; 
create table temp_clean_loans_nullHomeKey_Joint  as
with subwindow as (
			select
			rn,
		    jt,
			ct,
			id,
			avg(age_1) over w as age_1,
			sum(daily_wage_2) over w as daily_wage_2,
			sum(voluntary_pesos_3) over w as voluntary_pesos_3,
			sum(acquisitive_vsm_4) over w as acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			sum(max_credit_vsm_6) over w as max_credit_vsm_6,
			start_year_11,
			sum(credit_vsm_13) over w as credit_vsm_13,
			min_wage_14, 
			sum(credit_pesos_15) over w as credit_pesos_15,
			state_17,
			sum(subsidy_fonhapo_18) over w as subsidy_fonhapo_18,
			sum(subsidy_state_19) over w as subsidy_state_19,
			avg(interest_rate_20) over w as interest_rate_20,
			municipality_key_26,
			building_type_28,
			price_29,
			municipality_32,
			postal_code_34,
			address_35,
			colonia_36,
			home_id_40,
			credit_id_41,
			sum(acquisitive_pesos_4) over w as acquisitive_pesos_4,
			sum(max_credit_pesos_6) over w as max_credit_pesos_6,
			max(married_7) over w as married_7,
			max(joint_loan_16) over w as joint_loan_16,
			max(home_type_33) over w as home_type_33,
			max(abandoned_42) over w as abandoned_42, 
			max(risk_index) over w as risk_index,
			sum(subcuenta_pesos) over w as subcuenta_pesos,
			developer,
			case when developer_id is not null then developer_id else (max(developer_id) over w) end as dev_id
			from match_nullHomeKey_Joint
			where ct=2 and (jt=3 or jt=2 or jt=4) and price_credit_difference >=0	
			
			window w as (partition by start_year_11, price_29, postal_code_34, municipality_key_26,colonia_36, developer_id order by joint_loan_16 desc range between unbounded preceding and unbounded following)
)

select * from subwindow where rn=1; 


-- MERGED TABLE OF MATCHING null home id's : loans with null home id, joint and matched
alter table temp_clean_loans_nullHomeKey_Joint drop column rn, drop column jt, drop column ct;
alter table temp_clean_loans_nullHomeKey_Joint rename column dev_id to developer_id ;
drop table if exists temp_match_nullHomeKey_Joint;

--TABLE Of the loans that are left: null home id, joint and unmatched
drop table if exists temp_clean_loans_nullHomeKey_Joint_unmatched;
drop table if exists temp_A_clean_loans;
create table temp_A_clean_loans as select credit_id_41 as credit_id from match_nullHomeKey_Joint where ct=2 and (jt=3 or jt=2 or jt=4) and price_credit_difference >=0;


create table temp_clean_loans_nullHomeKey_Joint_unmatched as select * from temp_A_clean_loans right join match_nullHomeKey_Joint on temp_A_clean_loans.credit_id = match_nullHomeKey_Joint.credit_id_41 where temp_A_clean_loans.credit_id is null; 
alter table temp_clean_loans_nullHomeKey_Joint_unmatched drop column credit_id, drop column price_credit_difference, drop column rn, drop column jt, drop column ct, drop column abandoned;


--select count(*) from temp_clean_loans_nullHomeKey_Joint_unmatched
--163,327

--select count(*) from temp_clean_loans_nullHomeKey_Joint
--18,691

--select count(*) from temp_nullHomeKey_notJoint
--2,012,008

--select count(*) from temp_clean_loans_withHomeKey
--1,945,851

--total sum: 4,139,877


drop table if exists clean_loans;

create table clean_loans as 
select 
age_1,
	daily_wage_2,
			voluntary_pesos_3,
			acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			max_credit_vsm_6,
start_year_11,
credit_vsm_13,
min_wage_14,
credit_pesos_15,
state_17,
subsidy_fonhapo_18,
subsidy_state_19,
interest_rate_20,
municipality_key_26,
building_type_28,
price_29,
municipality_32,
postal_code_34,
address_35,
colonia_36,
home_id_40,
credit_id_41,
acquisitive_pesos_4,
max_credit_pesos_6,
married_7,
joint_loan_16,
home_type_33,
abandoned_42,
risk_index,
subcuenta_pesos,
developer,
developer_id
from  temp_clean_loans_nullHomeKey_Joint_unmatched
union
select 
age_1,
	daily_wage_2,
			voluntary_pesos_3,
			acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			max_credit_vsm_6,
start_year_11,
credit_vsm_13,
min_wage_14,
credit_pesos_15,
state_17,
subsidy_fonhapo_18,
subsidy_state_19,
interest_rate_20,
municipality_key_26,
building_type_28,
price_29,
municipality_32,
postal_code_34,
address_35,
colonia_36,
home_id_40,
credit_id_41,
acquisitive_pesos_4,
max_credit_pesos_6,
married_7,
joint_loan_16,
home_type_33,
abandoned_42,
risk_index,
subcuenta_pesos,
developer,
developer_id
from temp_clean_loans_nullHomeKey_Joint
union 
select 
age_1,
	daily_wage_2,
			voluntary_pesos_3,
			acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			max_credit_vsm_6,
start_year_11,
credit_vsm_13,
min_wage_14,
credit_pesos_15,
state_17,
subsidy_fonhapo_18,
subsidy_state_19,
interest_rate_20,
municipality_key_26,
building_type_28,
price_29,
municipality_32,
postal_code_34,
address_35,
colonia_36,
home_id_40,
credit_id_41,
acquisitive_pesos_4,
max_credit_pesos_6,
married_7,
joint_loan_16,
home_type_33,
abandoned_42,
risk_index,
subcuenta_pesos,
developer,
developer_id
from temp_nullHomeKey_notJoint
union select
age_1,
	daily_wage_2,
			voluntary_pesos_3,
			acquisitive_vsm_4,
			gender_5, -- since the principal loan is on the top
			max_credit_vsm_6,
start_year_11,
credit_vsm_13,
min_wage_14,
credit_pesos_15,
state_17,
subsidy_fonhapo_18,
subsidy_state_19,
interest_rate_20,
municipality_key_26,
building_type_28,
price_29,
municipality_32,
postal_code_34,
address_35,
colonia_36,
home_id_40,
credit_id_41,
acquisitive_pesos_4,
max_credit_pesos_6,
married_7,
joint_loan_16,
home_type_33,
abandoned_42,
risk_index,
subcuenta_pesos,
developer,
developer_id from
temp_clean_loans_withHomeKey; 



--select count(*) from clean_loans
--4,139,877

--select count(*) from clean_loans where start_year_11 >2009
--1,862, 848 for loans 2010 and after

--select count(*) from clean_loans where start_year_11 >2009 and abandoned_42 = 1
--49,218



--deflation adjustments

--create deflate table
drop table if exists loan_deflate;	
create table loan_deflate (
	yr	INTEGER NOT NULL,
	deflate	FLOAT NOT NULL
);


insert into loan_deflate (yr, deflate)
values
(1996,35.46799),
(1997,42.78349),
(1998,49.59821),
(1999,57.82438),
(2000,63.31281),
(2001,67.34441),
(2002,70.73232),
(2003,73.9484),
(2004,77.41545),
(2005,80.50283),
(2006,83.42464),
(2007,86.73398),
(2008,91.17908),
(2009,96.00916),
(2010,100),
(2011,103.4074),
(2012,107.659),
(2013,111.7569),
(2014,116.248);

create table temp_deflate as select * from clean_loans, loan_deflate where start_year_11 = yr;
alter table temp_deflate drop column yr;
drop table clean_loans;

--current: temp_deflate

drop table if exists clean_loans;
create table clean_loans as select
age_1,
acquisitive_vsm_4,
gender_5, -- since the principal loan is on the top
max_credit_vsm_6,
start_year_11,
credit_vsm_13,
state_17,
interest_rate_20,
municipality_key_26,
building_type_28,
trim(upper(municipality_32)) as municipality_32,
postal_code_34,
trim(address_35) as address_35,
trim(upper(colonia_36)) as colonia_36,
home_id_40,
credit_id_41,
married_7,
case when joint_loan_16=1 then 1 when joint_loan_16=2 then 1 else joint_loan_16 end as joint_loan,
home_type_33,
abandoned_42,
risk_index,
--case when trim(upper(var42)) = 'ABANDONADA' then 1 else 0 end as abandoned_42 from temp_clean_loans
case when trim(upper(developer)) = 'SIN FORMATO' then null else trim(upper(developer)) end as developer,
case when developer_id=99999999 then null else developer_id end as developer_id,
daily_wage_2/deflate*100 as daily_wage_2,
voluntary_pesos_3/deflate*100 as voluntary_pesos_3,
min_wage_14/deflate*100 as min_wage_14,
credit_pesos_15/deflate*100 as credit_pesos_15,
subsidy_fonhapo_18/deflate*100 as subsidy_fonhapo_18,
subsidy_state_19/deflate*100 as subsidy_state_19,
price_29/deflate*100 as price_29,
acquisitive_pesos_4/deflate*100 as acquisitive_pesos_4,
max_credit_pesos_6/deflate*100 as max_credit_pesos_6,
subcuenta_pesos/deflate*100 as subcuenta_pesos 
from 
temp_deflate;

--rename one of the files so they are all named temp_clean_loans
drop table if exists temp_clean_loans_nullHomeKey_notJoint; 
create table temp_clean_loans_nullHomeKey_notJoint as select * from temp_nullHomeKey_notJoint;
drop table if exists temp_no_location_info, temp_clean_loans_a, temp_clean_loans_b, temp_a_clean_loans,temp_nullHomeKey_notJoint;


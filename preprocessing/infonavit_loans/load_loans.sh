#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load the initial loan data
$RUN_ON_MYDB <<SQL
drop table if exists loans;
drop table if exists tmp_loans;
SQL

TABLE=$(cat create_loans.sql)
$RUN_ON_MYDB -c "$TABLE"


$RUN_ON_MYDB <<SQL
\copy tmp_loans (var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15,var16,var17,var18,var19,var20,var21,var22,var23,var24,var25,var26,var27,var28,var29,var30,var31,var32,var33,var34,var35,var36,var37,var38,var39,var40,var41,var42 ) FROM /mnt/data/infonavit/new_data_june2/fixed_dataset_192_rows_deleted.txt WITH CSV HEADER DELIMITER '|';
SQL

$RUN_ON_MYDB <<SQL
ALTER TABLE tmp_loans ALTER COLUMN Var40 TYPE BIGINT USING Cast((trim(case when trim(var40) = 'NULL' then NULL  ELSE var40 END)) as bigint);

CREATE TABLE loans as
select l.*,COALESCE(dummy,0)as hotspot from tmp_loans l left outer join (
	select 1 as dummy,var26 from 
	(select range as var26 from sum_custom_aban_noround('var26','tmp_loans') 
	order by abandoned_percent desc limit 100) sub ) as selected on l.var26=selected.var26;


ALTER TABLE loans ADD PRIMARY KEY (id);

create index idx_loans_var34 on loans(var34);
create index idx_loans_var26 on loans(var26);

create index idx_loans_var40 on loans(var40);
create index idx_loans_var41 on loans(var41);

drop table if exists tmp_loans;
SQL



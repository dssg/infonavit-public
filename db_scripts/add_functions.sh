#!/bin/bash -x
# The username is required as parameter

USERNAME=$1

RUN_ON_MYDB="psql -X -U $USERNAME -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit"

# load a function for postgres for generating histogram tables
$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists hist_custom(bins int,var text, tablestr text);
CREATE OR REPLACE FUNCTION hist_custom(bins int,var text,tablestr text)
RETURNS TABLE(bucket int,range text, freq bigint,percent numeric) AS \$\$
BEGIN
  RETURN QUERY
	EXECUTE '
	with var_stats as (
		select min('||var||') as min,
		max('||var||') as max,
		count(*) as count_all
		from '||tablestr||'
),
histogram as (
   select width_bucket('||var||', min, max, '||bins||') as bucket,
	  (min('||var||')  || ''-'' || max('||var||')) as range,	
          count(*) as freq
     from '||tablestr||', var_stats
	group by bucket
	order by bucket
)
 select bucket, COALESCE(range,''no data''), freq, round(freq/CAST(count_all as numeric),2) as percent 
 from histogram,var_stats; 
	';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL

# load a function for postgres for generating histogram tables
$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists hist_custom_sub(bins int,var text, tablestr text,min int, max int);
CREATE OR REPLACE FUNCTION hist_custom_sub(bins int,var text,tablestr text,min int, max int)
RETURNS TABLE(bucket int, range text, freq bigint,percent numeric) AS \$\$
BEGIN
  RETURN QUERY
	EXECUTE '
	with 
	subset as (
	select '||var||' from '||tablestr||' where '||var||'>'||min||' and '||var||'<'||max||'
),
var_stats as (
		select min('||var||') as min,
		max('||var||') as max,
		count(*) as count_all
		from subset
),
histogram as (
   select width_bucket('||var||', min, max, '||bins||') as bucket,
	  (min('||var||')  || ''-'' || max('||var||')) as range,	
          count(*) as freq
     from subset, var_stats
	group by bucket
	order by bucket
)
 select bucket, COALESCE(range,''no data''), freq, round(freq/CAST(count_all as numeric),2) as percent 
 from histogram,var_stats; 
	';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL



# load a function for postgres for generating histogram tables
$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists hist_custom_aban(bins int,var text, tablestr text);
CREATE OR REPLACE FUNCTION hist_custom_aban(bins int,var text,tablestr text)
RETURNS TABLE(bucket int, range text, freq bigint,percent numeric,abandoned_freq bigint,abandoned_percent numeric) AS \$\$
BEGIN
  RETURN QUERY
        EXECUTE '
        with var_stats as (
                select min('||var||') as min,
                max('||var||') as max,
                count(*) as count_all,
        	SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as count_aban        
	from '||tablestr||'
),
histogram as (
   select width_bucket('||var||', min, max, '||bins||') as bucket,
          (min('||var||')  || ''-'' || max('||var||')) as range,        
          count(*) as freq,
	  SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as abandoned_freq
     from '||tablestr||', var_stats
        group by bucket
        order by bucket
)
 select bucket, 
	COALESCE(range,''no data''), freq, round(freq/CAST(count_all as numeric),2) as percent,
	abandoned_freq,
	round(abandoned_freq/CAST(count_aban as numeric),2) as abandoned_percent  
 from histogram,var_stats; 
        ';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL



# load a function for postgres for generating histogram tables
$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists hist_custom_aban_sub(bins int,var text, tablestr text,min int, max int);
CREATE OR REPLACE FUNCTION hist_custom_aban_sub(bins int,var text,tablestr text,min int, max int)
RETURNS TABLE(bucket int, range text, freq bigint,percent numeric,abandoned_freq bigint,abandoned_percent numeric) AS \$\$
BEGIN
  RETURN QUERY
        EXECUTE '
with 
        subset as (
        select '||var||',var42 from '||tablestr||' where '||var||'>'||min||' and '||var||'<'||max||'
	),
	var_stats as (
                select min('||var||') as min,
                max('||var||') as max,
                count(*) as count_all,
                SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as count_aban        
        from subset
),
histogram as (
   select width_bucket('||var||', min, max, '||bins||') as bucket,
          (min('||var||')  || ''-'' || max('||var||')) as range,        
          count(*) as freq,
          SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as abandoned_freq
     from subset, var_stats
        group by bucket
        order by bucket
)
 select bucket, 
        COALESCE(range,''no data''), freq, round(freq/CAST(count_all as numeric),2) as percent,
        abandoned_freq,
        round(abandoned_freq/CAST(count_aban as numeric),2) as abandoned_percent  
 from histogram,var_stats; 
        ';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL


# load a function for postgres for generating histogram tables
$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists sum_custom_aban(var text, tablestr text);
CREATE OR REPLACE FUNCTION sum_custom_aban(var text,tablestr text)
RETURNS TABLE(range text, freq bigint,percent numeric,abandoned_freq bigint,abandoned_percent numeric) AS \$\$
BEGIN
  RETURN QUERY
        EXECUTE '
        with var_stats as (
        SELECT        
		count(*) as count_all,
                SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as count_aban        
        from '||tablestr||'
),
histogram as (
   select 
	('||var||') as range,        
          count(*) as freq,
          SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as abandoned_freq
     from '||tablestr||', var_stats
        group by range
        order by range
)
 select  
        CAST(COALESCE(range,''no data'') as text)as range, freq, round(freq/CAST(count_all as numeric),2) as percent,
        abandoned_freq,
        round(abandoned_freq/CAST(count_aban as numeric),2) as abandoned_percent  
 from histogram,var_stats; 
        ';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL


$RUN_ON_MYDB <<SQL
DROP FUNCTION if exists sum_custom_aban_noround(var text, tablestr text);
CREATE OR REPLACE FUNCTION sum_custom_aban_noround(var text,tablestr text)
RETURNS TABLE(range text, freq bigint,percent numeric,abandoned_freq bigint,abandoned_percent numeric,ratio numeric) AS \$\$
BEGIN
  RETURN QUERY
        EXECUTE '
        with var_stats as (
        SELECT        
                count(*) as count_all,
                SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as count_aban        
        from '||tablestr||'
),
histogram as (
   select 
        ('||var||') as range,        
          count(*) as freq,
          SUM(CASE WHEN var42=''ABANDONADA'' then 1 else 0 end) as abandoned_freq
     from '||tablestr||', var_stats
        group by range
        order by range
)
 select  
        CAST(COALESCE(range,''no data'') as text)as range, freq, freq/CAST(count_all as numeric) as percent,
        abandoned_freq,
        abandoned_freq/CAST(count_aban as numeric) as abandoned_percent,
	abandoned_freq/CAST(freq as numeric) as ratio  
 from histogram,var_stats; 
        ';
RETURN;
END;
\$\$ LANGUAGE plpgsql;
SQL


CREATE TABLE payment_lapse_count AS (
WITH tmp3 AS (
	WITH tmp2 AS (
		WITH tmp AS (
			select cv_credito, year, month, 
			    sum(CASE WHEN pe IS NOT NULL THEN pe ELSE 0 END) as total_pay, 
			    max(CASE WHEN pf IS NOT NULL THEN pf ELSE 0 END) as max_pf,
			    sum(CASE WHEN tp = 1 THEN pe ELSE 0 END) as pe_1,
			    sum(CASE WHEN tp = 2 OR tp = 3 THEN pe ELSE 0 END) as pe_2,
			    sum(CASE WHEN tp <= 0 THEN pe ELSE 0 END) as pe_neg,
			    count(CASE WHEN tp = 1 THEN 1 ELSE null END) as tp_1_count,
			    count(CASE WHEN tp = 2 OR tp = 3 THEN 1 ELSE null END) as tp_2_count,  
			    count(CASE WHEN tp <= 0 THEN 1 ELSE null END) as tp_neg_count 
			    FROM payments where pe is not null
			GROUP BY cv_credito, year, month  limit 10000)
		select *, (sum(tmp.total_pay) over w)<=0 and (count(tmp.total_pay is not null) over w) =3 as non_paying
		from tmp 
		window w AS (order by cv_credito, year, month ROWS BETWEEN 2 preceding AND current row)   
		order by cv_credito, year, month)
	select row_number() over () as id, * from tmp2)
select t2.cv_credito, count(*) from tmp3 t1
        JOIN tmp3 t2
	            ON t2.id = (SELECT min(id) from tmp3 where id > t1.id)
		            WHERE t1.non_paying = 'f' and t2.non_paying = 't' and t1.cv_credito = t2.cv_credito and (t1.month = t2.month -1 OR t1.year = t2.year - 1)
			            GROUP BY t2.cv_credito;)

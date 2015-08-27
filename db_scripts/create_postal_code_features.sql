-- Create Postal Code Features Table..... Colonias are bad at matching
--DROP TABLE IF EXISTS postal_code_features;
CREATE TABLE postal_code_features AS (
SELECT *, cast(num_abd as double precision)/ cast(num_loans as double precision) as abd_percent FROM (
SELECT var26 as cv_municipio_credito,
	var34 as cv_codigo_postal, 
	var11 as year_granted,
	--var36 as tx_colonia,
       count(*) as num_loans,
       SUM(CASE
		WHEN var42 is not null THEN 1
		ELSE 0
	   END) as num_abd,
       avg(var15) as avg_loan_val,
       max(var15) as max_loan_val,
       min(var15) as min_loan_val,
       avg(var1) as avg_age,
       avg(var2) as avg_income,
       avg(im_saldo_subcuenta) as avg_subaccount,
       avg(var18 + var19) as avg_subsidy,
       max(var18 + var19) as max_subsidy,
       avg(var29) as avg_sales_price,
       max(var29) as max_sales_price,
       min(var29) as min_sales_price
FROM loans
JOIN subcuenta_int ON (loans.var41 = subcuenta_int.cv_credito)
WHERE var34 != '' and var26 != '' and var11 != 0
GROUP BY var26, var34, var11
ORDER BY var11) as sub
WHERE num_loans > 1);

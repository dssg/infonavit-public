CREATE TABLE colonia_features AS (
SELECT *, 
	case when colonia_num_loans<>0 then (cast(colonia_num_abd as double precision)/ cast(colonia_num_loans as double precision)) else 0 end as colonia_abd_percent,
	case when colonia_num_newgranted_cur_year <> 0 then (cast(colonia_num_abd_first_year as double precision) / cast(colonia_num_newgranted_cur_year as double precision)) else 0 end as colonia_num_abd_first_year_percent
FROM (
  SELECT coloniaid,
       cur_year as cur_year_cf,
       past as past_cf,
       count(*) as colonia_num_loans,
       SUM(abandoned) as colonia_num_abd,
       SUM(CASE WHEN start_year_11=cur_year then abandoned else 0 end) as colonia_num_abd_first_year,
       SUM(CASE WHEN start_year_11=cur_year then 1 else 0 end) as colonia_num_newgranted_cur_year,
       avg(credit_pesos_15) as colonia_avg_loan_val,
       max(credit_pesos_15) as colonia_max_loan_val,
       min(credit_pesos_15) as colonia_min_loan_val,
       avg(age_1) as colonia_avg_age,
       avg(daily_wage_2) as colonia_avg_income,
       avg(im_saldo_subcuenta) as colonia_avg_subaccount,
       avg(subsidy_fonhapo_18 + subsidy_state_19) as colonia_avg_subsidy,
       max(subsidy_fonhapo_18 + subsidy_state_19) as colonia_max_subsidy,
       avg(price_29) as colonia_avg_sales_price,
       max(price_29) as colonia_max_sales_price,
       min(price_29) as colonia_min_sales_price,
       avg(interest_rate_20) as colonia_avg_interest_rate,
       avg(ct_pnthsp) as colonia_avg_hospital_escore,
       avg(ct_pntprq) as colonia_avg_parks_escore,
       avg(ct_pntmrc) as colonia_avg_markets_escore,
       avg(ct_pntesc) as colonia_avg_schools_escore,
       avg(ct_pnteqp) as colonia_avg_equip_escore,
       avg(ct_pntref) as colonia_avg_references_escore,
       avg(ct_pnttrn) as colonia_avg_transportation_escore,
       avg(ct_pntvld) as colonia_avg_roads_transport_escore,
       avg(ct_suphab) as colonia_avg_living_area_escore,
       avg(ct_gbs) as colonia_avg_sustainability_escore,
       avg(ct_pnticv) as colonia_avg_validitiy_index_escore,
       avg(ct_pntisa) as colonia_avg_satisfaction_escore,
       avg(ct_hogdig) as colonia_avg_digital_escore,
       avg(ct_cldvvn) as colonia_avg_housing_quality_escore,
       avg(ct_pntaga) as colonia_avg_water_escore,
       avg(ct_pntenr) as colonia_avg_power_escore,
       avg(ct_pntcmd) as colonia_avg_community_escore,
       avg(ct_ecuve) as colonia_avg_total_escore
FROM clean_loans_by_year
       LEFT OUTER JOIN subcuenta_clean ON (clean_loans_by_year.credit_id_41 = subcuenta_clean.cv_credito)
       LEFT OUTER JOIN ecuve ON (clean_loans_by_year.credit_id_41 = ecuve.cv_credito)
       JOIN feature_loans_colonia ON (feature_loans_colonia.loanid = clean_loans_by_year.id)
WHERE start_year_11 != 0 
GROUP BY coloniaid, cur_year, past
ORDER BY coloniaid, cur_year)
as sub);

CREATE INDEX idx_colonia_features_coloniaid_cur_year_past ON colonia_features (coloniaid, cur_year_cf, past_cf);

CREATE TABLE loan_features AS (
SELECT l.credit_id_41 AS cv_credito_lf,
	l.cur_year as cur_year_lf,
	l.past as past_lf,
	l.credit_pesos_15 AS loan_value,
	CASE WHEN cf.colonia_avg_loan_val = 0 THEN 0
	     ELSE l.credit_pesos_15 / cf.colonia_avg_loan_val
		END AS loan_value_relative,
	l.interest_rate_20 AS loan_interest_rate,
	CASE WHEN cf.colonia_avg_interest_rate = 0 THEN 0
	     ELSE l.interest_rate_20 / cf.colonia_avg_interest_rate
		END AS loan_interest_rate_relative,
	l.subcuenta_pesos AS loan_subaccount_value,
	CASE WHEN cf.colonia_avg_subaccount = 0 THEN 0
	     ELSE l.subcuenta_pesos / cf.colonia_avg_subaccount
		END AS loan_subaccount_value_relative,
	l.subsidy_fonhapo_18 + l.subsidy_state_19 AS loan_total_subsidy,
	CASE WHEN cf.colonia_avg_subsidy = 0 THEN 0
	     ELSE (l.subsidy_fonhapo_18 + l.subsidy_state_19) / cf.colonia_avg_subsidy
		END AS loan_total_subsidy_relative,
	(l.subsidy_fonhapo_18 + l.subsidy_state_19) > 0.0 AS loan_has_subsudy,
	l.voluntary_pesos_3 > 0.0 AS loan_voluntary_contrib_bool,
	l.voluntary_pesos_3 as loan_voluntary_contrib,
	l.price_29 AS loan_sales_price,
	l.acquisitive_pesos_4 as loan_acquisitive,
	l.acquisitive_vsm_4 as loan_acquisitive_vsm,
	l.max_credit_pesos_6 as loan_max_credit,
	l.max_credit_vsm_6 as loan_max_credit_vsm,
	CASE WHEN min_wage_14 = 0 THEN 0 
		ELSE l.daily_wage_2/min_wage_14 END AS loan_wage_vsm,
	CASE WHEN cf.colonia_avg_sales_price = 0 THEN 0
	     ELSE l.price_29 / cf.colonia_avg_sales_price
		END AS loan_sales_price_relative,
	l.joint_loan as loan_joint,
	l.home_type_33 as loan_home_type,
	l.building_type_28 as loan_building_type,
	l.credit_vsm_13 as loan_value_vsm
	FROM clean_loans_by_year l
	LEFT OUTER JOIN subcuenta_clean sub
		ON (l.credit_id_41 = sub.cv_credito)
	LEFT OUTER JOIN feature_loans_colonia 
  		ON (feature_loans_colonia.loanid = l.id)
	JOIN colonia_features cf 
		ON (cf.coloniaid = feature_loans_colonia.coloniaid
	  		 AND l.cur_year = cf.cur_year_cf
	  		 AND l.past = cf.past_cf));

CREATE INDEX idx_loan_features_cv_credito_lf_cur_year_lf_past_lf ON loan_features (cv_credito_lf, cur_year_lf, past_lf);

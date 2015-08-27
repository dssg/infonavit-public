CREATE TABLE personal_features AS (
SELECT l.credit_id_41 as cv_credito_pf,
	l.cur_year as cur_year_pf,
	l.past as past_pf,
	r.indece_de_riesgo AS personal_risk_index, 
	l.age_1 as personal_age,
	l.age_1 / cf.colonia_avg_age AS personal_age_relative,
	l.daily_wage_2 AS personal_daily_wage,
	l.daily_wage_2 / cf.colonia_avg_income AS personal_daily_wage_relative,
	l.married_7 as personal_married,
	CASE WHEN l.gender_5>=1 then l.gender_5 else NULL end as personal_gender,
	l.acquisitive_vsm_4
FROM clean_loans_by_year l
LEFT OUTER JOIN risk_index_int r
	ON (l.credit_id_41 = r.cv_credito)
JOIN feature_loans_colonia 
  	ON (feature_loans_colonia.loanid = l.id)
JOIN colonia_features cf 
	ON (cf.coloniaid = feature_loans_colonia.coloniaid
	  		 AND l.cur_year = cf.cur_year_cf
	  		 AND l.past = cf.past_cf));

CREATE INDEX idx_personal_features_cv_credito_pf_cur_year_pf_past_pf ON personal_features (cv_credito_pf, cur_year_pf, past_pf);

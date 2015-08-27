CREATE TABLE house_features AS (
SELECT  l.credit_id_41 as cv_credito_hf,
  l.cur_year as cur_year_hf,
  l.past as past_hf,
  e.ct_pnthsp as hospital_escore,
  e.ct_pntprq as parks_escore,
  e.ct_pntmrc as markets_escore,
  e.ct_pntesc as schools_escore,
  e.ct_pnteqp as equip_escore,
  e.ct_pntref as references_escore,
  e.ct_pnttrn as transportation_escore,
  e.ct_pntvld as roads_transport_escore,
  e.ct_suphab as living_area_escore,
  e.ct_gbs as sustainability_escore,
  e.ct_pnticv as validitiy_index_escore,
  e.ct_pntisa as satisfaction_escore,
  e.ct_hogdig as digital_escore,
  e.ct_cldvvn as housing_quality_escore,
  e.ct_pntaga as water_escore,
  e.ct_pntenr as power_escore,
  e.ct_pntcmd as community_escore,
  e.ct_ecuve as total_escore,
  CASE WHEN cf.colonia_avg_hospital_escore = 0 THEN 0
         ELSE e.ct_pnthsp / cf.colonia_avg_hospital_escore
  END AS hospital_escore_relative,
  CASE WHEN cf.colonia_avg_parks_escore = 0 THEN 0
         ELSE e.ct_pntprq / cf.colonia_avg_parks_escore
  END AS parks_escore_relative,
  CASE WHEN cf.colonia_avg_markets_escore = 0 THEN 0
         ELSE e.ct_pntmrc / cf.colonia_avg_markets_escore
  END AS markets_escore_relative,
  CASE WHEN cf.colonia_avg_schools_escore = 0 THEN 0
         ELSE e.ct_pntesc / cf.colonia_avg_schools_escore
  END AS schools_escore_relative,
  CASE WHEN cf.colonia_avg_equip_escore = 0 THEN 0
         ELSE e.ct_pnteqp / cf.colonia_avg_equip_escore
  END AS equip_escore_relative,
  CASE WHEN cf.colonia_avg_references_escore = 0 THEN 0
         ELSE e.ct_pntref / cf.colonia_avg_references_escore
  END AS references_escore_relative,
  CASE WHEN cf.colonia_avg_transportation_escore = 0 THEN 0
         ELSE e.ct_pnttrn / cf.colonia_avg_transportation_escore
  END AS transportation_escore_relative,
  CASE WHEN cf.colonia_avg_roads_transport_escore = 0 THEN 0
         ELSE e.ct_pntvld / cf.colonia_avg_roads_transport_escore
  END AS roads_transport_escore_relative,
  CASE WHEN cf.colonia_avg_living_area_escore = 0 THEN 0
         ELSE e.ct_suphab / cf.colonia_avg_living_area_escore
  END AS living_area_escore_relative,
  CASE WHEN cf.colonia_avg_sustainability_escore = 0 THEN 0
         ELSE e.ct_gbs / cf.colonia_avg_sustainability_escore
  END AS sustainability_escore_relative,
  CASE WHEN cf.colonia_avg_validitiy_index_escore = 0 THEN 0
         ELSE e.ct_pnticv / cf.colonia_avg_validitiy_index_escore
  END AS validitiy_index_escore_relative,
  CASE WHEN cf.colonia_avg_satisfaction_escore = 0 THEN 0
         ELSE e.ct_pntisa / cf.colonia_avg_satisfaction_escore
  END AS satisfaction_escore_relative,
  CASE WHEN cf.colonia_avg_digital_escore = 0 THEN 0
         ELSE e.ct_hogdig / cf.colonia_avg_digital_escore
  END AS digital_escore_relative,
  CASE WHEN cf.colonia_avg_housing_quality_escore = 0 THEN 0
         ELSE e.ct_cldvvn / cf.colonia_avg_housing_quality_escore
  END AS housing_quality_escore_relative,
  CASE WHEN cf.colonia_avg_water_escore = 0 THEN 0
         ELSE e.ct_pntaga / cf.colonia_avg_water_escore
  END AS water_escore_relative,
  CASE WHEN cf.colonia_avg_power_escore = 0 THEN 0
         ELSE e.ct_pntenr / cf.colonia_avg_power_escore
  END AS power_escore_relative,
  CASE WHEN cf.colonia_avg_community_escore = 0 THEN 0
         ELSE e.ct_pntcmd / cf.colonia_avg_community_escore
  END AS community_escore_relative,
  CASE WHEN cf.colonia_avg_total_escore = 0 THEN 0
         ELSE e.ct_ecuve / cf.colonia_avg_total_escore
  END AS total_escore_relative
FROM clean_loans_by_year l
LEFT OUTER JOIN ecuve e
  ON (l.credit_id_41 = e.cv_credito)
JOIN feature_loans_colonia 
  ON (feature_loans_colonia.loanid = l.id)
JOIN colonia_features cf 
  ON (cf.coloniaid = feature_loans_colonia.coloniaid
     AND l.cur_year = cf.cur_year_cf
    AND l.past = cf.past_cf));

CREATE INDEX idx_house_features_cv_credito_hf_cur_year_hf_past_hf ON house_features (cv_credito_hf, cur_year_hf, past_hf);

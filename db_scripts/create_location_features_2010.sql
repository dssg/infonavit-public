--DROP TABLE IF EXISTS location_features;

CREATE TABLE location_features  AS (
WITH distance_features AS (
SELECT fl.loanid,
	fd.* 
	FROM feature_geo_distance_denue_by_year_with_past fd
	JOIN feature_loans_colonia fl
	ON (fd.coloniaid = fl.coloniaid))
SELECT l.credit_id_41 as cv_credito_loc,
	df.* 
	FROM distance_features df 
	JOIN clean_loans_by_year l
	ON (df.loanid = l.id
		AND df.cur_year_fgd = l.cur_year
		AND df.past_fgd = l.past));

ALTER TABLE location_features
        DROP COLUMN loanid,
        DROP COLUMN coloniaid;
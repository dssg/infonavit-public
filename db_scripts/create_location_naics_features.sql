CREATE TABLE location_naics_features  AS (
WITH distance_features AS (
SELECT fl.loanid,
    fd.*
    FROM feature_geo_distance_denue_naics_by_year_with_past fd
    JOIN feature_loans_colonia fl
    ON (fd.coloniaid = fl.coloniaid))
SELECT l.credit_id_41 as cv_credito_loc_naics,
    df.*
    FROM distance_features df
    JOIN clean_loans_by_year l
    ON (df.loanid = l.id
        AND df.cur_year_fgdn = l.cur_year
        AND df.past_fgdn = l.past));

ALTER TABLE location_naics_features
        DROP COLUMN loanid,
        DROP COLUMN coloniaid;

CREATE INDEX idx_location_naics_features_cv_credito_loc_naics_cur_year_fgdn_past_fgdn ON location_naics_features (cv_credito_loc_naics, cur_year_fgdn, past_fgdn);
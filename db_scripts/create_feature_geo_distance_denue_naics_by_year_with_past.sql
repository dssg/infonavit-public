CREATE TABLE feature_geo_distance_denue_naics_by_year_with_past AS (
SELECT CASE WHEN past_fgdn = 1 THEN year + 1
        ELSE year
    END AS cur_year_fgdn,
    past_fgdn,
    fgdn.*
    FROM feature_geo_distance_denue_naics_by_year fgdn
    CROSS JOIN generate_series(0,1) as past_fgdn);

ALTER TABLE feature_geo_distance_denue_naics_by_year_with_past DROP COLUMN year;

CREATE INDEX idx_feature_geo_distance_denue_naics_by_year_with_past_coloniaid ON feature_geo_distance_denue_naics_by_year_with_past (coloniaid);
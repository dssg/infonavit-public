CREATE TABLE feature_geo_distance_denue_by_year_with_past AS (
SELECT CASE WHEN past_fgd = 1 THEN year + 1
        ELSE year
    END AS cur_year_fgd,
    past_fgd,
    fgd.*
    FROM feature_geo_distance_denue_by_year fgd
    CROSS JOIN generate_series(0,1) as past_fgd);

ALTER TABLE feature_geo_distance_denue_by_year_with_past DROP COLUMN year;

CREATE INDEX idx_feature_geo_distance_denue_by_year_with_past_coloniaid ON feature_geo_distance_denue_by_year_with_past (coloniaid);
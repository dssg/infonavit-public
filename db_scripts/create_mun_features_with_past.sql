CREATE TABLE mun_features_with_past AS (
SELECT CASE WHEN past_mf = 1 THEN year + 1
        ELSE year
    END AS cur_year_mf,
    past_mf,
    mf.*
    FROM mun_features mf
    CROSS JOIN generate_series(0,1) as past_mf);

ALTER TABLE mun_features_with_past DROP COLUMN year;
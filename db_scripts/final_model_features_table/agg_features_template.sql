DROP TABLE IF EXISTS prototype_features;

CREATE TABLE prototype_features AS(

WITH agg_features AS (
    select coloniaid, {} FROM master_loan_features_version4 WHERE cur_year=2015 group by coloniaid
    --limit 100
), subwindow AS (
    select *,row_number() over w as rn from master_loan_features_version4
    where cur_year=2015 and past=1
    window w as (partition by coloniaid range between unbounded preceding and unbounded following)
), features AS(
    select coloniaid, {}  from subwindow  where rn=1
    --limit 100
)
    SELECT * FROM agg_features JOIN features USING (coloniaid)
);

ALTER TABLE prototype_features
ADD years_since_granted int4;

UPDATE prototype_features
SET years_since_granted=1;

CREATE INDEX idx_coloniaid ON prototype_features(coloniaid);


-- SELECT cv_credito, coloniaid, personal_daily_wage, personal_age, no_busemp__0_40k
-- FROM master_loan_features_version4 WHERE coloniaid=100 AND cur_year=2015

-- SELECT coloniaid, personal_daily_wage, personal_age, no_busemp__0_40k
-- FROM prototype_features WHERE coloniaid=100
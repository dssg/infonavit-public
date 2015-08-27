CREATE TABLE location_features  AS (
WITH distance_features AS (
SELECT fl.loanid,
    fd.* 
    FROM feature_geo_distance_denue_by_year_with_past fd
    JOIN feature_loans_colonia fl
    ON (fd.coloniaid = fl.coloniaid))
SELECT l.credit_id_41 as cv_credito_loc,
    df.*, 
case when no_employee_0_2_5k <> 0 then no_businesses_0_2_5k/(cast (no_employee_0_2_5k as double precision)) else 0 end as no_busemp_0_2_5k,
case when no_employee_0_5k <> 0 then no_businesses_0_5k/(cast (no_employee_0_5k as double precision)) else 0 end   as no_busemp__0_5k,
case when no_employee_0_10k <> 0 then no_businesses_0_10k/(cast (no_employee_0_10k as double precision)) else 0 end   as no_busemp__0_10k,
case when no_employee_0_15k <> 0 then no_businesses_0_15k/(cast (no_employee_0_15k as double precision)) else 0 end   as no_busemp__0_15k,
case when no_employee_0_20k <> 0 then no_businesses_0_20k/(cast (no_employee_0_20k as double precision)) else 0 end   as no_busemp__0_20k,
case when no_employee_0_25k <> 0 then no_businesses_0_25k/(cast (no_employee_0_25k as double precision)) else 0 end   as no_busemp__0_25k,
case when no_employee_0_30k <> 0 then no_businesses_0_30k/(cast (no_employee_0_30k as double precision)) else 0 end   as no_busemp__0_30k,
case when no_employee_0_35k <> 0 then no_businesses_0_35k/(cast (no_employee_0_35k as double precision)) else 0 end   as no_busemp__0_35k,
case when no_employee_0_40k <> 0 then no_businesses_0_40k/(cast (no_employee_0_40k as double precision)) else 0 end   as no_busemp__0_40k,
case when no_employee_0_45k <> 0 then no_businesses_0_45k/(cast (no_employee_0_45k as double precision)) else 0 end   as no_busemp__0_45k,
case when no_employee_0_50k <> 0 then no_businesses_0_50k/(cast (no_employee_0_50k as double precision)) else 0 end   as no_busemp__0_50k,
case when no_employee_2_5_5k<>0 then no_businesses_2_5_5k/(cast (no_employee_2_5_5k as double precision)) else 0 end  as no_busemp_2_5_5k,
case when no_employee_5_10k <> 0 then no_businesses_5_10k/(cast (no_employee_5_10k as double precision)) else 0 end   as no_busemp_5_10k,
case when no_employee_10_15k <> 0 then no_businesses_10_15k/(cast (no_employee_10_15k as double precision)) else 0 end   as no_busemp_10_15k,
case when no_employee_15_20k <> 0 then no_businesses_15_20k/(cast (no_employee_15_20k as double precision)) else 0 end   as no_busemp_15_20k,
case when no_employee_20_25k <> 0 then no_businesses_20_25k/(cast (no_employee_20_25k as double precision)) else 0 end   as no_busemp_20_25k,
case when no_employee_25_30k <> 0 then no_businesses_25_30k/(cast (no_employee_25_30k as double precision)) else 0 end   as no_busemp_25_30k,
case when no_employee_30_35k <> 0 then no_businesses_30_35k/(cast (no_employee_30_35k as double precision)) else 0 end   as no_busemp_30_35k,
case when no_employee_35_40k <> 0 then no_businesses_35_40k/(cast (no_employee_35_40k as double precision)) else 0 end   as no_busemp_35_40k,
case when no_employee_40_45k <> 0 then no_businesses_40_45k/(cast (no_employee_40_45k as double precision)) else 0 end   as no_busemp_40_45k,
case when no_employee_45_50k <> 0 then no_businesses_45_50k/(cast (no_employee_45_50k as double precision)) else 0 end   as no_busemp_45_50k

FROM distance_features df 
    JOIN clean_loans_by_year l
    ON (df.loanid = l.id
        AND df.cur_year_fgd = l.cur_year
        AND df.past_fgd = l.past));

ALTER TABLE location_features
        DROP COLUMN loanid,
        DROP COLUMN coloniaid;

CREATE INDEX idx_location_features_cv_credito_loc_cur_year_fgd_past_fgd ON location_features (cv_credito_loc, cur_year_fgd, past_fgd);

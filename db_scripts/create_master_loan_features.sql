CREATE TABLE master_loan_features_version4 AS (
SELECT  l.credit_id_41 as cv_credito,
        l.cur_year,
        l.past,
        l.start_year_11 as year_granted,
        l.cur_year - l.start_year_11 as years_since_granted,
        l.abandon_year,
        l.abandon_month,
        pf.*,
        lf.*,
        hf.*,
        cf.*,
        mf.*,
        locf.*,
        locnf.*,
        l.abandoned as abandoned,
	l.abandoned_y as abandoned_y
FROM clean_loans_by_year l
        LEFT OUTER JOIN personal_features pf
            ON (l.credit_id_41 = pf.cv_credito_pf
                AND l.cur_year = pf.cur_year_pf
                AND l.past = pf.past_pf)
        LEFT OUTER JOIN loan_features lf
            ON (l.credit_id_41 = lf.cv_credito_lf
                AND l.cur_year = lf.cur_year_lf
                AND l.past = lf.past_lf)
        LEFT OUTER JOIN house_features hf
            ON (l.credit_id_41 = hf.cv_credito_hf
                AND l.cur_year = hf.cur_year_hf
                AND l.past = hf.past_hf)
        JOIN feature_loans_colonia 
            ON (feature_loans_colonia.loanid = l.id)
        JOIN colonia_features cf
            ON (cf.coloniaid = feature_loans_colonia.coloniaid
                AND l.cur_year = cf.cur_year_cf
                AND l.past = cf.past_cf)
        LEFT OUTER JOIN location_features locf
         ON (l.credit_id_41 = locf.cv_credito_loc
            AND l.cur_year = locf.cur_year_fgd
            AND l.past = locf.past_fgd) 
        LEFT OUTER JOIN location_naics_features locnf
         ON (l.credit_id_41 = locnf.cv_credito_loc_naics
            AND l.cur_year = locnf.cur_year_fgdn
            AND l.past = locnf.past_fgdn)  
        LEFT OUTER JOIN mun_features_with_past mf
         ON (mf.cve = l.municipality_key_26 
            AND mf.cur_year_mf = l.cur_year
            AND mf.past_mf = l.past)
);

ALTER TABLE master_loan_features_version4
        DROP COLUMN cv_credito_pf,
        DROP COLUMN cv_credito_lf,
        DROP COLUMN cv_credito_hf,
        DROP COLUMN cv_credito_loc,
        DROP COLUMN cv_credito_loc_naics,
        DROP COLUMN cur_year_pf,
        DROP COLUMN cur_year_lf,
        DROP COLUMN cur_year_hf,
        DROP COLUMN cur_year_cf,
        DROP COLUMN cur_year_fgd,
        DROP COLUMN cur_year_fgdn,
        DROP COLUMN cur_year_mf,
        DROP COLUMN past_pf,
        DROP COLUMN past_lf,
        DROP COLUMN past_hf,
        DROP COLUMN past_cf,
        DROP COLUMN past_mf,
        DROP COLUMN past_fgd,
        DROP COLUMN past_fgdn;




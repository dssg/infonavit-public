CREATE TABLE clean_loans_by_year AS (
WITH loan_abd AS 
(SELECT cl.*,
    ad.abandon_year,
    ad.abandon_month
    FROM clean_loans cl
        LEFT OUTER JOIN abandonment_date ad
ON (cl.credit_id_41 = ad.cv_credito)
)
SELECT cur_year,
    past,
    la.*,
    CASE WHEN abandon_year IS NOT NULL 
        AND abandon_month IS NOT NULL
        AND abandon_year <= cur_year
        AND past = 0
            THEN 1
        ELSE CASE WHEN abandon_year IS NOT NULL
            AND abandon_month IS NOT NULL
            AND abandon_year < cur_year
            AND past = 1
                THEN 1
            ELSE 0
        END
    END AS abandoned,
    CASE WHEN abandon_year IS NOT NULL
        AND abandon_month IS NOT NULL
        AND abandon_year <= cur_year
            THEN 1
        ELSE 0
    END AS abandoned_y
    FROM loan_abd la
        CROSS JOIN generate_series(2010, 2015) AS cur_year
        CROSS JOIN generate_series(0, 1) as past
    WHERE start_year_11 <= cur_year);

ALTER TABLE clean_loans_by_year DROP COLUMN abandoned_42;

CREATE INDEX idx_clean_loans_by_year_cur_year_past ON clean_loans_by_year (cur_year, past);

CREATE INDEX idx_clean_loans_by_year_credit_id ON clean_loans_by_year (credit_id_41);

CREATE INDEX idx_clean_loans_by_year_cur_year_past_credit_id ON clean_loans_by_year (cur_year, past, credit_id_41);

CREATE INDEX idx_clean_loans_by_year_id ON clean_loans_by_year (id);

CLUSTER clean_loans_by_year USING idx_clean_loans_by_year_cur_year_past_credit_id;
ANALYZE clean_loans_by_year;

Order of DB Scripts:

1 -- Run load_abandonment_data.sh to load /mnt/data/infonavit/new_data_june2/CARTERA_ABANDONADA_UTF8_PIPES.txt into "abandonment" table

1*** -- Run longtowide.awk on payments data to convert it to wide matrix format

2 -- Run load_payment_data.sh to load /mnt/data/infonavit/payments/payments_all_years.csv into "payments" table

3 -- Run clean_payments.sh to convert "payments" table to "payments_clean"

4 -- Run create_abandonment_date.sh to convert payments data into abandonment dates

5 -- Run load_loan_data.sh to create "loans" table from /mnt/data/infonavit/new_data_june2/fixed_dataset_192_rows_deleted.txt

6*** -- Run create_clean_loans.sh to create "clean_loans" from "loans"

7 -- Run load_subcuenta.sh to create "subcuenta_clean" table from /mnt/data/infonavit/subcuenta/SUBCUENTA_OFERENTES.txt

8 -- Run ~/infonavit/preprocessing/infonavit_ecuve/load_ecuve.sh to create "ecuve" table from ecuve.csv

9****** -- create feature_loans_colonia

10 -- Run ~/infonavit/feature-engineering/geospatial/create_feature_geo_distance_load_all.sh to create "feature_geo_distance_denue$year" tables

10 -- Run ~/infonavit/feature-engineering/geospatial/create_feature_geo_distance_naics_load_all.sh to create "feature_geo_distance_naics_denue$year" tables

11 -- Run ~/infonavit/feature-engineering/geospatial/combine_distance.sh to create "feature_geo_distance_denue_by_year" table

12 -- Run ~/infonavit/feature-engineering/geospatial/combine_naics.sh to create "feature_geo_distance_naics_denue_by_year" table

13 -- Run load_risk_data.sh to create "risk_index" table
    -- Convert to risk_index_int?

14 -- Run load_master_loan_features.sh to create "master_loan_features" table

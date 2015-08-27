import sys
from sklearn import ensemble, svm

# Add pipeline_src to include path (NOTE: this is a hardcoded path... will fail if you move dirs)
path = "../pipeline_src/"
if not path in sys.path:
    sys.path.insert(1, path)
del path

from experiment import Experiment

############################################################################
# Pipeline: Loading & Preprocessing
############################################################################
train_end_years = [2011, 2012, 2013, 2014]

# Create a list of columns that won't be used in prediction to drop
non_features = ['cv_credito',
                'coloniaid',
                'nom_mun',
                'mun_region',
                'mun_geo_zone',
                'year_granted',
                'cve',
                'abandoned',
                'abandoned_y',
                'abandoned_ever_y',
                'abandon_year',
                'abandon_month',
                'cur_year',
                'past',
                'regimen',
                'loan_has_subsudy',
                'loan_voluntary_contrib_bool']

keep_cols = ['years_since_granted', 
             'personal_risk_index',
             'personal_age',
             'personal_daily_wage',
             'personal_married',
             'personal_gender',
             'loan_value',
             'loan_building_type',
             'total_escore',
             'colonia_num_loans',
             'colonia_num_abd',
             'colonia_num_abd_first_year',
             'colonia_avg_loan_val',
             'colonia_max_loan_val',
             'colonia_min_loan_val',
             'colonia_avg_age',
             'colonia_avg_income',
             'colonia_avg_subaccount',
             'colonia_max_subsidy',
             'colonia_avg_interest_rate',
             'colonia_abd_percent',
             'colonia_num_abd_first_year_percent']

dist_total_cols = ['no_employee_0_2_5k',
                 'no_businesses_0_2_5k',
                 'no_employee_2_5_5k',
                 'no_employee_5_10k',
                 'no_employee_10_15k',
                 'no_employee_15_20k',
                 'no_employee_20_25k',
                 'no_employee_25_30k',
                 'no_employee_30_35k',
                 'no_employee_35_40k',
                 'no_employee_40_45k',
                 'no_businesses_2_5_5k',
                 'no_businesses_5_10k',
                 'no_businesses_10_15k',
                 'no_businesses_15_20k',
                 'no_businesses_20_25k',
                 'no_businesses_25_30k',
                 'no_businesses_30_35k',
                 'no_businesses_35_40k',
                 'no_businesses_40_45k',
                 'no_busemp_0_2_5k',
                 'no_busemp_2_5_5k',
                 'no_busemp_5_10k',
                 'no_busemp_10_15k',
                 'no_busemp_15_20k',
                 'no_busemp_20_25k',
                 'no_busemp_25_30k',
                 'no_busemp_30_35k',
                 'no_busemp_35_40k',
                 'no_busemp_40_45k']

dist_by_type_cols = ['no_employee_6111_0_2_5k',
                     'no_businesses_6111_0_2_5k',
                     'no_employee_6111_2_5_5k',
                     'no_employee_6111_5_10k',
                     'no_employee_6111_10_15k',
                     'no_employee_6111_15_20k',
                     'no_employee_6111_20_25k',
                     'no_employee_6111_25_30k',
                     'no_employee_6111_30_35k',
                     'no_employee_6111_35_40k',
                     'no_employee_6111_40_45k',
                     'no_businesses_6111_2_5_5k',
                     'no_businesses_6111_5_10k',
                     'no_businesses_6111_10_15k',
                     'no_businesses_6111_15_20k',
                     'no_businesses_6111_20_25k',
                     'no_businesses_6111_25_30k',
                     'no_businesses_6111_30_35k',
                     'no_businesses_6111_35_40k',
                     'no_businesses_6111_40_45k',
                     'no_employee_622_0_2_5k',
                     'no_businesses_622_0_2_5k',
                     'no_employee_622_2_5_5k',
                     'no_employee_622_5_10k',
                     'no_employee_622_10_15k',
                     'no_employee_622_15_20k',
                     'no_employee_622_20_25k',
                     'no_employee_622_25_30k',
                     'no_employee_622_30_35k',
                     'no_employee_622_35_40k',
                     'no_employee_622_40_45k',
                     'no_businesses_622_2_5_5k',
                     'no_businesses_622_5_10k',
                     'no_businesses_622_10_15k',
                     'no_businesses_622_15_20k',
                     'no_businesses_622_20_25k',
                     'no_businesses_622_25_30k',
                     'no_businesses_622_30_35k',
                     'no_businesses_622_35_40k',
                     'no_businesses_622_40_45k',
                     'no_employee_461_0_2_5k',
                     'no_businesses_461_0_2_5k',
                     'no_employee_461_2_5_5k',
                     'no_employee_461_5_10k',
                     'no_employee_461_10_15k',
                     'no_employee_461_15_20k',
                     'no_employee_461_20_25k',
                     'no_employee_461_25_30k',
                     'no_employee_461_30_35k',
                     'no_employee_461_35_40k',
                     'no_employee_461_40_45k',
                     'no_businesses_461_2_5_5k',
                     'no_businesses_461_5_10k',
                     'no_businesses_461_10_15k',
                     'no_businesses_461_15_20k',
                     'no_businesses_461_20_25k',
                     'no_businesses_461_25_30k',
                     'no_businesses_461_30_35k',
                     'no_businesses_461_35_40k',
                     'no_businesses_461_40_45k',
                     'no_employee_46211_0_2_5k',
                     'no_businesses_46211_0_2_5k',
                     'no_employee_46211_2_5_5k',
                     'no_employee_46211_5_10k',
                     'no_employee_46211_10_15k',
                     'no_employee_46211_15_20k',
                     'no_employee_46211_20_25k',
                     'no_employee_46211_25_30k',
                     'no_employee_46211_30_35k',
                     'no_employee_46211_35_40k',
                     'no_employee_46211_40_45k',
                     'no_businesses_46211_2_5_5k',
                     'no_businesses_46211_5_10k',
                     'no_businesses_46211_10_15k',
                     'no_businesses_46211_15_20k',
                     'no_businesses_46211_20_25k',
                     'no_businesses_46211_25_30k',
                     'no_businesses_46211_30_35k',
                     'no_businesses_46211_35_40k',
                     'no_businesses_46211_40_45k',
                     'no_employee_722_0_2_5k',
                     'no_businesses_722_0_2_5k',
                     'no_employee_722_2_5_5k',
                     'no_employee_722_5_10k',
                     'no_employee_722_10_15k',
                     'no_employee_722_15_20k',
                     'no_employee_722_20_25k',
                     'no_employee_722_25_30k',
                     'no_employee_722_30_35k',
                     'no_employee_722_35_40k',
                     'no_employee_722_40_45k',
                     'no_businesses_722_2_5_5k',
                     'no_businesses_722_5_10k',
                     'no_businesses_722_10_15k',
                     'no_businesses_722_15_20k',
                     'no_businesses_722_20_25k',
                     'no_businesses_722_25_30k',
                     'no_businesses_722_30_35k',
                     'no_businesses_722_35_40k',
                     'no_businesses_722_40_45k',
                     'no_employee_81321_0_2_5k',
                     'no_businesses_81321_0_2_5k',
                     'no_employee_81321_2_5_5k',
                     'no_employee_81321_5_10k',
                     'no_employee_81321_10_15k',
                     'no_employee_81321_15_20k',
                     'no_employee_81321_20_25k',
                     'no_employee_81321_25_30k',
                     'no_employee_81321_30_35k',
                     'no_employee_81321_35_40k',
                     'no_employee_81321_40_45k',
                     'no_businesses_81321_2_5_5k',
                     'no_businesses_81321_5_10k',
                     'no_businesses_81321_10_15k',
                     'no_businesses_81321_15_20k',
                     'no_businesses_81321_20_25k',
                     'no_businesses_81321_25_30k',
                     'no_businesses_81321_30_35k',
                     'no_businesses_81321_35_40k',
                     'no_businesses_81321_40_45k',
                     'no_busemp_6111_0_2_5k',
                     'no_busemp_6111_2_5_5k',
                     'no_busemp_6111_5_10k',
                     'no_busemp_6111_10_15k',
                     'no_busemp_6111_15_20k',
                     'no_busemp_6111_20_25k',
                     'no_busemp_6111_25_30k',
                     'no_busemp_6111_30_35k',
                     'no_busemp_6111_35_40k',
                     'no_busemp_6111_40_45k',
                     'no_busemp_622_0_2_5k',
                     'no_busemp_622_2_5_5k',
                     'no_busemp_622_5_10k',
                     'no_busemp_622_10_15k',
                     'no_busemp_622_15_20k',
                     'no_busemp_622_20_25k',
                     'no_busemp_622_25_30k',
                     'no_busemp_622_30_35k',
                     'no_busemp_622_35_40k',
                     'no_busemp_622_40_45k',
                     'no_busemp_461_0_2_5k',
                     'no_busemp_461_2_5_5k',
                     'no_busemp_461_5_10k',
                     'no_busemp_461_10_15k',
                     'no_busemp_461_15_20k',
                     'no_busemp_461_20_25k',
                     'no_busemp_461_25_30k',
                     'no_busemp_461_30_35k',
                     'no_busemp_461_35_40k',
                     'no_busemp_461_40_45k',
                     'no_busemp_46211_0_2_5k',
                     'no_busemp_46211_2_5_5k',
                     'no_busemp_46211_5_10k',
                     'no_busemp_46211_10_15k',
                     'no_busemp_46211_15_20k',
                     'no_busemp_46211_20_25k',
                     'no_busemp_46211_25_30k',
                     'no_busemp_46211_30_35k',
                     'no_busemp_46211_35_40k',
                     'no_busemp_46211_40_45k',
                     'no_busemp_722_0_2_5k',
                     'no_busemp_722_2_5_5k',
                     'no_busemp_722_5_10k',
                     'no_busemp_722_10_15k',
                     'no_busemp_722_15_20k',
                     'no_busemp_722_20_25k',
                     'no_busemp_722_25_30k',
                     'no_busemp_722_30_35k',
                     'no_busemp_722_35_40k',
                     'no_busemp_722_40_45k',
                     'no_busemp_81321_0_2_5k',
                     'no_busemp_81321_2_5_5k',
                     'no_busemp_81321_5_10k',
                     'no_busemp_81321_10_15k',
                     'no_busemp_81321_15_20k',
                     'no_busemp_81321_20_25k',
                     'no_busemp_81321_25_30k',
                     'no_busemp_81321_30_35k',
                     'no_busemp_81321_35_40k',
                     'no_busemp_81321_40_45k']


non_scaled_list=['personal_age_relative',
                             'personal_daily_wage_relative',
                             'personal_gender',
                             'personal_married',
                             'loan_joint',
                             'loan_value_relative',
                             'loan_interest_rate_relative',
                             'loan_subaccount_value_relative',
                             'loan_total_subsidy_relative',
                             'loan_sales_price_relative',
                             'hospital_escore_relative',
                             'parks_escore_relative',
                             'markets_escore_relative',
                             'schools_escore_relative',
                             'equip_escore_relative',
                             'references_escore_relative',
                             'transportation_escore_relative',
                             'roads_transport_escore_relative',
                             'living_area_escore_relative',
                             'sustainability_escore_relative',
                             'validitiy_index_escore_relative',
                             'satisfaction_escore_relative',
                             'digital_escore_relative',
                             'housing_quality_escore_relative',
                             'water_escore_relative',
                             'power_escore_relative',
                             'community_escore_relative',
                             'total_escore_relative',
                             'no_busemp_0_2_5k',
                             'no_busemp__0_5k',
                             'no_busemp__0_10k',
                             'no_busemp__0_15k',
                             'no_busemp__0_20k',
                             'no_busemp__0_25k',
                             'no_busemp__0_30k',
                             'no_busemp__0_35k',
                             'no_busemp__0_40k',
                             'no_busemp__0_45k',
                             'no_busemp__0_50k',
                             'no_busemp_2_5_5k',
                             'no_busemp_5_10k',
                             'no_busemp_10_15k',
                             'no_busemp_15_20k',
                             'no_busemp_20_25k',
                             'no_busemp_25_30k',
                             'no_busemp_30_35k',
                             'no_busemp_35_40k',
                             'no_busemp_40_45k',
                             'no_busemp_45_50k',
                             'no_busemp_6111_0_2_5k',
                             'no_busemp_6111_0_5k',
                             'no_busemp_6111_0_10k',
                             'no_busemp_6111_0_15k',
                             'no_busemp_6111_0_20k',
                             'no_busemp_6111_0_25k',
                             'no_busemp_6111_0_30k',
                             'no_busemp_6111_0_35k',
                             'no_busemp_6111_0_40k',
                             'no_busemp_6111_0_45k',
                             'no_busemp_6111_0_50k',
                             'no_busemp_6111_2_5_5k',
                             'no_busemp_6111_5_10k',
                             'no_busemp_6111_10_15k',
                             'no_busemp_6111_15_20k',
                             'no_busemp_6111_20_25k',
                             'no_busemp_6111_25_30k',
                             'no_busemp_6111_30_35k',
                             'no_busemp_6111_35_40k',
                             'no_busemp_6111_40_45k',
                             'no_busemp_6111_45_50k',
                             'no_busemp_622_0_2_5k',
                             'no_busemp_622_0_5k',
                             'no_busemp_622_0_10k',
                             'no_busemp_622_0_15k',
                             'no_busemp_622_0_20k',
                             'no_busemp_622_0_25k',
                             'no_busemp_622_0_30k',
                             'no_busemp_622_0_35k',
                             'no_busemp_622_0_40k',
                             'no_busemp_622_0_45k',
                             'no_busemp_622_0_50k',
                             'no_busemp_622_2_5_5k',
                             'no_busemp_622_5_10k',
                             'no_busemp_622_10_15k',
                             'no_busemp_622_15_20k',
                             'no_busemp_622_20_25k',
                             'no_busemp_622_25_30k',
                             'no_busemp_622_30_35k',
                             'no_busemp_622_35_40k',
                             'no_busemp_622_40_45k',
                             'no_busemp_622_45_50k',
                             'no_busemp_461_0_2_5k',
                             'no_busemp_461_0_5k',
                             'no_busemp_461_0_10k',
                             'no_busemp_461_0_15k',
                             'no_busemp_461_0_20k',
                             'no_busemp_461_0_25k',
                             'no_busemp_461_0_30k',
                             'no_busemp_461_0_35k',
                             'no_busemp_461_0_40k',
                             'no_busemp_461_0_45k',
                             'no_busemp_461_0_50k',
                             'no_busemp_461_2_5_5k',
                             'no_busemp_461_5_10k',
                             'no_busemp_461_10_15k',
                             'no_busemp_461_15_20k',
                             'no_busemp_461_20_25k',
                             'no_busemp_461_25_30k',
                             'no_busemp_461_30_35k',
                             'no_busemp_461_35_40k',
                             'no_busemp_461_40_45k',
                             'no_busemp_461_45_50k',
                             'no_busemp_46211_0_2_5k',
                             'no_busemp_46211_0_5k',
                             'no_busemp_46211_0_10k',
                             'no_busemp_46211_0_15k',
                             'no_busemp_46211_0_20k',
                             'no_busemp_46211_0_25k',
                             'no_busemp_46211_0_30k',
                             'no_busemp_46211_0_35k',
                             'no_busemp_46211_0_40k',
                             'no_busemp_46211_0_45k',
                             'no_busemp_46211_0_50k',
                             'no_busemp_46211_2_5_5k',
                             'no_busemp_46211_5_10k',
                             'no_busemp_46211_10_15k',
                             'no_busemp_46211_15_20k',
                             'no_busemp_46211_20_25k',
                             'no_busemp_46211_25_30k',
                             'no_busemp_46211_30_35k',
                             'no_busemp_46211_35_40k',
                             'no_busemp_46211_40_45k',
                             'no_busemp_46211_45_50k',
                             'no_busemp_722_0_2_5k',
                             'no_busemp_722_0_5k',
                             'no_busemp_722_0_10k',
                             'no_busemp_722_0_15k',
                             'no_busemp_722_0_20k',
                             'no_busemp_722_0_25k',
                             'no_busemp_722_0_30k',
                             'no_busemp_722_0_35k',
                             'no_busemp_722_0_40k',
                             'no_busemp_722_0_45k',
                             'no_busemp_722_0_50k',
                             'no_busemp_722_2_5_5k',
                             'no_busemp_722_5_10k',
                             'no_busemp_722_10_15k',
                             'no_busemp_722_15_20k',
                             'no_busemp_722_20_25k',
                             'no_busemp_722_25_30k',
                             'no_busemp_722_30_35k',
                             'no_busemp_722_35_40k',
                             'no_busemp_722_40_45k',
                             'no_busemp_722_45_50k',
                             'no_busemp_81321_0_2_5k',
                             'no_busemp_81321_0_5k',
                             'no_busemp_81321_0_10k',
                             'no_busemp_81321_0_15k',
                             'no_busemp_81321_0_20k',
                             'no_busemp_81321_0_25k',
                             'no_busemp_81321_0_30k',
                             'no_busemp_81321_0_35k',
                             'no_busemp_81321_0_40k',
                             'no_busemp_81321_0_45k',
                             'no_busemp_81321_0_50k',
                             'no_busemp_81321_2_5_5k',
                             'no_busemp_81321_5_10k',
                             'no_busemp_81321_10_15k',
                             'no_busemp_81321_15_20k',
                             'no_busemp_81321_20_25k',
                             'no_busemp_81321_25_30k',
                             'no_busemp_81321_30_35k',
                             'no_busemp_81321_35_40k',
                             'no_busemp_81321_40_45k',
                             'no_busemp_81321_45_50k']

encode_features = ['personal_gender',
                   'personal_married',
                   'loan_building_type']

non_quantize_features = ['years_since_granted', 
                         'personal_married', 
                         'personal_gender',
                         'loan_joint'] 

#all_features = keep_cols + dist_total_cols + dist_by_type_cols
#all_features_no_type = keep_cols + dist_total_cols


for train_end in train_end_years:
  for past_flag in [True]:
    # Instantiate an experiment
    exp = Experiment()

    # load data from hdf5
    exp.hdf_file = '/mnt/scratch/master_loan_features_v41.comp.h5'
    exp.load_data_hdf(train_range=(2008, train_end), 
                      test_range=(train_end, train_end + 1), 
                      past=past_flag, 
                      all_years=True)

    regimen_train = exp.x_train['regimen']
    regimen_test = exp.x_test['regimen']

    # if all_dist_features:
    #     drop_list = [col for col in list(exp.x_train) if not col in all_features]
    # else: 
    #     drop_list = [col for col in list(exp.x_train) if not col in all_features_no_type]

    # exp.drop_cols(drop_list)

    # Drop non-feature columns by name
    exp.drop_cols(non_features)

    # Drop all columns that have any NA's in them
    # Can also pass 'row' to drop all rows with NA's in them
    exp.drop_nas('row')

    # Drop non-feature columns by name again incase they came back.....
    exp.drop_cols(non_features)

    ##################################
    # Feature Interactions 
    ##################################

    # Convert all features to quantiles
    features_to_quantize = [feature for feature in list(exp.x_train) if not feature in non_quantize_features]

    # note to self: Try svm w/ these interactions...
    multiplicitive_features = ['personal_risk_index',
                               'personal_daily_wage',
                               'personal_married',
                               'personal_gender',
                               'personal_age']

    # Get names of the new features
    quantile_features = [feature + "_quantile" for feature in features_to_quantize]

    # Make quantiles (5 buckets)
    exp.make_quantile_columns(features_to_quantize, 5)

    # Optional (drop original cols after quantizing)
    # exp.drop_cols(features_to_quantize)

    # exp.encode_list_as_dummy(encode_features, string=True)

    # exp.drop_cols(encode_features)

    # quantile_features = []

    # for feature in list(exp.x_train):
    #     for q_feature in features_to_quantize:
    #         if (q_feature + "_" in feature 
    #             and 'relative' not in feature):
    #             quantile_features.append(feature) 

    print "Quantile features to be interacted with:"
    print quantile_features

    print "Multiplicative features:"
    print multiplicitive_features

    for q_feature in quantile_features:
      for m_feature in multiplicitive_features:
        if m_feature in q_feature:
          continue

        new_feature = q_feature + "_x_" + m_feature +  "_interaction"
        
        try:
            exp.x_train[new_feature] = exp.x_train[q_feature] * exp.x_train[m_feature]
            exp.x_test[new_feature] = exp.x_test[q_feature] * exp.x_test[m_feature]
            print "Created feature: {}".format(new_feature)
        except KeyError:
            print "Quantile feature doesnt exist. Probably didnt get made. Skipping interaction"


    #exp.drop_cols()

    #############################################################
    # Model definition and evaluation
    #############################################################
    # Pass a list of variable names to scale, else all features in the training set
    # are scaled. All scalers are stored in the experiment object for scaling the 
    # test set.
    # exp.scale_features_training()
    exp.scale_features_training(non_scaled_list=non_scaled_list)

    # Next scale the test set using the same scaling functions for each feature
    exp.scale_features_testing(non_scaled_list=non_scaled_list)


    #############################################################
    # Model definition and evaluation
    #############################################################

    class_weight_vals = ['auto']
    C_vals = [10.0**-2, 10.0**-1, 10.0**1, 50, 10.0**3, 10**4]
    tol_vals = [0.01, 0.1, 1.0]
    penalty_vals = ['l1', 'l2']
    max_iter_vals = [1000, 2000, 5000, 10000]
    loss_vals = ['squared_hinge']

    for max_iter in max_iter_vals:
      for loss in loss_vals:
        for penalty in penalty_vals:
          for class_weights in class_weight_vals:
            for C in C_vals:
              for tol in tol_vals:
                # Pick model and specify parameters
                svm_clf = svm.LinearSVC(max_iter=max_iter,
                                  dual=False,
                                  class_weight=class_weights,
                                  C=C,
                                  tol=tol,
                                  penalty=penalty,
                                  loss=loss)

                # Extract the training set as a numpy array from the experiment object 
                # with exp.get_train_np(). This returns the tuple (exp.x_train_sub, exp.y_train_sub)
                print "Training Model:"
                print svm_clf
                
                svm_clf = svm_clf.fit(exp.get_train_np()[0], exp.get_train_np()[1])
                print "Training Complete."

                exp.test_model(svm_clf)

                # Create evaluation HTML document
                exp.eval_model(svm_clf, html_file='./model_results/SVC_interact_{}_{}_auto_{}_{}_current_{}_train_end_{}.html'.format(str(C).replace('.', '_'), 
                                                                                               str(tol).replace('.', '_'),
                                                                                               penalty,
                                                                                               max_iter,
                                                                                               past_flag,
                                                                                               train_end))
    del exp



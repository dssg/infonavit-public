import sys
from sklearn import ensemble
from sklearn.externals import joblib
import pickle

# Add pipeline_src to include path (NOTE: this is a hardcoded path... will fail if you move dirs)
path = "../pipeline_src/"
if not path in sys.path:
    sys.path.insert(1, path)
del path

from experiment import Experiment

############################################################################
# Pipeline: Loading & Preprocessing
############################################################################

# Create a list of columns that won't be used in prediction to drop
non_features = ['cv_credito',
                'coloniaid',
                'colonia_num_abd',
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
                'loan_voluntary_contrib_bool',
                'personal_gender',
                'personal_married',
                'loan_building_type']

# list of features to not convert to quantiles since we are converting all
# other features
non_quantize_features = ['years_since_granted']

# Create the experiment object
exp = Experiment()

# Specify the HDF5 file to load data from
exp.hdf_file = '/mnt/scratch/master_loan_features_v41.comp.h5'
# Specify the years to load
exp.load_data_hdf(train_range=(2008, 2014), 
                  test_range=(2014, 2015), 
                  past=True, 
                  all_years=True)

# Drop non-feature columns by name
exp.drop_cols(non_features)

# Drop all columns that have any NA's in them
# Can also pass 'row' to drop all rows with NA's in them
exp.drop_nas('row')

# Drop non-feature columns by name again incase they came back
# (we found abandoned_y was continually re-added back the training data after dropping NA's)
exp.drop_cols(non_features)

##################################
# Feature Interactions 
##################################

# Convert all features to quantiles
features_to_quantize = [feature for feature in list(exp.x_train) if not feature in non_quantize_features]

multiplicitive_features = ['personal_risk_index',
                           'personal_daily_wage',
                           'personal_age']

# Get names of the new features
quantile_features = [feature + "_quantile" for feature in features_to_quantize]

# Make quantiles (5 buckets)
exp.make_quantile_columns(features_to_quantize, 7)


###### Interaction Features commented out since they require too much time & RAM to compute
# print "Quantile features to be interacted with:"
# print quantile_features

# print "Multiplicative features:"
# print multiplicitive_features

# for q_feature in quantile_features:
#   for m_feature in multiplicitive_features:
#     if m_feature in q_feature:
#       continue

#     new_feature = q_feature + "_x_" + m_feature +  "_interaction"

#     try:
#         exp.x_train[new_feature] = exp.x_train[q_feature] * exp.x_train[m_feature]
#         exp.x_test[new_feature] = exp.x_test[q_feature] * exp.x_test[m_feature]
#         print "Created feature: {}".format(new_feature)
#     except KeyError:
#         print "Quantile feature doesnt exist. Probably didnt get made. Skipping interaction"


#############################################################
# Model definition and evaluation
#############################################################

# Pick model and specify parameters
rfc = ensemble.RandomForestClassifier(n_estimators=2500,
                                      criterion='gini', 
                                      max_features='log2',
                                      max_depth=15,
                                      n_jobs=-1,
                                      class_weight='subsample',
                                      min_weight_fraction_leaf=0.0)  

print "Training Model:"
print rfc

rfc = rfc.fit(exp.x_train, exp.y_train)

print "Training Complete."  

print "Pickeling the final model to /mnt/scratch/final_model/final_model.pkl"

joblib.dump(rfc, "/mnt/scratch/final_model/final_model.pkl")
pickle.dump((list(exp.x_train), exp.preprocessor.quantile_breaks), open("/mnt/scratch/final_model/final_model_feats_n_qb.pkl", 'wb'))
                                                                                                        
del exp

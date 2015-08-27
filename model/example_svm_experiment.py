import sys
from sklearn import svm

# Add pipeline_src to include path (NOTE: this is a hardcoded path... will fail if you move dirs)
path = "../pipeline_src/"
if not path in sys.path:
    sys.path.insert(1, path)
del path

from experiment import Experiment

############################################################################
# Pipeline: Loading & Preprocessing
############################################################################

# Instantiate an experiment
exp = Experiment()

# Load data & specify train and test ranges
# can also specify a list of columns to load with load_list=[]
# or a list of columns to drop with drop_list=[]
exp.load_data(load_list = [],
              drop_list = ['abandoned', 'cur_year', 'past'],
              train_range=(2008,2012), 
              test_range=(2012, 2013), 
              train_current=False,
              test_current=False,
              fast=False,
              all_years=False,
              head=True)

# Create a list of columns that won't be used in prediction to drop
non_features = ['coloniaid',
                'colonia_num_loans',
                'colonia_num_abd',
                'mun_region',
                'mun_geo_zone',
                'abandoned']

# Drop non-feature columns by name
exp.drop_cols(non_features)

# Drop all columns that have any NA's in them
# Can also pass 'row' to drop all rows with NA's in them
exp.drop_nas('row')

# Pass a list of variable names to scale, else all features in the training set
# are scaled. All scalers are stored in the experiment object for scaling the 
# test set.
exp.scale_features_training()

# Next scale the test set using the same scaling functions for each feature
exp.scale_features_testing()

# Subsample the training set into exp.x_train and exp.y_train
# with the specified ratio of abandoned_count / non_abandoned_count
# Can also specify whether to subsample based on cv_credito or just based 
# on row indexes
exp.subsample_training(0.08, use_cv_credito=True)

# drop the cv credito now that we've done subsampling
exp.drop_cols(['cv_credito'])

#############################################################
# Model definition and evaluation
#############################################################

# Pick model and specify parameters
svm_clf = svm.LinearSVC(dual=False, class_weight='auto')

# Extract the training set as a numpy array from the experiment object 
# with exp.get_train_np(). This returns the tuple (exp.x_train_sub, exp.y_train_sub)
print "Training Model..."
svm_clf = svm_clf.fit(exp.get_train_np()[0], exp.get_train_np()[1])
print "Training Complete."

# Create evaluation HTML document
exp.eval_model(svm_clf, "model_results/svm_example_test.html")



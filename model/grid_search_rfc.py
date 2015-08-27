import sys
from sklearn import ensemble

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
              drop_list = ['cur_year', 'past'],
              train_range=(2008,2012), 
              test_range=(2012, 2013), 
              train_current=False,
              test_current=False,
              fast=False,
              all_years=False,
              head=False,
              subsample=None)

# Create a list of columns that won't be used in prediction to drop
non_features = ['coloniaid',
                'colonia_num_loans',
                'colonia_num_abd',
                'mun_region',
                'mun_geo_zone',
                'year_granted',
                'cve',
                'abandoned',
                'abandon_year',
                'abandon_month']

# Drop non-feature columns by name
exp.drop_cols(non_features)

# Drop all columns that have any NA's in them
# Can also pass 'row' to drop all rows with NA's in them
exp.drop_nas('row')

# Subsample the training set into exp.x_train and exp.y_train
# with the specified ratio of abandoned_count / non_abandoned_count
# Can also specify whether to subsample based on cv_credito or just based 
# on row indexes
exp.subsample_training(0.33, use_cv_credito=True)

# drop the cv credito now that we've done subsampling
exp.drop_cols(['cv_credito'])

#############################################################
# Model definition and evaluation
#############################################################


max_depths = [30, 20, 10]
n_estimators = [1000, 2500, 5000]
criteria = ['entropy', 'gini']
max_features = [20, 30, 40]
min_samples_leaf = [4, 2, 1]

for num_features in max_features:
  for criterion in criteria:
    for num_e in n_estimators:
      for depth in max_depths:
        for min_samples in min_samples_leaf:
          # Pick model and specify parameters
          rfc = ensemble.RandomForestClassifier(n_estimators=num_e,
                                                criterion=criterion, 
                                                max_features=num_features,
                                                min_samples_leaf=min_samples,
                                                max_depth=depth,
                                                n_jobs=15)

          # Extract the training set as a numpy array from the experiment object 
          # with exp.get_train_np(). This returns the tuple (exp.x_train_sub, exp.y_train_sub)
          print "Training Model..."
          rfc = rfc.fit(exp.get_train_np()[0], exp.get_train_np()[1])
          print "Training Complete."

          exp.test_model(rfc)

          # Create evaluation HTML document
          exp.eval_model(rfc, html_file='./model_results/RFC_Grid_Search_{}_{}_{}_{}_{}.html'.format(min_samples, depth, num_e, criterion, num_features))



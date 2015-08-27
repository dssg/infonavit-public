import sys
from sklearn import ensemble, tree

# Add pipeline_src to include path (NOTE: this is a hardcoded path... will fail if you move dirs)
path = "../pipeline_src/"
if not path in sys.path:
    sys.path.insert(1, path)
del path

from experiment import Experiment

############################################################################
# Pipeline: Loading & Preprocessing
############################################################################
train_end_years = [2012]

features_to_encode = ['coloniaid', 'mun_region', 'mun_geo_zone', 'loan_voluntary_contrib_bool', 'loan_has_subsudy']

# Create a list of columns that won't be used in prediction to drop
non_features = ['cv_credito',
                'nom_mun',
                'year_granted',
                'cve',
                'abandoned',
                'abandoned_y',
                'abandon_year',
                'abandon_month',
                'cur_year',
                'past']


for train_end in train_end_years:
  for past_flag in [False, True]:
    # Instantiate an experiment
    exp = Experiment()

    # load data from hdf5
    exp.load_data_hdf(train_range=(2008, train_end), 
                      test_range=(train_end, train_end + 1), 
                      past=past_flag, 
                      all_years=True)


    # Drop non-feature columns by name
    exp.drop_cols(non_features)

    # Drop all columns that have any NA's in them
    # Can also pass 'row' to drop all rows with NA's in them
    exp.drop_nas('row')

    # Drop non-feature columns by name again incase they came back.....
    exp.drop_cols(non_features)



    exp.encode_list_as_dummy(['years_since_granted', 
                              'loan_has_subsudy',
                              'loan_voluntary_contrib_bool'])
    
    # exp.x_train['risk_index_duration'] =  exp.x_train['risk_index'] * exp.x_trian['years_since_granted_0']


    # Encode features...
    # exp.encode_list_as_dummy(features_to_encode)

    # Drop encoded original features
    exp.drop_cols(features_to_encode)

    #############################################################
    # Model definition and evaluation
    #############################################################

    # Compute training abd %
    train_abd_pct = exp.y_train.sum() / float(exp.y_train.shape[0])


    class_weights = ['auto']
    n_estimators = [100, 200]
    learning_rate = [1, 0.9, 0.75, 1.5]
    criteria = ['gini']
    max_depths = [1, 2, 3]
    max_features = [30, 40, 50, 100]
    min_weight_fraction_leaf_vals = [train_abd_pct * 0.25, 
                                     train_abd_pct * 0.5, 
                                     train_abd_pct * 0.75,
                                     train_abd_pct * 1.25,
                                     train_abd_pct * 1.5,
                                     train_abd_pct * 2.0,
                                     train_abd_pct * 3.0,
                                     train_abd_pct * 4.0]


    for lr in learning_rate:
      for num_e in n_estimators:
        for criterion in criteria:
          for depth in max_depths:
            for num_features in max_features:
              for mwfl in min_weight_fraction_leaf_vals:
                ada_clf = ensemble.AdaBoostClassifier(base_estimator=tree.DecisionTreeClassifier(criterion='entropy',
                                                                                                  max_depth = depth,
                                                                                                  class_weight='auto',
                                                                                                  max_features=num_features,
                                                                                                  min_weight_fraction_leaf=mwfl),
                                                       n_estimators=num_e,
                                                       algorithm='SAMME.R',
                                                       learning_rate=lr)
    
                # Extract the training set as a numpy array from the experiment object 
                # with exp.get_train_np(). This returns the tuple (exp.x_train_sub, exp.y_train_sub)
                print "Training Model..."
                print ada_clf
                ada_clf = ada_clf.fit(exp.get_train_np()[0], exp.get_train_np()[1])
                print "Training Complete."
    
                exp.test_model(ada_clf)
    
                # Create evaluation HTML document
                exp.eval_model(ada_clf, html_file='./model_results/ADA_v3_{}_{}_{}_{}_{}_{}.html'.format(train_end, lr, depth, num_e, criterion, num_features))
                                                                                              
    del exp

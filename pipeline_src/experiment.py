import os
import sys
import pandas as pd
import numpy as np
import data_loader
import model_eval
import preprocessing

class Experiment:
    """ 
    The Experiment class is the overarching class which holds the majority
    of the data pipeline as well as the specifics of the Experiment. An Experiment
    Object is instantiated to load the data from postgres and perform/save 
    necessary preprocessing for further testing. 
    
    Attributes:
    feature_list (list): list of features loaded from postgres, updated to actual list
        in x_train when calling eval_model.
    train_range (tuple(int, int)): tuple of start year (inclusive) and stop year (exclusive)
        for the training data. Start date filters based on year_granted, and stop date selects
        which year the final "known features" will be computed from
    test_range (tuple(int, int)): tuple of start year (inclusive) and stop year (exclusive)
        for the testing data.
    x_train (pd.DataFrame): [n_features x train_size] x features for training. T
    y_train (pd.DataFrame): [train_size] target values for training. 
    x_test (pd.DataFrame): [n_features x test_size] x features for testing. 
    y_test (pd.DataFrame): [test_size] target value for testing. 
    preprocessor (preprocessing.Preprocessor): Instance of Preprocessor class, stores a list
        of feature scalers used on the training set to allow the same scaling to be done on test set.
        Also has methods for dropping NA's, subsampling, and encoding categorical features.
    
    Methods:
    set_y_var (y_var): define the target variable for the experiment.
    set_train_test_split (train_range, test_range): redefine the train/test split.
    print_shape (): print the shape of all currently populated dataframes attributes.
    load_data (load_list, drop_list,  train_range, test_range, train_current, test_current, 
        fast, all_years): given a list of features to either load, or if none specified, 
        to drop, from all features, this function creates queries and loads appropriate data 
        from the database into the x/y train/test attributes.
    load_data_csv(train_file, test_file, load_list, drop_list, train_delim, test_delim): Given 
        a csv file to load training or testing data from, load data into x/y train/test. Warning this
        method uses a lot of memory overhead
    load_data_hdf (train_range, test_range, past, all_years): Load the appropriate training/testing data
        from HDF5 file self.hdf_file and load into train/test x/y df's. This is the fastest and most
        memory efficient loader I've found.
    drop_nas (margin): given a margin of either 'row' or 'col' this function drops all
        instances of margin, i.e. all rows or all cols, where any NA values are 
        found from x_df and y_df.
    drop_cols(drop_list): given a list of column names, drop these columns inplace in x_df and y_df. 
    encode_list_as_dummy (list): For each variable in the given list, a column is added for each unique
        value of the column, with a binary indicator of whether the original column had that value.
    scale_features_training (scaled_feature_list, non_scaled_list): for all features in scaled_feature_list,
        or for all features in the dataframe if none specified, create a sklearn StandardScalar object,
        scale the column in x_train, and save the StandardScalar in the preprocessor object to scale
        the same feature for testing later. 
    scale_features_testing (scaled_feature_list, non_scaled_list): for all features in scaled_feature_list, 
        or for all features in the dataframe if none specified, load StandardScalar object from 
        preprocessor, and scale the column in x_test. 
    subsample_training (percent_abd): downsample the non-abandoned houses in x_train until the percent of 
        abandoned loans equals percent_abd. This function populates x_train_sub and y_train_sub, and 
        causes get_train_np to return these subsets rather than the full set.
    subsample_subsample (num_rows): return a specific number of randomly chosen rows from x_train_sub and
        y_train_sub for computationally intensive purposes. (svm...)
    eval_model (model, html_file): given a trained sklearn model and an output file location, this 
        function tests the model and prints the results in an html document at the specified path.
    add_feature_column (func, new_feature_name): given a function to apply row-wise to x_df, and a 
        name for the new feature column, this function appends the new feature to the dataframe inplace.
    get_train_np (): Return x_train, y_train or x_train_sub, y_train_sub depending on if subsampling 
        occured in pipeline, and convert from pandas df to numpy array for sklearn training & evaluation.
    get_test_np (): Return x_test, y_test and convert from pandas df to numpy array. 
    get_features (): Return list of features stored in object.
    """
 
    def __init__(self):
        self.feature_list  = []
        self.train_range = None
        self.test_range = None
        self.x_train = None
        self.y_train = None
        self.x_test = None
        self.y_test = None
        self.y_test_pred_prob = None
        self.y_test_pred = None
        self.y_var = "abandoned_y"
        self.has_prob = True
        self.preprocessor = preprocessing.Preprocessor()
        self.subsampled = False
        self.subsample_ratio = 0.0
        self.html_file = None
        self.hdf_file = '/mnt/data/infonavit/master_loan_features/master_loan_features_v4.h5'


    def __del__(self):
        del self


    # Method to set dependant variable.
    def set_y_var(self, y_var):
        self.y_var = y_var


    def set_train_test_split(self, train_range, test_range):
        self.train_range = train_range
        self.test_range = test_range


    def print_shape(self):
        if self.x_train is not None and self.y_train is not None:
            print ".x_train.shape = {}".format(self.x_train.shape)
            print ".y_train.shape = {}".format(self.y_train.shape)
        if self.x_test is not None and self.y_test is not None:
            print ".x_test.shape = {}".format(self.x_test.shape)
            print ".y_test.shape = {}".format(self.y_test.shape)
 
    # Main function to load the data into the internal x_df, and y_df
    def load_data(self, 
                  load_list=[], 
                  drop_list=['cur_year', 'past'],
                  train_range=(2008, 2012),
                  test_range=(2012, 2013),
                  train_current=False,
                  test_current=False,
                  fast=False,
                  all_years=False,
                  head=False,
                  subsample=None,
                  num_abd=None,
                  num_not_abd=None):
        self.train_range = train_range
        self.test_range = test_range
        if subsample is not None and type(subsample) == type(1):
            self.x_train, self.y_train, self.x_test, self.y_test, self.feature_list = data_loader.load_data_subsample(subsample, 
                        load_list, drop_list, self.y_var, self.train_range, self.test_range, train_current, test_current, fast, all_years)
        else:
            self.x_train, self.y_train, self.x_test, self.y_test, self.feature_list = data_loader.load_data(load_list, drop_list, 
                                                     self.y_var, self.train_range, self.test_range,
                                                     train_current, test_current, fast, all_years, head,
                                                     num_abd=num_abd, num_not_abd=num_not_abd)
        print "Data loaded succesfully:"
        self.print_shape()

    # Used to load directly from csv
    def load_data_csv(self,
                      train_file=None,
                      test_file=None,
                      load_list=[],
                      drop_list=[],
                      train_delim=',',
                      test_delim=','):
        if train_file is not None:
            self.x_train, self.y_train = data_loader.load_from_csv(train_file,
                                                               load_list=load_list,
                                                               drop_list=drop_list,
                                                               y_var=self.y_var,
                                                               delim=train_delim)
            print "Training Loaded."
        if test_file is not None:
            self.x_test, self.y_test = data_loader.load_from_csv(test_file,
                                                                 load_list=load_list,
                                                                 drop_list=drop_list,
                                                                 y_var=self.y_var,
                                                                 delim=test_delim)
            print "Testing Loaded."


    # Wrapper around data_loader.load_from_hdf for the expierment class
    def load_data_hdf(self, 
                     train_range=(2008, 2012),
                     test_range=(2012, 2013),
                     past=True,
                     all_years=False,
                    additional_features=False):

        self.train_range = train_range
        self.test_range = test_range
        print "Loading training data from file {}...".format(self.hdf_file)
        self.x_train, self.y_train = data_loader.load_from_hdf(filename=self.hdf_file, 
                                                              cur_year=self.train_range[1], 
                                                              year_granted=train_range[0],
                                                              # load_list=load_list,
                                                              # drop_list=drop_list,
                                                              past=past,
                                                              all_years=all_years,
                                                              y_var=self.y_var,
                                                              additional_features=additional_features)
        print "Training Data loaded."
        print "Loading Testing data..."
        self.x_test, self.y_test = data_loader.load_from_hdf(filename=self.hdf_file, 
                                                              cur_year=self.test_range[1], 
                                                              year_granted=train_range[0],
                                                              # load_list=load_list,
                                                              # drop_list=drop_list,
                                                              past=True,
                                                              all_years=False,
                                                              y_var=self.y_var,
                                                              additional_features=additional_features)
        print "Data loading complete"
        self.print_shape()


    # Given a margin, this function drops all rows/columns that contain any NA's 
    # for that given margin.
    def drop_nas(self, margin='col'):
        print "Original shape of dataframes before dropping NA's:"
        self.print_shape()
        self.preprocessor.drop_nas(self, margin)
        print "New shape after dropping:"
        self.print_shape()


    # Drop given list of columns inplace
    def drop_cols(self, drop_list):
        print "Original shape before dropping columns:"
        self.print_shape()
        self.preprocessor.drop_cols(self, drop_list)
        print "New shape after dropping:"
        self.print_shape()


    # Given a list of features, this function encodes them all as binary 
    # dummy columns for each unique value in column
    def encode_list_as_dummy(self, col_list, string=False):
        print "Original shape of dataframes before adding dummies:"
        self.print_shape()
        self.preprocessor.encode_as_dummy(self, col_list, string)
        print "New shape after dropping cols & adding dummies:"
        self.print_shape()

    # Given a list of columns and a number of buckets this function tries to generate
    # a quantile column for each given column with the specified number of buckets
    def make_quantile_columns(self, col_list, num_buckets):
        self.preprocessor.quantize_columns(self, col_list, num_buckets)

    # Used for SVM this function subtracts the mean from specified features and divides
    # by variance. Scaling factors are stored in preprocessor object to scale testing in
    # same way.
    def scale_features_training(self, scaled_feature_list=[], non_scaled_list=[]):
        if scaled_feature_list == []:
            print "Scaled feature list undefined in method call. Scaling all features by default"
            scaled_feature_list = [feature for feature in list(self.x_train) if feature not in non_scaled_list]
        print "Fitting scalers on training set, and saving scalers for testing."
        print "Scaling features: {}".format(scaled_feature_list)
        self.x_train = self.preprocessor.scale_features_training(self.x_train, scaled_feature_list)
        print "Scaling complete."

    # Using the scalers created from scale_features_training, this functiona additionally
    # scales all the features of the testing set with the same parameters
    def scale_features_testing(self, scaled_feature_list=[], non_scaled_list=[]):
        if scaled_feature_list == []:
            print "Scaled feature list undefined in method call. Scaling all features by default"
            scaled_feature_list = [feature for feature in list(self.x_train) if feature not in non_scaled_list]

        print "Using scalers fit on training set to scale test set."
        print "Scaling features: {}".format(scaled_feature_list)
        self.x_test = self.preprocessor.scale_features_testing(self.x_test, scaled_feature_list)
        print "Scaling complete."

    # Function to oversample the non-abandoned set to make training more balanced
    def subsample_training(self, percent_abd, use_cv_credito=True, inplace=True):
        if inplace:
            if self.subsampled == True:
                print "X_train alredy sub-sampled inplace"
            self.x_train, self.y_train = self.preprocessor.sub_sample(self.x_train, self.y_train, percent_abd, self.y_var, use_cv_credito)
            self.subsampled = True
            self.subsample_ratio = percent_abd
        else:
            return self.preprocessor.sub_sample(self.x_train, self.y_train, percent_abd, self.y_var, use_cv_credito)
        self.print_shape()


    def subsample_subsample(self, num_rows):
        if (num_rows > self.x_train.shape[0]):
            print "Given subsample size must be less than total rows in x_train_sub."
            return

        # Get random subset of indexes equal to the partition size
        random_subset = np.random.choice(self.x_train.index, num_rows, replace=False)
        # Select out those rows
        return self.x_train.loc[random_subset], self.y_train.loc[random_subset]

    # Given a model, this function runs the model on the test set and computes 
    # either the estimated probabilities of each example, or the scaled scores.
    def test_model(self, model):
        print "Testing model on x_test..."
        self.feature_list = list(self.x_train)
        try:
            self.y_test_pred_prob = model.predict_proba(self.x_test)
            self.y_test_pred_prob = np.array([tup[1] for tup in self.y_test_pred_prob])
            self.has_prob = True
            print "Predicted probabilities for each test case saved in exp.y_test_pred_prob."
        except AttributeError:
            try:
                self.y_test_pred_prob = np.array(model.decision_function(self.x_test))
                self.has_prob = False
                print "Predicted scores for each test case saved in exp.y_test_pred_prob."
                print "WARNING: Scores are scaled to 0-1 to be able to use same evaulation metrics as probability. But these are not probabilities..."
            except AttributeError:
                self.y_test_pred_prob = None
                self.has_prob = False
                self.y_test_pred = model.predict(self.x_test)
                print "Model has no probability or score prediction method... Just doing standard predictions"


    # Given the model and a file to save results to this function write an 
    # HTML evaluation log for the model
    def eval_model(self, model, html_file=None, save_to_sql=True):
        self.html_file = model_eval.save_experiment_html(self, model, html_file)
        if save_to_sql:
            try:
                model_eval.save_to_sql(self, model)
            except Exception, e:
                print e
                print "Save to sql failed."
        return self.html_file
        
    # # Given a function to apply row_wise, and a name for a new feature,
    # # This methods adds that feature to the internal dataframe
    # def add_feature_column(self, func, new_feature_name):
    #     print "WARNING: this doesnt work right yet..."
    #     self.x_df[new_feature_name] = self.x_df.apply(func, axis=1)
    
    def get_train_np(self):
        return np.array(self.x_train).astype(float), np.ravel(np.array(self.y_train))

    
    def get_test_np(self):
        return np.array(self.x_test).astype(float), np.ravel(np.array(self.y_test))

    
    def get_features(self):
        self.feature_list = list(self.x_train)
        return self.feature_list






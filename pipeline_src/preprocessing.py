import pandas as pd
import numpy as np
from sklearn import preprocessing

#Class for preprocessing data in our pipeline
class Preprocessor:
    """ 
    The preprocessor class holds a variety of preprocessing methods to operate on Experiment attributes, 
    and additionally stores a dictionary of StandardScaler objects which maps between feature
    name and their associated scaler object. This is useful to apply the same scaling function 
    to the training set as the test set. A preprocessor object is instantiated for each experiment object.
    """
    def __init__(self):
        #Init empty dictionary to store scalers applied in the training data
        #so the same transformation can be applied in the test set
        self.scalers = {}
        self.dropped_cols = []
        self.dropped_rows = []
        self.quantile_breaks = {}

    def count_nas(self, x_df, y_df, margin='col'):
        #Get bool values for nas
        is_na = x_df.isnull()

        if(margin=='col'):
            #Count per colums
            nas_count = is_na.apply(sum, axis=0)
            #Filter for columns with more than 0 nas
            col_names = nas_count[nas_count > 0]
            print "These columns have nas: "+str(col_names)
        elif(margin=='row'):            
            #Count per rows
            nas_count = is_na.apply(sum, axis=1)
            row_idx = nas_count[nas_count > 0].index
            print str(len(row_idx))+" rows will be droppped"
        else:
            print 'col and row are the only possible values for margin'

    #Dropping data with NAs
    def drop_nas(self, exp, margin='col'):
        all_cols = set(list(exp.x_train))
        all_rows_train = set(exp.x_train.index)
        all_rows_test = set(exp.x_test.index)
        
        if(margin=='col'):
            # Drop columns with NA's in each independantly
            exp.x_train.dropna(axis=1, inplace=True)
            exp.x_test.dropna(axis=1, inplace=True)
            
            # Get list of intersection of columns which are left
            keep_cols = set(list(exp.x_train)).intersection(list(exp.x_test))
            # Compute which columns got dropped
            drop_cols = all_cols.difference(keep_cols)
            
            print "NA's found in the following columns. Dropping: {}".format(drop_cols)
            
            for col_name in drop_cols:
                try:
                    exp.x_train.drop(col_name, axis=1, inplace=True)
                except ValueError:
                    pass
                try:
                    exp.x_test.drop(col_name, axis=1, inplace=True)
                except ValueError:
                    pass

        elif(margin=='row'):
            # Drop rows with NA's in each independantly
            exp.x_train.dropna(axis=0, inplace=True)
            exp.x_test.dropna(axis=0, inplace=True)
            
            # Compute which columns got dropped
            drop_rows_train = all_rows_train.difference(set(exp.x_train.index))
            drop_rows_test = all_rows_test.difference(set(exp.x_test.index))
            
            exp.y_train.drop(drop_rows_train, axis=0, inplace=True)
            exp.y_test.drop(drop_rows_test, axis=0, inplace=True)

        else:
            print 'col and row are the only possible values for margin'
    
    #Dropping full columns by name
    def drop_cols(self, exp, drop_list):
        # Drop the non-features columns
        for col_name in drop_list:
            try:
                exp.x_train.drop(col_name, axis=1, inplace=True)
            except ValueError:
                print "Column \"{}\" not found in x_train... passing...".format(col_name)
            try:
                exp.x_test.drop(col_name, axis=1, inplace=True)
            except ValueError:
                print "Column \"{}\" not found in x_test... passing...".format(col_name)
            
    
    #Feature scaling (for SVMs)
    #Keeps a record of scaled features in the training set
    #so the same transformation can be applied to a the test set
    def scale_feature_training(self, x_df, feature_name):
        #Subselect columns
        sub = x_df[feature_name].values

        #Create a scaler object and apply scaling
        scaler = preprocessing.StandardScaler().fit(sub)
        #Save scaler in the scalers dic using the column name as a key
        #TODO - Check that scaler is empty
        self.scalers[feature_name] = scaler
        #Apply scaling
        sub = scaler.transform(sub)
        return sub
    
    #Feature scaling

    #Scales features on the test set, based on transformations
    #done in the training set
    def scale_feature_testing(self, x_df, feature_name):
        #Subselect columns
        sub = x_df[feature_name].values
        #Get the scaler for the feature
        #TODO  - What happens if user hasnt scale that feature?
        scaler = self.scalers[feature_name]
        #Apply scaling
        sub = scaler.transform(sub)
        return sub


    #Scale multiple features at once
    def scale_features(self, x_df, features_name, scaler_fun):
        x_df.convert_objects(convert_numeric=True)

        for feature in features_name:
            if (type(x_df[feature].values[0]) != np.bool_
                and type(x_df[feature].values[0]) != str):
                #Subset columns
                sub = x_df[feature]
                #Apply scaling function
                scaled_feature = scaler_fun(x_df, feature)
                #Replace columns with scaled values
                x_df.loc[:, feature] = scaled_feature
        return x_df

    def scale_features_training(self, x_df, features_name):
        return self.scale_features(x_df, features_name, self.scale_feature_training)

    def scale_features_testing(self, x_df, features_name):
        return self.scale_features(x_df, features_name, self.scale_feature_testing)

    
    #Sampling methods
    def sub_sample(self, x_df, y_df, percent_abd, y_var="abandoned", use_cv_credito=True):
        """ Function to return a random subsample of training points with the given percent split
        Returns x_df and corresponding y_df with y_df[y_var].sum() / y_df.shape[0] = percent_abd """
        # Define the abandoned variable
        num_abd = y_df.sum()
        num_not_abd = int((float(1.0 - percent_abd) / float(percent_abd)) * num_abd)
        
        print "Subsampling {} abandoned homes, and {} non-abandoned w/ratio {}.".format(num_abd, num_not_abd, percent_abd)
        
        # Check if that many non-abandoned houses actually exist in data set and raise exception if not
        if (y_df.shape[0] - y_df.sum()) - num_not_abd < 0:
            print "Not enough non-abandoned houses to fulfill {} percent abandoned requirement.".format(percent_abd)
            num_not_abd = (y_df.shape[0] - y_df.sum())
            print "Using {} non-abandoned homes instead.".format(num_not_abd)
        
        # Get all abanadoned abandoned loans
        abd_x = x_df.loc[y_df == True] 
        abd_y = y_df.loc[y_df == True]
        
        # Get indexes of all non-abandoned loans
        non_abd_idxs = (y_df.loc[y_df == False]).index
        
       # Get unique list of cv_creditos for all non_abandoned houses
        if use_cv_credito:
            non_abd_cv_creditos = x_df.loc[non_abd_idxs]["cv_credito"].unique()
            # pick a random subset of these so we can select all rows related to them
            # assume each cv_credito in training set has ~5 rows, so first divide num_not_abd by 5
            num_not_abd = int(float(num_not_abd) / 5.0)
            non_abd_cv_creditos_subset = np.random.choice(non_abd_cv_creditos, num_not_abd, replace=False)
        else:
            # Get random subset of indexes equal to the partition size
            non_abd_idx_subset = np.random.choice(non_abd_idxs, num_not_abd, replace=False)

        # Select out those rows
        if use_cv_credito:
            non_abd_x = x_df.loc[x_df["cv_credito"].isin(non_abd_cv_creditos_subset)]
            non_abd_y = y_df.loc[x_df["cv_credito"].isin(non_abd_cv_creditos_subset)]
        else:
            non_abd_x = x_df.loc[non_abd_idx_subset]
            non_abd_y = y_df.loc[non_abd_idx_subset]

        # Concatenate the abandoned and non abandoned to get the final subsets
        x_df_sub = pd.concat([abd_x, non_abd_x])
        y_df_sub = pd.concat([abd_y, non_abd_y])
        
        return x_df_sub, y_df_sub


    def encode_as_dummy(self, exp, col_list, string=False):
        if type(col_list) != list:
            print "ERROR: (Encode Dummy) Please pass column names as a list. Nothing encoded. Returning."
            return
            
        for col_name in col_list:
            # Compute dummy variables with column name as prefix
            encoded_train_df = pd.get_dummies(exp.x_train[col_name], prefix=col_name)
            encoded_test_df = pd.get_dummies(exp.x_test[col_name], prefix=col_name)
            
            new_train_col_list = set(list(encoded_train_df))
            new_test_col_list = set(list(encoded_test_df))

            if len(new_train_col_list) > 100:
                print "WARNING: (Encode Dummy) Creating {} extra columns...".format(len(new_train_col_list))
            
            # Check that the training and testing columns match
            if new_train_col_list != new_test_col_list:
                # if not, get the difference for each set
                missing_train_cols = list(new_test_col_list - new_train_col_list)
                missing_test_cols = list(new_train_col_list - new_test_col_list)
                
                # And fill them with all zeros since we know they cant be
                # 1 if they didnt show up in original encoding
                for col in missing_train_cols:
                    encoded_train_df[col] = 0

                for col in missing_test_cols:
                    encoded_test_df[col] = 0

            # Append them to the right side of the data frame
            exp.x_train = exp.x_train.merge(encoded_train_df, copy=False, left_index=True, right_index=True)
            exp.x_test = exp.x_test.merge(encoded_test_df, copy=False, left_index=True, right_index=True)
            
            # # drop the original column used for dummy
            # exp.x_train.drop(col_name, axis=1, inplace=True)
            # exp.x_test.drop(col_name, axis=1, inplace=True)
            
            new_features = list(encoded_train_df)

            if not string:
                new_features_sorted = sorted(new_features, key=lambda x: int(x.split('_')[-1]))
            else:
                new_features_sorted = new_features

            # # Drop one of the dummy columns to avoid multi-colinearity
            exp.x_train.drop(new_features_sorted[0], axis=1, inplace=True)
            exp.x_test.drop(new_features_sorted[0], axis=1, inplace=True)


    def quantize_columns(self, exp, col_list, num_buckets):
        quantile_step = 1.0/float(num_buckets)
        quantile_list = [quantile_step * i for i in range(0,num_buckets+1)]

        for col_name in col_list:
            # Compute quantile labels & save breaks in preprocessor
            print "Computing quantiles for {}".format(col_name)
            try:
                quantile_labels, self.quantile_breaks[col_name] = pd.qcut(exp.x_train[col_name],
                                        self.quantile_breaks[col_name],
                                        labels=range(len(bins) - 1))

                print "Using the following as the quantile ranges: {}".format(self.quantile_breaks[col_name])

                # Add the quantile labels as a column
                print "Adding the new quantile column as: {}".format(col_name + "_quantile")
                exp.x_train[col_name + "_quantile"] = quantile_labels

                # Apply same quantiles to test.........
                print "Applying same quantile ranges to test set..."
                quantile_labels = pd.cut(exp.x_test[col_name], 
                                         self.quantile_breaks[col_name],
                                         labels=range(len(bins) - 1))
                exp.x_test[col_name + "_quantile"] = quantile_labels

            except Exception, e:
                print "QCut failed for some reason... trying manual bins"
                print e
                bins = []
                for quantile_pct in quantile_list:
                    bins.append(exp.x_train[col_name].quantile(quantile_pct))

                # Apply max of max
                bins.append(max(exp.x_train[col_name].max(), exp.x_test[col_name].max()))
                # Apply min of min
                bins.append(min(exp.x_train[col_name].min(), exp.x_test[col_name].min()))

                bins = sorted(list(set(bins)))

                if len(bins) <= 2:
                    print "Column {} has less or equal to 2 buckets. Not enough for quantiles. Skipping.".format(col_name)
                    continue 

                # increase size of bins to include end pts
                bins[0] = bins[0] -  1.0
                bins[-1] = bins[-1] + 1.0

                self.quantile_breaks[col_name] = bins
                print "Using the following as the quantile ranges: {}".format(self.quantile_breaks[col_name])

                quantile_labels = pd.cut(exp.x_train[col_name],
                                        self.quantile_breaks[col_name],
                                        labels=range(len(bins) - 1))

                if len(quantile_labels) > quantile_labels.count():
                    print "NA's found in quantile... Skipping column {}".format(col_name)
                    continue

                # Add the quantile labels as a column
                print "Adding the new quantile column as: {}".format(col_name + "_quantile")
                exp.x_train[col_name + "_quantile"] = quantile_labels

                # Apply same quantiles to test.........
                print "Applying same quantile ranges to test set..."
                quantile_labels = pd.cut(exp.x_test[col_name], 
                                         self.quantile_breaks[col_name],
                                         labels=range(len(bins) - 1))
                exp.x_test[col_name + "_quantile"] = quantile_labels

            # print "Dropping original column: {}".format(col_name)
            # exp.x_train.drop(col_name, axis=1, inplace=True)
            # exp.x_test.drop(col_name, axis=1, inplace=True)




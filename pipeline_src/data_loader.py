import psycopg2
import numpy as np
import pandas as pd
from contextlib import contextmanager
import random
from os.path import expanduser
import pandas.io.sql as psql
# import iopro.pyodbc as pyodbc
from sqlalchemy import create_engine
from time import sleep

# Turn off the chained assignment warning, we're not doing anything wrong... I checked...
pd.options.mode.chained_assignment = None  # default='warn'


# Create context manager to deal with postgres connection using psycopg2
@contextmanager
def connect_to_db():
    # Get home directory and password from ~/.pgpass file
    home = expanduser("~")
    pg_file = open(home + "/.pgpass", 'r')
    pgpass = pg_file.readlines()
    pg_password = pgpass[0].split(':')[4].replace('\n', '')

    try:
        conn = psycopg2.connect(database="infonavit",
                                user="infonavit",
                                password=pg_password,
                                host="dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com")
        yield conn
    except Exception, e:
        print e
        raise IOError("Error establishing DB Connection. Try again fool.")
    finally:
        conn.close()

## Attempt using commerical loading software to see if would load our data faster
# @contextmanager
# def connect_to_db_odbc():
#     # connection settings defined in /etc/odbc.ini
#     connect_string = "DSN=pginfonavit;"

#     try:
#         conn = pyodbc.connect(connect_string)
#         yield conn
#     except Exception, e:
#         print e
#         raise IOError("Error establishing DB Connection. Try again fool.")
#     finally:
#         conn.close()


# Connect to database using sql alchemy
@contextmanager
def connect_to_db_alchemy():
    # Get home directory and password from ~/.pgpass file
    home = expanduser("~")
    pg_file = open(home + "/.pgpass", 'r')
    pgpass = pg_file.readlines()
    pg_password = pgpass[0].split(':')[4].replace('\n', '')

    try:
        conn = create_engine(
            'postgresql://infonavit:' + pg_password + '@dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com/infonavit')
        yield conn
    except Exception, e:
        print e
        raise IOError("Error establishing DB Connection. Try again fool.")

# Load pre-saved sql queries from hdf5 file
def load_from_hdf(filename='/mnt/data/infonavit/master_loan_features41/master_loan_features_v41.h5', 
                  cur_year=2012, 
                  year_granted=2008, 
                  past=True, 
                  all_years=False,
                  y_var='abandoned_y',
                  additional_features = False):
    # Given an hdf5 file location and specified training / testing split, this function
    # Returns an x and y data set for model training or evaluation

    table_name = '{}_{}'.format(year_granted, cur_year)

    if past:
        table_name = 'past_' + table_name
    else:
        table_name = 'current_' + table_name

    if all_years:
        table_name = table_name + '_all'

    try:
        table = pd.read_hdf(filename, table_name)
    except KeyError:
        print "Table {} not found in hdf5 file {}".format(table_name, filename)
        print "Try different train/test split & past/all_years."
        return None, None

    # Rewrite index to fix dropna's?
    table.index = range(1,len(table.index)+1)


    if additional_features:
        master_dist=[]
        with connect_to_db() as conn:
            master_dist=pd.read_sql_query('select * from master_distance',conn)
        table = pd.merge(table,master_dist,how='inner',on='cv_credito',sort=False,copy=False)
        table.index = range(1,len(table.index)+1)




    y_table = table[y_var]
    table.drop(y_var, axis=1, inplace=True)

    return table, y_table


# Load pre-dumped queries from csv
def load_from_csv(filename, load_list, drop_list, y_var='abandoned_y', delim=';'):
    # If a list of columns to be dropped is specified, then get the 
    # list of current columns and select out the ones not in the drop list
    print "No load_list specified, loading all columns."
    with connect_to_db() as conn:
        print "Connected"
        all_cols = pd.read_sql("select column_name from information_schema.columns"
                               + " where table_name='master_loan_features_version4';", conn)
        all_cols = list(all_cols['column_name'])
        load_list = [col for col in all_cols if col not in drop_list]

    # Convert load_list to a string to pass to the sql query
    var_list_str = ""
    for idx, var in enumerate(all_cols):
        var_list_str += var
        if idx != len(all_cols) - 1:
            var_list_str += ", "

    df_iter =  pd.read_csv(filename, 
                            sep=delim,
                            using=load_data,
                            low_memory=True,
                            chunksize=50000)

    df_full = pd.concat(df for df in df_iter)
    x_load_list = list(all_cols)
    x_load_list.remove(y_var)

    return df_full[x_load_list], df_full[y_var]


# Given a number of abandoned and not abandoned, load random subsample of given size
def load_data_subsample(num_not_abd, 
                        load_list, drop_list, y_var, 
                        train_range, test_range,
                        train_current, test_current, 
                        fast, all_years):

    if train_range[0] >= test_range[1]:
        raise ValueError("Invalid train/test split. Please test on past, train on future.")
    if train_range[1] > test_range[0]:
        raise ValueError("Invalid train/test split. Train range cannot overlap with test range.")

    # If a list of columns to be dropped is specified, then get the 
    # list of current columns and select out the ones not in the drop list
    if len(load_list) == 0:
        print "No load_list specified, loading all columns."
        with connect_to_db() as conn:
            all_cols = pd.read_sql("select column_name from information_schema.columns"
                                   + " where table_name='master_loan_features_version4';", conn)
            all_cols = list(all_cols['column_name'])
            load_list = [col_name for col_name in all_cols if col_name not in drop_list]

    # Convert load_list to a string to pass to the sql query
    var_list_str = ""
    for idx, var in enumerate(load_list):
        var_list_str += var
        if idx != len(load_list) - 1:
            var_list_str += ", "

    df_list = []
    chunk_size = 50000
    offset = 0

    train_past_flag = "1"
    test_past_flag = "1"

    # Set the value for the "past" column correctly for loading train / test 
    # set as specified by train_current and test_current booleans
    if train_current:
        train_past_flag = "0"
    if test_current:
        test_past_flag = "0"

    #with connect_to_db_odbc() as conn:
    with connect_to_db_alchemy() as conn:

        print "Loading with SqlAlchemy streaming"
        train_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                          + "WHERE year_granted >= {} ".format(train_range[0])
                          + "AND past = {}  ".format(train_past_flag))

        # If all years of data are desired, then load all loans where current year is less than
        # upper bound on training range
        if all_years:
            train_query = train_query + "AND cur_year < {} ".format(train_range[1])
        # Else, just pick the last year of the training range
        else:
            train_query = train_query + "AND cur_year = {} ".format(train_range[1] - 1)

        train_abd_query = train_query + "AND abandoned_y = 1;"

        # divide by a million (close to average query size) to get random threshold
        random_thresh = float(num_not_abd) / float(2000000.0)

        train_non_abd_query = train_query + "AND random() < {} LIMIT {};".format(random_thresh, num_not_abd)


        print "train_abd_query: " + "SELECT load_list FROM " + train_abd_query.split("FROM")[1]

        print "Fetching abandoned..."

        # returns a proxy
        result = (conn
                  .execution_options(stream_results=True)
                  .execute(train_abd_query))

        print "Query returned, now converting iterator to df"
        train_abd = pd.DataFrame(iter(result))
        train_abd.columns = result.keys()
        result.close()
        del result
        
        print "train_non_abd_query: " + "SELECT load_list FROM " + train_non_abd_query.split("FROM")[1]

        print "Fetching non abandoned..."
        result = (conn
                  .execution_options(stream_results=True)
                  .execute(train_non_abd_query))
        
        print "Query returned, now converting iterator to df"
        train_non_abd = pd.DataFrame(iter(result))
        train_non_abd.columns = result.keys()
        result.close()
        del result
        print "Done. Concatenating train_abd and train_non_abd..."
        train_full = pd.concat([train_abd, train_non_abd], ignore_index=True, copy=False)
        del train_abd
        del train_non_abd
    print "Train loading complete."
    sleep(5)
    print "Attempting to reconnect to db"
    with connect_to_db_alchemy() as conn:
        print "Connected."
        # Create testing set queries
        test_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                      + "WHERE past = {} ".format(test_past_flag)
                      + "AND cur_year = {} ".format(test_range[1] - 1)
                      + "AND year_granted >= {} ".format(train_range[0]))

        
        test_thresh = num_not_abd / float(1400000.0)
        test_query = test_query + "AND random() < {} LIMIT {};".format(test_thresh, num_not_abd)


        print "test_query: " + "SELECT load_list FROM " + test_query.split("FROM")[1]

        result = (conn
                  .execution_options(stream_results=True)
                  .execute(test_query))
        print "Query returned, converting interator to df."
        test_full = pd.DataFrame(iter(result))
        test_full.columns = result.keys()
        result.close()
        del result
    print "Test loading complete."
    x_load_list = list(load_list)
    x_load_list.remove(y_var)
    
    return (train_full[x_load_list],
            train_full[y_var],
            test_full[x_load_list],
            test_full[y_var],
            load_list)


# Load data directly from SQL 
def load_data(load_list, drop_list, y_var, train_range, test_range,
              train_current, test_current, fast, all_years, head=False, 
              num_abd=None, num_not_abd=None):
    """ Load load_list columns, or load all columns and drop drop_list columns 
    if none are specified. If a drop_list is specified, load_list is ignored. 
    All data is loaded into correctly typed pandas dataframes and the full dataframes
    are returned. If fast is False, 
    """

    if train_range[0] >= test_range[1]:
        raise ValueError("Invalid train/test split. Please test on past, train on future.")
    if train_range[1] > test_range[0]:
        raise ValueError("Invalid train/test split. Train range cannot overlap with test range.")


    # If a list of columns to be dropped is specified, then get the 
    # list of current columns and select out the ones not in the drop list
    if len(load_list) == 0:
        print "No load_list specified, loading all columns."
        with connect_to_db() as conn:
            all_cols = pd.read_sql("select column_name from information_schema.columns"
                                   + " where table_name='master_loan_features_version4';", conn)
            all_cols = list(all_cols['column_name'])
            load_list = [col_name for col_name in all_cols if col_name not in drop_list]

    x_load_list = list(load_list)
    x_load_list.remove(y_var)

    # Convert load_list to a string to pass to the sql query
    var_list_str = ""
    for idx, var in enumerate(load_list):
        var_list_str += var
        if idx != len(load_list) - 1:
            var_list_str += ", "

    df_list = []
    chunk_size = 50000
    offset = 0

    train_past_flag = "1"
    test_past_flag = "1"

    # Set the value for the "past" column correctly for loading train / test 
    # set as specified by train_current and test_current booleans
    if train_current:
        train_past_flag = "0"
    if test_current:
        test_past_flag = "0"

        # Run query on DB
        # If fast loading boolean is true, then pandas chunksize is used to load data. This
        # is faster but less memory efficient
    if fast:
        print "Loading with SqlAlchemy streaming"
        train_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                       + "WHERE year_granted >= {} ".format(train_range[0])
                       + "AND past = {}  ".format(train_past_flag))

        # Create testing set queries
        test_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                      + "WHERE past = {} ".format(test_past_flag)
                      + "AND cur_year = {} ".format(test_range[1] - 1)
                      + "AND year_granted >= {} ".format(train_range[0]))

        # If all years of data are desired, then load all loans where current year is less than
        # upper bound on training range
        if all_years:
            train_query = train_query + "AND cur_year < {} ".format(train_range[1])
        # Else, just pick the last year of the training range
        else:
            train_query = train_query + "AND cur_year = {} ".format(train_range[1] - 1)

        if num_not_abd and num_abd:
            # divide by a million (close to average query size) to get random threshold
            not_abd_thresh = float(num_not_abd) / float(2000000.0)
            abd_thresh = float(num_abd) / float(25000.0)

            train_abd_query = train_query + "AND abandoned_y = 1 AND random() < {} LIMIT {};".format(abd_thresh, num_abd)
            train_non_abd_query = train_query + "AND random() < {} LIMIT {};".format(not_abd_thresh, num_not_abd)

            print "train_query: " + "SELECT load_list FROM " + train_query.split("FROM")[1]

            test_thresh = abd_thresh + not_abd_thresh
            test_size = num_abd + num_not_abd

            test_query = test_query + "AND random() < {} LIMIT {};".format(test_thresh, test_size)

            print "test_query: " + "SELECT load_list FROM " + test_query.split("FROM")[1]
            
            print "Connecting to postgresql..."
            with connect_to_db_alchemy() as conn:
                print "Connected"
                # returns a proxy
                result = (conn
                          .execution_options(stream_results=True)
                          .execute(train_abd_query))

                train_abd = pd.DataFrame(iter(result))
                train_abd.columns = result.keys()
                result.close()
                del result

                result = (conn
                          .execution_options(stream_results=True)
                          .execute(train_non_abd_query))

                train_non_abd = pd.DataFrame(iter(result))
                train_non_abd.columns = result.keys()
                result.close()
                del result

                train_full = pd.concat([train_abd, train_non_abd], ignore_index=True, copy=False)
                del train_abd
                del train_non_abd

                result = (conn
                          .execution_options(stream_results=True)
                          .execute(test_query))

                test_full = pd.DataFrame(iter(result))
                test_full.columns = result.keys()
                result.close()
                del result

        else:
            print "train_query: " + "SELECT load_list FROM " + train_query.split("FROM")[1]

            # Create testing set queries
            test_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                          + "WHERE past = {} ".format(test_past_flag)
                          + "AND cur_year = {} ".format(test_range[1] - 1)
                          + "AND year_granted >= {} ".format(train_range[0]))

            print "test_query: " + "SELECT load_list FROM " + test_query.split("FROM")[1]
            
            print "Connecting to postgresql..."
            with connect_to_db_alchemy() as conn:
                # returns a proxy
                result = (conn
                          .execution_options(stream_results=True)
                          .execute(train_query))

                train_full = pd.DataFrame(iter(result))
                train_full.columns = result.keys()
                result.close()
                del result

            #print result.keys()
            #cur = conn.cursor()
            #result = cur.execute(train_query)
            #train_full=pd.DataFrame(result.fetchsarray())

                result = (conn
                          .execution_options(stream_results=True)
                          .execute(test_query))

                test_full = pd.DataFrame(iter(result))
                test_full.columns = result.keys()
                result.close()
                del result

            #del result
            #result = cur.execute(test_query)
            #test_full=pd.DataFrame(result.fetchsarray())


    else:
        with connect_to_db() as conn:

            print "Loading data the slow way... Chunksize = {}".format(chunk_size)
            while True:
                train_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                               + "WHERE year_granted >= {} ".format(train_range[0])
                               + "AND past = {} ".format(train_past_flag))

                # If all years of data are desired, then load all loans where current year is less than
                # upper bound on training range
                if all_years:
                    train_query = train_query + "AND cur_year < {} ".format(train_range[1])
                # Else, just pick the last year of the training range
                else:
                    train_query = train_query + "AND cur_year = {} ".format(train_range[1] - 1)

                # Add limit of chunksize and offset to load sequentially
                train_query = train_query + "ORDER BY cv_credito, cur_year, past LIMIT {} OFFSET {};".format(chunk_size, offset)

                print "Loading training set rows {} to {}...".format(offset, offset + chunk_size)
                # print "x_train_query: " + x_train_query
                print "train_query: " + "SELECT load_list FROM " + train_query.split("FROM")[1]

                df_list.append(psql.read_sql_query(train_query, conn))

                offset += chunk_size

                # Keep loading chunks until the last chunk loaded is the last one (size is less than max chunk size)
                if len(df_list[-1]) < chunk_size:
                    print "Training set loaded."
                    # reset offset
                    offset = 0
                    break

                if head and offset > 0:
                    print "Training Loading stopped since head=True"
                    offset = 0
                    break

            train_full = pd.concat(df_list, ignore_index=True, copy=False)
            del df_list

            df_list = []

            while True:
                # Create testing set queries
                test_query = ("SELECT " + var_list_str + " FROM master_loan_features_version4 "
                              + "WHERE past = {} ".format(test_past_flag)
                              + "AND cur_year = {} ".format(test_range[1] - 1)
                              + "AND year_granted >= {} ".format(train_range[0])
                              + "ORDER BY cv_credito, cur_year, past LIMIT {} OFFSET {};".format(chunk_size, offset))

                print "Loading testing set rows {} to {}...".format(offset, offset + chunk_size)
                # print "x_test_query: " + x_test_query
                print "y_test_query: " + "SELECT load_list FROM " + test_query.split("FROM")[1]

                df_list.append(psql.read_sql_query(test_query, conn))

                offset += chunk_size

                # Keep loading chunks until the last chunk loaded is the last one (size is less than max chunk size)
                if len(df_list[-1]) < chunk_size:
                    print "Test set loaded."
                    break
                if head and offset > 0:
                    print "Test loading stopped since head=True."
                    break

            test_full = pd.concat(df_list, ignore_index=True, copy=False)
            del df_list

    return (train_full[x_load_list],
            train_full[y_var],
            test_full[x_load_list],
            test_full[y_var],
            load_list)

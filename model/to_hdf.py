import pandas as pd

hdf_file = '/mnt/data/infonavit/master_loan_features/master_loan_features_v4.h5'
store = pd.HDFStore(hdf_file)

 
csv_file = '/mnt/data/infonavit/master_loan_features/masterloans2011_all_current.csv'


csv_chunks_iter = pd.read_csv(csv_file,
                              sep=';',
                              iterator=True,
                              chunksize=50000)
    
df_count = 0

for df_chunk in csv_chunks_iter:
    df_chunk.to_hdf(hdf_file, 'current_2008_2011_all', append=True)
    df_count += 1
    print "Loaded chunk {} ==> row: {}".format(df_count, df_count * 50000)

print "chuncks all appended to hdf5"

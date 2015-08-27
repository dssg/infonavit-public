import pandas as pd
from preprocessing import Preprocessor

df = pd.read_csv("../feature-engineering/all_mun_features/mun_features.csv")
df = df.head(1000)
df = df[['mun_vehicles_rate', 'mun_motorcycles_rate']]

train, test = train_test_split(df, test_size = 0.2)

p = Preprocessor(df)
p.df
p.scale_features_training(['mun_vehicles_rate', 'mun_motorcycles_rate'])
p.df


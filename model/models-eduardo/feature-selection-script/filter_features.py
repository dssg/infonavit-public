import re

#Read create table file
lines = open('rf_all_mun.txt').read().splitlines()

#Filter by lines with characters
lines = filter(lambda x: len(x)>0, lines)

#Parse column name and type
def get_name_and_type(str):
    m = re.search("\({1}'{1}(.*)'{1},{1}\s{1}(.*)\){1}", str)
    return m.group(1), m.group(2)

tuples = [get_name_and_type(line) for line in lines]

#Get only the last x percent of features
idx = int(len(tuples)*0.5)
worst = tuples[idx:]

#Filter by mun features
worst_mun_features = filter(lambda (name,score): name[:3]=='mun', worst)
worst_mun_features_names = map(lambda (name,score): name, worst_mun_features)

print worst_mun_features_names


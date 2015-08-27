import re

#Read create table file
lines = open('create_master_v4.sql').read().splitlines()

#Filter by lines with characters
lines = filter(lambda x: len(x)>0, lines)

#Filter by lines containing columns
column_lines = filter(lambda x: x[-1]==",", lines)

#Parse column name and type
def get_name_and_type(str):
    m = re.search("\s*(.+)\s+(.+),", str)
    return m.group(1), m.group(2)

tuples = [get_name_and_type(line) for line in column_lines]


#The following columns are NOT being used for training
#cv_credito, cur_year, past, year_granted, abandon_year, abandon_month
#abandoned and abandoned_y
#Also, years since granted is going to be fixed for the prototype (with a
#value of 1)
columns_to_drop = ['abandoned_y', 'abandoned', 'cve', 'nom_mun', 
                   'mun_region', 'mun_geo_zone', 'cv_credito',
                   'cur_year', 'past', 'year_granted', 'abandon_year',
                   'abandon_month', 'loan_has_subsudy', 'loan_voluntary_contrib_bool',
                   'regimen']

tuples = filter(lambda x: x[0] not in columns_to_drop, tuples)

#Map column name prefixes to aggregations
name_mapping = {
'no'        : 'No',
'mun'       : 'No',
'colonia'   : 'No',
'loan'      : 'Yes',
'personal'  : 'Yes',
'escore'    : 'No',
'acquisitive' : 'Yes',
}

#Check acquisitive_vsm_4

#Extract an aggregation based on the name of the column
def extract_aggregation(col_name):
    words = col_name.split("_")
    inter = set(words).intersection(name_mapping.keys())
    inter = list(inter)
    return name_mapping[inter[0]] if len(inter) else 'Unkwown'
    
#Add aggregation to each tuple
tuples = [(name,type_,extract_aggregation(name)) for (name,type_) in tuples]


#Classify features depending on aggregation
agg = filter(lambda (n,t,a): a=='Yes', tuples)
no_agg = filter(lambda (n,t,a): a=='No', tuples)
unknown = filter(lambda (n,t,a): a=='Unkwown', tuples)

agg_names = map(lambda (n,t,a): n, agg)
no_agg_names = map(lambda (n,t,a): n, no_agg)
unkwown_names = map(lambda (n,t,a): n, unknown)

conc = lambda x,y:str(x)+', '+str(y)

#SQL for features that need aggregation
agg_names = map(lambda n: 'avg({}) as {}'.format(str(n),str(n)), agg_names)
agg_str = reduce(conc, agg_names)
no_agg_str = reduce(conc, no_agg_names)
unkwown_names

sql_template = open('agg_features_template.sql').read()
sql_str =  sql_template.format(agg_str, no_agg_str)
sql_file = open("agg_features.sql", "w")
sql_file.write(sql_str)
sql_file.close()
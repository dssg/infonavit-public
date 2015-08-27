iconv -f iso-8859-1 -t utf-8 mge2013v6_2.csv > states.csv
iconv -f iso-8859-1 -t utf-8 mgm2013v6_2.csv > municipalities.csv
R < preprocess.R --no-save
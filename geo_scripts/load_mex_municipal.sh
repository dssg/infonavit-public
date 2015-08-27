#!/bin/bash -x



shp2pgsql -d -I -s 4326 -W "latin1" /mnt/data/infonavit/shapefiles/municipal.shp municipal | psql -X -U infonavit -h dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com -d infonavit





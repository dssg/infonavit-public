CREATE TABLE homicides (
	cve VARCHAR(5) NOT NULL, 
	cve_ent VARCHAR(2) NOT NULL, 
	nom_ent VARCHAR(49) NOT NULL, 
	year INTEGER NOT NULL, 
	total_homicides INTEGER NOT NULL, 
	male_homicides INTEGER NOT NULL, 
	female_homicides INTEGER NOT NULL, 
	total_population INTEGER NOT NULL, 
	male_population INTEGER NOT NULL, 
	female_population INTEGER NOT NULL
);

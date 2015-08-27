CREATE TABLE population (
	cve VARCHAR(5) NOT NULL,
	cve_ent INTEGER NOT NULL, 
	nom_ent VARCHAR(31) NOT NULL, 
	cve_mun INTEGER NOT NULL, 
	nom_mun VARCHAR(49) NOT NULL, 
	type_level_1 VARCHAR(34) NOT NULL, 
	type_level_2 VARCHAR(24) NOT NULL, 
	type_level_3 VARCHAR(45) NOT NULL, 
	indicator_id BIGINT NOT NULL, 
	indicator VARCHAR(99) NOT NULL, 
	measurement FLOAT, 
	year INTEGER NOT NULL
);

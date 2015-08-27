CREATE TABLE crime (
	year INTEGER NOT NULL, 
	state VARCHAR(19) NOT NULL, 
	municipality VARCHAR(49) NOT NULL, 
	property_crimes INTEGER NOT NULL, 
	sexual_assault INTEGER NOT NULL, 
	homicide INTEGER NOT NULL, 
	injuries INTEGER NOT NULL, 
	other FLOAT NOT NULL, 
	kidnapping INTEGER NOT NULL, 
	robbery FLOAT NOT NULL, 
	cattle_raiding INTEGER NOT NULL, 
	highway_robbery INTEGER NOT NULL, 
	bank_robbery INTEGER NOT NULL, 
	code VARCHAR(5) NOT NULL
);

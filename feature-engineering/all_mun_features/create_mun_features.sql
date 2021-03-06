CREATE TABLE mun_features (
	cve VARCHAR(5) NOT NULL, 
	year INTEGER NOT NULL, 
	nom_mun VARCHAR(76) NOT NULL, 
	region VARCHAR(17) NOT NULL, 
	geo_zone VARCHAR(13) NOT NULL, 
	average_degree_of_schooling_of_the_population_15_years_and_over_estimation FLOAT, 
	households_estimation FLOAT, 
	percentage_of_population_15_to_29_years_estimation FLOAT, 
	percentage_of_population_60_or_more_years_estimation FLOAT, 
	total_population_estimation FLOAT, 
	total_population_men_estimation FLOAT, 
	total_population_women_estimation FLOAT, 
	homicide_rate FLOAT, 
	male_homicide_rate FLOAT, 
	female_homicide_rate FLOAT, 
	effectpeopledead INTEGER, 
	effectpeoplemissing INTEGER, 
	effectpeopleinjured FLOAT, 
	effectpeopleharmed FLOAT, 
	effectpeopleaffected FLOAT, 
	effectpeopleevacuated FLOAT, 
	effectpeoplerelocated INTEGER, 
	effecthousesdestroyed INTEGER, 
	effecthousesaffected INTEGER, 
	effectlossesvalueusd FLOAT, 
	motor_vehicles_rate FLOAT, 
	motorcycles_rate FLOAT, 
	passenger_buses_rate FLOAT, 
	trucks_and_vans_rate FLOAT, 
	vehicles_rate FLOAT, 
	births_rate FLOAT, 
	births_men_rate FLOAT, 
	births_sex_unspecified_rate FLOAT, 
	births_women_rate FLOAT, 
	deaths_of_infants_under_one_year_rate FLOAT, 
	deaths_of_infants_under_one_year_men_rate FLOAT, 
	deaths_of_infants_under_one_year_old_sex_not_specified_rate FLOAT, 
	deaths_of_infants_under_one_year_women_rate FLOAT, 
	divorces_rate FLOAT, 
	general_deaths_rate FLOAT, 
	general_deaths_men_rate FLOAT, 
	general_deaths_unspecified_sex_rate FLOAT, 
	general_deaths_women_rate FLOAT, 
	marriages_rate FLOAT, 
	gross_expenditure_per_capita FLOAT
);

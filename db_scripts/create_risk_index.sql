create table risk_index (
	id serial PRIMARY KEY,
	cv_credito varchar(10) not null, 
	nu_ano_ejercicio integer not null, 
	indece_de_riesgo integer
);

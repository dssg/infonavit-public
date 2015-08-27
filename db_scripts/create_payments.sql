create table payments (
	id serial PRIMARY KEY,
	cv_credito bigint not null, 
	nu_ano_ejercicio integer not null, 
	tx_situacion_vivienda varchar(32), 
	year integer,
	month integer,
	pe float, 
	pf float, 
	tp integer, 
	pro integer, 
	reest integer,
        mora integer,
	deuda float	
);


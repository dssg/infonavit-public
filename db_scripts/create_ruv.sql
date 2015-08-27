CREATE TABLE ruv (
	gid serial PRIMARY KEY,
	"cv_cuv" VARCHAR(16), 
	"in_clasificado" INTEGER NOT NULL, 
	"tx_nodo" VARCHAR(13) NOT NULL, 
	"tx_oferta" VARCHAR(50), 
	"fh_habitabilidad" DATE NOT NULL, 
	"in_zona_riesgo" INTEGER NOT NULL, 
	"cv_tipo_vivienda" VARCHAR(3) NOT NULL, 
	"fh_pago_registro" DATE NOT NULL, 
	"cv_codigo_postal" VARCHAR(5) NOT NULL, 
	"cv_municipio" VARCHAR(5) NOT NULL, 
	"tx_municipio" VARCHAR(36) NOT NULL
);

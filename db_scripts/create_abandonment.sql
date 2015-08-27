CREATE TABLE abandonment (
	gid serial PRIMARY KEY,
	"cv_credito" BIGINT NOT NULL,
	"nu_omisos" INTEGER NOT NULL,
	"cv_estatus_contable" VARCHAR(3) NOT NULL,
	"cv_regimen" VARCHAR(3) NOT NULL,
	"cv_pool_describe" VARCHAR(4) NOT NULL,
	"tx_situacion_vivienda" VARCHAR(11) NOT NULL,
	"fh_periodo" DATE NOT NULL
);
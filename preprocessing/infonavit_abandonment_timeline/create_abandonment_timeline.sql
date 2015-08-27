CREATE TABLE "abandonment_timeline" (
	"nu_omisos" INTEGER NOT NULL, 
	"im_saldo" FLOAT NOT NULL, 
	"fh_periodo" DATE NOT NULL, 
	"delegacion" VARCHAR(2) NOT NULL, 
	"cv_credito" VARCHAR(10) NOT NULL, 
	"rango_omisos" VARCHAR(4), 
	"cv_estatus_contable" VARCHAR(3) NOT NULL, 
	"cv_regimen" VARCHAR(3) NOT NULL, 
	"tx_situacion_vivienda" VARCHAR(11) NOT NULL
);

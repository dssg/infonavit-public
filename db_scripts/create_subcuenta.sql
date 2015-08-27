CREATE TABLE subcuenta (
	    gid serial PRIMARY KEY,
	    "cv_credito" BIGINT NOT NULL,
	    "im_saldo_subcuenta" FLOAT NOT NULL,
	    "tx_oferente" VARCHAR(71),
	    "cv_oferente" BIGINT NOT NULL,
	    "tx_tipo_credito" VARCHAR(17) NOT NULL
);

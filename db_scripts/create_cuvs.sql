CREATE TABLE cuvs (
    gid serial PRIMARY KEY,
    latitud FLOAT,
    longitud FLOAT,
    cuv FLOAT,
    "numerorecamaras" INTEGER,
    "areaterreno" FLOAT,
    "m2construccion" FLOAT,
    "tipologia" VARCHAR(24),
    "nombreestado" VARCHAR(19),
    "nombremunicipio" VARCHAR(30),
    colonia VARCHAR(50),
    "porcentajeravancevivienda" INTEGER,
    "fechadtu" TIMESTAMP WITHOUT TIME ZONE
);

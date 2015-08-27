CREATE TABLE ecuve (
	id_ecuve INTEGER NOT NULL, 
	cv_rgnicvv VARCHAR(17) NOT NULL, 
	cv_nss VARCHAR(11) NOT NULL, 
	id_vivienda INTEGER, 
	cv_avaluo VARCHAR(17), 
	cv_convivencia VARCHAR(10), 
	cv_credito VARCHAR(10) NOT NULL, 
	cve VARCHAR(5) NOT NULL, 
	cv_paquete VARCHAR(16), 
	cv_ofr VARCHAR(8), 
	cv_entfdr VARCHAR(5) NOT NULL, 
	fh_inf DATE NOT NULL, 
	id_tpovvn INTEGER NOT NULL, 
	id_clsvvn VARCHAR(16), 
	id_rng INTEGER NOT NULL, 
	id_tpocrd VARCHAR(17), 
	id_fchinf INTEGER NOT NULL, 
	id_aracns VARCHAR(5), 
	ct_pnthsp FLOAT NOT NULL, 
	ct_pntprq FLOAT NOT NULL, 
	ct_pntmrc FLOAT NOT NULL, 
	ct_pntesc FLOAT NOT NULL, 
	ct_pnteqp FLOAT NOT NULL, 
	ct_pntref FLOAT NOT NULL, 
	ct_pnttrn FLOAT NOT NULL, 
	ct_pntvld FLOAT NOT NULL, 
	ct_suphab FLOAT NOT NULL, 
	ct_gbs FLOAT NOT NULL, 
	ct_pnticv FLOAT NOT NULL, 
	ct_pntisa FLOAT NOT NULL, 
	ct_hogdig FLOAT NOT NULL, 
	ct_cldvvn FLOAT NOT NULL, 
	ct_pntaga FLOAT NOT NULL, 
	ct_pntenr FLOAT NOT NULL, 
	ct_pntcmd FLOAT NOT NULL, 
	ct_ecuve FLOAT NOT NULL, 
	ct_fchpo INTEGER NOT NULL
);

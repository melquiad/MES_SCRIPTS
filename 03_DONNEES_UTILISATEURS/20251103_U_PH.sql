

-- mise à jour campagnes 2023 et 2024
BEGIN;

CREATE TABLE public.coefs (
	codesp char(4),
	ph REAL,
	st REAL,
	cn REAL,
	CONSTRAINT coef_pkey PRIMARY KEY (codesp)
) WITHOUT OIDS;

\COPY public.coefs FROM '~/Documents/ECHANGES/MES_SCRIPTS/03_DONNEES_UTILISATEURS/coefsCodesp.csv' WITH DELIMITER ';' NULL AS 'NA'

CREATE TEMPORARY TABLE ph AS
 SELECT f.npp, ROUND(AVG(c.ph)::NUMERIC, 0) AS ph, COUNT(*) AS nb_esp
 FROM inv_exp_nm.g3flore f
 INNER JOIN coefs c ON f.codesp = c.codesp
 WHERE c.ph IS NOT NULL
 AND f.incref > 17
 GROUP BY f.npp
 ORDER BY f.npp;

UPDATE inv_exp_nm.u_g3foret f
 SET u_ph = p.ph::CHAR(1), u_nb_esp_ph = p.nb_esp
 FROM ph p
 WHERE f.npp = p.npp;

DROP TABLE public.coefs;
DROP TABLE ph;

UPDATE metaifn.afchamp
 SET calcout = 19, validout = 19
 WHERE donnee IN ('U_PH', 'U_NB_ESP_PH') and famille = 'INV_EXP_NM';

COMMIT;


-- controle

-- il y a des codesp sans ph et des codesp hors table coefs
SELECT codesp, e2p.incref
FROM inv_exp_nm.u_g3foret
INNER JOIN inv_exp_nm.g3flore USING (npp)
INNER JOIN inv_exp_nm.u_e2point e2p USING (npp)
WHERE U_PH IS NULL
GROUP BY (codesp, u_inv_facon, e2p.incref)
ORDER BY incref DESC;





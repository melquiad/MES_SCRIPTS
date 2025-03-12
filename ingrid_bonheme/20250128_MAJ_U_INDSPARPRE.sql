

-- Mise à jour 2023
BEGIN;

DROP TABLE IF EXISTS public.majr;

CREATE TABLE public.majr (espar CHAR(4), u_biogeo2002 CHAR(1), val CHAR(2), CONSTRAINT maj_pkey PRIMARY KEY (espar, u_biogeo2002)) WITHOUT OIDS;

\COPY public.majr FROM '~/Documents/ECHANGES/MES_SCRIPTS/ingrid_bonheme/U_IND_RB_FR_corresp_fichier22oct2019_CORR.csv' WITH CSV HEADER DELIMITER ';' NULL AS '';

WITH toto AS (
		 SELECT g3f.npp, m.val
		 FROM inv_exp_nm.g3foret g3f
		 INNER JOIN inv_exp_nm.u_e2point ue2 ON g3f.npp = ue2.npp
		 INNER JOIN majr m ON RTRIM(g3f.esparpre) = RTRIM(m.espar) AND ue2.u_biogeo2002 = m.u_biogeo2002
		 WHERE NOT ue2.u_inv_facon AND g3f.incref = 18
		 )
 UPDATE inv_exp_nm.u_g3foret ua
 SET U_INDSPARPRE = t.val
 FROM toto t
 WHERE ua.npp = t.npp;

-- Contrôle
SELECT INCREF, U_INDSPARPRE
FROM inv_exp_nm.u_g3foret ua
WHERE INCREF = 18;

-- MAJ métadonnées
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'U_INDSPARPRE';

DROP TABLE public.majr;

COMMIT;

SELECT esparpre, count(*)
from inv_exp_nm.u_g3foret
inner join inv_exp_nm.u_e2point using (npp, incref)
inner join inv_exp_nm.g3foret using (npp, incref)
where U_INDSPARPRE is NULL and not u_inv_facon
group by esparpre;

SELECT INCREF, COUNT(U_INDSPARPRE)
FROM inv_exp_nm.u_g3foret
GROUP BY INCREF ORDER BY INCREF;


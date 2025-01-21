

-- On crée une variable utilisateur d'entrée u_IR5_Ols dans la table u_g3arbre (variable qu'il faudra utiliser pour faire tourner le calcul de production)
ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_ir5_ols float;

-- On crée une variable utilisateur de sortie u_C13_5_Ols (variable qui servira au calcul de u_PV2_Ols)
ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_c13_5_ols float;

-- On crée une variable utilisateur u_V13_5_ols
ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_v13_5_ols float;

-- On crée une variable utilisateur de sortie u_PV2_Ols (variable qui stockera la production calculée à partir de u_IR5_Ols)
ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_pv2_ols float;

-- On crée une variable utilisateur de sortie u_PV_Ols (production avec effet technique)
ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_pv_ols float;

/*
-- réinitialisation de u_ir5_ols, u_pv2_ols et de u_c13_5_ols
UPDATE u_g3arbre u
SET u_c13_5_ols = NULL, u_ir5_ols = NULL, u_pv2_ols = NULL;
*/

-- Importation du fichier de Clémentine
CREATE TABLE public.corr_ir5_ess (
    essence TEXT,
    ess bpchar(2),
    delta_moy_prct float(4));

\COPY public.corr_ir5_ess FROM '/home/lhaugomat/Documents/MES_SCRIPTS/clementine_ols/CorrectionIR5_ESS_retrac.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

-- On met le coeff du noyer à 0
UPDATE public.corr_ir5_ess 
SET delta_moy_prct = 0
WHERE ess = '27';

-- Calcul de u_ir5_ols pour incref 4 à 8
UPDATE inv_exp_nm.u_g3arbre u
SET u_ir5_ols = g.ir5 * (1 + (c.delta_moy_prct / 100))
FROM  public.corr_ir5_ess c
INNER JOIN inv_exp_nm.g3arbre g ON c.ess = g.ess
--WHERE g.incref = 7 AND u.npp = g.npp AND u.a = g.a;
WHERE g.incref BETWEEN 4 AND 8 AND u.npp = g.npp AND u.a = g.a;

/*
SELECT u.npp, u.a, u.u_ir5_ols, c.ess, c.essence
FROM inv_exp_nm.u_g3arbre u
INNER JOIN inv_exp_nm.g3arbre g USING (npp,a)
INNER JOIN public.corr_ir5_ess c ON c.ess = g.ess
WHERE u.u_ir5_ols != 0 AND g.incref BETWEEN 4 AND 8;

SELECT g.ir5
FROM g3arbre g
WHERE g.incref = 8 AND g.ir5 = 0;
*/

-- calcul du u_c13_5_ols
UPDATE inv_exp_nm.u_g3arbre u
SET u_c13_5_ols = GREATEST(c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif), 0)
--SET u_c13_5_ols = GREATEST(c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif), 0.01)
--SET u_c13_5_ols = c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif)
FROM prod_exp.c4ctarif c
INNER JOIN inv_exp_nm.g3arbre g ON c.ess = g.ess
INNER JOIN prod_exp.c4tarifs t ON c.ntarif = t.ntarif AND t.typtarif = 'E1'
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif AND a.incref = 7 AND format = 'DTOTAL' AND domaine = 0
--WHERE c.nctarif = 1 AND u.npp = g.npp AND u.a = g.a AND g.incref = 7;
WHERE c.nctarif = 1 AND u.npp = g.npp AND u.a = g.a AND g.incref IN (4,5,6,7,8);

/*
SELECT GREATEST(c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif), 0.00001)
--SELECT c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif)
FROM prod_exp.c4ctarif c
INNER JOIN g3arbre g ON c.ess = g.ess
INNER JOIN u_g3arbre u USING (npp,a)
INNER JOIN prod_exp.c4tarifs t ON c.ntarif = t.ntarif AND t.typtarif = 'E1'
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif AND a.incref = 8 AND format = 'DTOTAL' AND domaine = 0
WHERE c.nctarif = 1 AND u.npp = g.npp AND u.a = g.a AND g.incref = 8;

SELECT u.npp, u.a, u.u_ir5_ols, u.u_c13_5_ols, c.ess, c.essence
FROM u_g3arbre u
INNER JOIN g3arbre g USING (npp,a)
INNER JOIN public.corr_ir5_ess c ON c.ess = g.ess
WHERE u.u_C13_5_ols < 0.00001 AND g.incref = 5;
*/

------------------------------------------------------------------------------------------------------------
-- CALCUL DE U_V13_5_Ols à partir de la chaine de calcul de la fonction calcVolArbreLnC13(8)
------------------------------------------------------------------------------------------------------------
-- création de la table temporaire des arbres --> nouvelle version CD
CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, g3a.incref
, g.gmode AS pro
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, CASE WHEN g3f.sfo_nm IS NULL OR g3f.sfo_nm = '0' THEN '3' ELSE g3f.sfo_nm END AS sfo
, g3a.ess, g3a.c13, uga.u_c13_5_ols AS c13_5 --> ON remplace g3a.c13_5 par uga.u_c13_5_ols
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.NPP = g3f.NPP
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.NPP = g3a.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.NPP = e1c.NPP
INNER JOIN inv_exp_nm.u_g3arbre uga ON g3a.NPP = uga.NPP AND g3a.a = uga.a 
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g."mode" = e2p.pro_nm
WHERE g3a.incref IN (4,5,6,7,8)
ORDER BY g3a.npp, g3a.a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
ANALYZE arbres;

-- récupération des tarifs à 1 entrée en log
CREATE TEMPORARY TABLE tarifs AS
SELECT DISTINCT TRIM(c.format) AS format, metaifn.mmfclasse(c.format) AS etendue, TRIM(c.ess) AS ess
, TRIM(ch.donnee) AS donnee, ch.position
, TRIM(d.unite) AS unite
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4ctarif c USING (ntarif)
LEFT JOIN metaifn.afchamp ch USING (format)
LEFT JOIN metaifn.addonnee d USING (donnee)
WHERE t.typtarif = 'C2'
ORDER BY TRIM(c.ess);

-- récupération des unités des paramètres du tarif
CREATE TEMPORARY TABLE unites AS
SELECT unite, mode, position
FROM metaifn.abmode
WHERE unite IN ('ALT2', 'PF', 'SF')
ORDER BY unite, position;

-- regroupement des tarifs et arbres, calcul du domaine de chaque arbre
CREATE TEMPORARY TABLE regroup AS
SELECT a.npp, a.a, a.incref, a.alt2, a.pro, a.sfo, a.ess, a.c13, a.c13_5 --> en fait remplacé par u_c13_5_ols dans la TABLE arbres
, t0.format AS format, t0.etendue AS etendue
, CASE t0.etendue 	WHEN 0 THEN 0 
					WHEN 1 THEN metaifn.mmfdomaine1(t0.format, u0.position)
					WHEN 2 THEN metaifn.mmfdomaine2(t0.format, u0.position, u1.position)
  END AS domaine
FROM arbres a
INNER JOIN tarifs t0 ON a.ess = t0.ess AND COALESCE(t0.position, 0) = 0
LEFT JOIN unites u0 ON COALESCE(t0.unite, 'RIEN') = u0.unite AND CASE COALESCE(t0.donnee, 'RIEN') WHEN 'ALT2' THEN a.alt2 WHEN 'PRO' THEN a.pro WHEN 'SFO' THEN a.sfo ELSE 'RIEN' END = u0.mode   
LEFT JOIN tarifs t1 ON a.ess = t1.ess AND t1.position = 1
LEFT JOIN unites u1 ON COALESCE(t1.unite, 'RIEN') = u1.unite AND CASE COALESCE(t1.donnee, 'RIEN') WHEN 'ALT2' THEN a.alt2 WHEN 'PRO' THEN a.pro WHEN 'SFO' THEN a.sfo ELSE 'RIEN' END = u1.mode   
ORDER BY a.npp, a.a;

ALTER TABLE regroup ADD CONSTRAINT pkregroup PRIMARY KEY (npp, a);
ANALYZE regroup;

-- récupération des coefficients de tarifs à 1 entrée
CREATE TEMP TABLE coefs AS
SELECT c1.ess, c1.format, c1.domaine, t.ntarif
, COALESCE(c1.coeftarif, 0::FLOAT) AS coef1, COALESCE(c2.coeftarif, 0::FLOAT) AS coef2
, COALESCE(c3.coeftarif, 0::FLOAT) AS coef3, COALESCE(c4.coeftarif, 0::FLOAT) AS coef4
, COALESCE(c5.coeftarif, 0::FLOAT) AS coef5, COALESCE(c6.coeftarif, 0::FLOAT) AS coef6
FROM prod_exp.c4tarifs t
LEFT JOIN prod_exp.c4ctarif c1 ON t.ntarif = c1.ntarif AND c1.nctarif = 1
LEFT JOIN prod_exp.c4ctarif c2 ON t.ntarif = c2.ntarif AND c2.nctarif = 2
LEFT JOIN prod_exp.c4ctarif c3 ON t.ntarif = c3.ntarif AND c3.nctarif = 3
LEFT JOIN prod_exp.c4ctarif c4 ON t.ntarif = c4.ntarif AND c4.nctarif = 4
LEFT JOIN prod_exp.c4ctarif c5 ON t.ntarif = c5.ntarif AND c5.nctarif = 5
LEFT JOIN prod_exp.c4ctarif c6 ON t.ntarif = c6.ntarif AND c6.nctarif = 6
LEFT JOIN prod_exp.c4ctarif c7 ON t.ntarif = c7.ntarif AND c7.nctarif = 7
WHERE t.typtarif = 'C2'
ORDER BY c1.ess, c1.format, c1.domaine, t.ntarif;

-- calcul des volumes
CREATE TEMPORARY TABLE vols AS
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pro, g.sfo, EXP((c.coef1 + c.coef2 * LN(g.c13)+ c.coef3 * (LN(g.c13))^2+ c.coef4 * (LN(g.c13))^3+ c.coef5 * (LN(g.c13))^4) + c.coef6 ^ 2 / 2) AS v13
, CASE WHEN g.c13_5 < 0.01 THEN 0 ELSE EXP((c.coef1 + c.coef2 * LN(g.c13_5)+ c.coef3 * (LN(g.c13_5))^2+ c.coef4 * (LN(g.c13_5))^3+ c.coef5 * (LN(g.c13_5))^4) + c.coef6 ^ 2 / 2) END AS v13_5
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine;

UPDATE vols
SET v13_5 = v13
WHERE v13_5 > v13;

-- calcul des volumes par tarif à 1 entrée en log de C13 par la mise à jour de U_V13_5_Ols à partir de la table vols dans la table U_G3ARBRE
UPDATE inv_exp_nm.u_g3arbre u
SET u_v13_5_ols = v.v13_5
FROM vols v
WHERE u.npp = v.npp AND u.a = v.a;

/*
SELECT u.npp, u.a, u.u_ir5_ols, u_c13_5_ols, u_v13_5_ols, c.ess, c.essence
FROM inv_exp_nm.u_g3arbre u
INNER JOIN inv_exp_nm.g3arbre g USING (npp,a)
INNER JOIN public.corr_ir5_ess c ON c.ess = g.ess
WHERE g.incref BETWEEN 4 AND 8 AND u.u_ir5_ols != 0 AND u_v13_5_ols IS NOT NULL;
*/

DROP TABLE arbres;
DROP TABLE tarifs;
DROP TABLE unites;
DROP TABLE regroup;
DROP TABLE coefs;
DROP TABLE vols;
---------------------------------------------------------------------------------------------------------------------------------------------

-- calcul de la nouvelle production u_pv2_ols
UPDATE inv_exp_nm.u_g3arbre u
SET u_pv2_ols = 0.2 *
CASE	WHEN u.u_c13_5_ols < 0.235 THEN a.v
		ELSE a.v * (1 - u.u_v13_5 / u.u_v13)
END
, u_abv2 = 0.2 * a.v * (1 - u.u_v13_5_ols / u.u_v13)
FROM inv_exp_nm.g3arbre a
WHERE u.npp = a.npp AND u.a = a.a
AND a.incref BETWEEN 4 AND 8;

------------------------------------------------------------------------------------------------------------------------------------------------------
-- CALCUL DE LA PRODUCTION AVEC EFFET TECHNIQUE
--------------------------------------------------------------------------------------------------------------------------------------------------
-- effet technique incref 8
CREATE TABLE public.seuils (
	ess CHAR(2), 
	essence VARCHAR(60), 
	cld CHAR(2), 
	cld_cm INT, 
	seuil DECIMAL(2, 1)
)
WITHOUT oids;

\COPY seuils FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref8/donnees/seuilsEffTech3.csv' WITH CSV DELIMITER ';' NULL AS ''


CREATE TABLE public.tau_k (
	ess CHAR(2),
	pro_nm CHAR(1),
	cld CHAR(2),
	tau FLOAT8,
	incref SMALLINT
)
WITHOUT oids;

\COPY public.tau_k FROM '/home/lhaugomat/Documents/MES_SCRIPTS/clementine_ols/effet_technique_recalcule_2023.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

ALTER TABLE public.tau_k
ADD COLUMN seuil FLOAT4;

UPDATE public.tau_k t
SET seuil = s.seuil
FROM public.seuils s
WHERE t.ess = s.ess;

-- insertion des données de tau_k (Incref8) dans prod_exp.tau_pv
ALTER TABLE prod_exp.tau_pv DROP CONSTRAINT tau_pv_pkey;

INSERT INTO prod_exp.tau_pv (ess, pro_nm, cld, tau, incref, seuil)
SELECT ess, pro_nm, cld, tau, incref, seuil FROM public.tau_k;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- effet technique incref 7
CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a, g3a.ess, g3a.c13, g3a.c13_5, g3a.htot, u2.u_zprel, g3f5.prelev5, u2.u_info5, e2p.pro_nm, g3f.sfo_nm, e1p.zp, coalesce(g3a5.veget3, 'rien') as veget3, coalesce(g3a5.veget5, 'rien') as veget5, g3a.v, g3a.wak, u3.u_vpr AS vprel, u3.u_vpr_an AS prel, e2p.poids, g3a.w
, CASE WHEN g3a.cld::INT < 21 THEN g3a.cld ELSE '21' END AS cld
, g3a.v - u3.u_vpr AS vres
, CASE WHEN u3.u_vpr > 0 THEN 0 ELSE g3a.w END AS wres
FROM  inv_exp_nm.g3arbre g3a 
INNER JOIN inv_exp_nm.u_g3arbre u3 USING (npp, a)
INNER JOIN prod_exp.g3arbre g3a5 USING (npp, a)
INNER JOIN inv_exp_nm.g3foret g3f USING (npp)
INNER JOIN prod_exp.g3foret g3f5 USING (npp)
INNER JOIN inv_exp_nm.e2point e2p USING (npp)
INNER JOIN inv_exp_nm.u_e2point u2 USING (npp)
INNER JOIN inv_exp_nm.e1point e1p USING (npp)
WHERE g3a.incref = 2
ORDER BY g3a.npp, g3a.a;

CREATE TABLE public.tau_k AS
SELECT ess, pro_nm, cld
, CASE WHEN SUM(wres) = 0 OR SUM(v) = 0 THEN 1 ELSE (SUM(vres * wres * poids) / SUM(wres * poids)) / (SUM(v * w * poids) / SUM(w * poids)) END AS tau
FROM arbres
GROUP BY ess, pro_nm, cld
ORDER BY ess, pro_nm, cld;

CREATE TABLE public.seuils (
	ess CHAR(2), 
	essence VARCHAR(60), 
	cld CHAR(2), 
	cld_cm INT, 
	seuil DECIMAL(2, 1)
)
WITHOUT oids;

\COPY seuils FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref7/donnees/seuilsEffTech2.csv' WITH DELIMITER ';' NULL AS ''

ALTER TABLE public.tau_k
ADD COLUMN seuil FLOAT4;

UPDATE public.tau_k t
SET tau = 
CASE
	WHEN t.cld > s.cld THEN 1
	ELSE t.tau
END, seuil = s.seuil
FROM public.seuils s
WHERE t.ess = s.ess;

SELECT t.ess, g.gmode AS pro_nm, t.cld, t.tau, 7 AS incref, t.seuil
FROM public.tau_k t
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = t.pro_nm;

-- insertion des données de tau_k (Incref7) dans prod_exp.tau_pv
ALTER TABLE prod_exp.tau_pv DROP CONSTRAINT tau_pv_pkey;

INSERT INTO prod_exp.tau_pv (ess, pro_nm, cld, tau, incref, seuil)
SELECT t.ess, g.gmode AS pro_nm, t.cld, t.tau, 7 AS incref, t.seuil
FROM public.tau_k t
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = t.pro_nm;

DROP TABLE seuils;
DROP TABLE arbres;
DROP TABLE tau_k;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- effet technique incref 6 dans laquelle on rajoute des jointures vers u_g3arbre et u_e2point
CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a, g3a.ess, g3a.c13, g3a.c13_5, g3a.htot
, ue2p.u_zprel
, g3f5.prelev5
, ue2p.u_info5
, e2p.pro_nm, g3f.sfo_nm, e1p.zp, coalesce(g3a5.veget3, 'rien') as veget3, coalesce(g3a5.veget5, 'rien') as veget5, g3a.v
--, g3a.vak
, ug3a.u_vpr AS vprel
, ug3a.u_vpr_an AS prel
, e2p.poids, g3a.w
, CASE WHEN g3a.cld::INT < 21 THEN g3a.cld ELSE '21' END AS cld13
, g3a.v - ug3a.u_vpr AS vres
, CASE WHEN ug3a.u_vpr > 0 THEN 0 ELSE g3a.w END AS wres
FROM inv_exp_nm.g3arbre g3a
INNER JOIN prod_exp.g3arbre g3a5 using(npp, a)
INNER JOIN inv_exp_nm.u_g3arbre ug3a USING (npp, a)
INNER JOIN inv_exp_nm.g3foret g3f using(npp)
INNER JOIN prod_exp.g3foret g3f5 using(npp)
INNER JOIN inv_exp_nm.e2point e2p using(npp)
INNER JOIN inv_exp_nm.u_e2point ue2p using(npp)
INNER JOIN inv_exp_nm.e1point e1p using(npp)
WHERE g3a.incref = 1
ORDER BY g3a.npp, g3a.a;

CREATE TABLE public.tau_k AS
SELECT ess, pro_nm, cld13
, CASE WHEN SUM(wres) = 0 OR SUM(v) = 0 THEN 1 ELSE (SUM(vres * wres * poids) / SUM(wres * poids)) / (SUM(v * w * poids) / SUM(w * poids)) END AS tau
FROM arbres
GROUP BY ess, pro_nm, cld13
ORDER BY ess, pro_nm, cld13;

CREATE TABLE public.seuils (
	ess CHAR(2), 
	essence VARCHAR(60), 
	cld CHAR(2), 
	cld_cm INT, 
	seuil DECIMAL(2, 1)
)
WITHOUT oids;

\COPY seuils FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref6/donnees/seuilsEffTech1.csv' WITH DELIMITER ';' NULL AS ''

ALTER TABLE public.tau_k
ADD COLUMN seuil FLOAT4;

UPDATE public.tau_k t
SET tau = 
CASE
	WHEN t.cld13 > s.cld THEN 1
	ELSE t.tau
END, seuil = s.seuil
FROM public.seuils s
WHERE t.ess = s.ess;

SELECT t.ess, g.gmode AS pro_nm, t.cld13, t.tau, 6 AS incref, t.seuil
FROM public.tau_k t
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = t.pro_nm;

-- insertion des données de tau_k (Incref7) dans prod_exp.tau_pv
ALTER TABLE prod_exp.tau_pv DROP CONSTRAINT tau_pv_pkey;

INSERT INTO prod_exp.tau_pv (ess, pro_nm, cld, tau, incref, seuil)
SELECT t.ess, g.gmode AS pro_nm, t.cld13, t.tau, 6 AS incref, t.seuil
FROM public.tau_k t
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = t.pro_nm;


----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------ actualisation de la production avec effet technique -----------------------------------------------

CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.ess, a.cld, 
CASE WHEN p.pro_nm = 'C' THEN '1' ELSE p.pro_nm END AS pro_nm, 
a.v, u.u_pv2_ols, COALESCE(t.tau, 1)::FLOAT AS tau
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre u USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
LEFT JOIN prod_exp.tau_pv t ON a.ess = t.ess AND CASE WHEN p.pro_nm = 'C' THEN '1' ELSE p.pro_nm END = t.pro_nm 
	AND t.cld = CASE WHEN FLOOR(20 * a.c13_5 / PI() + 0.5 ) > 20 THEN '20'
					 ELSE TO_CHAR(FLOOR(20 * a.c13_5 / PI() + 0.5 ), 'FM09')
				END
WHERE a.incref BETWEEN 4 AND 8;

ALTER TABLE arbres ADD CONSTRAINT pkarbres PRIMARY KEY (npp, a);

/*
UPDATE inv_exp_nm.u_g3arbre u
SET u_et_an = 0.2 * 
CASE	WHEN a3.c13_5 < 0.235 THEN 0
		ELSE (1 - a.tau) * (a3.v * u.u_v13_5 / u.u_v13)
END
, u_abv_an = GREATEST(0.2 * a3.v * (1 - a.tau * u.u_v13_5 / u.u_v13), 0)
FROM arbres a
INNER JOIN inv_exp_nm.g3arbre a3 ON a.npp = a3.npp AND a.a = a3.a
WHERE u.npp = a.npp AND u.a = a.a
AND a3.incref = 8;
*/

UPDATE inv_exp_nm.u_g3arbre a3
SET u_pv_ols = GREATEST(0.2 * 
CASE	WHEN a3.u_c13_5_ols < 0.235 THEN u.v
		ELSE u.v * (1 - a.tau * a3.u_v13_5_ols / a3.u_v13)
END
, 0)
FROM arbres a
INNER JOIN inv_exp_nm.g3arbre u ON a.npp = u.npp AND a.a = u.a
WHERE a3.npp = a.npp AND a3.a = a.a
AND a3.incref BETWEEN 4 AND 8;


-- contrôle et export pour Clémetine
SELECT u.npp, u.a, g.incref, u.u_ir5_ols, u.u_c13_5_ols, u.u_v13_5_ols, u.u_pv2_ols, u.u_pv_ols, u.u_pv2, g.ir5, g.c13_5, g.v, g.pv
FROM inv_exp_nm.u_g3arbre u
INNER JOIN inv_exp_nm.g3arbre g USING (npp,a)
WHERE  g.incref BETWEEN 4 AND 8
ORDER BY g.incref, u.npp, u.a;


/*
-- calcul de la production en volume total aérien
UPDATE inv_exp_nm.u_g3arbre u
SET u_pv0 = 0.2 *
CASE	WHEN a3.c13_5 < 0.235 THEN u.u_v0
		ELSE u.u_v0 * (1 - u.u_v13_5 / u.u_v13)
END
FROM inv_exp_nm.g3arbre a3
WHERE u.npp = a3.npp AND u.a = a3.a
AND a3.incref = 8;
*/

DROP TABLE arbres;
 





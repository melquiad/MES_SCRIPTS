
SELECT g.fs, g.pds
FROM inv_exp_nm.g3arbre g
WHERE incref = 18
AND pds != 1
ORDER BY fs, pds DESC;


-- 14_calculs_arbres ----------------------------------------------------------

-- import des poids pour incref 19
\COPY pdsa FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-exploitation/inv_exp_nm/Incref19/donnees/poids_2024_1.csv' WITH CSV HEADER DELIMITER ',' NULL AS 'NA';
-------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE public.poidsa AS
SELECT npp, a, pds, w, wac
FROM pdsa;

ALTER TABLE public.poidsa ADD CONSTRAINT poidsa_pkey PRIMARY KEY (npp, a);

ANALYZE public.poidsa;
    
DROP TABLE pdsa;

UPDATE inv_exp_nm.g3arbre
SET fs = 1, w = p.w, wac = COALESCE(p.wac, p.w), pds = p.pds
FROM public.poidsa p
WHERE g3arbre.npp = p.npp AND g3arbre.a = p.a
AND g3arbre.incref= 19;

UPDATE inv_exp_nm.p3arbre
SET fs = 1, w = p.w, wac = COALESCE(p.wac, p.w), pds = p.pds
FROM public.poidsa p
WHERE p3arbre.npp = p.npp AND p3arbre.a = p.a
AND p3arbre.incref= 19;

UPDATE inv_exp_nm.g3morts
SET fs = 1, w = p.w, wac = COALESCE(p.wac, p.w), pds = p.pds
FROM public.poidsa p
WHERE g3morts.npp = p.npp AND g3morts.a = p.a
AND g3morts.incref= 19;

UPDATE inv_exp_nm.p3morts
SET fs = 1, w = p.w, wac = COALESCE(p.wac, p.w), pds = p.pds
FROM public.poidsa p
WHERE p3morts.npp = p.npp AND p3morts.a = p.a
AND p3morts.incref= 19;

DROP TABLE public.poidsa;

-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
-- CALCUL DU VOLUME DES ARBRES AVEC HAUTEUR (3 ENTRÉES)
DROP TABLE IF EXISTS arbres;

CREATE TEMPORARY TABLE arbres AS 
SELECT a.npp, a.a, a.incref, a.c13, a.gtot, a.htot, a.hdec, a.ess, a.espar, a.ori, a.decoupe, a.simplif, ua.u_vest, ua.u_v13, a.r, a.w, a.pds
, NULL::FLOAT AS hdec_c
, NULL::FLOAT AS vest_c
, NULL::FLOAT AS v13_c
, NULL::FLOAT8 AS v_c
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
WHERE a.incref= 19
UNION 
SELECT a.npp, a.a, a.incref, a.c13, a.gtot, a.htot, a.hdec, a.ess, a.espar, a.ori, a.decoupe, a.simplif, ua.u_vest, ua.u_v13, a.r, a.w, a.pds
, NULL::FLOAT AS hdec_c
, NULL::FLOAT AS vest_c
, NULL::FLOAT AS v13_c
, NULL::FLOAT8 AS v_c
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
WHERE a.incref= 19
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pk_arbres PRIMARY KEY (npp, a);

ANALYZE arbres;
-------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS arbs;
-- calcul de V13 par tarif de cubage à 1 entrée
CREATE TEMPORARY TABLE arbs AS
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13--, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g, g3a.w, g3a.pds, g3a.gtot
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN prod_exp.e2point pe2p ON e2p.npp = pe2p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN arbres g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.npp = e1c.npp
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = pe2p.pro_nm
UNION 
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13--, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g, g3a.w, g3a.pds, g3a.gtot
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN prod_exp.e2point pe2p ON e2p.npp = pe2p.npp
INNER JOIN inv_exp_nm.p3point g3f ON e2p.NPP = g3f.NPP
INNER JOIN arbres g3a ON g3f.NPP = g3a.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.NPP = e1c.NPP
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = pe2p.pro_nm
ORDER BY npp, a;

ALTER TABLE arbs ADD CONSTRAINT pk_arbs PRIMARY KEY (npp, a);
CREATE INDEX arbs_ess_idx ON arbs USING btree (ess);
CREATE INDEX arbs_incref_idx ON arbs USING btree (incref);
ANALYZE arbs;

/*
Récupération des coefficients du tarif à 1 entrée
*/
CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2024 -- tarifs valides pour la campagne 2024
    GROUP BY id_type_tarif, id_tarif
)
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.alt2, x.pf_maaf, x.greco, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (alt2 TEXT, pf_maaf TEXT, greco TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.formule_tarif ~* 'ln\(C13\)'
AND et.periode @> 2024 -- tarifs valides pour la campagne 2024
ORDER BY ess, id_tarif;

-- arbres sans tarif correspondant : normalement, il ne devrait pas y en avoir
SELECT a.npp, a.a, a.ess, c.fact, a.greco
FROM arbs a
INNER JOIN coefs_ess c ON a.ess = c.ess
EXCEPT 
SELECT a.npp, a.a, a.ess, c.fact, a.greco
FROM arbs a
INNER JOIN coefs_ess c ON a.ess = c.ess
INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
WHERE 
    CASE
        WHEN c.fact IS NULL THEN TRUE
        WHEN c.fact = 'greco' THEN a.greco = c.greco
        WHEN c.fact = 'alt2,pf_maaf' THEN a.alt2 = c.alt2 AND a.pf_maaf = c.pf_maaf
        WHEN c.fact = 'greco,pf_maaf' THEN a.greco = c.greco AND a.pf_maaf = c.pf_maaf
        WHEN c.fact = 'alt2,greco,pf_maaf' THEN a.alt2 = c.alt2 AND a.greco = c.greco AND a.pf_maaf = c.pf_maaf
    END; 


UPDATE arbs ab
SET vest = t.v13
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13)
                + COALESCE(coef3, 0) * (LN(c13))^2
                + COALESCE(coef4, 0) * (LN(c13))^3
                + COALESCE(coef5, 0) * (LN(c13))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13)
                + COALESCE(coef3, 0) * (LN(c13))^2
                + COALESCE(coef4, 0) * (LN(c13))^3
                + COALESCE(coef5, 0) * (LN(c13))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v13
    FROM arbs a
    INNER JOIN coefs_ess c ON a.ess = c.ess
    INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
    WHERE 
        CASE
            WHEN c.fact IS NULL THEN TRUE
            WHEN c.fact = 'greco' THEN a.greco = c.greco
            WHEN c.fact = 'alt2,pf_maaf' THEN a.alt2 = c.alt2 AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'greco,pf_maaf' THEN a.greco = c.greco AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'alt2,greco,pf_maaf' THEN a.alt2 = c.alt2 AND a.greco = c.greco AND a.pf_maaf = c.pf_maaf
        END
) t
WHERE ab.npp = t.npp AND ab.a = t.a;

UPDATE arbres a
SET v13_c = a1.vest
FROM arbs a1
WHERE a.npp = a1.npp
AND a.a = a1.a;

/*
SELECT count(*) FROM arbres WHERE v13_c IS NULL; -- doit valoir 0 sinon problème
SELECT * from arbs;
SELECT  * FROM coefs_ess;
-- diagnostic : quelles essences dans quelles GRECO n'ont pas de tarif à 1 entrée ?
SELECT * FROM arbres WHERE v13_c IS NULL;
SELECT DISTINCT ess, greco FROM arbres WHERE v13_c IS NULL; --> pas de colonne 'greco' dans la table arbres !
*/

DROP TABLE coefs_ess;
DROP TABLE arbs;
 
UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13 = a.v13_c
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v13 = a.v13_c
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a;

/*
SELECT count(*), count(u_v13)
FROM inv_exp_nm.u_g3arbre
WHERE incref= 19;

SELECT count(*), count(u_v13)
FROM inv_exp_nm.u_p3arbre
WHERE incref= 19;
*/

DROP TABLE arbres;
DROP TABLE coefs_ess;
DROP TABLE arbs;
---------------------------------------------------------------------
---------------------------------------------------------------------
-- 16_production
-- calcul des volumes par tarif à 1 entrée en log de C13

DROP TABLE IF EXISTS arbres;

CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN prod_exp.e2point pe2p ON e2p.npp = pe2p.npp -- rajout pour la propriété
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.NPP = g3f.NPP
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.NPP = g3a.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.NPP = e1c.NPP
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = pe2p.pro_nm  -- modif de e2p en pe2p
WHERE g3a.incref = 19
ORDER BY g3a.npp, g3a.a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
CREATE INDEX arbres_incref_idx ON arbres USING btree (incref);
ANALYZE arbres;

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2024             -- CAMPAGNE
    GROUP BY id_type_tarif, id_tarif
)
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.alt2, x.pf_maaf, x.greco, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (alt2 TEXT, pf_maaf TEXT, greco TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.formule_tarif ~* 'ln\(C13\)'
AND et.periode @> 2024             -- CAMPAGNE
ORDER BY ess, id_tarif;

UPDATE arbres ab
SET vest_5 = t.v13_5
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN c13_5 < 10^(-2) THEN 0
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v13_5
    FROM arbres a
    INNER JOIN coefs_ess c ON a.ess = c.ess
    INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
    WHERE 
        CASE
            WHEN c.fact IS NULL THEN TRUE
            WHEN c.fact = 'greco' THEN a.greco = c.greco
            WHEN c.fact = 'alt2,pf_maaf' THEN a.alt2 = c.alt2 AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'greco,pf_maaf' THEN a.greco = c.greco AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'alt2,greco,pf_maaf' THEN a.alt2 = c.alt2 AND a.greco = c.greco AND a.pf_maaf = c.pf_maaf
        END
) t
WHERE ab.npp = t.npp AND ab.a = t.a;

UPDATE arbres
SET vest_5 = 0
WHERE vest_5 < 10^(-6);

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13_5 = a.vest_5
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a;

SELECT count(*)
FROM arbs
WHERE valmin;

/*SELECT p2.incref, SUM(p2.poids * ua.u_vest * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;*/
DROP TABLE coefs_ess;
DROP TABLE arbres;
----****************************************************----

SET enable_nestloop = FALSE;

-- arbres vifs
SELECT p2.incref, SUM(p2.poids * ua.u_v13 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p2.incref, SUM(p2.poids * ua.u_v13 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_p3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

-- U_VEST
SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;v

-- V0
SELECT p2.incref, SUM(p2.poids * a.v0 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p2.incref, SUM(p2.poids * a.v0 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3arbre a ON p2.npp = a.npp
GROUP BY p2.incref
ORDER BY p2.incref DESC;

-- V
SELECT p2.incref, SUM(p2.poids * a.v * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p2.incref, SUM(p2.poids * a.v * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3arbre a ON p2.npp = a.npp
GROUP BY p2.incref
ORDER BY p2.incref DESC;


-- arbres morts
SELECT p2.incref, SUM(p2.poids * a.v * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3morts ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p2.incref, SUM(p2.poids * a.v * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_p3morts ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

------------------------------------------------------------------------
------------------------------------------------------------------------
-- On réinitialise V0
UPDATE inv_exp_nm.g3arbre a
SET v0 = NULL
WHERE a.incref = 19;

UPDATE inv_exp_nm.p3arbre p
SET v0 = NULL
WHERE p.incref = 19;

-- calcul de V0   /!\ --> U_V0 passe en V0 pour la campagne 2024
	--> pensez à créer les colonnes en base pour g3arbre et p3arbre (cf chgt structure) et à créer les métadonnées associées.
CREATE TABLE public.coefs (
	ess CHAR(2),
	essence VARCHAR(100),
	ntarif CHAR(3),
	a FLOAT,
	b FLOAT,
	g FLOAT,
	d FLOAT,
	CONSTRAINT coefs_pkey PRIMARY KEY (ess)
)
WITH (
  OIDS=FALSE
);

\COPY public.coefs FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-exploitation/inv_exp_nm/Incref19/donnees/coefs_tarifVallet.csv' WITH DELIMITER ';' NULL AS '' --> même fichier tous les ans

UPDATE inv_exp_nm.g3arbre a
SET v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM public.coefs c
INNER JOIN inv_exp_nm.g3arbre a1 ON c.ess = a1.ess
WHERE a.incref= 19
AND a1.htot IS NOT NULL
AND a.npp = a1.npp AND a.a = a1.a;

UPDATE inv_exp_nm.p3arbre a
SET v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM public.coefs c
INNER JOIN inv_exp_nm.p3arbre a1 ON c.ess = a1.ess
WHERE a.incref= 19
AND a1.ess <> '19'
AND a1.htot IS NOT NULL
AND a.npp = a1.npp AND a.a = a1.a;

UPDATE inv_exp_nm.p3arbre a
SET v0 = (a.v + a.vr) * 1.25
FROM public.coefs c
INNER JOIN inv_exp_nm.p3arbre a1 ON c.ess = a1.ess
WHERE a.incref= 19
AND a1.ess = '19'
AND a1.htot IS NOT NULL
AND a.npp = a1.npp AND a.a = a1.a;

-- imputation de V0
DROP TABLE arbres;

CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, a.v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref= 19
UNION ALL
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, a.v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref= 19
ORDER BY npp, a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, v0, v0 / v13 AS coef, v13, 'A'::BPCHAR AS ref
FROM arbres a
WHERE simplif = '0'
ORDER BY npp, a;

ALTER TABLE refs
ADD CONSTRAINT refs_pkey PRIMARY KEY (npp, a);

ANALYZE refs;

CREATE TEMPORARY TABLE corresp AS
SELECT *
FROM (
	WITH t0 AS (
		SELECT a.npp, a.a, a.espar, a.dimess, r.c13
      , r.coef, r.v0, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, v0, v13, ref
	FROM t0
	WHERE rang = 1
) AS t
ORDER BY npp, a;

ALTER TABLE corresp
ADD CONSTRAINT corresp_pkey PRIMARY KEY (npp, a);

ANALYZE corresp;

UPDATE corresp c
SET ref = r.ref
FROM refs r
WHERE c.npp = r.npp
AND c.a = r.a;

UPDATE arbres a
SET v0imp = c.v0 * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

UPDATE inv_exp_nm.g3arbre ga
SET v0 = a.v0imp
FROM arbres a
WHERE ga.npp = a.npp AND ga.a = a.a
AND ga.v0 IS NULL;

UPDATE inv_exp_nm.p3arbre pa
SET v0 = a.v0imp
FROM arbres a
WHERE pa.npp = a.npp AND pa.a = a.a
AND pa.v0 IS NULL;

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;
DROP TABLE coefs;



















BEGIN;

-- CALCUL DE D13, CLD, CLCIR À PARTIR DU C13 DES ARBRES VIFS
UPDATE inv_exp_nm.g3arbre
SET d13 = ROUND(c13::NUMERIC, 3) / PI()
, clcir = 	
	CASE WHEN FLOOR(20 * ROUND(c13::NUMERIC, 3) + 0.5) > 34 THEN '34'
         ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 3) + 0.5), 'FM09')
	END
, cld = 
	CASE WHEN FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ) > 49 THEN '49'
         ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ), 'FM09')
	END
WHERE incref = 17;

UPDATE inv_exp_nm.p3arbre
SET d13 = ROUND(c13::NUMERIC, 3) / PI()
, clcir = 	
	CASE WHEN FLOOR(20 * ROUND(c13::NUMERIC, 3) + 0.5) > 34 THEN '34'
         ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 3) + 0.5), 'FM09')
    END
, cld = 
    CASE WHEN FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ) > 49 THEN '49'
         ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ), 'FM09')
    END
WHERE incref = 17;
--------------------------------------------------------------------------------------

-- CALCUL DE CLD ET VEGETM DANS LES TABLES D'ARBRES MORTS
UPDATE inv_exp_nm.g3morts
SET cld = 
CASE WHEN FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ) > 49 THEN '49'
     ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ), 'FM09')
END
, vegetm = CASE WHEN veget = '1' THEN 'A' ELSE '5' END
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET cld = 
CASE    WHEN FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ) > 49 THEN '49'
        ELSE TO_CHAR(FLOOR(20 * ROUND(c13::NUMERIC, 2) / PI() + 0.5 ), 'FM09')
END
, vegetm = CASE WHEN veget = '1' THEN 'A' ELSE '5' END
WHERE incref = 17;
---------------------------------------------------------------------------------------

-- NOUVELLES CLASSES DE CIRCONFÉRENCE ET DIAMÈTRE + ORIG
UPDATE inv_exp_nm.g3arbre
SET clac = LEAST(ROUND((ROUND(c13::NUMERIC, 3) * 100)::NUMERIC), 410)
, clad = LEAST((ROUND(ROUND(c13::NUMERIC, 2) / PI() * 100)::NUMERIC), 130)
, orig = CASE WHEN ori = '1' THEN '1' ELSE '0' END
WHERE incref = 17;

UPDATE inv_exp_nm.p3arbre
SET clac = LEAST(ROUND((ROUND(c13::NUMERIC, 3) * 100)::NUMERIC), 410)
, clad = LEAST((ROUND(ROUND(c13::NUMERIC, 2) / PI() * 100)::NUMERIC), 130)
, orig = CASE WHEN ori = '1' THEN '1' ELSE '0' END
WHERE c13 IS NOT NULL
AND incref = 17;

UPDATE inv_exp_nm.g3morts
SET clac = LEAST(ROUND((ROUND(c13::NUMERIC, 3) * 100)::NUMERIC), 410)
, clad = LEAST((ROUND(ROUND(c13::NUMERIC, 2) / PI() * 100)::NUMERIC), 130)
, orig = CASE WHEN ori = '1' THEN '1' ELSE '0' END
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET clac = LEAST(ROUND((ROUND(c13::NUMERIC, 3) * 100)::NUMERIC), 410)
, clad = LEAST((ROUND(ROUND(c13::NUMERIC, 2) / PI() * 100)::NUMERIC), 130)
, orig = CASE WHEN ori = '1' THEN '1' ELSE '0' END
WHERE incref = 17;

SET enable_nestloop = FALSE;
-------------------------------------------------------------------------------------

-- REGROUPEMENT DES CLASSES DE DIMENSIONS
-- CLDIM1, CLDIM2, CLDIM3
UPDATE inv_exp_nm.g3arbre
SET cldim1 = d1.gmode, cldim2 = d2.gmode, cldim3 = d3.gmode
FROM metaifn.abgroupe d1, metaifn.abgroupe d2, metaifn.abgroupe d3
WHERE d1.gunite = 'DIMD1' AND d1.unite = 'CLAD' AND d1.mode = clad
AND d2.gunite = 'DIMD2' AND d2.unite = 'CLAD' AND d2.mode = clad
AND d3.gunite = 'DIMD3' AND d3.unite = 'CLAD' AND d3.mode = clad
AND incref = 17;

UPDATE inv_exp_nm.p3arbre
SET cldim1 = d1.gmode, cldim2 = d2.gmode, cldim3 = d3.gmode
FROM metaifn.abgroupe d1, metaifn.abgroupe d2, metaifn.abgroupe d3
WHERE d1.gunite = 'DIMD1' AND d1.unite = 'CLAD' AND d1.mode = clad
AND d2.gunite = 'DIMD2' AND d2.unite = 'CLAD' AND d2.mode = clad
AND d3.gunite = 'DIMD3' AND d3.unite = 'CLAD' AND d3.mode = clad
AND incref = 17;

SET enable_nestloop = TRUE;
--------------------------------------------------------------------------------------

-- REGROUPEMENT DES ESPAR EN ESS
-- vifs en forêt
UPDATE inv_exp_nm.g3arbre
SET ess = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'ESS' AND g.unite = 'ESPAR1' AND RTRIM(g.mode) = RTRIM(espar)
AND incref = 17;

-- vifs en peupleraies
UPDATE inv_exp_nm.p3arbre
SET ess = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'ESS' AND g.unite = 'ESPAR1' AND RTRIM(g.mode) = RTRIM(espar)
AND incref = 17;

-- vifs en LHF
UPDATE inv_exp_nm.l3arbre
SET ess = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'ESS' AND g.unite = 'ESPAR1' AND RTRIM(g.mode) = RTRIM(espar)
AND incref = 17;

-- morts en forêt
UPDATE inv_exp_nm.g3morts
SET ess = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'ESS' AND g.unite = 'ESPAR1' AND RTRIM(g.mode) = RTRIM(espar)
AND incref = 17;

-- morts en peupleraies
UPDATE inv_exp_nm.p3morts
SET ess = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'ESS' AND g.unite = 'ESPAR1' AND RTRIM(g.mode) = RTRIM(espar)
AND incref = 17;
---------------------------------------------------------------------------------

-- REGROUPEMENT DES ESSENCES
UPDATE inv_exp_nm.g3arbre
SET essg16 = g1.gmode
, fr = 
    CASE    WHEN ess < '50' THEN 'F' 
            WHEN ess > '50' THEN 'R' 
    END
FROM metaifn.abgroupe g1
WHERE g1.unite = 'ESS' AND g1.gunite = 'ESSD16' AND g1.mode = ess
AND incref = 17;

UPDATE inv_exp_nm.p3arbre
SET essg16 = g1.gmode
, fr = 
	CASE 	WHEN ess < '50' THEN 'F' 
			WHEN ess > '50' THEN 'R' 
	END
FROM metaifn.abgroupe g1
WHERE g1.unite = 'ESS' AND g1.gunite = 'ESSD16' AND g1.mode = ess
AND incref = 17;

UPDATE inv_exp_nm.g3morts
SET fr = 
CASE WHEN ess < '50' THEN 'F' 
	 WHEN ess > '50' THEN 'R' 
END
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET fr = 
CASE WHEN ess < '50' THEN 'F' 
	 WHEN ess > '50' THEN 'R' 
END
WHERE incref = 17;
-------------------------------------------------------------------------------------------

-- CALCUL DE LA SURFACE TERRIERE ET DE L'ECORCE
CREATE TEMP TABLE arbres AS
SELECT npp, a, incref
, c13, ess
, NULL::FLOAT AS ec
FROM inv_exp_nm.g3arbre 
WHERE incref = 17
UNION 
SELECT npp, a, incref
, c13, ess
, NULL::FLOAT AS ec
FROM inv_exp_nm.p3arbre 
WHERE incref = 17
ORDER BY npp, a;

CREATE TEMPORARY TABLE coefs_ess AS 
SELECT et.id_type_tarif, et.id_tarif, et.ess, c.coef1, c.coef2
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (decoupe TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL)
WHERE tt.lib_type_tarif ILIKE '%cercle%'
AND et.periode @> 2022; -- contrôle que la campagne 2021 est dans la période de validité du tarif pour l'essence

UPDATE arbres
SET ec = c.coef1 * c13 + c.coef2
FROM coefs_ess c
WHERE arbres.ess = c.ess;

UPDATE inv_exp_nm.g3arbre
SET ec = a.ec
FROM arbres a
WHERE g3arbre.npp = a.npp AND g3arbre.a = a.a;

UPDATE inv_exp_nm.g3arbre
SET gtot = c13 * c13 / (4 * PI())
WHERE incref = 17;

UPDATE inv_exp_nm.p3arbre
SET ec = a.ec
FROM arbres a
WHERE p3arbre.npp = a.npp AND p3arbre.a = a.a;

DROP TABLE coefs_ess;
DROP TABLE arbres;

UPDATE inv_exp_nm.p3arbre
SET gtot = c13 * c13 / (4 * PI())
WHERE incref = 17;

UPDATE inv_exp_nm.g3morts
SET gtot = c13 * c13 / (4 * PI())
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET gtot = c13 * c13 / (4 * PI())
WHERE incref = 17;

-- intégration des poids des arbres (calculs faits sous R)
CREATE UNLOGGED TABLE public.pdsa
(
    npp CHARACTER(16) NOT NULL,
    a SMALLINT NOT NULL,
    fs FLOAT8,
    w FLOAT8,
    wac FLOAT8,
    CONSTRAINT pdsa_pkey PRIMARY KEY (npp, a)
)
WITH (
  OIDS=FALSE
);

----- à exécuter dans psql ------------------------------------------------------------------------------------------------------------------------------
\COPY pdsa FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref17/donnees/Poids_Arbres_Incref17.csv' WITH CSV HEADER DELIMITER '	' NULL AS 'NA'
-------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TEMPORARY TABLE poidsa AS
SELECT npp, a, FS, w, wac
FROM public.pdsa;

ALTER TABLE poidsa ADD CONSTRAINT poidsa_pkey PRIMARY KEY (npp, a);

ANALYZE poidsa;
    
DROP TABLE public.pdsa;

UPDATE inv_exp_nm.g3arbre
SET fs = p.fs, w = p.w, wac = COALESCE(p.wac, p.w)
FROM poidsa p
WHERE g3arbre.npp = p.npp AND g3arbre.a = p.a
AND g3arbre.incref = 17;

UPDATE inv_exp_nm.p3arbre
SET fs = p.fs, w = p.w, wac = COALESCE(p.wac, p.w)
FROM poidsa p
WHERE p3arbre.npp = p.npp AND p3arbre.a = p.a
AND p3arbre.incref = 17;

UPDATE inv_exp_nm.g3morts
SET fs = p.fs, w = p.w, wac = COALESCE(p.wac, p.w)
FROM poidsa p
WHERE g3morts.npp = p.npp AND g3morts.a = p.a
AND g3morts.incref = 17;

UPDATE inv_exp_nm.p3morts
SET fs = p.fs, w = p.w, wac = COALESCE(p.wac, p.w)
FROM poidsa p
WHERE p3morts.npp = p.npp AND p3morts.a = p.a
AND p3morts.incref = 17;

DROP TABLE poidsa;



/* Quelques contrôles
SELECT COUNT(*), count(w), count(wac)
FROM inv_exp_nm.g3arbre
WHERE incref = 17;

SELECT COUNT(*), count(w), count(wac)
FROM inv_exp_nm.p3arbre
WHERE incref = 17;

SELECT COUNT(*), count(w), count(wac)
FROM inv_exp_nm.g3morts
WHERE incref = 17;

SELECT COUNT(*), count(w), count(wac)
FROM inv_exp_nm.p3morts
WHERE incref = 17;

SELECT a.incref, sum(a.w * p.poids), sum(a.wac * p.poids)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids), sum(a.wac * p.poids)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids), sum(a.wac * p.poids)
FROM inv_exp_nm.g3morts a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids), sum(a.wac * p.poids)
FROM inv_exp_nm.p3morts a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/

---------------------------------------------------------------------------------------------------------------------------------------------

-- ATTENTION ! AVANT D'EXÉCUTER LES CALCULS SUIVANTS, LA PROPRIÉTÉ DOIT ÊTRE CHARGÉE ET CALCULÉE !!!


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
WHERE a.incref = 17
UNION 
SELECT a.npp, a.a, a.incref, a.c13, a.gtot, a.htot, a.hdec, a.ess, a.espar, a.ori, a.decoupe, a.simplif, ua.u_vest, ua.u_v13, a.r, a.w, a.pds
, NULL::FLOAT AS hdec_c
, NULL::FLOAT AS vest_c
, NULL::FLOAT AS v13_c
, NULL::FLOAT8 AS v_c
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
WHERE a.incref = 17
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pk_arbres PRIMARY KEY (npp, a);

ANALYZE arbres;

-- calcul de HDEC par tarif
DROP TABLE IF EXISTS arbs;

CREATE TEMPORARY TABLE arbs AS 
SELECT incref, npp, a, htot, c13, ori, ess
FROM arbres
WHERE htot IS NOT NULL
AND decoupe = '0'
ORDER BY npp, a; 

ALTER TABLE arbs ADD CONSTRAINT pk_arbs PRIMARY KEY (npp, a);

ALTER TABLE arbs
    ADD COLUMN hdec_c FLOAT4; 

CREATE TEMPORARY TABLE coefs_hdec AS 
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.ori, c.alpha, c.beta, c.gamma, c.delta
FROM prod_exp.ess_tarif et
INNER JOIN prod_exp.tarifs t USING (id_type_tarif, id_tarif)
INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (ori TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(alpha REAL, beta REAL, gamma REAL, delta REAL)
WHERE tt.formule_tarif ~~* 'hdec%'
AND et.periode @> 2021; -- tarif valide en 2021

UPDATE arbs a
SET hdec_c = htot * (1 - exp(ch.alpha + ch.beta * ln(1 - 13 / (htot * 10.0)) + ch.gamma * ln((c13 * 1000.0) / (pi() * 70)) + ch.delta * (ln((c13 * 1000.0) / (pi() * 70)))^2))
FROM coefs_hdec ch
WHERE a.ess = ch.ess AND (ch.ori IS NULL OR a.ori = ch.ori);

UPDATE arbres a
SET hdec_c = GREATEST(a1.hdec_c, 1.3)
FROM arbs a1
WHERE a.npp = a1.npp AND a.a = a1.a
AND a1.hdec_c IS NOT NULL;

/*
SELECT *
FROM arbres
WHERE hdec_c IS NULL AND decoupe = '0' AND simplif = '0';
*/

DROP TABLE coefs_hdec;
DROP TABLE arbs;


-- calcul de VEST par tarif de cubage à 3 entrées en forêt et peupleraie
DROP TABLE IF EXISTS coefs_ess;
DROP TABLE IF EXISTS arbs;

CREATE TEMPORARY TABLE arbs AS
SELECT a.npp, a.a, a.incref
, a.c13, a.htot, COALESCE(a.hdec_c, a.hdec) AS hdec
, REPLACE(a.decoupe, '2', '0') AS decoupe
, a.ess
, CASE
    WHEN ess = '68' THEN a.c13
    ELSE LEAST(a.c13, 3)
  END AS c13max
, COALESCE(md.position, 0) AS dposition
, NULL::FLOAT AS fnew
, NULL::FLOAT AS f
, NULL::FLOAT AS vest
, NULL::SMALLINT AS ntarif
, FALSE AS valmin
FROM arbres a
LEFT JOIN metaifn.abmode md ON md.unite = 'DECOUPE' AND md.mode = a.decoupe
WHERE a.htot IS NOT NULL
ORDER BY a.npp, a.a;

ALTER TABLE arbs ADD CONSTRAINT arbs_pkey PRIMARY KEY (npp, a);
CREATE INDEX arbs_ess_idx ON arbs USING btree (ess);
CREATE INDEX arbs_incref_idx ON arbs USING btree (incref);
ANALYZE arbs;

CREATE TEMPORARY TABLE coefs_ess AS 
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.decoupe, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7, c.coef8, c.coef9
, et.facteurs
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (decoupe TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL, coef8 REAL, coef9 REAL)
WHERE tt.formule_tarif ILIKE 'fnew%'
AND et.periode @> 2021; -- contrôle que la campagne 2021 est dans la période de validité du tarif pour l'essence

ALTER TABLE coefs_ess ADD CONSTRAINT coefs_ess_pkey PRIMARY KEY (ess, id_type_tarif, id_tarif);

UPDATE arbs a
SET fnew = t.fnew
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN (coef1 
                + coef2 * c13max 
                + coef3 * sqrt(c13max) / htot 
                + coef5 *  hdec / (hdec + coef6) 
                + coef8 * 1 / power(c13max, coef9)
            ) * (1 - power((pi() * 0.07 / c13max), 3) * power((1 - 1.3 / htot), 3)) 
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN coef1 
                + coef2 * c13max 
                + coef3 * sqrt(c13max) / htot 
                + coef5 *  power(hdec / (hdec + coef6), 1 + COALESCE(coef7, 0)) 
                + coef8 * 1 / power(c13max, coef9)
        WHEN tt.lib_type_tarif ~~* '%v3'
            THEN coef1 
                + coef2 * c13max 
                + coef4 * hdec 
                + coef8 * 1 / power(c13max, coef9)
        WHEN tt.lib_type_tarif ~~* '%v4'
            THEN coef1 
                + COALESCE(coef2, 0) * c13max 
                + coef3 * sqrt(c13max) / htot 
                + coef4 * ln(hdec / htot) 
                + COALESCE(coef8, 0) * 1 / power(c13max, COALESCE(coef9, 0))
        WHEN tt.lib_type_tarif ~~* '%v5'
            THEN coef1 
                + coef2 * c13max 
                + COALESCE(coef3, 0) * sqrt(c13max) / htot 
                + coef4 * ln(hdec) 
                + COALESCE(coef8, 0) * 1 / power(c13max, COALESCE(coef9, 0))
      END AS fnew
    FROM arbs a
    INNER JOIN coefs_ess c ON a.ess = c.ess AND (c.decoupe IS NULL OR a.decoupe = c.decoupe)
    INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
) t
WHERE a.npp = t.npp AND a.a = t.a;

CREATE TEMPORARY TABLE bornes AS 
SELECT *
FROM (
VALUES ('01', 0.15, 0.40, 0.8), ('02', 0.15, 0.44, 0.8), ('03', 0.15, 0.43, 0.8), ('04', 0.13, 0.41, 0.6), ('05', 0.16, 0.44, 1.0), ('06', 0.16, 0.43, 1.0), 
('07', 0.17, 0.42, 0.8), ('08', 0.17, 0.37, 1.0), ('09', 0.13, 0.43, 0.9), ('10', 0.10, 0.40, 0.9), ('11', 0.10, 0.46, 1.0), ('12', 0.12, 0.38, 0.8), 
('13', 0.11, 0.39, 0.8), ('14', 0.14, 0.40, 0.8), ('15', 0.15, 0.39, 0.8), ('16', 0.15, 0.40, 0.5), ('17', 0.14, 0.41, 0.9), ('18', 0.10, 0.40, 0.9), 
('19', 0.10, 0.37, 0.6), ('20', 0.12, 0.48, 0.9), ('21', 0.11, 0.42, 0.9), ('22', 0.16, 0.41, 0.8), ('23', 0.11, 0.41, 0.9), ('24', 0.12, 0.43, 0.8), 
('25', 0.10, 0.50, 0.9), ('26', 0.23, 0.39, 0.5), ('27', 0.19, 0.38, 0.7), ('28', 0.13, 0.33, 0.8), ('29', 0.11, 0.44, 0.8), ('30', 0.15, 0.40, 0.8), 
('31', 0.10, 0.40, 0.9), ('32', 0.10, 0.38, 0.7), ('33', 0.13, 0.36, 0.6), ('34', 0.21, 0.38, 0.5), ('35', 0.15, 0.40, 0.8), ('36', 0.15, 0.40, 0.5), 
('37', 0.15, 0.40, 0.5), ('38', 0.16, 0.35, 0.9), ('39', 0.14, 0.33, 0.5), ('40', 0.17, 0.38, 0.9), ('41', 0.10, 0.41, 0.8), ('42', 0.15, 0.40, 0.8), 
('49', 0.12, 0.38, 0.9), ('51', 0.17, 0.40, 0.9), ('52', 0.17, 0.42, 1.0), ('53', 0.20, 0.44, 0.9), ('54', 0.18, 0.47, 1.0), ('55', 0.25, 0.40, 1.0), 
('56', 0.20, 0.42, 0.7), ('57', 0.22, 0.37, 0.8), ('58', 0.23, 0.42, 1.0), ('59', 0.16, 0.38, 0.7), ('60', 0.15, 0.40, 0.7), ('61', 0.17, 0.48, 0.9), 
('62', 0.20, 0.43, 0.9), ('63', 0.14, 0.45, 0.9), ('64', 0.20, 0.40, 0.7), ('65', 0.19, 0.41, 0.8), ('66', 0.15, 0.40, 0.5), ('67', 0.21, 0.35, 0.9), 
('68', 0.20, 0.41, 0.8), ('69', 0.18, 0.39, 0.8), ('70', 0.15, 0.40, 0.8), ('71', 0.15, 0.40, 0.7), ('72', 0.17, 0.41, 0.8), ('73', 0.17, 0.41, 0.7), 
('74', 0.10, 0.44, 0.6), ('75', 0.15, 0.40, 0.9), ('76', 0.15, 0.40, 0.8), ('77', 0.23, 0.37, 0.8) 
) AS t(ess, fnew_min, fnew_max, fmax);

UPDATE arbs a
SET f = LEAST(LEAST(GREATEST(a.fnew, b.fnew_min), b.fnew_max) / POWER((1 - 1.3 / a.htot), 2), b.fmax)
, valmin = (b.fnew_min > a.fnew)
FROM bornes b
WHERE a.ess = b.ess;

UPDATE arbs
SET vest = f * c13 * c13 * htot / (4 * PI());

/*
SELECT count(*)
FROM arbs
WHERE valmin; -- => 44 arbres en 2022
*/

UPDATE arbres a
SET vest_c = a1.vest
FROM arbs a1
WHERE a.npp = a1.npp
AND a.a = a1.a;

DROP TABLE bornes;
DROP TABLE coefs_ess;
DROP TABLE arbs;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_vest = t.vest_c
FROM arbres t
WHERE ua.npp = t.npp AND ua.a = t.a;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_vest = t.vest_c
FROM arbres t
WHERE ua.npp = t.npp AND ua.a = t.a;




-- calcul de V13 par tarif de cubage à 1 entrée
CREATE TEMPORARY TABLE arbs AS
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13--, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN arbres g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.npp = e1c.npp
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
UNION 
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13--, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.p3point g3f ON e2p.NPP = g3f.NPP
INNER JOIN arbres g3a ON g3f.NPP = g3a.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.NPP = e1c.NPP
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
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
    AND et.periode @> 2021 -- tarifs valides pour la campagne 2021
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
AND et.periode @> 2021 -- tarifs valides pour la campagne 2021
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

/*    
9 arbres, répartis en : 
ESS = 06 (chêne vert), GRECO = C (Grand Est semi-continental) => recopier GRECO J
ESS = 32 (charme-houblon), GRECO = B (Centre Nord semi-océanique) => recopier GRECO J
ESS = 41 (alisier torminal), GRECO = D (Vosges) => recopier GRECO C
ESS = 68 (autre conifère exotique), GRECO = D (Vosges) => recopier GRECO C
ESS = 74 (Mélèze exotique), GRECO = E (Jura) => recopier GRECO G
*/
    
-- On crée les tarifs en recopiant les existants d'une autre GRECO (précisé ci-dessus après demande à F. Morneau)
DROP TABLE IF EXISTS manquants;

CREATE TEMPORARY TABLE manquants AS 
SELECT DISTINCT a.ess, a.greco
, NULL::char(1) AS greco_copie
FROM arbs a
INNER JOIN coefs_ess c ON a.ess = c.ess
EXCEPT 
SELECT DISTINCT a.ess, a.greco
, NULL::char(1)
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
ORDER BY ess, greco; 

UPDATE manquants m
SET greco_copie = s.greco
FROM (VALUES ('06', 'J'), ('32', 'J'), ('41', 'C'), ('68', 'C'), ('74', 'G')) AS s (ess, greco)
WHERE m.ess = s.ess;

DROP TABLE IF EXISTS new_tarifs;

CREATE TEMPORARY TABLE new_tarifs AS 
WITH tarifs_copies AS (
    SELECT ce.id_type_tarif, ce.id_tarif, ce.ess, m.greco, m.greco_copie 
    FROM coefs_ess ce
    INNER JOIN manquants m ON ce.ess = m.ess AND ce.greco = m.greco_copie
    ORDER BY ess, id_tarif
)
, max_id_tarif AS (
    SELECT t.id_type_tarif, max(t.id_tarif) AS id_max
    FROM prod_exp.tarifs t
    INNER JOIN tarifs_copies tc USING (id_type_tarif)
    GROUP BY id_type_tarif
)
SELECT tc.ess, tc.greco, tc.greco_copie, mid.id_type_tarif
, RANK() OVER(PARTITION BY mid.id_type_tarif ORDER BY tc.ess, t.id_tarif) AS rang
, t.id_tarif
, mid.id_max + RANK() OVER(PARTITION BY mid.id_type_tarif ORDER BY tc.ess, t.id_tarif) AS id_tarif_new
, t.lib_tarif, t.coefficients
FROM tarifs_copies tc
INNER JOIN prod_exp.tarifs t ON tc.id_type_tarif = t.id_type_tarif AND tc.id_tarif = t.id_tarif
INNER JOIN max_id_tarif mid ON tc.id_type_tarif = mid.id_type_tarif;

INSERT INTO prod_exp.tarifs (id_type_tarif, id_tarif, lib_tarif, coefficients)
SELECT id_type_tarif, id_tarif_new, lib_tarif, coefficients
FROM new_tarifs
ORDER BY id_type_tarif, id_tarif_new;

INSERT INTO prod_exp.ess_tarif (id_type_tarif, id_tarif, ess, facteurs, periode)
SELECT nt.id_type_tarif, nt.id_tarif_new, et.ess
, et.facteurs || ('{"greco": "' || nt.greco || '"}')::jsonb
, '[2021,)'::int4range AS periode
FROM new_tarifs nt
INNER JOIN prod_exp.ess_tarif et ON nt.id_type_tarif = et.id_type_tarif AND nt.id_tarif = et.id_tarif AND nt.greco_copie = et.facteurs ->> 'greco'
ORDER BY nt.id_type_tarif, nt.id_tarif_new, et.id_ess_tarif;

DROP TABLE new_tarifs;
DROP TABLE manquants;


-- On recrée la table coefs_ess
DROP TABLE coefs_ess;

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2021 -- tarifs valides pour la campagne 2021
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
AND et.periode @> 2021 -- tarifs valides pour la campagne 2021
ORDER BY ess, id_tarif;

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
WHERE incref = 17;

SELECT count(*), count(u_v13)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 17;
*/

DROP TABLE arbres;

-- IMPUTATION DU VOLUME EN FORÊT
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
, a2.u_vest AS vest, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS vimp
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 17
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, vest, vest / v13 AS coef, v13, 'A'::BPCHAR AS ref
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
      , r.coef, r.vest, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, vest, v13, ref
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
SET vimp = c.vest * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

/*
SELECT count(*)
FROM arbres
WHERE vimp IS NULL; --> 0

SELECT * FROM arbres WHERE vimp IS NULL order by npp, a, ess, dimess; --> aucune sélection
*/

UPDATE inv_exp_nm.u_g3arbre ua
SET u_vest = a.vimp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_vest IS NULL;

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;

/*
SELECT COUNT(*), count(u_vest)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 17;

SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/

-- IMPUTATION DU VOLUME EN PEUPLERAIE

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
, a2.u_vest AS vest, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS vimp
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 17
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, vest, vest / v13 AS coef, v13, 'A'::BPCHAR AS ref
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
      , r.coef, r.vest, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, vest, v13, ref
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
SET vimp = c.vest * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_vest = a.vimp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_vest IS NULL;

/*
SELECT * FROM arbres WHERE vimp IS NULL order by npp, a, ess, dimess;
*/

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;

/*
SELECT COUNT(*), count(u_vest)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 17;

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
ORDER BY a.incref DESC;
*/

-- VOLUME DES ARBRES MORTS EN FORÊT ET PEUPLERAIE
DROP TABLE IF EXISTS arbres;

CREATE TEMPORARY TABLE arbres AS 
WITH arbsf AS (
    SELECT a.npp, a.a, a.gtot, a.w, a.pds
    FROM inv_exp_nm.g3arbre a
    WHERE a.incref = 17                         -- INCREF !
    UNION ALL
    SELECT m.npp, m.a, m.gtot, m.w, m.pds
    FROM inv_exp_nm.g3morts m
    WHERE m.incref = 17                         -- INCREF !
)
, competf AS (
    SELECT npp, SUM(gtot * w / pds) AS g
    FROM arbsf
    GROUP BY npp
)
, arbsp AS (
    SELECT a.npp, a.a, a.gtot, a.w, a.pds
    FROM inv_exp_nm.p3arbre a
    WHERE a.incref = 17                         -- INCREF !
    UNION ALL
    SELECT m.npp, m.a, m.gtot, m.w, m.pds
    FROM inv_exp_nm.p3morts m
    WHERE m.incref = 17                         -- INCREF !
)
, competp AS (
    SELECT npp, SUM(gtot * w / pds) AS g
    FROM arbsp
    GROUP BY npp
)
SELECT g3m.npp, g3m.a
, g3m.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3m.ess, g3m.c13
, c.g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.NPP = g3f.NPP
INNER JOIN inv_exp_nm.g3morts g3m ON g3f.NPP = g3m.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3m.NPP = e1c.NPP
INNER JOIN competf c ON g3m.npp = c.npp
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
WHERE g3m.incref = 17                         -- INCREF !
UNION 
SELECT p3m.npp, p3m.a
, p3m.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, p3m.ess, p3m.c13
, c.g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.p3point p3p ON e2p.NPP = p3p.NPP
INNER JOIN inv_exp_nm.p3morts p3m ON p3p.NPP = p3m.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON p3m.NPP = e1c.NPP
INNER JOIN competp c ON p3m.npp = c.npp
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_2015
WHERE p3m.incref = 17                         -- INCREF !
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pk_arbres PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2020 -- tarifs valides pour la campagne 2020
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
AND et.periode @> 2020 -- tarifs valides pour la campagne 2020
ORDER BY ess, id_tarif;

-- arbres sans tarif correspondant...
SELECT a.npp, a.a, a.ess, c.fact, a.greco
FROM arbres a
INNER JOIN coefs_ess c ON a.ess = c.ess
EXCEPT 
SELECT a.npp, a.a, a.ess, c.fact, a.greco
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
    END; -- 0 arbre

UPDATE arbres ab
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

/*
SELECT count(*) FROM arbres WHERE vest IS NULL;
*/

DROP TABLE coefs_ess;
 
UPDATE inv_exp_nm.g3morts m
SET v = a.vest
FROM arbres a
WHERE m.npp = a.npp
AND m.a = a.a;

UPDATE inv_exp_nm.p3morts m
SET v = a.vest
FROM arbres a
WHERE m.npp = a.npp
AND m.a = a.a;

--/*
SELECT COUNT(*), count(v)
FROM inv_exp_nm.g3morts
WHERE incref = 17;

SELECT COUNT(*), count(v)
FROM inv_exp_nm.p3morts
WHERE incref = 17;
*/

DROP TABLE arbres;


-- CALCUL DU VOLUME DE REBUT (voir note rebut2020.pdf) -- EN FORET
-- imputation de la hauteur totale
CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot, a.hrb_dm / 10.0 AS hrb
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, 'S'::BPCHAR AS REF
, NULL::FLOAT8 AS c0
, NULL::FLOAT8 AS crb
, NULL::FLOAT8 AS hbft
, NULL::FLOAT8 AS vbft
, NULL::FLOAT8 AS vr
, NULL::FLOAT8 AS r
FROM inv_exp_nm.g3arbre a
WHERE a.incref = 17
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT npp, a, espar
, dimess, c13, htot, 'A'::BPCHAR AS ref
FROM arbres
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
      , r.htot
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13), ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
        FROM arbres a
        INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
    )
    SELECT npp, a, espar, dimess, c13, htot, ref
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
SET htot = c.htot
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

/*
SELECT count(*)
FROM arbres
WHERE htot IS NULL;
*/

-- calcul de C0 et HBFT
UPDATE arbres
SET c0 = c13 * htot / (htot - 1.3)
, hbft = htot - 0.07 * pi() * (htot - 1.3) / c13;

-- calcul de CRB et VBFT
UPDATE arbres
SET crb = c13 * (htot - hrb) / (htot - 1.3)
, vbft = (c0^2 + 0.07 * pi() * c0 + (0.07 * pi())^2) * hbft / (12 * pi());

-- calcul de VR
UPDATE arbres
SET vr = (c0^2 + crb * c0 + crb^2) * hrb / (12 * pi())
WHERE hrb <= hbft;

-- calcul de R
UPDATE arbres
SET r = 
    CASE 
        WHEN hrb > hbft THEN 1
        WHEN vr IS NOT NULL AND vbft > 0 THEN vr / vbft
        ELSE 0
    END;

/*
SELECT avg(r)
FROM arbres
WHERE dimess IN ('MB', 'GB', 'TGB');

SELECT sum(a.vr * w * poids)
FROM arbres a
INNER JOIN inv_exp_nm.g3arbre ga USING (npp, a)
INNER JOIN inv_exp_nm.e2point USING (npp);
*/

UPDATE inv_exp_nm.g3arbre ga
SET r = a.r
FROM arbres a
WHERE ga.npp = a.npp AND ga.a = a.a;

/*
SELECT count(*)
FROM inv_exp_nm.g3arbre 
WHERE r IS NULL
AND incref = 17;
*/

DROP TABLE corresp;
DROP TABLE refs;
DROP TABLE arbres;


-- CALCUL DU VOLUME DE REBUT (voir note rebut2020.pdf) -- EN PEUPLERAIE
-- imputation de la hauteur totale
CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot, a.hrb_dm / 10.0 AS hrb
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, 'S'::BPCHAR AS REF
, NULL::FLOAT8 AS c0
, NULL::FLOAT8 AS crb
, NULL::FLOAT8 AS hbft
, NULL::FLOAT8 AS vbft
, NULL::FLOAT8 AS vr
, NULL::FLOAT8 AS r
FROM inv_exp_nm.p3arbre a
WHERE a.incref = 17
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT npp, a, espar
, dimess, c13, htot, 'A'::BPCHAR AS ref
FROM arbres
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
      , r.htot
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13), ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
        FROM arbres a
        INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
    )
    SELECT npp, a, espar, dimess, c13, htot, ref
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
SET htot = c.htot
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

/*
SELECT count(*)
FROM arbres
WHERE htot IS NULL;
*/

-- calcul de C0 et HBFT
UPDATE arbres
SET c0 = c13 * htot / (htot - 1.3)
, hbft = htot - 0.07 * pi() * (htot - 1.3) / c13;

-- calcul de CRB et VBFT
UPDATE arbres
SET crb = c13 * (htot - hrb) / (htot - 1.3)
, vbft = (c0^2 + 0.07 * pi() * c0 + (0.07 * pi())^2) * hbft / (12 * pi());

-- calcul de VR
UPDATE arbres
SET vr = (c0^2 + crb * c0 + crb^2) * hrb / (12 * pi())
WHERE hrb <= hbft;

-- calcul de R
UPDATE arbres
SET r = 
    CASE 
        WHEN hrb > hbft THEN 1
        WHEN vr IS NOT NULL AND vbft > 0 THEN vr / vbft
        ELSE 0
    END;

/*
SELECT avg(r)
FROM arbres
WHERE dimess IN ('MB', 'GB', 'TGB');

SELECT a.incref, sum(a.vr * w * poids)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

UPDATE inv_exp_nm.p3arbre ga
SET r = a.r
FROM arbres a
WHERE ga.npp = a.npp AND ga.a = a.a;

--/*
SELECT count(*)
FROM inv_exp_nm.p3arbre 
WHERE r IS NULL
AND incref = 17;

SELECT count(*)
FROM arbres
WHERE r IS NULL;
*/

DROP TABLE corresp;
DROP TABLE refs;
DROP TABLE arbres;


-- CALCUL DES DONNEES DERIVEES DU VOLUME DES ARBRES VIFS
UPDATE inv_exp_nm.g3arbre a
SET vr = ua.u_vest * a.r
, v = ua.u_vest * (1 - a.r)
FROM inv_exp_nm.u_g3arbre ua
WHERE ua.npp = a.npp AND ua.a = a.a
AND a.incref = 17;

UPDATE inv_exp_nm.p3arbre a
SET vr = ua.u_vest * a.r
, v = ua.u_vest * (1 - a.r)
FROM inv_exp_nm.u_p3arbre ua
WHERE ua.npp = a.npp AND ua.a = a.a
AND a.incref = 17;

/*
SELECT a.incref, avg(a.vr)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE ROUND(a.c13::NUMERIC, 3) >= 0.705
GROUP BY 1
ORDER BY 1 DESC;

SELECT a.incref, sum(a.vr * w * poids)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;

SELECT a.incref, avg(a.vr)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE ROUND(a.c13::NUMERIC, 3) >= 0.705
GROUP BY 1
ORDER BY 1 DESC;
*/

-- mise à jour du volume cumulé par point
UPDATE inv_exp_nm.g3foret
SET vh = t.vha
--, hlor = t.hlor
FROM (
	SELECT npp, 
		CASE WHEN SUM(wac * v) IS NULL THEN 0 ELSE SUM(wac * v) END AS vha, 
		CASE WHEN COALESCE(SUM(wac * gtot), 0) = 0 THEN 0 ELSE SUM(wac * htot * gtot) / SUM(wac * gtot) END AS hlor 
	FROM inv_exp_nm.g3foret
	LEFT JOIN inv_exp_nm.g3arbre USING (npp)
	LEFT JOIN inv_exp_nm.u_g3arbre USING (npp, a)
	WHERE g3foret.incref = 17
	GROUP BY npp
) t
WHERE g3foret.npp = t.npp;

UPDATE inv_exp_nm.g3foret
SET clvh = 
CASE 
	WHEN vh = 0 THEN '00'
	WHEN vh <= 25 THEN '01'
	WHEN vh <= 50 THEN '02'
	WHEN vh <= 75 THEN '03'
	WHEN vh <= 100 THEN '04'
	WHEN vh <= 125 THEN '05'
	WHEN vh <= 150 THEN '06'
	WHEN vh <= 200 THEN '07'
	WHEN vh <= 250 THEN '08'
	WHEN vh <= 300 THEN '09'
	WHEN vh <= 350 THEN '10'
	WHEN vh <= 400 THEN '11'
	WHEN vh <= 500 THEN '12'
	WHEN vh <= 600 THEN '13'
	ELSE '14'
END
, clvh_10 = 
CASE 
	WHEN vh = 0 THEN '00'
	WHEN vh <= 10 THEN '01'
	WHEN vh <= 20 THEN '02'
	WHEN vh <= 30 THEN '03'
	WHEN vh <= 40 THEN '04'
	WHEN vh <= 50 THEN '05'
	WHEN vh <= 60 THEN '06'
	WHEN vh <= 70 THEN '07'
	WHEN vh <= 80 THEN '08'
	WHEN vh <= 90 THEN '09'
	WHEN vh <= 100 THEN '10'
	WHEN vh <= 110 THEN '11'
	WHEN vh <= 120 THEN '12'
	WHEN vh <= 130 THEN '13'
	WHEN vh <= 140 THEN '14'
	WHEN vh <= 150 THEN '15'
	WHEN vh <= 160 THEN '16'
	WHEN vh <= 170 THEN '17'
	WHEN vh <= 180 THEN '18'
	WHEN vh <= 190 THEN '19'
	WHEN vh <= 200 THEN '20'
	WHEN vh <= 210 THEN '21'
	WHEN vh <= 220 THEN '22'
	WHEN vh <= 230 THEN '23'
	WHEN vh <= 240 THEN '24'
	WHEN vh <= 250 THEN '25'
	WHEN vh <= 260 THEN '26'
	WHEN vh <= 270 THEN '27'
	WHEN vh <= 280 THEN '28'
	WHEN vh <= 290 THEN '29'
	WHEN vh <= 300 THEN '30'
	WHEN vh <= 310 THEN '31'
	WHEN vh <= 320 THEN '32'
	WHEN vh <= 330 THEN '33'
	WHEN vh <= 340 THEN '34'
	WHEN vh <= 350 THEN '35'
	WHEN vh <= 360 THEN '36'
	WHEN vh <= 370 THEN '37'
	WHEN vh <= 380 THEN '38'
	WHEN vh <= 390 THEN '39'
	WHEN vh <= 400 THEN '40'
	WHEN vh <= 410 THEN '41'
	WHEN vh <= 420 THEN '42'
	WHEN vh <= 430 THEN '43'
	WHEN vh <= 440 THEN '44'
	WHEN vh <= 450 THEN '45'
	WHEN vh <= 460 THEN '46'
	WHEN vh <= 470 THEN '47'
	WHEN vh <= 480 THEN '48'
	WHEN vh <= 490 THEN '49'
	WHEN vh <= 500 THEN '50'
	ELSE '51'
END
WHERE incref = 17;

-- calcul de NT
UPDATE inv_exp_nm.g3arbre
SET nt = 1
WHERE incref = 17;

UPDATE inv_exp_nm.p3arbre
SET nt = 1
WHERE incref = 17;

-- Calcul de NT sur arbres morts
UPDATE inv_exp_nm.g3morts
SET nt = 1
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET nt = 1
WHERE incref = 17;

-- calcul de V0
CREATE UNLOGGED TABLE public.coefs (
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

\COPY coefs FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref16/donnees/coefs_tarifVallet.csv' WITH DELIMITER ';' NULL AS ''

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM coefs c
INNER JOIN inv_exp_nm.g3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 17
AND a.htot IS NOT NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM coefs c
INNER JOIN inv_exp_nm.p3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 17
AND a.ess <> '19'
AND a.htot IS NOT NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = (a.v + a.vr) * 1.25
FROM coefs c
INNER JOIN inv_exp_nm.p3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 17
AND a.ess = '19'
AND a.htot IS NOT NULL;

-- imputation de V0
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
, a2.u_v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 17
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
, a2.u_v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 17
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

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v0 = a.v0imp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_v0 IS NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = a.v0imp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_v0 IS NULL;

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;
DROP TABLE coefs;


/*
SELECT COUNT(*), count(u_v0)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 17;

SELECT COUNT(*), count(u_v0)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 17;
*/


/*
SELECT a.incref, sum(a.w * p.poids * ua.u_v0)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids * ua.u_v0)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/



-- calcul de RAKVEGET dans les arbres morts
UPDATE inv_exp_nm.g3morts
SET rakveget = '1'
WHERE incref = 17;

UPDATE inv_exp_nm.p3morts
SET rakveget = '1'
WHERE incref = 17;


-- TRAITEMENT DES IR5 SUR ARBRES VIFS EN FORET
-- rattrapage de l'IR5 sur les arbres avec IRN et sans IR5, pour les arbres avec mesure d'âge
UPDATE inv_exp_nm.g3arbre i
SET ir5 = 
  CASE
    WHEN i.ncern = 4 THEN round(p.ir4::NUMERIC, 4)
    WHEN i.ncern = 3 THEN round(p.ir3::NUMERIC, 4)
    WHEN i.ncern = 2 THEN round(p.ir2::NUMERIC, 4)
    WHEN i.ncern = 1 THEN round(p.ir1::NUMERIC, 4)
  END  / i.ncern * 5
FROM prod_exp.g3arbre p
WHERE i.npp = p.npp AND i.a = p.a
AND i.incref = 17
AND i.ir5 IS NULL
AND i.ncern > 0;

-- rattrapage de l'IR5 sur les arbres avec IRN et sans IR5, pour les arbres sans mesure d'âge
UPDATE inv_exp_nm.g3arbre
SET ir5 = irn / ncern * 5
WHERE incref = 17
AND ir5 IS NULL
AND irn IS NOT NULL
AND ncern > 0;

-- on met à 5 les NCERN sur lesquels NCERN est à null
UPDATE inv_exp_nm.g3arbre
SET ncern = 5
WHERE ncern IS NULL
AND incref = 17;

-- on met à 0 l'IR5 quand NCERN = 0
UPDATE inv_exp_nm.g3arbre
SET ir5 = 0
WHERE ncern = 0
AND incref = 17;

-- on met à 0 NCERN et IR5 sur les arbres sans IR5 non simplifiés, hors chêne vert et noyer
UPDATE inv_exp_nm.g3arbre
SET ir5 = 0, ncern = 0
WHERE simplif = '0'
AND ir5 IS NULL
AND ess NOT IN ('06', '27')
AND incref = 17;

-- imputation des IR5
CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.ir5
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 1
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 2
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 3
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 4
        ELSE 5
  END AS dimess
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS ir5_imp
FROM inv_exp_nm.g3arbre a
WHERE a.incref = 17
AND a.ess NOT IN ('06', '27')   -- le chêne vert et le noyer sont traités à part plus loin...
ORDER BY npp, a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

/*
Récupération des coefficients
*/

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT DISTINCT tt.id_type_tarif, et.id_tarif, x AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ir5'
    AND et.periode @> 2021          -- CAMPAGNE
)
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.dimess, c.coef1
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (dimess TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL)
WHERE tt.formule_tarif ~* 'ir5'
AND et.periode @> 2021              -- CAMPAGNE
ORDER BY ess, id_tarif;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar, a.ess
, a.dimess, a.c13, a.ir5, c.coef1, 'A'::BPCHAR AS ref
FROM arbres a
LEFT JOIN coefs_ess c ON a.ess = c.ess AND a.dimess = c.dimess::INT2
WHERE simplif = '0'
ORDER BY npp, a;

ALTER TABLE refs
ADD CONSTRAINT refs_pkey PRIMARY KEY (npp, a);

ANALYZE refs;

CREATE TEMPORARY TABLE corresp AS
SELECT *
FROM (
    WITH t0 AS (
        SELECT a.npp, a.a, a.espar, a.ess, a.dimess, r.c13
        , COALESCE(r.coef1, 0) AS alpha, ROUND(r.ir5::NUMERIC, 4) AS ir5
        , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
            , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
        FROM arbres a
        INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
    )
    SELECT npp, a, espar, ess, dimess, c13, alpha, ir5, ref
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
SET ir5_imp = c.ir5 * POWER(a.c13 / c.c13, c.alpha)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

-- contrôle des extrêmes
SELECT COUNT(*)
FROM arbres
WHERE NOT ir5_imp BETWEEN 0 AND 0.1;
-- 0 arbre 


/* IR5 à NULL => pose pb
SELECT *
FROM arbres
WHERE ir5_imp IS NULL
ORDER BY npp, a;

-- 0 arbre
*/

UPDATE inv_exp_nm.g3arbre a
SET ir5 = ab.ir5_imp
FROM arbres ab
WHERE a.npp = ab.npp AND a.a = ab.a
AND a.ir5 IS NULL
AND a.incref = 17;

UPDATE inv_exp_nm.g3arbre
SET ir5 = 0
WHERE incref = 17
AND ess = '27'; -- cas du Noyer

DROP TABLE corresp;
DROP TABLE refs;
DROP TABLE coefs_ess;
DROP TABLE arbres;

-- cas du chêne vert sur lequel on ne mesure plus l'IR5
-- Au préalable : demander les nouveaux coefficients annuels à François Morneau / Florence Gohon !
-- /!\ LE TARIF EST À AJOUTER DANS LES NOUVELLES TABLES DE TARIFS !!!
WITH new_tarif AS (
    SELECT tt.id_type_tarif, max(t.id_tarif) + 1 AS new_id_tarif
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
    WHERE tt.lib_type_tarif LIKE '%chêne vert'
    GROUP BY tt.id_type_tarif
)
, insertion_tarif AS (
    INSERT INTO prod_exp.tarifs (id_type_tarif, id_tarif, coefficients)
    SELECT nt.id_type_tarif, nt.new_id_tarif
    , '{"coef1":1.5, "coef2":-0.0291, "coef3":0.1796, "coef4":-0.1500, "coef5":0.0424, "coef6":0.009132, "coef7":0.006}'::jsonb AS coefficients
    FROM new_tarif nt
)
INSERT INTO prod_exp.ess_tarif (id_type_tarif, id_tarif, ess, periode)
SELECT nt.id_type_tarif, nt.new_id_tarif
, '06' AS ess
, '[2021, 2021]'::int4range
FROM new_tarif nt;

-- puis on l'utilise pour le calcul
DROP TABLE IF EXISTS coefs_ess;

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT DISTINCT tt.id_type_tarif, et.id_tarif, x AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'chêne vert'
    AND et.periode @> 2021          -- CAMPAGNE
)
SELECT et.id_type_tarif, et.id_tarif, et.ess--, x.dimess
, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (dimess TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.lib_type_tarif ~* 'chêne vert'
AND et.periode @> 2021              -- CAMPAGNE
ORDER BY ess, id_tarif;

UPDATE inv_exp_nm.g3arbre a
SET ir5 = 
CASE
	WHEN ROUND(a.c13::NUMERIC, 3) < c.coef1 THEN (c.coef2 + c.coef3 * c13 + c.coef4 * c13^2 + c.coef5 * c13^3) * (1 - 2 * PI() * c.coef6) / (2 * PI())
	ELSE c.coef7
END
FROM coefs_ess c
WHERE a.ess = c.ess
AND a.incref = 17;

DROP TABLE coefs_ess;


/*
SELECT COUNT(*), count(ir5)
FROM inv_exp_nm.g3arbre
WHERE incref = 17;

SELECT a.incref, sum(a.w * p.poids * a.ir5)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids * a.ir5)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.ess = '06'
GROUP BY a.incref
ORDER BY a.incref DESC;
*/

-- CALCULS D'ACCROISSEMENTS
-- calcul du C13_5
CREATE TEMPORARY TABLE coefs_ess AS 
SELECT et.id_type_tarif, et.id_tarif, et.ess, c.coef1, c.coef2
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (decoupe TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL)
WHERE tt.lib_type_tarif ILIKE '%cercle%'
AND et.periode @> 2021; -- CAMPAGNE

UPDATE inv_exp_nm.g3arbre
SET c13_5 = GREATEST(c13 - (2 * PI() * ir5) / (1 - 2 * PI() * c.coef1), 0)
FROM coefs_ess c 
WHERE g3arbre.ess = c.ess
AND g3arbre.incref = 17;

DROP TABLE coefs_ess;

/*
SELECT COUNT(*), count(c13_5)
FROM inv_exp_nm.g3arbre
WHERE incref = 17;
*/

-- calcul de ABG, AD, PG, RG et de RT5
UPDATE inv_exp_nm.g3arbre
SET abg = (c13 * c13 - c13_5 * c13_5) / (20 * PI())
, ad = (c13 - c13_5) / (5 * PI())
, pg = CASE	
			WHEN c13_5 < 0.235 THEN (c13 * c13) / (20 * PI())
			ELSE (c13 * c13 - c13_5 * c13_5) / (20 * PI())  --ABG
	   END
, rg = CASE	
			WHEN c13_5 < 0.235 THEN (0.235 * 0.235) / (20 * PI())
			ELSE 0
	   END
, rt5 = CASE
			WHEN c13_5 < 0.235 THEN '1'
			ELSE '0'
		END
WHERE incref = 17;

COMMIT;

VACUUM ANALYZE inv_exp_nm.g3arbre;
VACUUM ANALYZE inv_exp_nm.p3arbre;
VACUUM ANALYZE inv_exp_nm.u_g3arbre;
VACUUM ANALYZE inv_exp_nm.u_p3arbre;
VACUUM ANALYZE inv_exp_nm.g3morts;
VACUUM ANALYZE inv_exp_nm.p3morts;
VACUUM ANALYZE inv_exp_nm.u_g3morts;
VACUUM ANALYZE inv_exp_nm.u_p3morts;

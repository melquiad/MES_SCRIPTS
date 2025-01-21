
---- SCRIPT DE 2018 --------------------------------------------

-- CALCUL DU VOLUME DES ARBRES AVEC HAUTEUR (3 ENTRÉES)
-- arbres vifs en forêt
CREATE TEMPORARY TABLE volarbres AS 
SELECT * FROM prod_exp.calcVolArbre_3Entrees(13, 'F') WHERE npp IN ('18-2B-360-1-226T'
,'18-27-121-1-074T','18-67-281-1-044','18-85-112-1-177T','18-64-134-1-295T','18-2B-360-1-228T'
,'18-52-223-1-072T','18-67-282-1-035T','18-09-203-1-280T','18-51-184-1-051T');


UPDATE inv_exp_nm.u_g3arbre ua
SET u_vest = t.vest
FROM volarbres t
WHERE ua.npp = t.npp AND ua.a = t.a;

SELECT count(*)
FROM volarbres
WHERE valmin;

DROP TABLE volarbres;

-- CALCUL DU VOLUME DES ARBRES VIFS À 1 ENTRÉE
UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13 = t.vest
FROM (
	SELECT * FROM PROD_EXP.calcVolArbreLnC13_2015(13) WHERE npp IN ('18-2B-360-1-226T'
,'18-27-121-1-074T','18-67-281-1-044','18-85-112-1-177T','18-64-134-1-295T','18-2B-360-1-228T'
,'18-52-223-1-072T','18-67-282-1-035T','18-09-203-1-280T','18-51-184-1-051T');
) t
WHERE ua.npp = t.npp AND ua.a = t.a;

-------------------------------------------------------
-- CALCUL DES DONNEES DERIVEES DU VOLUME DES ARBRES VIFS
UPDATE inv_exp_nm.g3arbre a
SET vr = ua.u_vest * a.r
, v = ua.u_vest * (1 - a.r)
FROM inv_exp_nm.u_g3arbre ua
WHERE ua.npp = a.npp AND ua.a = a.a
AND a.incref = 13
AND a.npp IN ('18-2B-360-1-226T'
,'18-27-121-1-074T','18-67-281-1-044','18-85-112-1-177T','18-64-134-1-295T','18-2B-360-1-228T'
,'18-52-223-1-072T','18-67-282-1-035T','18-09-203-1-280T','18-51-184-1-051T');

SELECT g3.npp, g3.a, g3.v, g3.vr
FROM inv_exp_nm.g3arbre g3
WHERE g3.npp IN ('18-2B-360-1-226T'
,'18-27-121-1-074T','18-67-281-1-044','18-85-112-1-177T','18-64-134-1-295T','18-2B-360-1-228T'
,'18-52-223-1-072T','18-67-282-1-035T','18-09-203-1-280T','18-51-184-1-051T');



----------------------------------------------------------------
---- SCRIPT DE 2023 --------------------------------------------



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
WHERE a.incref = 13  AND a.npp IN ('18-2B-360-1-226T') AND a.a = 7;
/*UNION 
SELECT a.npp, a.a, a.incref, a.c13, a.gtot, a.htot, a.hdec, a.ess, a.espar, a.ori, a.decoupe, a.simplif, ua.u_vest, ua.u_v13, a.r, a.w, a.pds
, NULL::FLOAT AS hdec_c
, NULL::FLOAT AS vest_c
, NULL::FLOAT AS v13_c
, NULL::FLOAT8 AS v_c
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
WHERE a.incref = 13
ORDER BY npp, a;*/

ALTER TABLE arbres ADD CONSTRAINT pk_arbres PRIMARY KEY (npp, a);

ANALYZE arbres;


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
AND et.periode @> 2023; -- contrôle que la campagne 2023 est dans la période de validité du tarif pour l'essence

ALTER TABLE coefs_ess ADD CONSTRAINT coefs_ess_pkey PRIMARY KEY (ess, id_type_tarif, id_tarif);

UPDATE arbs a
SET fnew = t.fnew
FROM (
    SELECT npp, a, a.ess
    , CASE 
       /* WHEN tt.lib_type_tarif ~~* '%v1'
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
                + coef8 * 1 / power(c13max, coef9)*/
        WHEN tt.lib_type_tarif ~~* '%v4'
            THEN coef1 
                + COALESCE(coef2, 0) * c13max
                + coef3 * sqrt(c13max) / htot 
                + coef4 * ln(hdec / htot) 
                + COALESCE(coef8, 0) * 1 / power(c13max, COALESCE(coef9, 0))
        /*WHEN tt.lib_type_tarif ~~* '%v5'
            THEN coef1 
                + coef2 * c13max 
                + COALESCE(coef3, 0) * sqrt(c13max) / htot 
                + coef4 * ln(hdec) 
                + COALESCE(coef8, 0) * 1 / power(c13max, COALESCE(coef9, 0))*/
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

TABLE arbs;

/*
SELECT count(*)
FROM arbs
WHERE valmin; -- => 53 arbres sur 2023
*/

UPDATE arbres a
SET vest_c = a1.vest
FROM arbs a1
WHERE a.npp = a1.npp
AND a.a = a1.a;

TABLE arbres;

DROP TABLE bornes;
DROP TABLE coefs_ess;
DROP TABLE arbs;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_vest = t.vest_c
FROM arbres t
WHERE ua.npp = t.npp AND ua.a = t.a;


SELECT g3.npp, g3.a, g3.u_vest
FROM inv_exp_nm.u_g3arbre g3
WHERE g3.npp IN ('18-2B-360-1-226T');
--,'18-27-121-1-074T','18-67-281-1-044','18-85-112-1-177T','18-64-134-1-295T','18-2B-360-1-228T'
--,'18-52-223-1-072T','18-67-282-1-035T','18-09-203-1-280T','18-51-184-1-051T');


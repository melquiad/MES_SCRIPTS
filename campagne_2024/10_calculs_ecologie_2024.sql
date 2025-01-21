BEGIN;

-- on met 0 dans AFFROC = NULL et dans CAILLOUX = NULL, CAI40 = NULL si OBSPEDO != 5
UPDATE inv_exp_nm.g3ecologie
SET affroc = '0'
WHERE affroc IS NULL
AND incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET cai40 = '0'
WHERE cai40 IS NULL
AND COALESCE(obspedo, '0') != '5'
AND incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET cailloux = '0'
WHERE cailloux IS NULL
AND COALESCE(obspedo, '0') != '5'
AND incref = 18;

-- on met 0 dans DENIVRIV quand DISTRIV = 1 ou 2
UPDATE inv_exp_nm.g3ecologie
SET denivriv = 0
WHERE distriv IN ('1', '2')
AND incref = 18;

-- RECODAGE DES TEXT1 ET TEXT2 DE NULL VERS LA MODALITÉ '0'
UPDATE inv_exp_nm.g3ecologie
SET text1 = COALESCE(text1, '0')
, text2 = COALESCE(text2, '0')
WHERE (text1 IS NULL OR text2 IS NULL)
AND incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET clpcalc = CASE WHEN pcalc IS NULL THEN 'X' ELSE pcalc::CHAR(1) END,
clpcalf = CASE WHEN pcalf IS NULL THEN 'X' ELSE pcalf::CHAR(1) END,
clpox = CASE WHEN pox IS NULL THEN 'X' ELSE pox::CHAR(1) END,
clppseudo = CASE WHEN ppseudo IS NULL THEN 'X' ELSE ppseudo::CHAR(1) END,
clpgley = CASE WHEN pgley IS NULL THEN 'X' ELSE pgley::CHAR(1) END
WHERE incref = 18;

-- calcul de TEXT1G et TEXT2G
UPDATE inv_exp_nm.g3ecologie
SET text2g = text2, text1g = text1
WHERE incref = 18;

-- calcul du rayonnement
UPDATE inv_exp_nm.g3ecologie e
SET rayo = p.rayo
FROM prod_exp.calcRayo(18::SMALLINT) p
WHERE e.npp = p.npp;

-- calcul de l'indice de rayonnement, de l'indice topographique, de l'indice d'hydromorphie, de l'indice de charge en cailloux et profondeur
UPDATE inv_exp_nm.g3ecologie
SET indic_rayo = 
CASE
    WHEN rayo IS NULL THEN NULL
    WHEN rayo <= 60 THEN '1'
    WHEN rayo <= 90 THEN '2'
    WHEN rayo <= 105 THEN '3'
    WHEN rayo <= 125 THEN '4'
    ELSE '5'
END
, indic_topo = 
CASE
    WHEN topo IN ('8', '9') THEN '6'
    WHEN topo = '7' THEN '5'
    WHEN pent2 IS NULL THEN 'X'
    WHEN pent2 < 18 THEN '1'
    WHEN rayo IS NULL THEN '3'
    WHEN rayo < 80 THEN '4'
    WHEN rayo <= 110 THEN '3'
    WHEN rayo > 110 THEN '2'
END
, indic_hydro = 
CASE
    WHEN tsol IN ('82', '83', '85', '89') OR humusg1 = '6' OR ppseudo IN (0, 1) OR pgley IN (0, 1) THEN '1'
    WHEN ppseudo IN (2, 3) OR pgley IN (2, 3) THEN '2'
    WHEN ppseudo IN (4, 5, 6) OR pgley IN (4, 5, 6) THEN '3'
    WHEN ppseudo IN (7, 8, 9) OR pgley IN (7, 8, 9) THEN '4'
    WHEN tsol IN ('08', '09', '10', '11', '54', '58') OR pox IS NOT NULL THEN '4'
    WHEN tsol IN ('57', '59') THEN '3'
    WHEN obspedo IN ('5', '9') AND prof2 IS NULL THEN 'X'
    ELSE '5'
END
, indic_cail = 
CASE
    WHEN cailloux IS NULL OR prof2 IS NULL THEN 'X'
    WHEN cailloux > 7 OR affroc > 7 THEN '1'
    WHEN cailloux IN (6, 7) OR affroc IN (6, 7) THEN '2'
    WHEN COALESCE(prof2, 0) <= 1 THEN '3'
    WHEN prof2 IN (2, 3) THEN '4'
    WHEN prof2 IN (4, 5, 6) THEN '5'
    WHEN prof2 > 6 THEN '6'
END
WHERE incref = 18;

-- calcul de la texture du sol
UPDATE inv_exp_nm.g3ecologie
SET texture = c.cmode
FROM metaifn.abcompose c
WHERE c.cunite = 'CTEXT1' AND c.mode1 = g3ecologie.text1g AND c.mode2 = g3ecologie.text2g
AND incref = 18;

-- calcul de l'indice de texture, de l'indice d'acidité du sol
UPDATE inv_exp_nm.g3ecologie
SET indic_text = 
CASE
    WHEN texture IS NULL OR prof2 IS NULL OR cailloux IS NULL THEN 'X'
    WHEN COALESCE(prof2, 0) < 2 THEN '1'
    WHEN (COALESCE(affroc::INT, 0) + COALESCE(cailloux::INT, 0)) > 7 THEN '2'
    WHEN (COALESCE(affroc::INT, 0) + COALESCE(cailloux::INT, 0)) > 3 THEN '3'
    WHEN (texture = '6' AND prof1 < 2) OR (texture IN ('5', '7')) THEN '9'
    WHEN texture = '6' AND (prof1 BETWEEN 2 AND 3) THEN '4'
    WHEN texture = '6' AND (prof1 BETWEEN 4 AND 5) THEN '5'
    WHEN texture = '6' AND prof1 > 5 THEN '6'
    WHEN texture = '4' THEN '6'
    WHEN texture IN ('1', '2') THEN '7'
    WHEN texture = '3' THEN '8'
    WHEN texture = '8' THEN 'H'
    ELSE 'X'
END
, indic_acid = 
CASE
    WHEN pcalc IN (0, 1) THEN '1'
    WHEN pcalc IN (2, 3, 4) THEN '2'
    WHEN pcalc > 4 THEN '3'
    WHEN (rocheg1 BETWEEN '5' AND '8') AND (prof2 <= 6 OR affroc::INT > 5 OR cailloux::INT > 5) THEN '4'
    WHEN (rocheg1 BETWEEN '5' AND '8') AND (prof2 > 6 AND affroc::INT < 6 AND cailloux::INT < 6) THEN '5'
    WHEN texture IN ('3', '5', '6', '7') THEN '6'
    WHEN texture = '4' THEN '7'
    WHEN texture IN ('1', '2', '8') OR obspedo IN ('H', 'R') OR htext = '0' THEN '8'
    ELSE 'X'
END
WHERE incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET indic_humus = 
CASE
    WHEN humus IN ('10','21','20','22') AND tsol IN ('21','22','14','15','17') AND indic_acid < '6' THEN '7'
    WHEN humus = '26' THEN '7'
    WHEN humus IN ('10','21') THEN '1'
    WHEN humus IN ('20','22', '29') THEN '2'
    WHEN humus IN ('30','31','42') THEN '3'
    WHEN humus IN ('40', '49', '50') THEN '4'
    WHEN humus IN ('15','25','45','55') THEN '5'
    WHEN humus IN ('18','28', '47', '48','80','81', '85') THEN '6'
    ELSE '0'
END
WHERE incref = 18;

-- calcul de la réserve utile
-- table temporaire de correspondance des textures
CREATE TEMPORARY TABLE textu (
    textu CHAR(1),
    coef REAL
)
WITH (
	OIDS = FALSE
);

INSERT INTO textu
VALUES ('0', 0),
('1', 0.7),
('2', 1),
('3', 1.35),
('4', 1.45),
('5', 1.95),
('6', 1.75),
('7', 1.8),
('8', 1.7),
('9', 1.75), 
('H', 1.75);

-- calcul de la réserve utile
UPDATE inv_exp_nm.g3ecologie
SET reserutile = (10 - COALESCE(cailloux, 0))::REAL * (COALESCE(prof1, 0)::REAL * ntext1 + (COALESCE(prof2, 0) - COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.g3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
WHERE g3ecologie.npp = t.npp
AND incref = 18;

DROP TABLE textu;

-- discrétisation de la réserve utile
UPDATE inv_exp_nm.g3ecologie
SET rut = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN reserutile < 10 THEN '1'
    WHEN reserutile < 30 THEN '2'
    WHEN reserutile < 50 THEN '3'
    WHEN reserutile < 70 THEN '4'
    WHEN reserutile < 90 THEN '5'
    WHEN reserutile < 110 THEN '6'
    WHEN reserutile < 130 THEN '7'
    WHEN reserutile < 150 THEN '8'
    WHEN reserutile < 170 THEN '9'
    WHEN reserutile < 190 THEN '10'
    WHEN reserutile >= 190 THEN '11'
END
WHERE incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET lpv = 
CASE
    WHEN TO_CHAR(dateeco, 'MMDD') < '0415' OR TO_CHAR(dateeco, 'MMDD') > '1015' THEN '0'
    WHEN dateeco IS NULL THEN NULL
    ELSE '1'
END
, clexpo = 
CASE
    WHEN expo IS NULL THEN NULL
    WHEN expo < 100 THEN '1'
    WHEN expo < 200 THEN '2'
    WHEN expo < 300 THEN '3'
    ELSE '4'
END
, clmq = 
CASE
    WHEN masque IS NULL THEN NULL
    WHEN masque < 25 THEN '1'
    WHEN masque < 50 THEN '2'
    WHEN masque < 75 THEN '3'
    ELSE '4'
END
WHERE incref = 18;

/*
SELECT f.incref, f.rut, SUM(ue.poids) AS eff_pond
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
INNER JOIN inv_exp_nm.g3ecologie f USING (npp)
WHERE p2.us_nm = '1'
AND f.incref >= 3
GROUP BY f.incref, f.rut
ORDER BY incref DESC, rut;

SELECT f.incref + 2005 AS campagne, RTRIM(f.rut) AS ruti, SUM(ue.poids) AS eff_pond
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
INNER JOIN inv_exp_nm.g3ecologie f USING (npp)
WHERE p2.us_nm = '1'
AND f.incref >= 10
GROUP BY f.incref, ruti
ORDER BY f.incref DESC, ruti
\crosstabview ruti campagne
*/

UPDATE inv_exp_nm.g3ecologie
SET textg1 = g1.gmode
FROM metaifn.abgroupe g1
WHERE g1.unite = 'TEXT' AND g1.mode = COALESCE(text1g, text2g) AND g1.gunite = 'CTEXT1'
AND incref = 18;

UPDATE inv_exp_nm.g3ecologie
SET cl_pent2 =
CASE
    WHEN pent2 IS NULL THEN 'XX'
    WHEN FLOOR(0.2 * pent2) > 20 THEN '20'
    ELSE TO_CHAR(FLOOR(0.2 * pent2), 'FM09')
END
WHERE incref = 18;

-- ajout et calcul de la donnée CONTXT
WITH contexte AS (
    SELECT e.npp, 
    r.dom_biog2 
     || CASE 
            WHEN c.zp >= (r.mont_b + (r.mont_h - r.mont_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.mont_h - r.mont_b) / 2
                THEN 'M'
            WHEN c.zp >= (r.suprm_b + (r.suprm_h - r.suprm_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.suprm_h - r.suprm_b) / 2
                THEN 'S'
            WHEN r.dom_biog2 = 'M'
                THEN 'X'
            ELSE 'C'
        END
     || CASE
            WHEN e.pcalc IN (0, 1, 2, 3, 4) OR (g.gmode IN ('5', '6', '7', '8') AND (e.prof2 <= 6 OR e.affroc >= 6 OR e.cailloux >= 6))
                THEN 'C'
            ELSE 'A'
        END
     || CASE
            WHEN e.tsol IN ('82', '83', '85') OR e.ppseudo IN (0, 1, 2, 3) OR e.pgley IN (0, 1, 2, 3)
                THEN 'H'
            ELSE 'S'
        END AS contxt
    FROM inv_exp_nm.g3ecologie e
    INNER JOIN inv_exp_nm.e1coord c ON e.npp = c.npp
    INNER JOIN inv_exp_nm.e2point p ON e.npp = p.npp
    INNER JOIN prod_exp.regn_limtag R ON p.regn = r.regn
    LEFT JOIN MetaIFN.abgroupe g ON g.unite = 'ROCHED0' AND g.gunite = 'ROCHED1' AND e.roche = g.mode
)
UPDATE inv_exp_nm.g3ecologie ec
SET contxt =  c.contxt
FROM contexte c
WHERE ec.npp = c.npp
AND ec.incref = 18;

-- mise à jour de la donnée TSOL22
UPDATE inv_exp_nm.g3ecologie
SET tsol22 = tsol
WHERE incref = 18;

COMMIT;

VACUUM ANALYZE inv_exp_nm.g3ecologie;


-- CALCULS EN PEUPLERAIE
BEGIN;


-- on met 0 dans AFFROC = NULL et dans CAILLOUX = NULL, CAI40 = NULL si OBSPEDO != 5
UPDATE inv_exp_nm.p3ecologie
SET affroc = '0'
WHERE affroc IS NULL
AND incref = 18;

UPDATE inv_exp_nm.p3ecologie
SET cai40 = '0'
WHERE cai40 IS NULL
AND COALESCE(obspedo, '0') != '5'
AND incref = 18;

UPDATE inv_exp_nm.p3ecologie
SET cailloux = '0'
WHERE cailloux IS NULL
AND COALESCE(obspedo, '0') != '5'
AND incref = 18;

-- on met 0 dans DENIVRIV quand DISTRIV = 1 ou 2
UPDATE inv_exp_nm.p3ecologie
SET denivriv = 0
WHERE distriv IN ('1', '2')
AND incref = 18;

-- RECODAGE DES TEXT1 ET TEXT2 DE NULL VERS LA MODALITÉ '0'
UPDATE inv_exp_nm.p3ecologie
SET text1 = COALESCE(text1, '0')
, text2 = COALESCE(text2, '0')
WHERE (text1 IS NULL OR text2 IS NULL)
AND incref = 18;


UPDATE inv_exp_nm.p3ecologie
SET clpcalc = CASE WHEN pcalc IS NULL THEN 'X' ELSE pcalc::CHAR(1) END,
clpcalf = CASE WHEN pcalf IS NULL THEN 'X' ELSE pcalf::CHAR(1) END,
clpox = CASE WHEN pox IS NULL THEN 'X' ELSE pox::CHAR(1) END,
clppseudo = CASE WHEN ppseudo IS NULL THEN 'X' ELSE ppseudo::CHAR(1) END,
clpgley = CASE WHEN pgley IS NULL THEN 'X' ELSE pgley::CHAR(1) END
WHERE incref = 18;

-- calcul de TEXT1G et TEXT2G
UPDATE inv_exp_nm.p3ecologie
SET text2g = text2, text1g = text1
WHERE incref = 18;

-- calcul du rayonnement
UPDATE inv_exp_nm.p3ecologie e
SET rayo = p.rayo
FROM prod_exp.calcRayo(18::SMALLINT) p
WHERE e.npp = p.npp;

-- calcul de l'indice de rayonnement, de l'indice topographique, de l'indice d'hydromorphie, de l'indice de charge en cailloux et profondeur
UPDATE inv_exp_nm.p3ecologie
SET indic_rayo = 
CASE
    WHEN rayo IS NULL THEN NULL
    WHEN rayo <= 60 THEN '1'
    WHEN rayo <= 90 THEN '2'
    WHEN rayo <= 105 THEN '3'
    WHEN rayo <= 125 THEN '4'
    ELSE '5'
END
, indic_topo = 
CASE
    WHEN topo IN ('8', '9') THEN '6'
    WHEN topo = '7' THEN '5'
    WHEN pent2 IS NULL THEN 'X'
    WHEN pent2 < 18 THEN '1'
    WHEN rayo IS NULL THEN '3'
    WHEN rayo < 80 THEN '4'
    WHEN rayo <= 110 THEN '3'
    WHEN rayo > 110 THEN '2'
END
, indic_hydro = 
CASE
    WHEN tsol IN ('82', '83', '85', '89') OR humusg1 = '6' OR ppseudo IN (0, 1) OR pgley IN (0, 1) THEN '1'
    WHEN ppseudo IN (2, 3) OR pgley IN (2, 3) THEN '2'
    WHEN ppseudo IN (4, 5, 6) OR pgley IN (4, 5, 6) THEN '3'
    WHEN ppseudo IN (7, 8, 9) OR pgley IN (7, 8, 9) THEN '4'
    WHEN tsol IN ('08', '09', '10', '11', '54', '58') OR pox IS NOT NULL THEN '4'
    WHEN tsol IN ('57', '59') THEN '3'
    WHEN obspedo IN ('5', '9') AND prof2 IS NULL THEN 'X'
    ELSE '5'
END
, indic_cail = 
CASE
    WHEN cailloux IS NULL OR prof2 IS NULL THEN 'X'
    WHEN cailloux > 7 OR affroc > 7 THEN '1'
    WHEN cailloux IN (6, 7) OR affroc IN (6, 7) THEN '2'
    WHEN COALESCE(prof2, 0) <= 1 THEN '3'
    WHEN prof2 IN (2, 3) THEN '4'
    WHEN prof2 IN (4, 5, 6) THEN '5'
    WHEN prof2 > 6 THEN '6'
END
WHERE incref = 18;

-- calcul de la texture du sol
UPDATE inv_exp_nm.p3ecologie
SET texture = c.cmode
FROM metaifn.abcompose c
WHERE c.cunite = 'CTEXT1' AND c.mode1 = p3ecologie.text1g AND c.mode2 = p3ecologie.text2g
AND incref = 18;

-- calcul de l'indice de texture, de l'indice d'acidité du sol
UPDATE inv_exp_nm.p3ecologie
SET indic_text = 
CASE
    WHEN texture IS NULL OR prof2 IS NULL OR cailloux IS NULL THEN 'X'
    WHEN COALESCE(prof2, 0) < 2 THEN '1'
    WHEN (COALESCE(affroc::INT, 0) + COALESCE(cailloux::INT, 0)) > 7 THEN '2'
    WHEN (COALESCE(affroc::INT, 0) + COALESCE(cailloux::INT, 0)) > 3 THEN '3'
    WHEN (texture = '6' AND prof1 < 2) OR (texture IN ('5', '7')) THEN '9'
    WHEN texture = '6' AND (prof1 BETWEEN 2 AND 3) THEN '4'
    WHEN texture = '6' AND (prof1 BETWEEN 4 AND 5) THEN '5'
    WHEN texture = '6' AND prof1 > 5 THEN '6'
    WHEN texture = '4' THEN '6'
    WHEN texture IN ('1', '2') THEN '7'
    WHEN texture = '3' THEN '8'
    WHEN texture = '8' THEN 'H'
    ELSE 'X'
END
, indic_acid = 
CASE
    WHEN pcalc IN (0, 1) THEN '1'
    WHEN pcalc IN (2, 3, 4) THEN '2'
    WHEN pcalc > 4 THEN '3'
    WHEN (rocheg1 BETWEEN '5' AND '8') AND (prof2 <= 6 OR affroc::INT > 5 OR cailloux::INT > 5) THEN '4'
    WHEN (rocheg1 BETWEEN '5' AND '8') AND (prof2 > 6 AND affroc::INT < 6 AND cailloux::INT < 6) THEN '5'
    WHEN texture IN ('3', '5', '6', '7') THEN '6'
    WHEN texture = '4' THEN '7'
    WHEN texture IN ('1', '2', '8') OR obspedo IN ('H', 'R') OR htext = '0' THEN '8'
    ELSE 'X'
END
WHERE incref = 18;

UPDATE inv_exp_nm.p3ecologie
SET indic_humus = 
CASE
    WHEN humus IN ('10','21','20','22') AND tsol IN ('21','22','14','15','17') AND indic_acid < '6' THEN '7'
    WHEN humus = '26' THEN '7'
    WHEN humus IN ('10','21') THEN '1'
    WHEN humus IN ('20','22', '29') THEN '2'
    WHEN humus IN ('30','31','42') THEN '3'
    WHEN humus IN ('40', '49', '50') THEN '4'
    WHEN humus IN ('15','25','45','55') THEN '5'
    WHEN humus IN ('18','28', '47', '48','80','81', '85') THEN '6'
    ELSE '0'
END
WHERE incref = 18;

-- calcul de la réserve utile
-- table temporaire de correspondance des textures
CREATE TEMPORARY TABLE textu (
    textu CHAR(1),
    coef REAL
)
WITH (
    OIDS = FALSE
);

INSERT INTO textu
VALUES ('0', 0),
('1', 0.7),
('2', 1),
('3', 1.35),
('4', 1.45),
('5', 1.95),
('6', 1.75),
('7', 1.8),
('8', 1.7),
('9', 1.75), 
('H', 1.75);

-- calcul de la réserve utile
UPDATE inv_exp_nm.p3ecologie
SET reserutile = (10 - COALESCE(cailloux, 0))::REAL * (COALESCE(prof1, 0)::REAL * ntext1 + (COALESCE(prof2, 0) - COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.p3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) T
WHERE p3ecologie.npp = t.npp
AND incref = 18;

DROP TABLE textu;

-- discrétisation de la réserve utile
UPDATE inv_exp_nm.p3ecologie
SET rut = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN reserutile < 10 THEN '1'
    WHEN reserutile < 30 THEN '2'
    WHEN reserutile < 50 THEN '3'
    WHEN reserutile < 70 THEN '4'
    WHEN reserutile < 90 THEN '5'
    WHEN reserutile < 110 THEN '6'
    WHEN reserutile < 130 THEN '7'
    WHEN reserutile < 150 THEN '8'
    WHEN reserutile < 170 THEN '9'
    WHEN reserutile < 190 THEN '10'
    WHEN reserutile >= 190 THEN '11'
END
WHERE incref = 18;

UPDATE inv_exp_nm.p3ecologie
SET lpv = 
CASE
    WHEN TO_CHAR(dateeco, 'MMDD') < '0415' OR TO_CHAR(dateeco, 'MMDD') > '1015' THEN '0'
    WHEN dateeco IS NULL THEN NULL
    ELSE '1'
END
, clexpo = 
CASE
    WHEN expo IS NULL THEN NULL
    WHEN expo < 100 THEN '1'
    WHEN expo < 200 THEN '2'
    WHEN expo < 300 THEN '3'
    ELSE '4'
END
, clmq = 
CASE
    WHEN masque IS NULL THEN NULL
    WHEN masque < 25 THEN '1'
    WHEN masque < 50 THEN '2'
    WHEN masque < 75 THEN '3'
    ELSE '4'
END
WHERE incref = 18;

/*
SELECT f.incref, f.rut, SUM(ue.poids) AS eff_pond
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
INNER JOIN inv_exp_nm.p3ecologie f USING (npp)
WHERE p2.us_nm = '5'
AND f.incref >= 11
GROUP BY f.incref, f.rut
ORDER BY incref DESC, rut;

SELECT f.incref + 2005 AS campagne, RTRIM(f.rut) AS ruti, SUM(ue.poids) AS eff_pond
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
INNER JOIN inv_exp_nm.p3ecologie f USING (npp)
WHERE p2.us_nm = '5'
AND f.incref >= 11
GROUP BY f.incref, ruti
ORDER BY f.incref DESC, ruti
\crosstabview ruti campagne
*/

UPDATE inv_exp_nm.p3ecologie
SET textg1 = g1.gmode
FROM metaifn.abgroupe g1
WHERE g1.unite = 'TEXT' AND g1.mode = COALESCE(text1g, text2g) AND g1.gunite = 'CTEXT1'
AND incref = 18;

UPDATE inv_exp_nm.p3ecologie
SET cl_pent2 =
CASE
    WHEN pent2 IS NULL THEN 'XX'
    WHEN FLOOR(0.2 * pent2) > 20 THEN '20'
    ELSE TO_CHAR(FLOOR(0.2 * pent2), 'FM09')
END
WHERE incref = 18;

-- ajout et calcul de la donnée CONTXT
WITH contexte AS (
    SELECT e.npp, 
    r.dom_biog2 
     || CASE 
            WHEN c.zp >= (r.mont_b + (r.mont_h - r.mont_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.mont_h - r.mont_b) / 2
                THEN 'M'
            WHEN c.zp >= (r.suprm_b + (r.suprm_h - r.suprm_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.suprm_h - r.suprm_b) / 2
                THEN 'S'
            WHEN r.dom_biog2 = 'M'
                THEN 'X'
            ELSE 'C'
        END
     || CASE
            WHEN e.pcalc IN (0, 1, 2, 3, 4) OR (g.gmode IN ('5', '6', '7', '8') AND (e.prof2 <= 6 OR e.affroc >= 6 OR e.cailloux >= 6))
                THEN 'C'
            ELSE 'A'
        END
     || CASE
            WHEN e.tsol IN ('82', '83', '85') OR e.ppseudo IN (0, 1, 2, 3) OR e.pgley IN (0, 1, 2, 3)
                THEN 'H'
            ELSE 'S'
        END AS contxt
    FROM inv_exp_nm.p3ecologie e
    INNER JOIN inv_exp_nm.e1coord c ON e.npp = c.npp
    INNER JOIN inv_exp_nm.e2point p ON e.npp = p.npp
    INNER JOIN prod_exp.regn_limtag R ON p.regn = r.regn
    LEFT JOIN MetaIFN.abgroupe g ON g.unite = 'ROCHED0' AND g.gunite = 'ROCHED1' AND e.roche = g.mode
)
UPDATE inv_exp_nm.p3ecologie ec
SET contxt =  c.contxt
FROM contexte c
WHERE ec.npp = c.npp
AND ec.incref = 18;

COMMIT;

VACUUM ANALYZE inv_exp_nm.p3ecologie;



-- CALCUL DES INDICATEURS INSENSE PAR ÉLÉMENTS
-- calcul en forêt
DROP TABLE IF EXISTS indic_elem;

CREATE TEMPORARY TABLE indic_elem AS
SELECT e.npp, e.incref, 'foret' AS domaine
, CASE 
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('31', '30', '47', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('31', '30', '47', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL) AND humus IN ('15', '25', '26', '42') THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
            AND greco IN ('E', 'H') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
            AND greco NOT IN ('E', 'H') 
        THEN 'S2'
    ELSE NULL
  END AS insense_ca
, CASE
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('J', 'K') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'F4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('30', '31', '47', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
        THEN 'F5'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext IS NULL)
                OR (htext = '0'
                    AND text1 = '0'
                    AND text2 = '0')
                OR (htext = '2'
                    AND text1 IN ('0', '4', '8', '1', '2', '3'))
                OR (htext = '1'
                    AND text2 IN ('0', '4', '8', '1', '2', '3'))
                ) 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('40', '45', '49') 
        THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('30', '31', '47', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND greco IN ('I', 'J', 'K') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND greco NOT IN ('I', 'J', 'K')
        THEN 'S2'
    ELSE NULL
  END AS insense_mg
, CASE
    WHEN htext IS NULL THEN 'IT'
    WHEN htext = '0' THEN 'IC'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55') AND (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) THEN 'F1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
        THEN 'F2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'E', 'G', 'H', 'I', 'J') 
        THEN 'F3'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'D', 'F', 'K') 
        THEN 'M1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2'
                    AND text1 IN ('4', '8'))
                OR (htext = '1'
                    AND text2 IN ('4', '8')))
            AND greco IN ('C', 'G') 
        THEN 'F4'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2'
            AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('A', 'D', 'E', 'I', 'J', 'K') 
        THEN 'M2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('B', 'F', 'H') 
        THEN 'S1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'G') 
        THEN 'F5'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('D', 'E', 'K') 
        THEN 'M3'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'H', 'I', 'J') 
        THEN 'S2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S6'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    WHEN humus IN ('20', '22', '29') AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) THEN 'F6'
    WHEN humus IN ('20', '22', '29') AND ((htext = '2' AND text1 <> '7') OR (htext = '1' AND text2 <> '7')) THEN 'S3'
    WHEN humus IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('7', '5', '6')) OR (htext = '1' AND text2 IN ('7', '5', '6'))) 
        THEN 'M4'
    WHEN humus IN ('15', '25', '26', '42')
            AND ((htext = '2' AND text1 NOT IN ('7', '5', '6')) OR (htext = '1' AND text2 NOT IN ('7', '5', '6'))) 
        THEN 'S4'
    WHEN ((htext = '2' AND text1 <> '9') OR (htext = '1' AND text2 <> '9'))
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
        THEN 'S5'
    ELSE NULL
  END AS insense_k
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN humus IN ('80') THEN 'S0'
    WHEN ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) THEN 'F1'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'D', 'E', 'G', 'H', 'I') 
        THEN 'F2'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'F', 'J', 'K') 
        THEN 'M1'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('E', 'G', 'H', 'I') 
        THEN 'F3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('A', 'C', 'D', 'J', 'K') 
        THEN 'M2'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1'  AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus IN ('50', '55') 
        THEN 'M3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus NOT IN ('50', '55') 
        THEN 'S1'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco = 'G' 
        THEN 'F4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'D', 'E', 'H', 'I', 'K') 
        THEN 'M4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'J') 
        THEN 'S2'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_p
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') AND humus NOT IN ('15', '25', '26', '42') THEN 'IT'
    WHEN humus = '80' THEN 'S0'
    WHEN humus IN ('15', '25', '26', '42') THEN 'F1'
    WHEN greco = 'G' AND humus IN ('20', '22', '29') THEN 'F2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco = 'F' 
        THEN 'M1'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco <> 'F' 
        THEN 'F3'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco IN ('F', 'I', 'J') 
        THEN 'M2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco NOT IN ('F', 'I', 'J') 
        THEN 'F4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'M3'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco NOT IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'F5'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('E', 'H', 'A') 
        THEN 'F6'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco = 'B' 
        THEN 'S1'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco NOT IN ('E', 'H', 'A', 'B') 
        THEN 'M4'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'S2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco NOT IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'M5'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_n
FROM inv_exp_nm.g3ecologie e
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.incref = 18
ORDER BY npp;

-- calcul en peupleraie
INSERT INTO indic_elem
SELECT e.npp, e.incref, 'foret' AS domaine
, CASE 
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('31', '30', '47', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('31', '30', '47', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL) AND humus IN ('15', '25', '26', '42') THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
            AND greco IN ('E', 'H') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
            AND greco NOT IN ('E', 'H') 
        THEN 'S2'
    ELSE NULL
  END AS insense_ca
, CASE
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('J', 'K') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('50', '55', '40', '45', '49') 
        THEN 'F4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('30', '31', '47', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
        THEN 'F5'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext IS NULL)
                OR (htext = '0'
                    AND text1 = '0'
                    AND text2 = '0')
                OR (htext = '2'
                    AND text1 IN ('0', '4', '8', '1', '2', '3'))
                OR (htext = '1'
                    AND text2 IN ('0', '4', '8', '1', '2', '3'))
                ) 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('40', '45', '49') 
        THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('30', '31', '47', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND greco IN ('I', 'J', 'K') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND greco NOT IN ('I', 'J', 'K')
        THEN 'S2'
    ELSE NULL
  END AS insense_mg
, CASE
    WHEN htext IS NULL THEN 'IT'
    WHEN htext = '0' THEN 'IC'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55') AND (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) THEN 'F1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
        THEN 'F2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'E', 'G', 'H', 'I', 'J') 
        THEN 'F3'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'D', 'F', 'K') 
        THEN 'M1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2'
                    AND text1 IN ('4', '8'))
                OR (htext = '1'
                    AND text2 IN ('4', '8')))
            AND greco IN ('C', 'G') 
        THEN 'F4'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2'
            AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('A', 'D', 'E', 'I', 'J', 'K') 
        THEN 'M2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('B', 'F', 'H') 
        THEN 'S1'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'G') 
        THEN 'F5'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('D', 'E', 'K') 
        THEN 'M3'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'H', 'I', 'J') 
        THEN 'S2'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S6'
    WHEN humus IN ('30', '31', '40', '45', '47', '48', '49', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    WHEN humus IN ('20', '22', '29') AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) THEN 'F6'
    WHEN humus IN ('20', '22', '29') AND ((htext = '2' AND text1 <> '7') OR (htext = '1' AND text2 <> '7')) THEN 'S3'
    WHEN humus IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('7', '5', '6')) OR (htext = '1' AND text2 IN ('7', '5', '6'))) 
        THEN 'M4'
    WHEN humus IN ('15', '25', '26', '42')
            AND ((htext = '2' AND text1 NOT IN ('7', '5', '6')) OR (htext = '1' AND text2 NOT IN ('7', '5', '6'))) 
        THEN 'S4'
    WHEN ((htext = '2' AND text1 <> '9') OR (htext = '1' AND text2 <> '9'))
            AND humus NOT IN ('30', '31', '40', '45', '47', '48', '49', '50', '55', '15', '25', '26', '42')
        THEN 'S5'
    ELSE NULL
  END AS insense_k
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN humus IN ('80') THEN 'S0'
    WHEN ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) THEN 'F1'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'D', 'E', 'G', 'H', 'I') 
        THEN 'F2'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'F', 'J', 'K') 
        THEN 'M1'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('E', 'G', 'H', 'I') 
        THEN 'F3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('A', 'C', 'D', 'J', 'K') 
        THEN 'M2'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1'  AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus IN ('50', '55') 
        THEN 'M3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus NOT IN ('50', '55') 
        THEN 'S1'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco = 'G' 
        THEN 'F4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'D', 'E', 'H', 'I', 'K') 
        THEN 'M4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'J') 
        THEN 'S2'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_p
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') AND humus NOT IN ('15', '25', '26', '42') THEN 'IT'
    WHEN humus = '80' THEN 'S0'
    WHEN humus IN ('15', '25', '26', '42') THEN 'F1'
    WHEN greco = 'G' AND humus IN ('20', '22', '29') THEN 'F2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco = 'F' 
        THEN 'M1'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco <> 'F' 
        THEN 'F3'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco IN ('F', 'I', 'J') 
        THEN 'M2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco NOT IN ('F', 'I', 'J') 
        THEN 'F4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'M3'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco NOT IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'F5'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('E', 'H', 'A') 
        THEN 'F6'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco = 'B' 
        THEN 'S1'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco NOT IN ('E', 'H', 'A', 'B') 
        THEN 'M4'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'S2'
    WHEN humus NOT IN ('15', '25', '26', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco NOT IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'M5'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_n
FROM inv_exp_nm.p3ecologie e
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.incref = 18
ORDER BY npp;

-- ajout de la sensibilité finale
ALTER TABLE indic_elem
    ADD COLUMN insense char(2);

WITH totaux AS (
    SELECT ie.npp, e.humus, e.prof2
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'F', '')) AS nb_faible
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'M', '')) AS nb_moyen
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'S', '')) AS nb_fort
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'I', '')) AS nb_indet
    FROM indic_elem ie
    INNER JOIN inv_exp_nm.g3ecologie e USING (npp)
)
UPDATE indic_elem ie
SET insense = 
  CASE
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'F1'
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'M1'
    WHEN nb_moyen >= 3 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'M2' 
    WHEN nb_moyen >= 3 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S1'
    WHEN nb_fort >= 3 AND nb_faible = 0 AND humus NOT IN ('80') THEN 'S2'
    WHEN nb_indet >= 3 OR (nb_indet = 2 AND prof2 IS NULL) THEN 'IN'
    WHEN prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'PA'
    WHEN prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S3'
    WHEN humus IN ('80') THEN 'S4'
  END
FROM totaux t
WHERE ie.npp = t.npp;

WITH totaux AS (
    SELECT ie.npp, e.humus, e.prof2
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'F', '')) AS nb_faible
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'M', '')) AS nb_moyen
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'S', '')) AS nb_fort
    , char_length(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n)) - char_length(replace(concat(ie.insense_ca, ie.insense_mg, ie.insense_k, ie.insense_p, ie.insense_n), 'I', '')) AS nb_indet
    FROM indic_elem ie
    INNER JOIN inv_exp_nm.p3ecologie e USING (npp)
)
UPDATE indic_elem ie
SET insense = 
  CASE
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'F1'
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'M1'
    WHEN nb_moyen >= 3 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'M2' 
    WHEN nb_moyen >= 3 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S1'
    WHEN nb_fort >= 3 AND nb_faible = 0 AND humus NOT IN ('80') THEN 'S2'
    WHEN nb_indet >= 3 OR (nb_indet = 2 AND prof2 IS NULL) THEN 'IN'
    WHEN prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'PA'
    WHEN prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S3'
    WHEN humus IN ('80') THEN 'S4'
  END
FROM totaux t
WHERE ie.npp = t.npp;

UPDATE inv_exp_nm.g3ecologie e
SET insense_ca = ie.insense_ca, 
    insense_mg = ie.insense_mg, 
    insense_k = ie.insense_k, 
    insense_p = ie.insense_p, 
    insense_n = ie.insense_n, 
    insense = ie.insense
FROM indic_elem ie
WHERE e.npp = ie.npp;

UPDATE inv_exp_nm.p3ecologie e
SET insense_ca = ie.insense_ca, 
    insense_mg = ie.insense_mg, 
    insense_k = ie.insense_k, 
    insense_p = ie.insense_p, 
    insense_n = ie.insense_n, 
    insense = ie.insense
FROM indic_elem ie
WHERE e.npp = ie.npp;

DROP TABLE indic_elem;

UPDATE inv_exp_nm.p3ecologie
SET tsol22 = tsol
WHERE incref = 18;

VACUUM ANALYZE inv_exp_nm.g3ecologie;
VACUUM ANALYZE inv_exp_nm.p3ecologie;

--------------------------------------------------------------------------------------------------------------------------
----- CALCUL DE HUMUS22 ET HUMUS22H
/* 
 * On suit la note de recodage fournie par Marine Dalmasso
 */

DROP TABLE IF EXISTS new_humus;

CREATE TEMPORARY TABLE new_humus AS
SELECT e.incref, e.npp
, e.humus, e.pcalc, e.indic_humus, e.cai40
, CASE 
        WHEN c.zp >= (r.mont_b + (r.mont_h - r.mont_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.mont_h - r.mont_b) / 2
            THEN 'M'
        WHEN c.zp >= (r.suprm_b + (r.suprm_h - r.suprm_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.suprm_h - r.suprm_b) / 2
            THEN 'S'
        WHEN r.dom_biog2 = 'M'
            THEN 'X'
        ELSE 'C'
  END
AS contxt
, NULL::char(2) AS humus22
FROM inv_exp_nm.g3ecologie e
INNER JOIN inv_exp_nm.e2point p ON e.npp = p.npp
INNER JOIN inv_exp_nm.e1coord c ON e.npp = c.npp
INNER JOIN prod_exp.regn_limtag r ON p.regn = r.regn
LEFT JOIN metaifn.abgroupe g ON g.unite = 'ROCHED0' AND g.gunite = 'ROCHED1' AND e.roche = g.mode
UNION
SELECT e.incref, e.npp
, e.humus, e.pcalc, e.indic_humus, e.cai40
, CASE 
        WHEN c.zp >= (r.mont_b + (r.mont_h - r.mont_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.mont_h - r.mont_b) / 2
            THEN 'M'
        WHEN c.zp >= (r.suprm_b + (r.suprm_h - r.suprm_b) / 2) - COS(COALESCE(e.expo, 300) * PI() / 200) * (r.suprm_h - r.suprm_b) / 2
            THEN 'S'
        WHEN r.dom_biog2 = 'M'
            THEN 'X'
        ELSE 'C'
    END
AS contxt
, NULL::char(2) AS humus22
FROM inv_exp_nm.p3ecologie e
INNER JOIN inv_exp_nm.e2point p ON e.npp = p.npp
INNER JOIN inv_exp_nm.e1coord c ON e.npp = c.npp
INNER JOIN prod_exp.regn_limtag r ON p.regn = r.regn
LEFT JOIN metaifn.abgroupe g ON g.unite = 'ROCHED0' AND g.gunite = 'ROCHED1' AND e.roche = g.mode
ORDER BY incref, npp;

-- 26 - Moder calciques
UPDATE new_humus
SET humus22 = '26'
WHERE incref < 17
AND indic_humus = '7'
AND contxt = 'M'
AND (pcalc IS NULL OR pcalc > 2);


-- 49 - peyromull
UPDATE new_humus
SET humus22 = '49'
WHERE incref < 17
AND cai40 >= 8
AND (indic_humus IN ('3', '4') OR humus IN ('45', '55'));


-- 29 - Peyromoder 
UPDATE new_humus
SET humus22 = '29'
WHERE incref < 17
AND cai40 >= 8
AND (indic_humus IN ('1', '2', '7') OR humus IN ('15', '25'));


-- 47 - hydromull carbonaté
UPDATE new_humus
SET humus22 = '47'
WHERE incref < 17
AND humus = '48'
AND pcalc IN (0, 1);

-- 85 - anmoor carbonaté
UPDATE new_humus
SET humus22 = '85'
WHERE incref < 17
AND humus = '81'
AND pcalc IN (0, 1);

-- autres humus
UPDATE new_humus
SET humus22 = humus
WHERE humus22 IS NULL;


/*
SELECT count(*)
FROM new_humus nh
WHERE nh.humus22 IS NULL
AND NOT EXISTS (
    SELECT 1
    FROM metaifn.abmode a
    WHERE a.unite = 'HUMUS'
    AND a."mode" = nh.humus
);


-- mise en base d'exploitation des deux données calculées
ALTER TABLE inv_exp_nm.g3ecologie
    ADD COLUMN humus22 CHAR(2);

ALTER TABLE inv_exp_nm.p3ecologie
    ADD COLUMN humus22 CHAR(2);
*/

UPDATE inv_exp_nm.g3ecologie e
SET humus22 = nh.humus22
FROM new_humus nh
WHERE e.npp = nh.npp;

UPDATE inv_exp_nm.p3ecologie e
SET humus22 = nh.humus22
FROM new_humus nh
WHERE e.npp = nh.npp;

DROP TABLE new_humus;

-- mise à jour des métadonnées
SELECT * FROM metaifn.ajoutdonnee('HUMUS22', null, 'HUMUS22', 'IFN', NULL, 25, 'char(2)', 'LT', true, true, $$Type d'humus (version 2022)$$, $$L'humus est la couche supérieure du sol, issue de la décomposition de la matière organique (version 2022).$$);
SELECT * FROM metaifn.ajoutchamp('HUMUS22', 'g3ecologie', 'inv_exp_nm', false, 0, null, 'bpchar', 2);
SELECT * FROM metaifn.ajoutchamp('HUMUS22', 'p3ecologie', 'inv_exp_nm', false, 11, null, 'bpchar', 2);


UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'tg3ecologie'
AND donnee ~* 'humus22'; -- met à jour les 2 nouvelles données en 1 requête avec un seul ~

UPDATE metaifn.afchamp
SET calcin = 11, calcout = 18, validin = 11, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'tp3ecologie'
AND donnee ~* 'humus22'; -- met à jour les 2 nouvelles données en 1 requête avec un seul ~




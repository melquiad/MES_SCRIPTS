
--- DOCUMENTATION dans METAIFN

-- Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('RU_AF', NULL, 'mm', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE
, 'Réserve utile (avec affleurement rocheux)'
, 'Indice de réserve utile en eau du sol du point d inventaire, calculé en tenant compte de la présence d affleurement rocheux, selon la formule : (10-AFFROC)*(10 - CAILLOUX) * ( (PROF1 * coef associé à TEXT1) + ( (PROF2 - PROF1) * coef associé à TEXT2) )/10'
,'Donnée mobilisée dans les indices écologiques fournis en ligne');

-- Documentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('RU_AF', 'G3FORET', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);
SELECT * FROM metaifn.ajoutchamp('RU_AF', 'P3POINT', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);

--- RECOPIE de U_RU_AF depuis u_g3foret vers RU_AF dans g3foret
-- création de la colonne en base
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN ru_af FLOAT8;

UPDATE inv_exp_nm.g3foret f
SET ru_af = ug.u_ru_af 
FROM inv_exp_nm.u_g3foret ug
WHERE f.npp = ug.npp;

--- RECOPIE de U_RU_AF depuis u_p3point vers RU_AF dans p3point
-- création de la colonne en base
ALTER TABLE inv_exp_nm.p3point ADD COLUMN ru_af FLOAT8;

UPDATE inv_exp_nm.p3point p
SET ru_af = up.u_ru_af 
FROM inv_exp_nm.u_p3point up
WHERE p.npp = up.npp;


--------------------------------------------------------
-- Mise à jour de RU_AF 
BEGIN;

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
-- En forêt
SET enable_nestloop = FALSE;

SELECT incref, COUNT(ru_af)
FROM inv_exp_nm.g3foret
--WHERE incref BETWEEN 13 AND 18
GROUP BY incref
ORDER BY incref DESC;

UPDATE inv_exp_nm.g3foret f
SET ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.g3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.g3ecologie e ON t.npp = e.npp
WHERE f.npp = t.npp
AND e.incref = 18;

/*
SELECT npp, ru_af
FROM inv_exp_nm.g3foret
WHERE incref = 18 AND ru_af IS NULL;
*/

-- En peupleraie

SELECT INCREF, COUNT(RU_AF)
FROM inv_exp_nm.p3point
GROUP BY INCREF
ORDER BY INCREF DESC;


UPDATE inv_exp_nm.p3point f
SET ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.p3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.p3ecologie e ON t.npp = e.npp
WHERE f.npp = t.npp
AND e.incref = 18;

/*
SELECT npp, ru_af
FROM inv_exp_nm.p3point
WHERE incref = 18 AND ru_af IS NULL;
*/

DROP TABLE textu;

UPDATE metaifn.afchamp
SET calcout = 18, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'ru_af';

COMMIT;

-------------------------------------------------------------------------------------------------
------------------------------------ CREATION DE RUT_AF -----------------------------------------
-------------------------------------------------------------------------------------------------
--- DOCUMENTATION dans METAIFN

-- Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('RUT_AF', NULL, 'RUT', 'IFN', NULL, 0, 'char(2)', 'CC', TRUE, TRUE
, 'Réserve utile avec affleurement rocheux'
, 'Ce calcul de la réserve utile prend en compte la proportion des affleurements rocheux présents sur la placette.');


-- Documentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('RUT_AF', 'G3FORET', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);
SELECT * FROM metaifn.ajoutchamp('RUT_AF', 'P3POINT', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);

-- création des colonnes en base
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN rut_af char(2);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN rut_af char(2);

/*
SELECT * FROM metaifn.addonnee WHERE donnee = 'U_RUT_AF';
SELECT * FROM metaifn.afchamp WHERE donnee = 'U_RUT_AF';
SELECT * FROM metaifn.abmode WHERE unite = 'RUT';
*/

--- RECOPIE de U_RUT_AF depuis u_g3foret vers RUT_AF dans g3foret
BEGIN;

UPDATE inv_exp_nm.g3foret f
SET rut_af = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN ru_af < 10 THEN '1'
    WHEN ru_af < 30 THEN '2'
    WHEN ru_af < 50 THEN '3'
    WHEN ru_af < 70 THEN '4'
    WHEN ru_af < 90 THEN '5'
    WHEN ru_af < 110 THEN '6'
    WHEN ru_af < 130 THEN '7'
    WHEN ru_af < 150 THEN '8'
    WHEN ru_af < 170 THEN '9'
    WHEN ru_af < 190 THEN '10'
    WHEN ru_af >= 190 THEN '11'
END
FROM inv_exp_nm.u_g3foret ug
INNER JOIN inv_exp_nm.g3ecologie ge USING (npp)
WHERE f.npp = ug.npp;


SELECT incref, COUNT(rut_af)
FROM inv_exp_nm.g3foret
GROUP BY incref ORDER BY incref DESC;

UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'rut_af'
AND FORMAT = 'G3FORET';

COMMIT;

--------------------------------------------------------
-- Calcul de RUT_AF en peupleraie - increfs 11 à 18 --
--------------------------------------------------------

BEGIN;

--- RECOPIE de U_RUT_AF depuis u_p3point vers RUT_AF dans p3point

UPDATE inv_exp_nm.p3point p3p
SET rut_af = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN ru_af < 10 THEN '1'
    WHEN ru_af < 30 THEN '2'
    WHEN ru_af < 50 THEN '3'
    WHEN ru_af < 70 THEN '4'
    WHEN ru_af < 90 THEN '5'
    WHEN ru_af < 110 THEN '6'
    WHEN ru_af < 130 THEN '7'
    WHEN ru_af < 150 THEN '8'
    WHEN ru_af < 170 THEN '9'
    WHEN ru_af < 190 THEN '10'
    WHEN ru_af >= 190 THEN '11'
END
FROM inv_exp_nm.u_p3point up
INNER JOIN inv_exp_nm.p3ecologie e USING (npp)
WHERE p3p.npp = e.npp and p3p.incref >= 11;

SELECT incref, COUNT(rut_af)
FROM inv_exp_nm.p3point
GROUP BY incref ORDER BY incref DESC;


UPDATE metaifn.afchamp
SET calcin = 11, calcout = 18, validin = 11, validout = 18, defout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'rut_af'
AND FORMAT = 'P3POINT';

COMMIT;

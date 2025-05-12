-- Mise à jour de U_RU_AF pour incref 19
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
SELECT INCREF, COUNT(U_RU_AF)
FROM inv_exp_nm.u_g3foret
GROUP BY INCREF ORDER BY INCREF DESC;


UPDATE inv_exp_nm.u_g3foret f
SET u_ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.g3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.g3ecologie e ON t.npp = e.npp
WHERE f.npp = t.npp
AND e.incref = 19;

UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 19, validin = 0, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'u_ru_af'
AND format = 'U_G3FORET';

/*
SELECT npp, u_ru_af
FROM inv_exp_nm.u_g3foret
WHERE incref = 19 AND u_ru_af IS NULL;
*/

-- En peupleraie
/*
SELECT npp, u_ru_af
FROM inv_exp_nm.u_p3point
WHERE incref = 19 AND u_ru_af IS NULL;
*/

SELECT INCREF, COUNT(U_RU_AF)
FROM inv_exp_nm.u_p3point
GROUP BY INCREF ORDER BY INCREF DESC;


UPDATE inv_exp_nm.u_p3point f
SET u_ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.p3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.p3ecologie e ON t.npp = e.npp
WHERE f.npp = t.npp
AND e.incref = 19;

DROP TABLE textu;

UPDATE metaifn.afchamp
SET defin = 11, defout = NULL, calcin = 11, calcout = 19, validin = 11, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'u_ru_af'
AND format = 'U_P3POINT';

COMMIT;


--********************************************************************************************--
-- Mise à jour de U_RUT_AF pour incref 19

-- en forêt

BEGIN;
ROLLBACK;

SELECT INCREF, COUNT(U_RUT_AF)
FROM INV_EXP_NM.U_G3FORET
GROUP BY INCREF ORDER BY INCREF DESC;

UPDATE inv_exp_nm.u_g3foret f
SET u_rut_af = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN u_ru_af < 10 THEN '1'
    WHEN u_ru_af < 30 THEN '2'
    WHEN u_ru_af < 50 THEN '3'
    WHEN u_ru_af < 70 THEN '4'
    WHEN u_ru_af < 90 THEN '5'
    WHEN u_ru_af < 110 THEN '6'
    WHEN u_ru_af < 130 THEN '7'
    WHEN u_ru_af < 150 THEN '8'
    WHEN u_ru_af < 170 THEN '9'
    WHEN u_ru_af < 190 THEN '10'
    WHEN u_ru_af >= 190 THEN '11'
END
FROM inv_exp_nm.g3ecologie e
WHERE f.npp = e.npp and f.incref = 19;


UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 19, validin = 0, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'u_rut_af'
AND format = 'U_G3FORET';

COMMIT;

-- en peupleraie 

BEGIN;
/*
ALTER TABLE inv_exp_nm.u_p3point
    ADD COLUMN u_rut_af CHAR(2);*/

COMMIT;

-- Mise à jour de U_RUT_AF pour incref 18
BEGIN;
ROLLBACK;

SELECT INCREF, COUNT(U_RUT_AF)
FROM INV_EXP_NM.U_P3POINT
GROUP BY INCREF ORDER BY INCREF DESC;

UPDATE inv_exp_nm.u_p3point p3p
SET u_rut_af = 
CASE 
    WHEN prof2 IS NULL OR (cailloux IS NULL AND obspedo = '5') THEN 'X'
    WHEN u_ru_af < 10 THEN '1'
    WHEN u_ru_af < 30 THEN '2'
    WHEN u_ru_af < 50 THEN '3'
    WHEN u_ru_af < 70 THEN '4'
    WHEN u_ru_af < 90 THEN '5'
    WHEN u_ru_af < 110 THEN '6'
    WHEN u_ru_af < 130 THEN '7'
    WHEN u_ru_af < 150 THEN '8'
    WHEN u_ru_af < 170 THEN '9'
    WHEN u_ru_af < 190 THEN '10'
    WHEN u_ru_af >= 190 THEN '11'
END
FROM inv_exp_nm.p3ecologie e
WHERE p3p.npp = e.npp and p3p.incref = 19;

COMMIT;

BEGIN;
/*
SELECT * 
FROM metaifn.ajoutchamp('U_RUT_AF', 'U_P3POINT', 'INV_EXP_NM',
FALSE, 11, 18, 'bpchar', 2);*/

COMMIT;

BEGIN;

UPDATE metaifn.afchamp
SET defin = 11, defout = NULL, calcin = 11, calcout = 19, validin = 11, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'u_rut_af'
AND format = 'U_P3POINT';

COMMIT;


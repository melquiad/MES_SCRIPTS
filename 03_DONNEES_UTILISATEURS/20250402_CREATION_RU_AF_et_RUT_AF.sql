BEGIN;

ALTER TABLE inv_exp_nm.g3foret ADD COLUMN ru_af FLOAT8;
ALTER TABLE inv_exp_nm.p3point ADD COLUMN ru_af FLOAT8;
	-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3foret ADD COLUMN ru_af FLOAT8;
ALTER FOREIGN TABLE inv_exp_nm.p3point ADD COLUMN ru_af FLOAT8;


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
	-- en forêt
UPDATE inv_exp_nm.g3foret f
SET ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.g3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.g3ecologie e ON t.npp = e.npp
WHERE f.npp = t.npp;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 19, validin = 0, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'ru_af'
AND format = 'TG3FORET';


	-- en peupleraie
UPDATE inv_exp_nm.p3point p
SET ru_af = (10 - COALESCE(e.affroc, 0))::REAL / 10.0 * (10.0 - COALESCE(e.cailloux, 0)::REAL) * (COALESCE(prof1, 0) * ntext1  + (COALESCE(prof2, 0)- COALESCE(prof1, 0))::REAL * ntext2)
FROM (
    SELECT npp, COALESCE(t1.coef, 0)::REAL AS ntext1, COALESCE(t2.coef, 0)::REAL AS ntext2
    FROM inv_exp_nm.p3ecologie e
    LEFT JOIN textu t1 ON e.text1g = t1.textu
    LEFT JOIN textu t2 ON e.text2g = t2.textu
) t
INNER JOIN inv_exp_nm.p3ecologie e ON t.npp = e.npp
WHERE p.npp = t.npp;

DROP TABLE textu;


SELECT * FROM metaifn.ajoutdonnee('RU_AF', NULL, 'mm', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, $$Réserve utile avec affleurement rocheux$$, $$Ce calcul de la réserve utile prend en compte la proportion d'affleurements rocheux présents sur la placette. $$);

SELECT * FROM metaifn.ajoutchamp('RU_AF', 'G3FORET', 'INV_EXP_NM', FALSE, 0, NULL, 'float8', 8);
SELECT * FROM metaifn.ajoutchamp('RU_AF', 'P3POINT', 'INV_EXP_NM', FALSE, 0, NULL, 'float8', 8);


UPDATE metaifn.afchamp
SET calcin = 11, calcout = 19, validin = 11, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'ru_af'
AND format = 'TP3POINT';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'RU_AF');


COMMIT;

--------------------------------------------------------------------------------------------
-- discrétisation de la réserve utile
BEGIN;


ALTER TABLE inv_exp_nm.g3foret ADD COLUMN rut_af CHAR(2);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN rut_af CHAR(2);
	-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3foret ADD COLUMN rut_af CHAR(2);
ALTER FOREIGN TABLE inv_exp_nm.p3point ADD COLUMN rut_af CHAR(2);


	-- en forêt
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
FROM inv_exp_nm.g3ecologie e
WHERE f.npp = e.npp;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 19, validin = 0, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'rut_af'
AND format = 'TG3FORET';


	-- en peupleraie
UPDATE inv_exp_nm.p3point p
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
FROM inv_exp_nm.p3ecologie e
WHERE p.npp = e.npp;

SELECT * FROM metaifn.ajoutdonnee('RUT_AF', NULL, 'RUT', 'IFN', NULL, 0, 'char(2)', 'CC', TRUE, TRUE, $$Réserve utile avec affleurement rocheux$$, $$Ce calcul de la réserve utile prend en compte la proportion des affleurements rocheux présents sur la placette.$$);

SELECT * FROM metaifn.ajoutchamp('RUT_AF', 'G3FORET', 'INV_EXP_NM', FALSE, 0, NULL, 'bpchar', 2);
SELECT * FROM metaifn.ajoutchamp('RUT_AF', 'P3POINT', 'INV_EXP_NM', FALSE, 0, NULL, 'bpchar', 2);

UPDATE metaifn.afchamp
SET calcin = 11, calcout = 19, validin = 11, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'rut_af'
AND format = 'TP3POINT';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'RUT_AF');

COMMIT;



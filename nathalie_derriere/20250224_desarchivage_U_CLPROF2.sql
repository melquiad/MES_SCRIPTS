
/*BEGIN;

-- partie unite
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_CLPROF2', 'AUTRE', 'NOMINAL', 'Classe de profondeur de sondage', 'Classe de profondeur de l horizon inférieur du sol à deux textures différenciées ou de l horizon unique du sol à une texture (10 classes)');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_CLPROF2', '1', 1, 1, 1, '0', 'Profondeur de sondage entre 0 (inclus) et 0,5 dm (exclu)')
, ('U_CLPROF2', '2', 2, 2, 1, '1', 'Profondeur de sondage entre 0,5 (inclus) et 1,5 dm (exclu)')
, ('U_CLPROF2', '3', 3, 3, 1, '2', 'Profondeur de sondage entre 1,5 (inclus) et 2,5 dm (exclu)')
, ('U_CLPROF2', '4', 4, 4, 1, '3', 'Profondeur de sondage entre 2,5 (inclus) et 3,5 dm (exclu)')
, ('U_CLPROF2', '5', 5, 5, 1, '4', 'Profondeur de sondage entre 3,5 (inclus) et 4,5 dm (exclu)')
, ('U_CLPROF2', '6', 6, 6, 1, '5', 'Profondeur de sondage entre 4,5 (inclus) et 5,5 dm (exclu)')
, ('U_CLPROF2', '7', 7, 7, 1, '6', 'Profondeur de sondage entre 5,5 (inclus) et 6,5 dm (exclu)')
, ('U_CLPROF2', '8', 8, 8, 1, '7', 'Profondeur de sondage entre 6,5 (inclus) et 7,5 dm (exclu)')
, ('U_CLPROF2', '9', 9, 9, 1, '8', 'Profondeur de sondage entre 7,5 (inclus) et 8,5 dm (exclu)')
, ('U_CLPROF2', '10', 10, 10, 1, '9', 'Profondeur de sondage supérieure ou égale à 8,5')
;

-- partie donnee
SELECT *
FROM metaifn.ajoutdonnee('U_CLPROF2', NULL, 'U_CLPROF2', 'AUTRE'
, NULL, 10, 'char(1)', 'CC', TRUE, TRUE, 'Classe de profondeur de sondage', 'Classe de profondeur de l horizon inférieur du sol à deux textures différenciées ou de l horizon unique du sol à une texture (10 classes)');

*/
-- Partie champ
DELETE FROM metaifn.afcalcul WHERE champ = 9021;
DELETE FROM metaifn.afchamp WHERE donnee = 'U_CLPROF2';

SELECT * 
FROM metaifn.ajoutchamp('U_CLPROF2', 'U_G3FORET', 'INV_EXP_NM', FALSE, 8, 12, 'bpchar', 1);

UPDATE metaifn.afchamp
SET defin = 0, calcin = 0, calcout = 18, validin = 0, validout = 18
WHERE famille = 'INV_EXP_NM' AND format = 'U_G3FORET'
AND donnee = 'U_CLPROF2';


SELECT * 
FROM metaifn.ajoutchamp('U_CLPROF2', 'U_P3POINT', 'INV_EXP_NM', FALSE, 11, 12, 'bpchar', 1);

UPDATE metaifn.afchamp
SET defin = 11, calcin = 11, calcout = 18, validin = 11, validout = 18
WHERE famille = 'INV_EXP_NM' AND format = 'U_P3POINT'
AND donnee = 'U_CLPROF2';


--controle
SELECT *
FROM metaifn.afchamp
WHERE famille='INV_EXP_NM'
AND format='U_G3FORET'
ORDER BY position desc;


-- recréation du champ dans la table
ALTER TABLE inv_exp_nm.u_g3foret
    ADD COLUMN U_CLPROF2 CHAR(1);

ALTER TABLE inv_exp_nm.u_p3point
    ADD COLUMN U_CLPROF2 CHAR(1);
	
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('XYLODENSMAP', 'U_CLPROF2');



-- MAJ
BEGIN;

UPDATE inv_exp_nm.u_g3foret f
SET U_CLPROF2 = 
CASE 
	WHEN e.prof2 IS NULL THEN NULL
	WHEN e.prof2 < 0.5 THEN '0'
	WHEN e.prof2 < 1.5 THEN '1'
	WHEN e.prof2 < 2.5 THEN '2'
	WHEN e.prof2 < 3.5 THEN '3'
	WHEN e.prof2 < 4.5 THEN '4'
	WHEN e.prof2 < 5.5 THEN '5'
	WHEN e.prof2 < 6.5 THEN '6'
	WHEN e.prof2 < 7.5 THEN '7'
	WHEN e.prof2 < 8.5 THEN '8'
	ELSE '9'
END
FROM inv_exp_nm.g3ecologie e
WHERE f.npp = e.npp


UPDATE inv_exp_nm.u_p3point p
SET U_CLPROF2 = 
CASE 
	WHEN e.prof2 IS NULL THEN NULL
	WHEN e.prof2 < 0.5 THEN '0'
	WHEN e.prof2 < 1.5 THEN '1'
	WHEN e.prof2 < 2.5 THEN '2'
	WHEN e.prof2 < 3.5 THEN '3'
	WHEN e.prof2 < 4.5 THEN '4'
	WHEN e.prof2 < 5.5 THEN '5'
	WHEN e.prof2 < 6.5 THEN '6'
	WHEN e.prof2 < 7.5 THEN '7'
	WHEN e.prof2 < 8.5 THEN '8'
	ELSE '9'
END
FROM inv_exp_nm.p3ecologie e
WHERE p.npp = e.npp


--controle 
SELECT npp, U_CLPROF2
FROM inv_exp_nm.u_g3foret
WHERE U_CLPROF2 IS NOT NULL;

SELECT npp, U_CLPROF2
FROM inv_exp_nm.u_p3point
WHERE U_CLPROF2 IS NOT NULL;


COMMIT;
ROLLBACK;

/*-----------------------------------------------------------------
-- désarchivage --> ici il a fallu recréer la donnee
UPDATE metaifn.afchamp
SET format = 'U_G3ARBRE', famille = 'INV_EXP_NM' 
WHERE famille = 'ARCHIVE'
AND format = 'ARCHIVE'
AND donnee = 'U_CLPROF2';
*/

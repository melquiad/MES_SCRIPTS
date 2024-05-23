-- METADONNEES
BEGIN;

-- 1.Documentation de l’unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_GINI_CL', 'AUTRE', 'NOMINAL', 'Coefficient de Gini discrétisé', 'Discrétisation du coefficient de Gini en classes de dixièmes');

-- 2.Documentation des modalités
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_GINI_CL', '0', 1, 1, 1, '0', '0, tous les arbres ont la même surface terrière')
, ('U_GINI_CL', '1', 2, 2, 1, '0 à 0.1', '0 (exclu) à 0.1 (exclu)')
, ('U_GINI_CL', '2', 3, 3, 1, '0.1 à 0.2', '0.1 (inclus) à 0.2 (exclu)')
, ('U_GINI_CL', '3', 4, 4, 1, '0.2 à 0.3', '0.2 (inclus) à 0.3 (exclu)')
, ('U_GINI_CL', '4', 5, 5, 1, '0.3 à 0.4', '0.3 (inclus) à 0.4 (exclu)')
, ('U_GINI_CL', '5', 6, 6, 1, '0.4 à 0.5', '0.4 (inclus) à 0.5 (exclu)')
, ('U_GINI_CL', '6', 7, 7, 1, '0.5 à 0.6', '0.5 (inclus) à 0.6 (exclu)')
, ('U_GINI_CL', '7', 8, 8, 1, '0.6 à 0.7', '0.6 (inclus) à 0.7 (exclu)')
, ('U_GINI_CL', '8', 9, 9, 1, '0.7 à 0.8', '0.7 (inclus) à 0.8 (exclu)')
, ('U_GINI_CL', '9', 10, 10, 1, '0.8 à 0.9', '0.8 (inclus) à 0.9 (exclu)')
, ('U_GINI_CL', '10', 11, 11, 1, '0.9 à 1', '0.9 (inclus) à 1 (exclu)')
, ('U_GINI_CL', '11', 12, 12, 1, '1', 'Coefficient de Gini égal à 1')
, ('U_GINI_CL', '12', 13, 13, 1, 'X', 'Coefficient de Gini non calculable')
;

COMMIT;

-- 3.Documentation de la donnée
BEGIN;

SELECT * FROM metaifn.ajoutdonnee('U_GINI_CL', NULL, 'U_GINI_CL', 'AUTRE', NULL, 6, 'varchar(2)', 'CC', TRUE, TRUE, 
'Coefficient de Gini discrétisé', 
'Discrétisation du coefficient de Gini en classes de dixièmes, qui représente l''hétérogénéité dans la distribution des surfaces terrières au sein de la placette.');

-- 4.Documentation de la colonne en base
SELECT *  FROM metaifn.ajoutchamp('U_GINI_CL', 'U_G3FORET', 'INV_EXP_NM', FALSE, 0, 17, 'varchar', 2);

UPDATE metaifn.afchamp 
SET calcin = 0, calcout = 17, validin = 0, validout = 17, defin = 0, defout = NULL  
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_GINI_CL';

SELECT *
FROM metaifn.afchamp 
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_GINI_CL';

-- 5. Affectation à un groupe d'utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('LIF', 'U_GINI_CL');

COMMIT;


-- CALCUL DE LA DONNEE EN FORET DE PRODUCTION
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.u_g3foret ADD COLUMN U_GINI_CL character(2); 
COMMENT ON COLUMN inv_exp_nm.u_g3foret.U_GINI_CL IS 'Coefficient de Gini discrétisé';

COMMIT;

-- DEFINITION DES DIFFERENTES CLASSES, SELON LA VALEUR INITIALE DE U_GINI

BEGIN;

UPDATE inv_exp_nm.u_g3foret AS ug3f
SET U_GINI_CL =
	CASE
		WHEN U_GINI = 0 THEN '0'
		WHEN U_GINI > 0 AND U_GINI < 0.1 THEN '1'
		WHEN U_GINI >= 0.1 AND U_GINI < 0.2 THEN '2'
		WHEN U_GINI >= 0.2 AND U_GINI < 0.3 THEN '3'
		WHEN U_GINI >= 0.3 AND U_GINI < 0.4 THEN '4'
		WHEN U_GINI >= 0.4 AND U_GINI < 0.5 THEN '5'
		WHEN U_GINI >= 0.5 AND U_GINI < 0.6 THEN '6'
		WHEN U_GINI >= 0.6 AND U_GINI < 0.7 THEN '7'
		WHEN U_GINI >= 0.7 AND U_GINI < 0.8 THEN '8'
		WHEN U_GINI >= 0.8 AND U_GINI < 0.9 THEN '9'
		WHEN U_GINI >= 0.9 AND U_GINI < 1 THEN '10'
		WHEN U_GINI = 1 THEN '11'
		ELSE 'X'
	END;

-- Contrôle
SELECT NPP, INCREF, U_GINI, U_GINI_CL
FROM inv_exp_nm.u_g3foret
-- WHERE U_GINI_CL IS NOT NULL
ORDER BY INCREF, NPP;

COMMIT;
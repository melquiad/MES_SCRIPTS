-- Création donnée U_TAILMASSIF
-- Calcul de la taille des massifs

-- Documentation de l'unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_TAILMASSIF', 'AUTRE', 'NOMINAL', 'Classes de surface', 'Classes de surface');

-- 2.Documentation des modalités
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_TAILMASSIF', '00', 1, 1, 2, 'inférieur à 2,25 ha', 'Massif inférieur à 2,25 ha')
, ('U_TAILMASSIF', '01', 2, 2, 2, 'entre 2,25 et 4 ha', 'Massif entre 2,25 (inclus) et 4 ha (exclu)')
, ('U_TAILMASSIF', '02', 3, 3, 2, 'entre 4 et 25 ha', 'Massif entre 4 (inclus) et 25 ha (exclu)')
, ('U_TAILMASSIF', '03', 4, 4, 2, 'entre 25 et 50 ha', 'Massif entre 25 (inclus) et 50 ha (exclu)')
, ('U_TAILMASSIF', '04', 5, 5, 2, 'entre 50 et 100 ha', 'Massif entre 50 (inclus) et 100 ha (exclu)')
, ('U_TAILMASSIF', '05', 6, 6, 2, 'entre 100 et 200 ha', 'Massif entre 100 (inclus) et 200 ha (exclu)')
, ('U_TAILMASSIF', '06', 7, 7, 2, 'entre 200 et 300 ha', 'Massif entre 200 (inclus) et 300 ha (exclu)')
, ('U_TAILMASSIF', '07', 8, 8, 2, 'entre 300 et 400 ha', 'Massif entre 300 (inclus) et 400 ha (exclu)')
, ('U_TAILMASSIF', '08', 9, 9, 2, 'entre 400 et 450 ha', 'Massif entre 400 (inclus) et 450 ha (exclu)')
, ('U_TAILMASSIF', '09', 10, 10, 2, 'entre 450 et 500 ha', 'Massif entre 450 (inclus) et 500 ha (exclu)')
, ('U_TAILMASSIF', '10', 11, 11, 2, 'entre 500 et 550 ha', 'Massif entre 500 (inclus) et 550 ha (exclu)')
, ('U_TAILMASSIF', '11', 12, 12, 2, 'entre 550 et 600 ha', 'Massif entre 550 (inclus) et 600 ha (exclu)')
, ('U_TAILMASSIF', '12', 13, 13, 2, 'entre 600 et 700 ha', 'Massif entre 600 (inclus) et 700 ha (exclu)')
, ('U_TAILMASSIF', '13', 14, 14, 2, 'entre 700 et 800 ha', 'Massif entre 700 (inclus) et 800 ha (exclu)')
, ('U_TAILMASSIF', '14', 15, 15, 2, 'entre 800 et 900 ha', 'Massif entre 800 (inclus) et 900 ha (exclu)')
, ('U_TAILMASSIF', '15', 16, 16, 2, 'entre 900 et 1 000 ha', 'Massif entre 900 (inclus) et 1 000 ha (exclu)')
, ('U_TAILMASSIF', '16', 17, 17, 2, 'entre 1 000 et 2 000 ha', 'Massif entre 1 000 (inclus) et 2 000 ha (exclu)')
, ('U_TAILMASSIF', '17', 18, 18, 2, 'entre 2 000 et 3 000 ha', 'Massif entre 2 000 (inclus) et 3 000 ha (exclu)')
, ('U_TAILMASSIF', '18', 19, 19, 2, 'entre 3 000 et 4 000 ha', 'Massif entre 3 000 (inclus) et 4 000 ha (exclu)')
, ('U_TAILMASSIF', '19', 20, 20, 2, 'entre 4 000 et 4 500 ha', 'Massif entre 4 000 (inclus) et 4 500 ha (exclu)')
, ('U_TAILMASSIF', '20', 21, 21, 2, 'entre 4 500 et 5 000 ha', 'Massif entre 4 500 (inclus) et 5 000 ha (exclu)')
, ('U_TAILMASSIF', '21', 22, 22, 2, 'entre 5 000 et 5 500 ha', 'Massif entre 5 000 (inclus) et 5 500 ha (exclu)')
, ('U_TAILMASSIF', '22', 23, 23, 2, 'entre 5 500 et 6 000 ha', 'Massif entre 5 500 (inclus) et 6 000 ha (exclu)')
, ('U_TAILMASSIF', '23', 24, 24, 2, 'entre 6 000 et 7 000 ha', 'Massif entre 6 000 (inclus) et 7 000 ha (exclu)')
, ('U_TAILMASSIF', '24', 25, 25, 2, 'entre 7 000 et 8 000 ha', 'Massif entre 7 000 (inclus) et 8 000 ha (exclu)')
, ('U_TAILMASSIF', '25', 26, 26, 2, 'entre 8 000 et 9 000 ha', 'Massif entre 8 000 (inclus) et 9 000 ha (exclu)')
, ('U_TAILMASSIF', '26', 27, 27, 2, 'entre 9 000 et 10 000 ha', 'Massif entre 9 000 (inclus) et 10 000 ha (exclu)')
, ('U_TAILMASSIF', '27', 28, 28, 2, 'entre 10 000 et 20 000 ha', 'Massif entre 10 000 (inclus) et 20 000 ha (exclu)')
, ('U_TAILMASSIF', '28', 29, 29, 2, 'entre 20 000 et 30 000 ha', 'Massif entre 20 000 (inclus) et 30 000 ha (exclu)')
, ('U_TAILMASSIF', '29', 30, 30, 2, 'entre 30 000 et 40 000 ha', 'Massif entre 30 000 (inclus) et 40 000 ha (exclu)')
, ('U_TAILMASSIF', '30', 31, 31, 2, 'entre 40 000 et 45 000 ha', 'Massif entre 40 000 (inclus) et 45 000 ha (exclu)')
, ('U_TAILMASSIF', '31', 32, 32, 2, 'entre 45 000 et 50 000 ha', 'Massif entre 45 000 (inclus) et 50 000 ha (exclu)')
, ('U_TAILMASSIF', '32', 33, 33, 2, 'entre 50 000 et 55 000 ha', 'Massif entre 50 000 (inclus) et 55 000 ha (exclu)')
, ('U_TAILMASSIF', '33', 34, 34, 2, 'entre 55 000 et 60 000 ha', 'Massif entre 55 000 (inclus) et 60 000 ha (exclu)')
, ('U_TAILMASSIF', '34', 35, 35, 2, 'entre 60 000 et 70 000 ha', 'Massif entre 60 000 (inclus) et 70 000 ha (exclu)')
, ('U_TAILMASSIF', '35', 36, 36, 2, 'entre 70 000 et 80 000 ha', 'Massif entre 70 000 (inclus) et 80 000 ha (exclu)')
, ('U_TAILMASSIF', '36', 37, 37, 2, 'entre 80 000 et 90 000 ha', 'Massif entre 80 000 (inclus) et 90 000 ha (exclu)')
, ('U_TAILMASSIF', '37', 38, 38, 2, 'entre 90 000 et 100 000 ha', 'Massif entre 90 000 (inclus) et 100 000 ha (exclu)')
, ('U_TAILMASSIF', '38', 39, 39, 2, 'entre 100 000 et 200 000 ha', 'Massif entre 100 000 (inclus) et 200 000 ha (exclu)')
, ('U_TAILMASSIF', '39', 40, 40, 2, 'entre 200 000 et 300 000 ha', 'Massif entre 200 000 (inclus) et 300 000 ha (exclu)')
, ('U_TAILMASSIF', '40', 41, 41, 2, 'entre 300 000 et 400 000 ha', 'Massif entre 300 000 (inclus) et 400 000 ha (exclu)')
, ('U_TAILMASSIF', '41', 42, 42, 2, 'entre 400 000 et 450 000 ha', 'Massif entre 400 000 (inclus) et 450 000 ha (exclu)')
, ('U_TAILMASSIF', '42', 43, 43, 2, 'entre 450 000 et 500 000 ha', 'Massif entre 450 000 (inclus) et 500 000 ha (exclu)')
, ('U_TAILMASSIF', '43', 44, 44, 2, 'entre 500 000 et 550 000 ha', 'Massif entre 500 000 (inclus) et 550 000 ha (exclu)')
, ('U_TAILMASSIF', '44', 45, 45, 2, 'entre 550 000 et 600 000 ha', 'Massif entre 550 000 (inclus) et 600 000 ha (exclu)')
, ('U_TAILMASSIF', '45', 46, 46, 2, 'entre 600 000 et 700 000 ha', 'Massif entre 600 000 (inclus) et 700 000 ha (exclu)')
, ('U_TAILMASSIF', '46', 47, 47, 2, 'entre 700 000 et 800 000 ha', 'Massif entre 700 000 (inclus) et 800 000 ha (exclu)')
, ('U_TAILMASSIF', '47', 48, 48, 2, 'entre 800 000 et 900 000 ha', 'Massif entre 800 000 (inclus) et 900 000 ha (exclu)')
, ('U_TAILMASSIF', '48', 49, 49, 2, 'entre 900 000 et 1 000 000 ha', 'Massif entre 900 000 (inclus) et 1 000 000 ha (exclu)')
, ('U_TAILMASSIF', '49', 50, 50, 2, 'supérieur à 1 000 000 ha', 'Massif supérieur à 1 000 000 ha')
, ('U_TAILMASSIF', 'X', 51, 51, 2, 'hors massif', 'Point hors massif')
;

-- Documentation de la donnée
SELECT *
FROM metaifn.ajoutdonnee('U_TAILMASSIF', NULL, 'U_TAILMASSIF', 'AUTRE',
NULL, 4, 'char(2)', 'CC', TRUE, TRUE, 'Taille du massif dans lequel se situe le point d''inventaire',
'Taille du massif dans lequel se situe le point d''inventaire : taille du massif basée sur la BD forêt V2, avec dep actualisés dispo au 20/10/2023. Un massif : polygones de la BD forêt distants de - de 200m et non coupés par éléments définis comme fragment.');

--Documentation de la colonne en base
SELECT *
FROM metaifn.ajoutchamp('U_TAILMASSIF', 'U_E2POINT', 'INV_EXP_NM',
FALSE, 0, 17, 'bpchar', 2);

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('DIRSO', 'U_TAILMASSIF');

--Création de la donnée U
ALTER TABLE inv_exp_nm.u_e2point
ADD COLUMN u_tailmassif CHAR(2);

-- 1. Croisement des points de l'inventaires avec la couche des massifs
-- Récupération de la superficie du massif dans lequel se trouve le point
-- Cas particuliers : le point n'est pas dans un massif ?
/*
WITH croise AS (
	SELECT c1.npp, i.id_massif, i.surf_massifs_ha
	, CASE 
		WHEN i.surf_massifs_ha < 2.25 THEN '00'
		WHEN i.surf_massifs_ha >= 2.25 AND i.surf_massifs_ha < 4 THEN '01'
		WHEN i.surf_massifs_ha >= 4 AND i.surf_massifs_ha < 25 THEN '02'
		WHEN i.surf_massifs_ha >= 25 AND i.surf_massifs_ha < 50 THEN '03'
		WHEN i.surf_massifs_ha >= 50 AND i.surf_massifs_ha < 100 THEN '04'
		WHEN i.surf_massifs_ha >= 100 AND i.surf_massifs_ha < 200 THEN '05'
		WHEN i.surf_massifs_ha >= 200 AND i.surf_massifs_ha < 300 THEN '06'
		WHEN i.surf_massifs_ha >= 300 AND i.surf_massifs_ha < 400 THEN '07'
		WHEN i.surf_massifs_ha >= 400 AND i.surf_massifs_ha < 450 THEN '08'
		WHEN i.surf_massifs_ha >= 450 AND i.surf_massifs_ha < 500 THEN '09'
		WHEN i.surf_massifs_ha >= 500 AND i.surf_massifs_ha < 550 THEN '10'
		WHEN i.surf_massifs_ha >= 550 AND i.surf_massifs_ha < 600 THEN '11'
		WHEN i.surf_massifs_ha >= 600 AND i.surf_massifs_ha < 700 THEN '12'
		WHEN i.surf_massifs_ha >= 700 AND i.surf_massifs_ha < 800 THEN '13'
		WHEN i.surf_massifs_ha >= 800 AND i.surf_massifs_ha < 900 THEN '14'
		WHEN i.surf_massifs_ha >= 900 AND i.surf_massifs_ha < 1000 THEN '15'
		WHEN i.surf_massifs_ha >= 1000 AND i.surf_massifs_ha < 2000 THEN '16'
		WHEN i.surf_massifs_ha >= 2000 AND i.surf_massifs_ha < 3000 THEN '17'
		WHEN i.surf_massifs_ha >= 3000 AND i.surf_massifs_ha < 4000 THEN '18'
		WHEN i.surf_massifs_ha >= 4000 AND i.surf_massifs_ha < 4500 THEN '19'
		WHEN i.surf_massifs_ha >= 4500 AND i.surf_massifs_ha < 5000 THEN '20'
		WHEN i.surf_massifs_ha >= 5000 AND i.surf_massifs_ha < 5500 THEN '21'
		WHEN i.surf_massifs_ha >= 5500 AND i.surf_massifs_ha < 6000 THEN '22'
		WHEN i.surf_massifs_ha >= 6000 AND i.surf_massifs_ha < 7000 THEN '23'
		WHEN i.surf_massifs_ha >= 7000 AND i.surf_massifs_ha < 8000 THEN '24'
		WHEN i.surf_massifs_ha >= 8000 AND i.surf_massifs_ha < 9000 THEN '25'
		WHEN i.surf_massifs_ha >= 9000 AND i.surf_massifs_ha < 10000 THEN '26'
		WHEN i.surf_massifs_ha >= 10000 AND i.surf_massifs_ha < 20000 THEN '27'
		WHEN i.surf_massifs_ha >= 20000 AND i.surf_massifs_ha < 30000 THEN '28'
		WHEN i.surf_massifs_ha >= 30000 AND i.surf_massifs_ha < 40000 THEN '29'
		WHEN i.surf_massifs_ha >= 40000 AND i.surf_massifs_ha < 45000 THEN '30'
		WHEN i.surf_massifs_ha >= 45000 AND i.surf_massifs_ha < 50000 THEN '31'
		WHEN i.surf_massifs_ha >= 50000 AND i.surf_massifs_ha < 55000 THEN '32'
		WHEN i.surf_massifs_ha >= 55000 AND i.surf_massifs_ha < 60000 THEN '33'
		WHEN i.surf_massifs_ha >= 60000 AND i.surf_massifs_ha < 70000 THEN '34'
		WHEN i.surf_massifs_ha >= 70000 AND i.surf_massifs_ha < 80000 THEN '35'
		WHEN i.surf_massifs_ha >= 80000 AND i.surf_massifs_ha < 90000 THEN '36'
		WHEN i.surf_massifs_ha >= 90000 AND i.surf_massifs_ha < 100000 THEN '37'
		WHEN i.surf_massifs_ha >= 100000 AND i.surf_massifs_ha < 200000 THEN '38'
		WHEN i.surf_massifs_ha >= 200000 AND i.surf_massifs_ha < 300000 THEN '39'
		WHEN i.surf_massifs_ha >= 300000 AND i.surf_massifs_ha < 400000 THEN '40'
		WHEN i.surf_massifs_ha >= 400000 AND i.surf_massifs_ha < 450000 THEN '41'
		WHEN i.surf_massifs_ha >= 450000 AND i.surf_massifs_ha < 500000 THEN '42'
		WHEN i.surf_massifs_ha >= 500000 AND i.surf_massifs_ha < 550000 THEN '43'
		WHEN i.surf_massifs_ha >= 550000 AND i.surf_massifs_ha < 600000 THEN '44'
		WHEN i.surf_massifs_ha >= 600000 AND i.surf_massifs_ha < 700000 THEN '45'
		WHEN i.surf_massifs_ha >= 700000 AND i.surf_massifs_ha < 800000 THEN '46'
		WHEN i.surf_massifs_ha >= 800000 AND i.surf_massifs_ha < 900000 THEN '47'
		WHEN i.surf_massifs_ha >= 900000 AND i.surf_massifs_ha < 1000000 THEN '48'
		WHEN i.surf_massifs_ha >= 1000000 THEN '49'
		ELSE 'X'
	END AS class_massif
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN public.taille_massifs i ON ST_Intersects(c1.geom, i.geom)
	INNER JOIN inv_exp_nm.e2point c2 ON c1.npp = c2.npp
	WHERE c2.incref BETWEEN 1 AND 17
)
UPDATE inv_exp_nm.u_e2point p
SET u_tailmassif = c.class_massif
FROM croise c
WHERE p.npp = c.npp;
*/

-- 2. Calcul de la donnée : création des différentes classes
CREATE TABLE public.croise (
	npp TEXT,
	id_massif TEXT,
	origine TEXT,
	surf_foret_ha FLOAT8
);

\COPY public.croise FROM '//fs-nogent/Partage_Ressources/2_Donnees_Utilisateurs/U_TAILMASSIF/croisement_ingrid/pts_massifsfodatac.csv' WITH CSV HEADER DELIMITER ',' NULL AS '';

BEGIN;

UPDATE inv_exp_nm.u_e2point p
SET u_tailmassif = CASE 
		WHEN c.id_massif IS NULL AND c.surf_foret_ha = 0 THEN 'X'
		WHEN c.surf_foret_ha < 2.25 THEN '00'
		WHEN c.surf_foret_ha >= 2.25 AND c.surf_foret_ha < 4 THEN '01'
		WHEN c.surf_foret_ha >= 4 AND c.surf_foret_ha < 25 THEN '02'
		WHEN c.surf_foret_ha >= 25 AND c.surf_foret_ha < 50 THEN '03'
		WHEN c.surf_foret_ha >= 50 AND c.surf_foret_ha < 100 THEN '04'
		WHEN c.surf_foret_ha >= 100 AND c.surf_foret_ha < 200 THEN '05'
		WHEN c.surf_foret_ha >= 200 AND c.surf_foret_ha < 300 THEN '06'
		WHEN c.surf_foret_ha >= 300 AND c.surf_foret_ha < 400 THEN '07'
		WHEN c.surf_foret_ha >= 400 AND c.surf_foret_ha < 450 THEN '08'
		WHEN c.surf_foret_ha >= 450 AND c.surf_foret_ha < 500 THEN '09'
		WHEN c.surf_foret_ha >= 500 AND c.surf_foret_ha < 550 THEN '10'
		WHEN c.surf_foret_ha >= 550 AND c.surf_foret_ha < 600 THEN '11'
		WHEN c.surf_foret_ha >= 600 AND c.surf_foret_ha < 700 THEN '12'
		WHEN c.surf_foret_ha >= 700 AND c.surf_foret_ha < 800 THEN '13'
		WHEN c.surf_foret_ha >= 800 AND c.surf_foret_ha < 900 THEN '14'
		WHEN c.surf_foret_ha >= 900 AND c.surf_foret_ha < 1000 THEN '15'
		WHEN c.surf_foret_ha >= 1000 AND c.surf_foret_ha < 2000 THEN '16'
		WHEN c.surf_foret_ha >= 2000 AND c.surf_foret_ha < 3000 THEN '17'
		WHEN c.surf_foret_ha >= 3000 AND c.surf_foret_ha < 4000 THEN '18'
		WHEN c.surf_foret_ha >= 4000 AND c.surf_foret_ha < 4500 THEN '19'
		WHEN c.surf_foret_ha >= 4500 AND c.surf_foret_ha < 5000 THEN '20'
		WHEN c.surf_foret_ha >= 5000 AND c.surf_foret_ha < 5500 THEN '21'
		WHEN c.surf_foret_ha >= 5500 AND c.surf_foret_ha < 6000 THEN '22'
		WHEN c.surf_foret_ha >= 6000 AND c.surf_foret_ha < 7000 THEN '23'
		WHEN c.surf_foret_ha >= 7000 AND c.surf_foret_ha < 8000 THEN '24'
		WHEN c.surf_foret_ha >= 8000 AND c.surf_foret_ha < 9000 THEN '25'
		WHEN c.surf_foret_ha >= 9000 AND c.surf_foret_ha < 10000 THEN '26'
		WHEN c.surf_foret_ha >= 10000 AND c.surf_foret_ha < 20000 THEN '27'
		WHEN c.surf_foret_ha >= 20000 AND c.surf_foret_ha < 30000 THEN '28'
		WHEN c.surf_foret_ha >= 30000 AND c.surf_foret_ha < 40000 THEN '29'
		WHEN c.surf_foret_ha >= 40000 AND c.surf_foret_ha < 45000 THEN '30'
		WHEN c.surf_foret_ha >= 45000 AND c.surf_foret_ha < 50000 THEN '31'
		WHEN c.surf_foret_ha >= 50000 AND c.surf_foret_ha < 55000 THEN '32'
		WHEN c.surf_foret_ha >= 55000 AND c.surf_foret_ha < 60000 THEN '33'
		WHEN c.surf_foret_ha >= 60000 AND c.surf_foret_ha < 70000 THEN '34'
		WHEN c.surf_foret_ha >= 70000 AND c.surf_foret_ha < 80000 THEN '35'
		WHEN c.surf_foret_ha >= 80000 AND c.surf_foret_ha < 90000 THEN '36'
		WHEN c.surf_foret_ha >= 90000 AND c.surf_foret_ha < 100000 THEN '37'
		WHEN c.surf_foret_ha >= 100000 AND c.surf_foret_ha < 200000 THEN '38'
		WHEN c.surf_foret_ha >= 200000 AND c.surf_foret_ha < 300000 THEN '39'
		WHEN c.surf_foret_ha >= 300000 AND c.surf_foret_ha < 400000 THEN '40'
		WHEN c.surf_foret_ha >= 400000 AND c.surf_foret_ha < 450000 THEN '41'
		WHEN c.surf_foret_ha >= 450000 AND c.surf_foret_ha < 500000 THEN '42'
		WHEN c.surf_foret_ha >= 500000 AND c.surf_foret_ha < 550000 THEN '43'
		WHEN c.surf_foret_ha >= 550000 AND c.surf_foret_ha < 600000 THEN '44'
		WHEN c.surf_foret_ha >= 600000 AND c.surf_foret_ha < 700000 THEN '45'
		WHEN c.surf_foret_ha >= 700000 AND c.surf_foret_ha < 800000 THEN '46'
		WHEN c.surf_foret_ha >= 800000 AND c.surf_foret_ha < 900000 THEN '47'
		WHEN c.surf_foret_ha >= 900000 AND c.surf_foret_ha < 1000000 THEN '48'
		WHEN c.surf_foret_ha >= 1000000 THEN '49'
		ELSE 'X'
	END
FROM croise c
WHERE p.npp = c.npp;

SELECT incref, COUNT(u_tailmassif)
FROM INV_EXP_NM.U_E2POINT
GROUP BY incref ORDER BY incref;

SELECT incref, u_tailmassif, COUNT(u_tailmassif)
FROM INV_EXP_NM.U_E2POINT
GROUP BY incref, u_tailmassif ORDER BY incref, u_tailmassif;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 17, validin = 0, validout = 17, defin = 0, defout = 17
WHERE famille = 'INV_EXP_NM'
AND format IN ('U_E2POINT')
AND donnee = 'U_TAILMASSIF';
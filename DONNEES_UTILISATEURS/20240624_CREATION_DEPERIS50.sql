-- METADONNEES
BEGIN;

-- 1.Documentation de l’unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('DEPERISPPT', 'IFN', 'NOMINAL', 'Intensité du dépérissement (avec DEPERIS)', 'Caractérise l''intensité du dépérissement de chaque placette en 6 classes (de 0 à 50% et plus)');

-- 2.Documentation des modalités
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('DEPERISPPT', '0', 1, 1, 1, '0%', 'Aucun arbre mort ou arbre avec un DEPERIS dégradé (D, E, F)')
, ('DEPERISPPT', '1', 2, 2, 1, 'moins de 20%', 'Moins de 20 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('DEPERISPPT', '2', 3, 3, 1, 'entre 20 et 30%', 'Entre 20 % (inclus) et 30 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('DEPERISPPT', '3', 4, 4, 1, 'entre 30 et 40%', 'Entre 30 % (inclus) et 40 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('DEPERISPPT', '4', 5, 5, 1, 'entre 40 et 50%', 'Entre 40 % (inclus) et 50 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('DEPERISPPT', '5', 6, 6, 1, '50% et plus', 'Au moins 50 % (inclus) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)');

-- 3.Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('DEPERIS50', NULL, 'DEPERISPPT', 'IFN', NULL, 6, 'varchar(1)', 'CC', TRUE, TRUE, 
'Intensité du dépérissement (avec DEPERIS)', 
'Caractérise l''intensité du dépérissement d''une placette selon son taux d''arbres dépérissants (classés D, E ou F en DEPERIS)');

-- 4.Documentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('DEPERIS50', 'G3FORET', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);
SELECT * FROM metaifn.ajoutchamp('DEPERIS50', 'P3POINT', 'INV_EXP_NM', FALSE, 0, 18, 'varchar', 1);

UPDATE metaifn.afchamp 
SET calcin = 16, calcout = 18, validin = 16, validout = 18, defin = 16, defout = NULL  
WHERE famille = 'INV_EXP_NM' AND donnee = 'DEPERIS50';

SELECT *
FROM metaifn.afchamp 
WHERE famille = 'INV_EXP_NM' AND donnee = 'DEPERIS50';

-- 5. Affectation à un groupe d'utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('IFN', 'DEPERIS50');

COMMIT;


-- CALCUL DE LA DONNEE EN FORET DE PRODUCTION
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.g3foret 
ADD COLUMN deperis50 character(1); 
COMMENT ON COLUMN inv_exp_nm.g3foret.deperis50 IS 'Intensité du dépérissement' ;

COMMIT;

-- arbres morts de moins de 5 ans
BEGIN;

WITH MORTS AS
	(SELECT G3M.NPP, G3M.INCREF, SUM(G3M.WAC) AS W_MORTS, COUNT(*) AS NB_MORTS
		FROM INV_EXP_NM.G3MORTS G3M
		WHERE G3M.VEGET in ('5','C')
			AND DATEMORT = '1'
			AND LIB = '2'
			AND CAST(G3M.CLAD AS INTEGER) BETWEEN 23 AND 130
			AND G3M.INCREF BETWEEN 16 AND 18
		GROUP BY G3M.NPP, G3M.INCREF),
-- Arbres vivants avec déperissement (attention jointure à l'arbre et pas seulement npp, le comptage d'arbres était faux)
VIVANTS AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_VIVANTS, COUNT(*) AS NB_VIVANTS
		FROM INV_EXP_NM.G3ARBRE G3A
--		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A) --> ne sert plus à rien
		WHERE VEGET = '0'
			AND DEPERIS in ('A','B','C','D','E', 'F') 
			AND G3A.INCREF BETWEEN 16 AND 18
		GROUP BY G3A.NPP, G3A.INCREF),
-- Arbres vivants avec au moins 50% de déperissement
DEPERIS50 AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_DEPERIS50, COUNT(*) as NB_DEPERIS50
		FROM INV_EXP_NM.G3ARBRE G3A
--		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A ) --> ne sert plus à rien
		WHERE VEGET = '0'
			AND DEPERIS in ('D','E', 'F') 
			AND G3A.INCREF BETWEEN 16 AND 18
		GROUP BY G3A.NPP, G3A.INCREF),		
---elements intermédiaires pour calculer le ratio : 		
DENOM AS (                        --calcul dénominateur
	SELECT 
		CASE 
			WHEN VIVANTS.NPP IS NOT NULL THEN VIVANTS.NPP ELSE MORTS.NPP END NPP,
		CASE
			WHEN VIVANTS.INCREF IS NOT NULL THEN VIVANTS.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS VIVANTS, COALESCE(MORTS.W_MORTS, 0) AS MORTS, 
	COALESCE(VIVANTS.W_VIVANTS,0) + COALESCE(MORTS.W_MORTS, 0) AS DENOM 
	FROM VIVANTS
	FULL JOIN MORTS ON VIVANTS.NPP = MORTS.NPP),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT 
	CASE
		WHEN MORTS.NPP IS NULL THEN DEPERIS50.NPP ELSE MORTS.NPP END NPP,
	CASE
		WHEN MORTS.INCREF IS NULL THEN DEPERIS50.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(MORTS.W_MORTS,0) MORTS, COALESCE(DEPERIS50.W_DEPERIS50, 0) DEPERIS50, 
	COALESCE(DEPERIS50.W_DEPERIS50, 0) + COALESCE(MORTS.W_MORTS, 0) AS NUMER
	FROM DEPERIS50
	FULL JOIN MORTS ON DEPERIS50.NPP = MORTS.NPP),		
-- TEST : SELECT npp1, denom.incref1 , npp, denom.incref, case when denom = 0  then 0 else coalesce(numer,0) / denom  * 100 end as ratio from denom left join numerateur  using (npp1, npp)
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR, -- Calcul du ratio de déperissement  (attention aux jointures  pour avoir  aussi les placettes 100% morts  FULL JOIN et pas LEFT JOIN)
	COALESCE(NUMER,0)/DENOM * 100 AS RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)
UPDATE inv_exp_nm.g3foret AS ug3f
SET DEPERIS50 =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 20 THEN '1'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '2'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '3'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '4'
					WHEN RATIO >= 50 THEN '5'
					ELSE NULL
	END 
FROM RESULTAT
WHERE ug3f.incref BETWEEN 16 AND 18
	AND RESULTAT.NPP = UG3F.NPP 
	AND RESULTAT.INCREF = UG3F.INCREF;

-- Contrôle
SELECT NPP, INCREF, DEPERIS50
FROM inv_exp_nm.g3foret
WHERE INCREF BETWEEN 16 AND 18
		--AND DEPERIS50 IS NOT NULL
ORDER BY INCREF, NPP;


-- CALCUL DE LA DONNEE EN PEUPLERAIES
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.p3point 
ADD COLUMN deperis50 character(1); 
COMMENT ON COLUMN inv_exp_nm.p3point.deperis50 IS 'Intensité du dépérissement' ;

COMMIT;

-- arbres morts de moins de 5 ans
BEGIN;

WITH MORTS AS
	(SELECT P3M.NPP, P3M.INCREF, SUM(P3M.WAC) AS W_MORTS, COUNT(*) AS NB_MORTS
		FROM INV_EXP_NM.P3MORTS P3M
		WHERE P3M.VEGET in ('5','C')
			AND DATEMORT = '1'
			AND LIB = '2'
			AND CAST(P3M.CLAD AS INTEGER) BETWEEN 23 AND 130
			AND P3M.INCREF BETWEEN 16 AND 18
		GROUP BY P3M.NPP, P3M.INCREF),
-- Arbres vivants avec déperissement
VIVANTS AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_VIVANTS, COUNT(*) NB_VIVANTS
		FROM INV_EXP_NM.P3ARBRE P3A
--		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND DEPERIS in ('A','B','C','D','E', 'F')
			AND P3A.INCREF BETWEEN 16 AND 18
		GROUP BY P3A.NPP, P3A.INCREF),
-- Arbres vivants avec au moins 50% de déperissement
DEPERIS50 AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_DEPERIS50, COUNT(*) NB_DEPERIS50
		FROM INV_EXP_NM.P3ARBRE P3A
--		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND DEPERIS in ('D','E', 'F')
			AND P3A.INCREF BETWEEN 16 AND 18
		GROUP BY P3A.NPP, P3A.INCREF),
---elements intermédiaires pour calculer le ratio : 		
--calcul dénominateur
DENOM AS (
	SELECT 
		CASE 
			WHEN VIVANTS.NPP IS NOT NULL THEN VIVANTS.NPP ELSE MORTS.NPP END NPP,
		CASE
			WHEN VIVANTS.INCREF IS NOT NULL THEN VIVANTS.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS VIVANTS, COALESCE(MORTS.W_MORTS, 0) AS MORTS, 
	COALESCE(VIVANTS.W_VIVANTS,0) + COALESCE(MORTS.W_MORTS, 0) AS DENOM 
	FROM VIVANTS
	FULL JOIN MORTS ON VIVANTS.NPP = MORTS.NPP),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT 
	CASE
		WHEN MORTS.NPP IS NULL THEN DEPERIS50.NPP ELSE MORTS.NPP END NPP,
	CASE
		WHEN MORTS.INCREF IS NULL THEN DEPERIS50.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(MORTS.W_MORTS,0) MORTS, COALESCE(DEPERIS50.W_DEPERIS50, 0) DEPERIS50, 
	COALESCE(DEPERIS50.W_DEPERIS50, 0) + COALESCE(MORTS.W_MORTS, 0) AS NUMER
	FROM DEPERIS50
	FULL JOIN MORTS ON DEPERIS50.NPP = MORTS.NPP),		
-- Calcul du ratio de déperissement
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR,
	CASE
		WHEN COALESCE(NUMER,0) > 0 THEN COALESCE(NUMER,0)/DENOM * 100 ELSE 0 END RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)				
UPDATE inv_exp_nm.p3point AS up3p
SET DEPERIS50 =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 20 THEN '1'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '2'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '3'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '4'
					WHEN RATIO >= 50 THEN '5'
					ELSE NULL
	END 
FROM RESULTAT
WHERE up3p.incref BETWEEN 16 AND 18
	AND RESULTAT.NPP = UP3P.NPP 
	AND RESULTAT.INCREF = UP3P.INCREF;


SELECT NPP, INCREF, DEPERIS50
FROM inv_exp_nm.p3point
WHERE INCREF BETWEEN 16 AND 18
		--AND DEPERIS50 IS NOT NULL
ORDER BY INCREF, NPP;


/*
-- Mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 16, calcout = 18, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'g3foret'
AND donnee ~~* 'DEPERIS50';

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 18, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'p3point'
AND donnee ~~* 'DEPERIS50';

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'DEPERIS50');
*/		
		

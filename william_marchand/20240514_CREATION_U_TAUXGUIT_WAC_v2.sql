-- METADONNEES
BEGIN;

-- 1.Documentation de l’unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('TAUXGUIT', 'AUTRE', 'NOMINAL', 'Taux d''arbres guités', 'Rapport entre le nombre d''arbres présentant au moins une boule de gui et le nombre total d''arbres évalués (excluant les petits bois), par placette (de 0 à 50% et plus)');

-- 2.Documentation des modalités
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('TAUXGUIT', '0', 1, 1, 1, '0 %', 'Aucun arbre portant au moins une boule de gui')
, ('TAUXGUIT', '1', 2, 2, 1, 'moins de 10 %', 'Moins de 10 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '2', 3, 3, 1, 'entre 10 et 20 %', 'Entre 10 % (inclus) et 20 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '3', 4, 4, 1, 'entre 20 et 30 %', 'Entre 20 % (inclus) et 30 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '4', 5, 5, 1, 'entre 30 et 40 %', 'Entre 30 % (inclus) et 40 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '5', 6, 6, 1, 'entre 40 et 50 %', 'Entre 40 % (inclus) et 50 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '6', 7, 7, 1, 'entre 50 et 60 %', 'Entre 50 % (inclus) et 60 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '7', 8, 8, 1, 'entre 60 et 70 %', 'Entre 60 % (inclus) et 70 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '8', 9, 9, 1, 'entre 70 et 80 %', 'Entre 70 % (inclus) et 80 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '9', 10, 10, 1, 'entre 80 et 90 %', 'Entre 80 % (inclus) et 90 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '10', 11, 11, 1, 'entre 90 et 99 %', 'Entre 90 % (inclus) et 100 % (exclu) d''arbres portant au moins une boule de gui')
, ('TAUXGUIT', '11', 12, 12, 1, '100 %', 'Tous les arbres portent au moins une boule de gui');

COMMIT;

-- 3.Documentation de la donnée
BEGIN;

SELECT * FROM metaifn.ajoutdonnee('U_TAUXGUIT', NULL, 'TAUXGUIT', 'AUTRE', NULL, 6, 'varchar(2)', 'CC', TRUE, TRUE, 
'Taux d''arbres guités', 
'Caractérise le taux d''arbres guités (les petits bois sont exclus) sur chaque placette en 6 classes (de 0 à 50 % et plus) avec utilisation du WAC');

-- 4.Documentation de la colonne en base
SELECT *  FROM metaifn.ajoutchamp('U_TAUXGUIT', 'U_G3FORET', 'INV_EXP_NM', FALSE, 3, 17, 'varchar', 2);

SELECT *  FROM metaifn.ajoutchamp('U_TAUXGUIT', 'U_P3POINT', 'INV_EXP_NM', FALSE, 3, 17, 'varchar', 2);

UPDATE metaifn.afchamp 
SET calcin = 3, calcout = 17, validin = 3, validout = 17, defin = 3, defout = NULL  
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_TAUXGUIT';

SELECT *
FROM metaifn.afchamp 
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_TAUXGUIT';

-- 5. Affectation à un groupe d'utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('DRIF', 'U_TAUXGUIT');

COMMIT;


-- CALCUL DE LA DONNEE EN FORET DE PRODUCTION
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.u_g3foret ADD COLUMN U_TAUXGUIT character(2); 
COMMENT ON COLUMN inv_exp_nm.u_g3foret.U_TAUXGUIT IS 'Taux d''arbres guités';

COMMIT;

BEGIN;

-- Arbres vivants avec caractérisation de présence de gui
WITH VIVANTS AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_VIVANTS
		FROM INV_EXP_NM.G3ARBRE G3A
		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A)
		WHERE VEGET = '0'
			AND SFGUI in ('0', '1','2','3') 
			AND G3A.INCREF BETWEEN 3 AND 17
			AND CAST(G3A.CLAD AS INTEGER) BETWEEN 23 AND 130
		GROUP BY G3A.NPP, G3A.INCREF),
-- Arbres vivants avec observation d'au moins une boule de gui
GUI AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_GUI, COUNT(*) as NB_GUI
		FROM INV_EXP_NM.G3ARBRE G3A
		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A )
		WHERE VEGET = '0'
			AND SFGUI in ('1', '2', '3') 
			AND G3A.INCREF BETWEEN 3 AND 17
			AND CAST(G3A.CLAD AS INTEGER) BETWEEN 23 AND 130
		GROUP BY G3A.NPP, G3A.INCREF),		
---elements intermédiaires pour calculer le ratio : 		
--calcul dénominateur
DENOM AS (
	SELECT VIVANTS.NPP AS NPP, VIVANTS.INCREF AS INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS DENOM 
	FROM VIVANTS),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT GUI.NPP AS NPP, GUI.INCREF AS INCREF,
	COALESCE(GUI.W_GUI, 0) AS NUMER
	FROM GUI),		
-- TEST : SELECT npp1, denom.incref1 , npp, denom.incref, case when denom = 0  then 0 else coalesce(numer,0) / denom  * 100 end as ratio from denom left join numerateur  using (npp1, npp)
-- Calcul du ratio d'arbres parasités
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR,
	COALESCE(NUMER,0)/DENOM * 100 AS RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)
UPDATE inv_exp_nm.u_g3foret AS ug3f
SET U_TAUXGUIT =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 10 THEN '1'
					WHEN RATIO >= 10 AND RATIO < 20 THEN '2'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '3'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '4'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '5'
					WHEN RATIO >= 50 AND RATIO < 60 THEN '6'
					WHEN RATIO >= 60 AND RATIO < 70 THEN '7'
					WHEN RATIO >= 70 AND RATIO < 80 THEN '8'
					WHEN RATIO >= 80 AND RATIO < 90 THEN '9'
					WHEN RATIO >= 90 AND RATIO < 100 THEN '10'
					WHEN RATIO = 100 THEN '11'
					ELSE NULL
	END 
FROM RESULTAT
WHERE ug3f.incref BETWEEN 3 AND 17 
	AND RESULTAT.NPP = UG3F.NPP 
	AND RESULTAT.INCREF = UG3F.INCREF;

-- Contrôle
SELECT NPP, INCREF, U_TAUXGUIT
FROM inv_exp_nm.u_g3foret
WHERE INCREF BETWEEN 3 AND 17
		--AND U_TAUXGUIT IS NOT NULL
ORDER BY INCREF, NPP;

COMMIT;

-- CALCUL DE LA DONNEE EN PEUPLERAIES
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.u_p3point ADD COLUMN U_TAUXGUIT character(2); 
COMMENT ON COLUMN inv_exp_nm.u_p3point.U_TAUXGUIT IS 'Taux d''arbres guités';

COMMIT;

-- Arbres vivants avec caractérisation de présence de gui
BEGIN;

WITH VIVANTS AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_VIVANTS
		FROM INV_EXP_NM.P3ARBRE P3A
		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND SFGUI in ('0', '1','2','3') 
			AND P3A.INCREF BETWEEN 3 AND 17
			AND CAST(P3A.CLAD AS INTEGER) BETWEEN 23 AND 130
		GROUP BY P3A.NPP, P3A.INCREF),
-- Arbres vivants avec au moins une boule de gui
GUI AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_GUI, COUNT(*) NB_GUI
		FROM INV_EXP_NM.P3ARBRE P3A
		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND SFGUI in ('1','2','3') 
			AND P3A.INCREF BETWEEN 3 AND 17
			AND CAST(P3A.CLAD AS INTEGER) BETWEEN 23 AND 130
		GROUP BY P3A.NPP, P3A.INCREF),
---elements intermédiaires pour calculer le ratio : 		
--calcul dénominateur
DENOM AS (
	SELECT VIVANTS.NPP AS NPP, VIVANTS.INCREF AS INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS DENOM 
	FROM VIVANTS),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT GUI.NPP AS NPP, GUI.INCREF AS INCREF,
	COALESCE(GUI.W_GUI, 0) AS NUMER
	FROM GUI),		
-- Calcul du ratio d'arbres parasités
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR,
	CASE
		WHEN COALESCE(NUMER,0) > 0 THEN COALESCE(NUMER,0)/DENOM * 100 ELSE 0 END RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)				
UPDATE inv_exp_nm.u_p3point AS up3p
SET U_TAUXGUIT =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 10 THEN '1'
					WHEN RATIO >= 10 AND RATIO < 20 THEN '2'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '3'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '4'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '5'
					WHEN RATIO >= 50 AND RATIO < 60 THEN '6'
					WHEN RATIO >= 60 AND RATIO < 70 THEN '7'
					WHEN RATIO >= 70 AND RATIO < 80 THEN '8'
					WHEN RATIO >= 80 AND RATIO < 90 THEN '9'
					WHEN RATIO >= 90 AND RATIO < 100 THEN '10'
					WHEN RATIO = 100 THEN '11'
					ELSE NULL
	END 
FROM RESULTAT
WHERE up3p.incref BETWEEN 3 AND 17 
	AND RESULTAT.NPP = UP3P.NPP 
	AND RESULTAT.INCREF = UP3P.INCREF;


-- Contrôle
SELECT NPP, INCREF, U_TAUXGUIT
FROM inv_exp_nm.u_p3point
WHERE INCREF BETWEEN 3 AND 17
		--AND U_TAUXGUIT IS NOT NULL
ORDER BY INCREF, NPP;


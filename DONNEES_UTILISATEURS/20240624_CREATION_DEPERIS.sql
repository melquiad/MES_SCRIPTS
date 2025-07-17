
-- Création de la donnée DEPERIS
BEGIN;


-- Ajout des colonnes dans les tables
ALTER TABLE inv_exp_nm.g3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.g3morts.deperis IS 'Dépérissement des arbres' ;

ALTER TABLE inv_exp_nm.p3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.p3morts.deperis IS 'Dépérissement des arbres' ;

-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.g3morts.deperis IS 'Dépérissement des arbres' ;

ALTER FOREIGN TABLE inv_exp_nm.p3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.p3morts.deperis IS 'Dépérissement des arbres' ;


-- Documentation de l'unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) 
VALUES ('DEPERIS', 'IFN', 'NOMINAL', 'Dépérissement des arbres',
'Dépérissement des arbres évalué à partir de la mortalité de branches, du manque d''aiguilles et du manque de ramifications.');

-- Documentation des modalités
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, valeurint, etendue, hls, rgb, cmyk, libelle, definition)
VALUES('DEPERIS', 'X', 1, 0, NULL, 1, NULL, NULL, NULL, 'non observ.', 'Les conditions d’observation ne permettent pas d’apprécier le dépérissement.')
, ('DEPERIS', 'A', 2, 1, NULL, 1, NULL, NULL, NULL, 'Dégradation absente', 'Arbre très sain, sans trace ou à très rares traces (< 5 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('DEPERIS', 'B', 3, 2, NULL, 1, NULL, NULL, NULL, 'Dégradation légère', 'Arbre sain, avec des signes légers (< 25 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('DEPERIS', 'C', 4, 3, NULL, 1, NULL, NULL, NULL, 'Dégradation modérée', 'Arbre plutôt sain, avec des signes modérés (< 50 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('DEPERIS', 'D', 5, 4, NULL, 1, NULL, NULL, NULL, 'Dégradation importante', 'Arbre dégradé, avec des signes importants (généralement entre 50 et 75 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('DEPERIS', 'E', 6, 5, NULL, 1, NULL, NULL, NULL, 'Dégradation très importante', 'Arbre très dégradé, avec des signes très importants (généralement entre 75 et 95 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('DEPERIS', 'F', 7, 6, NULL, 1, NULL, NULL, NULL, 'Dégradation totale', 'Arbre quasiment mort ou mort, à très forte mortalité de branches et/ou manque de ramifications ou aiguilles.');

-- Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('DEPERIS', NULL, 'DEPERIS', 'IFN', NULL, 7, 'varchar(1)', 'CC', TRUE, TRUE, 
'Dépérissement des arbres', 'Dépérissement des arbres évalué à partir de la mortalité de branches, du manque d''aiguilles et du manque de ramifications');

-- Documentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('DEPERIS', 'G3ARBRE', 'INV_EXP_NM', FALSE, 16, 18, 'varchar', 1);
SELECT * FROM metaifn.ajoutchamp('DEPERIS', 'P3ARBRE', 'INV_EXP_NM', FALSE, 16, 18, 'varchar', 1);

COMMIT;


BEGIN;


-- Mise à jour de la donnée
-- pour campagne 2021 et plus

UPDATE inv_exp_nm.g3arbre ua
SET deperis = 
	CASE
		WHEN ua.mortbdeper = 'X' THEN 'X'		
		WHEN ua.mortbdeper = '0' AND (a.mr = '0' OR a.ma = '0') THEN 'A'		
		WHEN (ua.mortbdeper = '1' AND (a.mr IN ('0', '1') 
			 OR a.ma IN ('0', '1'))) OR (ua.mortbdeper = '0' AND (a.mr = '1' OR a.ma = '1')) THEN 'B'			 
		WHEN (ua.mortbdeper = '2' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.mortbdeper IN ('0', '1') AND (a.mr = '2' OR a.ma = '2')) THEN 'C'			 
		WHEN (ua.mortbdeper = '3' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.mortbdeper IN ('2', '3') AND (a.mr = '2' OR a.ma = '2')) 
			 OR (ua.mortbdeper IN ('0', '1', '2') AND (a.mr = '3' OR a.ma = '3')) THEN 'D'			 
		WHEN (ua.mortbdeper = '3' AND (a.mr = '3' OR a.ma = '3'))
			 OR (ua.mortbdeper IN ('0', '1', '2') AND (a.mr = '4' OR a.ma = '4')) THEN 'E'		
		WHEN ua.mortbdeper IN ('4', '5') OR (a.mr = '5' OR a.ma = '5')
			 OR (ua.mortbdeper = '3' AND (a.mr = '4' OR a.ma = '4')) THEN 'F'		
		ELSE 'X' END
FROM inv_exp_nm.g3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, deperis, count(*)
FROM inv_exp_nm.g3arbre
WHERE incref >= 16
GROUP BY incref, deperis
ORDER BY incref, deperis;

SELECT ua.incref, mr, ma, mortbdeper, deperis
FROM inv_exp_nm.g3arbre ua
WHERE ua.incref = 19 AND deperis = 'E';


UPDATE inv_exp_nm.p3arbre ua
SET deperis = 
	CASE
		WHEN ua.mortbdeper = 'X' THEN 'X'	
		WHEN ua.mortbdeper = '0' AND (a.mr = '0' OR a.ma = '0') THEN 'A'		
		WHEN (ua.mortbdeper = '1' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.mortbdeper = '0' AND (a.mr = '1' OR a.ma = '1')) THEN 'B'			 
		WHEN (ua.mortbdeper = '2' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.mortbdeper IN ('0', '1') AND (a.mr = '2' OR a.ma = '2')) THEN 'C'			 
		WHEN (ua.mortbdeper = '3' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.mortbdeper IN ('2', '3') AND (a.mr = '2' OR a.ma = '2')) 
			 OR (ua.mortbdeper IN ('0', '1', '2') AND (a.mr = '3' OR a.ma = '3')) THEN 'D'			 
		WHEN (ua.mortbdeper = '3' AND (a.mr = '3' OR a.ma = '3'))
			 OR (ua.mortbdeper IN ('0', '1', '2') AND (a.mr = '4' OR a.ma = '4')) THEN 'E'		
		WHEN ua.mortbdeper IN ('4', '5') OR (a.mr = '5' OR a.ma = '5')
			 OR (ua.mortbdeper = '3' AND (a.mr = '4' OR a.ma = '4')) THEN 'F'		
		ELSE 'X' END
FROM inv_exp_nm.p3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, deperis, count(*)
FROM inv_exp_nm.p3arbre
WHERE incref >= 16
GROUP BY incref, deperis
ORDER BY incref, deperis;

SELECT ua.incref, mr, ma, mortbdeper, deperis
FROM inv_exp_nm.p3arbre ua
WHERE ua.incref = 19 AND deperis = 'F';


-- Mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 16, calcout = 19, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'g3arbre'
AND donnee ~~* 'DEPERIS';

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 19, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'p3arbre'
AND donnee ~~* 'DEPERIS';

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'DEPERIS');

COMMIT;

------------------------------------------------------------------------------------------------------
-- Création de la donnée DEPERIS pour les arbres morts
------------------------------------------------------------------------------------------------------

-- ajout des colonnes en base
ALTER TABLE inv_exp_nm.g3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.g3morts.deperis IS 'Dépérissement des arbres' ;

ALTER TABLE inv_exp_nm.p3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.p3morts.deperis IS 'Dépérissement des arbres' ;

-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.g3morts.deperis IS 'Dépérissement des arbres' ;

ALTER FOREIGN TABLE inv_exp_nm.p3morts ADD COLUMN deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.p3morts.deperis IS 'Dépérissement des arbres' ;

-- Mise à jour de la donnée
-- pour campagne 2021 et plus
UPDATE inv_exp_nm.g3morts ua
SET deperis = 
	CASE
		WHEN A.VEGETM = '5' AND A.DATEMORT = '1'  AND A.LIB = '2' AND CAST(A.CLAD AS INTEGER) BETWEEN 23 AND 130  THEN 'F'		
		ELSE 'X' END
FROM inv_exp_nm.g3morts a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, deperis, count(*)
FROM inv_exp_nm.g3morts
WHERE incref >= 16
GROUP BY incref, deperis
ORDER BY incref, deperis;


 -- en peupleraie
UPDATE inv_exp_nm.p3morts ua
SET deperis = 
	CASE
		WHEN A.VEGETM = '5' AND A.DATEMORT = '1'  AND A.LIB = '2' AND CAST(A.CLAD AS INTEGER) BETWEEN 23 AND 130  THEN 'F'	
		ELSE 'X' END
FROM inv_exp_nm.p3morts a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, deperis, count(*)
FROM inv_exp_nm.p3morts
WHERE incref >= 16
GROUP BY incref, deperis
ORDER BY incref, deperis;



-- Documentation de la colonne en base
SELECT * 
FROM metaifn.ajoutchamp('DEPERIS', 'G3MORTS', 'INV_EXP_NM', FALSE, 0, 17, 'varchar', 1);

SELECT * 
FROM metaifn.ajoutchamp('DEPERIS', 'P3MORTS', 'INV_EXP_NM', FALSE, 0, 17, 'varchar', 1);

UPDATE metaifn.afchamp 
SET calcin = 16, calcout = 19, validin = 16, validout = 18, defin = 16, defout = NULL  
WHERE famille = 'INV_EXP_NM' AND donnee = 'DEPERIS';









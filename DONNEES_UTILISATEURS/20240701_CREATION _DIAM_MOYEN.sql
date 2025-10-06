

--> DONNEE à CREER AUSSI EN PEUPLERAIE : pour l'instant elle n'existe qu'en forêt.

-- on ajoute les colonnes en base
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN diam_moy varchar(3);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN diam_moy varchar(3);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3foret ADD COLUMN diam_moy varchar(3);
ALTER FOREIGN TABLE inv_exp_nm.p3point ADD COLUMN diam_moy varchar(3);

/*
--contrôle
SELECT f.incref , count(f.u_diam_moy) 
FROM inv_exp_nm.u_g3foret f
GROUP BY incref;
*/

BEGIN;

SELECT * FROM metaifn.ajoutdonnee ('DIAM_MOY', NULL, 'CLAD', 'IFN', NULL, 0, 'varchar(3)', 'CC', TRUE, TRUE
, 'Diamètre moyen sur la placette', 'Diamètre moyen des arbres recensables sur la placette ');

SELECT * FROM metaifn.ajoutchamp ('DIAM_MOY', 'G3FORET', 'INV_EXP_NM', FALSE, 0, 18, 'varchar(3)', 8);
SELECT * FROM metaifn.ajoutchamp ('DIAM_MOY', 'P3POINT', 'INV_EXP_NM', FALSE, 0, 18, 'varchar(3)', 8);


INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee)
VALUES ('IFN', 'DIAM_MOY');

COMMIT;
------------------------------------------------------------------------------------------------

BEGIN;

-- mise à jour de g3forêt
WITH maj as(
	SELECT npp, LEAST((ROUND(sum(d13 * WAC) / sum(wac)*100)::NUMERIC), 130) as diam_moy
	FROM inv_exp_nm.g3arbre
	GROUP BY npp)
UPDATE inv_exp_nm.g3foret g3f
SET diam_moy = m.diam_moy
FROM maj m
WHERE g3f.npp = m.npp;

-- mise à jour de p3point où la donnée n'existait pas
WITH maj as(
	SELECT npp, LEAST((ROUND(sum(d13 * WAC) / sum(wac)*100)::NUMERIC), 130) as diam_moy
	FROM inv_exp_nm.p3arbre
	GROUP BY npp)
UPDATE inv_exp_nm.p3point p3p
SET diam_moy = m.diam_moy
FROM maj m
WHERE p3p.npp = m.npp;

COMMIT;

-- Vérification
SELECT incref, count(diam_moy)
FROM inv_exp_nm.g3foret
GROUP BY INCREF
ORDER BY INCREF DESC;

SELECT incref, count(diam_moy)
FROM inv_exp_nm.p3point
GROUP BY INCREF
ORDER BY INCREF DESC;


-- MAJ métadonnées
UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 19, validin = 0, validout = 19
WHERE famille = 'INV_EXP_NM'
AND donnee = 'DIAM_MOY';




-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_V0';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_V0';

ALTER TABLE inv_exp_nm.g3arbre DROP COLUMN v0;
ALTER TABLE inv_exp_nm.p3arbre DROP COLUMN v0;

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN v0 float8;
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN v0 float8;
	--> en base de producton
ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN v0 float8;
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN v0 float8;

-- Documentation metaifn

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('V0', NULL, 'm3', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Volume aérien total', 'Volume tige (du sol jusqu’à la cime) + branches (tous diamètres).
Tarifs de cubage issus du projet de recherche national Carbofor. Données de cubage historiques (période allant de 1920 à 1950 environ) organisées en base de données par l’INRA.');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('V0', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('V0', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Copie de la donnée à partir de U_V0

UPDATE inv_exp_nm.g3arbre g
SET v0 = ug.u_v0
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre g
SET v0 = ug.u_v0
FROM inv_exp_nm.u_p3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 19, validin = 0, validout = 19
WHERE donnee = 'V0';

s


/* -- Contrôle
SELECT incref, count(v0), avg(v0), sum(v0)
FROM inv_exp_nm.g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(v0), avg(v0), sum(v0)
FROM inv_exp_nm.p3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(u_v0), avg(u_v0), sum(u_v0)
FROM inv_exp_nm.u_g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(u_v0), avg(u_v0), sum(u_v0)
FROM inv_exp_nm.u_p3arbre
GROUP BY incref
ORDER BY incref DESC;
*/

/*
-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_v0;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_v0;
*/

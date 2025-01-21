
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_V0';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_V0';

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN v0 float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN v0 float(8);

-- Documentation metaifn

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('V0', NULL, 'm3', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Volume aérien total', 'Volume tige (du sol jusqu’à la cime) + branches (tous diamètres).
Tarifs de cubage issus du projet de recherche national Carbofor. Données de cubage historiques (période allant de 1920 à 1950 environ) organisées en base de données par l’INRA.');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('V0', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('V0', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_BIOM_AR

UPDATE inv_exp_nm.g3arbre g
SET v0 = ug.u_v0
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET v0 = up.u_v0
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;


-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_v0;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_v0;


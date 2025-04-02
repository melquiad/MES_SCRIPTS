
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_PV0';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_PV0';

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN pv0 float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN pv0 float(8);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN pv0 float(8);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN pv0 float(8);

-- Documentation metaifn

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('PV0', NULL, 'm3/an', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Production annuelle en volume aérien total', 'Production annuelle définie à partir du volume aérien total de l arbre');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('PV0', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('PV0', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_PV0

UPDATE inv_exp_nm.g3arbre g
SET pv0 = ug.u_pv0
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET pv0 = up.u_pv0
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;

/*-- contrôle
SELECT incref, avg(pv0), count(pv0)
FROM inv_exp_nm.g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, avg(pv0), count(pv0)
FROM inv_exp_nm.p3arbre
GROUP BY incref
ORDER BY incref DESC;
*/

-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_pv0;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_pv0;


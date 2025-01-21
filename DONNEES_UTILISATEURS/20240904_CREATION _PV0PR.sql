
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_PV0PR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_PV0PR';

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN pv0pr float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN pv0pr float(8);

-- Documentation metaifn

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('PV0PR', NULL, 'm3/an', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Actualisation du volume aérien total prélevé', 'Valeur de l actualisation du volume aérien total prélevé (accroissement en volume annualisé à mi-période)');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('PV0PR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('PV0PR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_BIOM_AR

UPDATE inv_exp_nm.g3arbre g
SET pv0pr = ug.u_pv0pr
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET pv0pr = up.u_pv0pr
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;


-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_pv0pr;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_pv0pr;


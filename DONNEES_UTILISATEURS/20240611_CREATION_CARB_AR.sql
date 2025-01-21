
-- On crée les champs dans g3arbre et p
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN carb_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN carb_ar float(8);

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('NTC', 'IFN', 'CONTINU', 'Tonne de carbone', 'Tonne de carbone');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('CARB_AR', NULL, 'MMS', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Stock de carbone aerien et racinaire', 'Stock de carbone aerien et racinaire');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('CARB_AR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('CARB_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_CARB_AR

UPDATE inv_exp_nm.g3arbre g
SET carb_ar = ug.u_carb_ar
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET carb_ar = up.u_carb_ar
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;


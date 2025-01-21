
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_BIOM_AR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_BIOM_AR';

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN biom_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN biom_ar float(8);

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('MMS', 'IFN', 'CONTINU', 'Masse de matière sèche', 'Masse de matière sèche');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('BIOM_AR', NULL, 'MMS', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Biomasse aerienne et racinaire', 'Biomasse aerienne et racinaire');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_BIOM_AR

UPDATE inv_exp_nm.g3arbre g
SET biom_ar = ug.u_biom_ar
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET biom_ar = up.u_biom_ar
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;


/*-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_biom_ar;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_biom_ar;
*/

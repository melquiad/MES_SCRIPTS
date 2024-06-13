
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN biom_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN biom_ar float(8);



-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('BIOM_AR', NULL, 'BIOGEO', 'IFN', NULL, 2, 'float', 'CC', TRUE, TRUE, 'Domaines biogéographiques (sens UE)', 'Domaines biogéographiques atlantique, continental, méditérannéen, alpin définis par l UE pour la directive habitat, faune, flore. Couche IG INPN 2017, datée 2002');

-- Partie champ
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float', 1);
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float', 1);
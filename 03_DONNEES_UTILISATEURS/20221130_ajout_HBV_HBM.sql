-------------------------------------- Ajout HBV et HBM ---------------------------------------------
--------------------------------------------------------------------------------------------------------
-- en base d'exploitation --

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN hbv real;
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN hbv real;

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN hbm real;
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN hbm real;

-- en base de production -- (à ne pas jouer en base de développement) --

ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN hbv real;
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN hbv real;

ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN hbm real;
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN hbm real;

SET enable_nestloop = FALSE;

UPDATE inv_exp_nm.g3arbre g
SET hbv = m.hbv_dm/10
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE g.npp = v.npp AND g.a = m.a AND v.annee >= 2020 ;

UPDATE inv_exp_nm.p3arbre p
SET hbv = m.hbv_dm/10
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE p.npp = v.npp AND p.a = m.a AND v.annee >= 2020 ;
--------------------------------------------------------
UPDATE inv_exp_nm.g3arbre g
SET hbm = m.hbm_dm/10
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE g.npp = v.npp AND g.a = m.a AND v.annee >= 2020 ;

UPDATE inv_exp_nm.p3arbre p
SET hbm = m.hbm_dm/10
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE p.npp = v.npp AND p.a = m.a AND v.annee >= 2020 ;

-- en base d'exploitation -- documentation dans METAIFN (données quantitatives) ----------------

SELECT * FROM metaifn.ajoutdonnee('HBV', NULL, 'm', 'IFN', NULL, 0, 'real', 'LT', TRUE, TRUE, 'Hauteur de la première branche vivante', 'Longueur en mètres depuis le niveau de base jusqu’au niveau de la première branche vivante');
SELECT * FROM metaifn.ajoutdonnee('HBM', NULL, 'm', 'IFN', NULL, 0, 'real', 'LT', TRUE, TRUE, 'Hauteur de la première branche morte', 'Longueur en mètres depuis le niveau de base jusqu’au niveau de la première branche morte');

SELECT * FROM metaifn.ajoutchamp('HBV', 'G3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'float4', NULL);
SELECT * FROM metaifn.ajoutchamp('HBV', 'P3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'float4', NULL);
SELECT * FROM metaifn.ajoutchamp('HBM', 'G3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'float4', NULL);
SELECT * FROM metaifn.ajoutchamp('HBM', 'P3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'float4', NULL);

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 16, validin = 15, validout = 16, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee = 'HBV';

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 16, validin = 15, validout = 16, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee = 'HBM';

--INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) VALUES ('IFN', 'HBV');
--INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) VALUES ('IFN', 'HBM');

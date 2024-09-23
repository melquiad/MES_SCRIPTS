

-- Documentation de la donnée

	-- création de l'unité U_EFT_TYPE (European Forest Types type)
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_EFT_TYPE', 'AUTRE', 'NOMINAL', 'Méthode d obtention de la donnée EFT', 'Méthode d obtention de la donnée EFT');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_EFT_TYPE', 'B', 0, 0, 1, 'Croisement avec la BD Forêt', 'Croisement avec la BD Forêt')
, ('U_EFT_TYPE', 'C', 1, 1, 1, 'Croisement avec CARHAB', 'Croisement avec CARHAB')
, ('U_EFT_TYPE', 'T', 2, 2, 1, 'Calcul à partir des données terrain', 'Calcul à partir des données terrain');


-- Création de la donnée

ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_eft_type char(1);

SELECT * FROM metaifn.ajoutdonnee('U_EFT_TYPE', NULL, 'U_EFT_TYPE', 'AUTRE', NULL, 2, 'char(1)', 'CT', TRUE, TRUE, $$Méthode d obtention de la donnée EFT$$, $$Caractérisation de la méthode de calcul de la donnée EFT.$$);

SELECT * FROM metaifn.ajoutchamp('U_EFT_TYPE', 'U_E2POINT', 'INV_EXP_NM', FALSE, 12, NULL, 'bpchar', 1);


----------------------------------------------------------
SELECT * FROM metaifn.abunite WHERE unite = 'U_EFT_TYPE';

SELECT * FROM metaifn.abmode WHERE unite = 'U_EFT_TYPE';

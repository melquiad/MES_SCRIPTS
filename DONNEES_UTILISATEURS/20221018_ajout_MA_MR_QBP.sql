-------------------------------------- Ajout MA ---------------------------------------------
--------------------------------------------------------------------------------------------------------
-- en base d'exploitation --

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN ma bpchar(1);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN ma bpchar(1);

-- en base de production -- (à ne pas jouer en base de développement) --

ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN ma bpchar(1);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN ma bpchar(1);

SET enable_nestloop = FALSE;

UPDATE inv_exp_nm.g3arbre g
SET ma = s.ma
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.sante s USING (id_ech, id_point)
WHERE g.npp = v.npp AND g.a = s.a AND g.incref >= 15;

UPDATE inv_exp_nm.p3arbre p
SET ma = s.ma
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.sante s USING (id_ech, id_point)
WHERE p.npp = v.npp AND p.a = s.a AND p.incref >= 15;

-- en base d'exploitation --

SELECT * FROM metaifn.ajoutchamp('MA', 'G3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('MA', 'P3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 16, validin = 15, validout = 16, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee = 'MA';

------------------------------------- Ajout MR -------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- en base d'exploitation --

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN mr bpchar(1);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN mr bpchar(1);

-- en base de production -- (à ne pas jouer en base de développement) --

ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN mr bpchar(1);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN mr bpchar(1);

SET enable_nestloop = FALSE;

UPDATE inv_exp_nm.g3arbre g
SET mr = s.mr
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.sante s USING (id_ech, id_point)
WHERE g.npp = v.npp AND g.a = s.a AND g.incref >= 15;

UPDATE inv_exp_nm.p3arbre p
SET mr = s.mr
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.sante s USING (id_ech, id_point)
WHERE p.npp = v.npp AND p.a = s.a AND p.incref >= 15;

-- en base d'exploitation --

SELECT * FROM metaifn.ajoutchamp('MR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('MR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 16, validin = 15, validout = 16, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee = 'MR';

---------------------------------------- Ajout QBP --------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- en base d'exploitation --

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN qbp bpchar(1);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN qbp bpchar(1);

-- en base de production -- (à ne pas jouer en base de développement) --

ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN qbp bpchar(1);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN qbp bpchar(1);

SET enable_nestloop = FALSE;

UPDATE inv_exp_nm.g3arbre g
SET qbp = m.qbp
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE g.npp = v.npp AND g.a = m.a AND g.incref >= 15;

UPDATE inv_exp_nm.p3arbre p
SET qbp = m.qbp
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.arbre_m1 m USING (id_ech, id_point)
WHERE p.npp = v.npp AND p.a = m.a AND p.incref >= 15;

-- en base d'exploitation --

SELECT * FROM metaifn.ajoutchamp('QBP', 'G3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('QBP', 'P3ARBRE', 'INV_EXP_NM', FALSE, 15, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 16, validin = 15, validout = 16, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee = 'QBP';

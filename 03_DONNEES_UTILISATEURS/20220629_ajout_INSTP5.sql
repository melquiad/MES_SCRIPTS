-- en base d'exploitation --

ALTER TABLE inv_exp_nm.g3foret ADD COLUMN instp5 bpchar(1);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN instp5 bpchar(1);


-- en base de production -- (à ne pas jouer en base de développement) --

ALTER FOREIGN TABLE inv_exp_nm.g3foret ADD COLUMN instp5 bpchar(1);
ALTER FOREIGN TABLE inv_exp_nm.p3point ADD COLUMN instp5 bpchar(1);

UPDATE inv_exp_nm.g3foret g
SET instp5 = d.instp5
FROM inv_prod_new.v_liste_points_lt2 v
INNER JOIN inv_prod_new.descript_m2 d USING (id_ech, id_point)
WHERE g.npp = d.npp;

UPDATE inv_exp_nm.p3point p
SET instp5 = d.instp5
FROM inv_prod_new.v_liste_points_lt2 v
INNER JOIN inv_prod_new.descript_m2 d USING (id_ech, id_point)
WHERE p.npp = d.npp;

-- en base d'exploitation --

SELECT * FROM metaifn.ajoutchamp('INSTP5', 'G3FORET', 'INV_EXP_NM', FALSE, 10, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('INSTP5', 'P3POINT', 'INV_EXP_NM', FALSE, 10, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 10, calcout = 0, validin = 10, validout = 0
WHERE famille = 'inv_exp_nm'
AND donnee = 'instp5';

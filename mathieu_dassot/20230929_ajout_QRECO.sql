
-- à lancer en base d'exploitation --
ALTER TABLE inv_exp_nm.e2point ADD COLUMN qreco bpchar(2);

-- à lancer en base de production -- (à ne pas jouer en base de développement) --
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN qreco bpchar(2);

UPDATE inv_exp_nm.e2point e
SET qreco = p.qreco
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.point_lt p USING (id_ech, id_point)
WHERE e.npp = v.npp;

-- à lancer en base d'exploitation --
SELECT * FROM metaifn.ajoutchamp('qreco', 'e2point', 'inv_exp_nm', FALSE, 15, NULL, 'bpchar', 1); --> fonction indifférente à la casse 

UPDATE metaifn.afchamp
SET defin = 15, defout = NULL, calcin = 15, calcout = NULL
WHERE famille = 'INV_EXP_NM'
AND donnee = 'QRECO';

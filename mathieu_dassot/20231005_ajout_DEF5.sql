
-- à lancer en base d'exploitation --
ALTER TABLE inv_exp_nm.e2point ADD COLUMN def5 bpchar(1);

-- à lancer en base de production -- (à ne pas jouer en base de développement) --
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN def5 bpchar(1);

UPDATE inv_exp_nm.e2point e
SET def5 = r.def5
FROM inv_prod_new.v_liste_points_lt2 v
INNER JOIN inv_prod_new.reco_m2 r USING (id_ech, id_point)
WHERE e.npp = v.npp;

-- à lancer en base d'exploitation --
SELECT * FROM metaifn.ajoutchamp('DEF5', 'e2point', 'inv_exp_nm', FALSE, 7, NULL, 'bpchar', 1); --> fonction indifférente à la casse 

UPDATE metaifn.afchamp
SET defin = 7, defout = NULL, calcin = 7, calcout = NULL
WHERE famille = 'INV_EXP_NM'
AND donnee = 'DEF5';
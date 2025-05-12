/*
SELECT ug.npp, ug.u_tfv, ug.u_tfv_in
FROM inv_exp_nm.u_g3foret ug
WHERE incref = 18;
--AND ug.u_tfv = '1'
--AND u_tfv_in NOT IN (SELECT ug.u_tfv FROM inv_exp_nm.u_g3foret ug); --> 0 points


SELECT up.npp, up.u_tfv, up.u_tfv_in
FROM inv_exp_nm.u_p3point up
WHERE incref = 18;
--AND up.u_tfv = '1'
--AND u_tfv_in NOT IN (SELECT up.u_tfv FROM inv_exp_nm.u_p3point up); --> 0 points

-- donc u_tfv = u_tfv_in quand le point est à l'intérieur de la bd forêt V2 --> d'où l'intérêt de transformer u_tfv_in en donnée zonage.
*/
----------------------------------------------------------------------------------------------------------------------------------------


-- On crée les champs dans e2point
ALTER TABLE inv_exp_nm.e2point ADD COLUMN tfv_in char(1);
	--> en base de producton
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN tfv_in char(1);


-- Documentation metaifn
	-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('TFV_IN', NULL, 'IN_ZONE', 'IFN', NULL, 0, 'char(1)', 'CC', TRUE, TRUE, 'Inclusion dans la BDForêt v2.', 'Point dans un polygone de la BD Forêt V2.');

	-- partie champ
SELECT * FROM metaifn.ajoutchamp('TFV_IN', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 19, 'bpchar(1)', 1);


-- Calcul de la donnée TFV_IN
UPDATE pg.inv_exp_nm.g3foret ug
SET tfv_in = CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN '1' ELSE '0' END
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.p3point up
SET tfv_in = CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN '1' ELSE '0' END
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE up.npp = h.npp;





-- via DuckDB , c'est à dire dans la console

LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

/* ---------- Contrôles ------------------
SELECT count(*) FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');

SELECT count(DISTINCT npp) FROM  read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');

SELECT npp , depbdv2 AS u_dep_bdfor, anrefbdv AS u_an_bdfor, codeTFVdis AS u_tfv, LEFT(dist_bdfor,1) AS u_dist_bdfor, 
	CASE WHEN LEFT(dist_bdfor,1)='1' THEN codeTFVdis ELSE 'NA'
	END AS u_tfv_in
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');
*/

UPDATE pg.inv_exp_nm.u_g3foret ug
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN codeTFVdis ELSE 'NA' END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.u_p3point up
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN codeTFVdis ELSE 'NA'END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv') AS h
WHERE up.npp = h.npp;


DETACH pg;

-------------------------------
/*--tests
SELECT count(npp)
FROM inv_exp_nm.u_g3foret ug
WHERE u_tfv IS NULL
AND incref = 18;

SELECT count(npp)
FROM inv_exp_nm.u_g3foret ug
WHERE u_tfv_in IS NULL
AND incref = 18;

SELECT count(npp)
FROM inv_exp_nm.u_g3foret ug
WHERE u_tfv_in = 'NA'
AND incref = 18;
*/
--------------------------------


-- Mise à jour incref 19

-- pour u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor
UPDATE pg.inv_exp_nm.u_g3foret ug
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.u_p3point up
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE up.npp = h.npp;

-- pour tfv_in
UPDATE pg.inv_exp_nm.g3foret ug
SET tfv_in = CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN '1' ELSE '0' END
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.p3point up
SET tfv_in = CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN '1' ELSE '0' END
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE up.npp = h.npp;










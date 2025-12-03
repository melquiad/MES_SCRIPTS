

-- via DuckDB
LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

---------- Contrôles du fichier ------------------
SELECT count(*) FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');

SELECT count(DISTINCT npp) FROM  read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');

SELECT npp , depbdv2 AS u_dep_bdfor, anrefbdv AS u_an_bdfor, codeTFVdis AS u_tfv, LEFT(dist_bdfor,1) AS u_dist_bdfor, 
	CASE WHEN LEFT(dist_bdfor,1)='1' THEN codeTFVdis
	END AS u_tfv_in
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv');

-----------------------------------------------------------------------------------------------------------------------
UPDATE pg.inv_exp_nm.u_g3foret ug
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN codeTFVdis END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.u_p3point up
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.depbdv2, h.anrefbdv, h.codeTFVdis, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN codeTFVdis END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi18_utfv.csv') AS h
WHERE up.npp = h.npp;


DETACH pg;




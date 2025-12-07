

-- via DuckDB
LOAD postgres;

--ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
ATTACH 'host=inv-bdd-dev.ign.fr port=5432 user=LHaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

---------- Contrôles du fichier ------------------
SELECT count(*) FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv');

SELECT count(DISTINCT npp) FROM  read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv');

SELECT npp , anref_bdfor AS u_an_bdfor, dep_bdfor AS u_dep_bdfor, tfv AS u_tfv, LEFT(dist_bdfor,1) AS u_dist_bdfor, 
	CASE WHEN LEFT(dist_bdfor,1)='1' THEN tfv
	END AS u_tfv_in
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv');

-----------------------------------------------------------------------------------------------------------------------
UPDATE pg.inv_exp_nm.u_g3foret ug
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.dep_bdfor, h.anref_bdfor, h.tfv, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN tfv END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE ug.npp = h.npp;

UPDATE pg.inv_exp_nm.u_p3point up
SET (u_dep_bdfor, u_an_bdfor, u_tfv, u_dist_bdfor, u_tfv_in) = (h.dep_bdfor, h.anref_bdfor, h.tfv, LEFT(h.dist_bdfor,1), CASE WHEN LEFT(h.dist_bdfor,1)='1' THEN tfv END)
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/marianne_duprez/ptsi19_utfv.csv') AS h
WHERE up.npp = h.npp;


DETACH pg;








-- Version DUCKDB
-- via DuckDB , c'est à dire dans la console
LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

SELECT e1.idp, pm.idp, e1.npp, e1.incref, pm.annee
FROM pg.inv_exp_nm .e1point e1
INNER JOIN read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/amael_le_squin/placettes_manquantes.csv') AS pm ON e1.idp = pm.idp;


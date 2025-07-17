
-- à faire dans DUCKDB

LOAD postgres;

--ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
ATTACH 'host=inv-bdd-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-prod.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-prod.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

SELECT * FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv');

SET enable_nestloop = FALSE;

WITH t AS (
			SELECT p.id_point, p.npp, pr.reco
			FROM pg.inv_prod_new.point p
			INNER JOIN read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv') AS pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
			)
UPDATE pg.inv_prod_new.point_lt pl
SET reco = t.reco
FROM t
WHERE pl.id_point = t.id_point
AND pl.id_ech IN (144, 145);
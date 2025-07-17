
-- Version DUCKDB
-- via DuckDB , c'est à dire dans la console
LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

SELECT * FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv');

SELECT * FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv') WHERE RIGHT(npp,1) = 'R';

SELECT * FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv') WHERE RIGHT(npp,1) != 'R';

/*SELECT r.npp, r.reco, p.npp, pp.id_point
FROM read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv') AS r
INNER JOIN pg.inv_prod_new.point p ON LEFT(r.npp,15) = LEFT(p.npp,15)
INNER JOIN pg.inv_prod_new.point_pi pp ON p.id_point = pp.id_point
ORDER BY r.npp;*/

SELECT pl.id_ech, pl.id_point, p.id_point, p.npp, pr.npp, pr.reco
FROM pg.inv_prod_new.point_lt pl
INNER JOIN pg.inv_prod_new.point p ON pl.id_point = p.id_point
INNER JOIN read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv') AS pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
WHERE pl.id_ech IN (144,145);


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




------------------------------- Version en créant la table ------------------------------------------------
CREATE TABLE public.pi2026_reco3
	(
	lotpi SMALLINT,
    npp CHARACTER(16) NOT NULL,
    reco CHARACTER(1),
    CONSTRAINT pi2026_reco3_pkey PRIMARY KEY (npp)
	)WITH (
  OIDS=FALSE
 );

\COPY public.pi2026_reco3 FROM '/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2026/pi2026_reco3.csv' WITH CSV HEADER DELIMITER ',' NULL AS 'NA';


SELECT pl.id_ech, pl.id_point, p.id_point, p.npp, pr.npp, pr.reco
FROM point_lt pl
INNER JOIN point p ON pl.id_point = p.id_point
INNER JOIN public.pi2026_reco3 pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
WHERE pl.id_ech IN (144,145);

-----------------------------------------------------------------------------
TABLE public.points_tir_final;
TABLE public.pi2026_reco3 ORDER BY npp;
TABLE public.points;
TABLE public.point_lt2;

SELECT pl.id_ech, pl.id_point, pr.npp, pr.reco--, p.id_point, p.npp
FROM public.points_tir_final pl
--INNER JOIN inv_prod_new.point p ON pl.id_point = p.id_point
--INNER JOIN public.pi2026_reco3 pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
INNER JOIN public.pi2026_reco3 pr ON pl.npp = pr.npp
WHERE pl.id_ech IN (144) AND pr.lotpi = '10'
ORDER BY npp;  --> 5 points

SELECT pl.id_ech_ph2, pl.id_point, pr.npp, pr.reco--, p.id_point, p.npp
FROM public.points pl
--INNER JOIN inv_prod_new.point p ON pl.id_point = p.id_point
--INNER JOIN public.pi2026_reco3 pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
INNER JOIN public.pi2026_reco3 pr ON pl.npp = pr.npp
WHERE pl.id_ech_ph2 IN (144) AND pr.lotpi = '10'
ORDER BY npp; --> 392 points

SELECT pl.id_ech, pl.id_point, pr.npp, pr.reco--, p.id_point, p.npp
FROM public.point_lt2 pl
--INNER JOIN inv_prod_new.point p ON pl.id_point = p.id_point
--INNER JOIN public.pi2026_reco3 pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
INNER JOIN public.pi2026_reco3 pr ON pl.npp = pr.npp
WHERE pl.id_ech IN (144) AND pr.lotpi = '10'
ORDER BY npp; --> 5 points


WITH t AS
(
SELECT p.npp, pl.id_point, pl.id_ech
FROM point_lt pl
INNER JOIN point p USING (id_point)
WHERE id_ech = 144
AND pl.id_point NOT IN (SELECT id_point FROM public.points_tir_final)
ORDER BY npp
)
SELECT t.id_ech, t.id_point, t.npp, pr.npp, pr.reco
FROM t
INNER JOIN public.pi2026_reco3 pr ON t.npp = pr.npp; --> 387



SELECT p.npp, pl.id_point, pl.id_ech
FROM point_lt pl
INNER JOIN point p USING (id_point)
INNER JOIN public.pi2026_reco3 pr ON p.npp = pr.npp
WHERE id_ech = 144
AND pl.id_point NOT IN (SELECT id_point FROM public.points_tir_final)
ORDER BY npp;

SELECT p.npp, pl.id_point, pl.id_ech, pr.reco
FROM point_lt pl
INNER JOIN point p USING (id_point)
INNER JOIN public.pi2026_reco3 pr ON p.npp = pr.npp
WHERE id_ech = 144
AND pl.id_point IN (SELECT id_point FROM public.points_tir_final)
ORDER BY npp;

--------------------------------------------------------------------------------------
SET enable_nestloop = FALSE;

WITH t AS (
			SELECT p.id_point, p.npp, pr.reco
			FROM point p
			INNER JOIN public.pi2026_reco3 pr ON LEFT(p.npp,15) = LEFT(pr.npp,15)
			)
UPDATE point_lt pl
SET reco = t.reco
FROM t
WHERE pl.id_point = t.id_point
AND pl.id_ech IN (144, 145);



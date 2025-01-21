-- via DuckDB
LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-prod.ign.fr port=5432 user=LHaugomat dbname=production' AS pg (TYPE postgres);
--ATTACH 'host=inv-prod.ign.fr port=5432 user=LHaugomat dbname=production' AS pg (TYPE postgres)


COPY
(
SELECT DISTINCT h.npp, h.idp, a.tmoy, a.rmoy
FROM read_csv('/home/lhaugomat/Documents/MES_SCRIPTS/henri_cuny/donnees_arbres_XDM_extraction_Cedric.csv') AS h
INNER JOIN pg.inv_exp_nm.e1point e USING (idp)
INNER JOIN pg.inv_exp_nm.point_aurelhy p ON right(e.npp, -1) = right(p.npp, -1)
INNER JOIN pg.carto_exo.aurelhy_an a ON p.id_pt = a.id_pt
WHERE a.annee_deb = 1991
ORDER BY h.npp
) TO  'XDM_aurelhy.csv' (FORMAT CSV, DELIMITER ',', HEADER);

























-- version Cédric
SELECT DISTINCT f.npp, f.idp, aa.tmoy, aa.rmoy
FROM read_csv('/home/lhaugomat/Documents/MES_SCRIPTS/henri_cuny/donnees_arbres_XDM_extraction_Cedric.csv') AS f
INNER JOIN pg.inv_exp_nm.e1point p1 USING (idp)
INNER JOIN pg.inv_exp_nm.point_aurelhy pa ON right(p1.npp, -1) = right(pa.npp, -1)
INNER JOIN pg.carto_exo.aurelhy_an aa ON pa.id_pt = aa.id_pt
WHERE a.annee_deb = 1991
ORDER BY h.npp;

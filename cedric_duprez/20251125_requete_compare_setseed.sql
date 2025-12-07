

LOAD postgres;
--ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg1 (TYPE postgres);
--ATTACH 'host=test-inv-prod.ign.fr port=5432 user=LHaugomat dbname=production' AS pg1 (TYPE postgres);
--ATTACH 'host=inv-prod.ign.fr port=5432 user=LHaugomat dbname=production' AS pg1 (TYPE postgres);
ATTACH 'host=inv-bdd-dev.ign.fr port=5432 user=LHaugomat dbname=inventaire' AS pg2 (TYPE postgres);


SELECT *
FROM postgres_query('pg1', '
SELECT p.npp, p.nph, p.code_pt AS poi, pe.id_noeud, round((st_x(st_transform(p.geom, 27572)))::NUMERIC) AS xl, round((st_y(st_transform(p.geom, 27572)))::NUMERIC) AS yl
, c.millesime AS campagne, pe.poids, pe.regn, pe.ser_86, pe.ser_alluv, pe.dep, pe.commune
FROM ifn_prod.point p
INNER JOIN ifn_prod.point_ech pe USING (id_point)
INNER JOIN ifn_prod.echantillon e USING (id_ech)
INNER JOIN ifn_prod.campagne c USING (id_campagne)
WHERE pe.id_ech = 147')
EXCEPT
SELECT *
FROM postgres_query('pg2', '
SELECT p.npp, p.nph, p.code_pt AS poi, pe.id_noeud, round((st_x(st_transform(p.geom, 27572)))::NUMERIC) AS xl, round((st_y(st_transform(p.geom, 27572)))::NUMERIC) AS yl
, c.millesime AS campagne, pe.poids, pe.regn, pe.ser_86, pe.ser_alluv, pe.dep, pe.commune
FROM ifn_prod.point p
INNER JOIN ifn_prod.point_ech pe USING (id_point)
INNER JOIN ifn_prod.echantillon e USING (id_ech)
INNER JOIN ifn_prod.campagne c USING (id_campagne)
WHERE pe.id_ech = 147');


SELECT *
FROM postgres_query('pg1', '
SELECT npp, id_noeud
, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 2027 AS campagne
, poids, regn, ser_86, ser_alluv, dep, commune
FROM pts_new
ORDER BY npp')
EXCEPT
SELECT *
FROM postgres_query('pg2', '
SELECT p.npp, pe.id_noeud, round((st_x(st_transform(p.geom, 27572)))::NUMERIC) AS xl, round((st_y(st_transform(p.geom, 27572)))::NUMERIC) AS yl
, c.millesime AS campagne, pe.poids, pe.regn, pe.ser_86, pe.ser_alluv, pe.dep, pe.commune
FROM ifn_prod.point p
INNER JOIN ifn_prod.point_ech pe USING (id_point)
INNER JOIN ifn_prod.echantillon e USING (id_ech)
INNER JOIN ifn_prod.campagne c USING (id_campagne)
WHERE pe.id_ech = 147');





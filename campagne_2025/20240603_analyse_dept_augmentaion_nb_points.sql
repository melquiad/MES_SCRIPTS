
SELECT c.millesime AS annee, pe.dep AS departement, count(*) AS nb_pts_pi
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN point_pi pp USING (id_ech, id_point)
--INNER JOIN sig_inventaire.dir_2024 d ON st_intersects(p.geom, d.geom)
WHERE c.millesime IN (2018, 2019, 2020, 2021, 2022, 2023, 2025)
AND e.passage = 1
AND pp.cso IN ('1', '3')
AND pp.uspi = 'X'
--AND d.ex = '04'
GROUP BY 2, 1
ORDER BY 2, 1;


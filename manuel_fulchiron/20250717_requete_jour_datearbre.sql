
SELECT EXTRACT(dow from date '2025-07-14');

SELECT a.id_ech, a.id_point, a.a, a.datearbre,TO_CHAR(datearbre,'Day') AS day_of_week
FROM arbre_2014 a
WHERE datearbre IS NOT NULL;
----------------------------------------------------------------------------------------------------------------------


SELECT d.dir, TO_CHAR(a.datearbre,'Day') AS jour, count(a.datearbre)--, pe.id_ech, p.npp, a.id_point, a.a c.millesime AS annee
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN arbre_2014 a USING (id_ech, id_point)
INNER JOIN sig_inventaire.dir_2024 d ON st_intersects(p.geom,d.geom)
WHERE a.datearbre IS NOT NULL
AND d.ex IN ('01','05')
-- AND c.millesime IN (2022,2023,2024,2025)
GROUP BY d.dir, jour;


SELECT d.dir, DATE_PART('dow', a.datearbre) AS num_jour, CASE WHEN DATE_PART('dow', a.datearbre) = 0 THEN 'Dimanche'
				   WHEN DATE_PART('dow', a.datearbre) = 1 THEN 'Lundi'
				   WHEN DATE_PART('dow', a.datearbre) = 2 THEN 'Mardi'
				   WHEN DATE_PART('dow', a.datearbre) = 3 THEN 'Mercredi'
				   WHEN DATE_PART('dow', a.datearbre) = 4 THEN 'Jeudi'
				   WHEN DATE_PART('dow', a.datearbre) = 5 THEN 'Vendredi'
				   WHEN DATE_PART('dow', a.datearbre) = 6 THEN 'Samedi'
				   ELSE NULL
				   END AS jour
, count(a.datearbre)--, pe.id_ech, p.npp, a.id_point, a.a c.millesime AS annee
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN arbre_2014 a USING (id_ech, id_point)
INNER JOIN sig_inventaire.dir_2024 d ON st_intersects(p.geom,d.geom)
WHERE a.datearbre IS NOT NULL
AND d.ex IN ('01','05')
-- AND c.millesime IN (2022,2023,2024,2025)
GROUP BY d.dir, num_jour
ORDER BY num_jour;






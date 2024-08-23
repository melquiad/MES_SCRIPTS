SET enable_nestloop = FALSE;
SET enable_nestloop = TRUE;

SELECT DISTINCT p.npp, g.notation, g.descr
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN carto_exo.carte_geol g ON st_intersects(p.geom,g.geometry)
WHERE c.millesime BETWEEN 2005 AND 2025
ORDER BY npp;

-- avec buffer
SELECT DISTINCT p.npp, g.notation, g.descr
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN carto_exo.carte_geol g ON st_intersects(st_buffer(p.geom,20),g.geometry)
WHERE c.millesime IN (2024,2025)
ORDER BY npp;
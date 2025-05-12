SET enable_nestloop = FALSE;
SET enable_nestloop = TRUE;
SET search_path = public, inv_prod_new;

SELECT DISTINCT p.npp, g.notation, g.descr
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN carto_exo.carte_geol g ON st_intersects(p.geom,g.geometry)
--INNER JOIN sig_inventaire.carte_geol g ON st_intersects(p.geom,g.geometry) --> à jouer sur inv-prod ou test-inv-prod
WHERE c.millesime = 2025
ORDER BY npp;

-- avec buffer de 25m
SELECT DISTINCT p.npp, g.notation, g.descr
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN carto_exo.carte_geol g ON st_intersects(st_buffer(p.geom,25),g.geometry)
--INNER JOIN sig_inventaire.carte_geol g ON st_intersects(st_buffer(p.geom,25),g.geometry) --> à jouer sur inv-prod ou test-inv-prod
WHERE c.millesime = 2025
ORDER BY npp;

-- avec buffer de 50m
SELECT DISTINCT p.npp, g.notation, g.descr
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN carto_exo.carte_geol g ON st_intersects(st_buffer(p.geom,50),g.geometry)
WHERE c.millesime IN (2025)
ORDER BY npp;

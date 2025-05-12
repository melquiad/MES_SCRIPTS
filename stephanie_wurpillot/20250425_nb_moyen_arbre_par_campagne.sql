SET enable_nestloop = FALSE;

SELECT c.millesime, e.id_ech, p.npp, pl.id_point, count(p.npp)
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
WHERE c.millesime = 2024
GROUP BY c.millesime, e.id_ech, p.npp, pl.id_point
ORDER BY npp;
--------------------------------------------------------------------
SELECT millesime, round(avg(nb_arbres),2) FROM (
					SELECT c.millesime, p.npp, count(p.npp) AS nb_arbres
					FROM campagne c
					INNER JOIN echantillon e USING (id_campagne)
					INNER JOIN point_ech pe USING (id_ech)
					INNER JOIN point p USING (id_point)
					INNER JOIN point_lt pl USING (id_ech, id_point)
					INNER JOIN arbre a USING (id_ech, id_point)
--					INNER JOIN arbre_m1 a1 USING (id_ech, id_point)
--					INNER JOIN arbre_m2 a2 USING (id_ech, id_point)
					WHERE c.millesime BETWEEN 2005 AND 2024
					GROUP BY c.millesime, p.npp
					)
GROUP BY millesime
ORDER BY millesime DESC;
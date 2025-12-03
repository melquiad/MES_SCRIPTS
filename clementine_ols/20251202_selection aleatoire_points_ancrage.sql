

SELECT setseed(0.5);

SELECT random();

BEGIN
FOR depa IN SELECT dep FROM deps_2002_rep
LOOP

SELECT p.npp, pl.id_point, pe.dep
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
WHERE c.millesime = 2025
AND dep = '44'
ORDER BY random()
LIMIT 20;

END LOOP;
END;















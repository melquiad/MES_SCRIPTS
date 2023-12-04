
SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee >=2007 AND pe.dep IN ('26','38')
UNION
SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee >=2007 AND pe.dep IN ('26','38')
UNION
SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee >=2007 AND pe.dep IN ('26','38');

---------------------------------------------------------------------------------------------------------------

SELECT p.npp, pe.dep, c.millesime as annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM point_lt lt
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN echantillon e USING(id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime  >=2007 AND pe.dep IN ('26','38');
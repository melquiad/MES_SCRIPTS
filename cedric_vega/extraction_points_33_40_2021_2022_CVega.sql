SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee IN (2021,2022) AND pe.dep IN ('33','40')
UNION
SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee IN (2021,2022) AND pe.dep IN ('33','40')
UNION
SELECT vlpl.npp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vlpl.annee IN (2021,2022) AND pe.dep IN ('33','40');
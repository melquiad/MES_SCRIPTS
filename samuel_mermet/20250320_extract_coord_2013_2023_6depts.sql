
SHOW search_path;
SET search_path = inv_prod_new, inv_exp_nm, public, topology;

SET enable_nestloop = FALSE;

SELECT v.npp, p.id_point, pe.id_ech, pe.dep, v.annee, d.deppr, pm.posipr
, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN descript_m1 d USING (id_ech, id_point)
INNER JOIN point_m1 pm USING (id_ech, id_point)
WHERE pe.dep IN ('16', '17', '24', '33', '40', '47' ) AND v.annee BETWEEN 2013 AND 2023
UNION 
SELECT v.npp, p.id_point, pe.id_ech, pe.dep, v.annee, d.deppr, pm.posipr
, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN descript_m1 d USING (id_ech, id_point)
INNER JOIN point_m1 pm USING (id_ech, id_point)
WHERE pe.dep IN ('16', '17', '24', '33', '40', '47' ) AND v.annee BETWEEN 2013 AND 2023
ORDER BY annee, npp;

SET enable_nestloop = TRUE;


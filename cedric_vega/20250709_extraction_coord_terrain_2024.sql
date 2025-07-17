-- Sélection des coordonnées des points phase 2 pour 2024

SELECT ep2.npp, ep2.incref, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93 
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
WHERE incref IN ('19');
----------------------------------------------------------------------------------------------------------
-- Sélection des coordonnées des points terrain pour 2024 

SELECT p.npp, e.id_ech, p.id_point, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN v_liste_points_lt1 v USING (id_point)
WHERE v.annee = 2024
AND e.phase_stat = 2
UNION 
SELECT p.npp, e.id_ech, p.id_point, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN v_liste_points_lt2 v USING (id_point)
WHERE v.annee = 2024
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
UNION 
SELECT p.npp, e.id_ech, p.id_point, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN v_liste_points_lt1_pi2 v USING (id_point)
WHERE v.annee = 2024
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
ORDER BY npp;



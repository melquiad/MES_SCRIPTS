
-- en base d'exploitation
SELECT e1.dep, e1.npp, e1.incref, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e1point e1
INNER JOIN inv_exp_nm.e1coord ec ON e1.npp = ec.npp
WHERE incref BETWEEN 10 AND 19
AND dep = '11';

-- en base de production
SELECT pe.dep, p.npp, v.annee, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_pi1 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
WHERE v.annee BETWEEN 2015 AND 2024
AND pe.dep = '11';



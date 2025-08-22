

SELECT DISTINCT pe.dep, p.npp, v.annee, n.tirmax, ne.ztir--, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_pi1 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN noeud n USING (id_noeud)
INNER JOIN noeud_ech ne USING (id_noeud)
WHERE v.annee BETWEEN 2018 AND 2024
AND pe.dep = '11'
AND ne.ztir IS NOT NULL;



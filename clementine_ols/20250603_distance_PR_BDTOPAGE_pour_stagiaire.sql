

--------------------------------------------------------------------
-- Calcul à partir de la table hydro

-- en base de production
SELECT vlpl.npp, p.idp, r.csa, r2.leve, pe.dep, vlpl.annee, h.dist_tronc AS distance_troncon, h.dist_sh AS distance_surf_hydro--, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
LEFT JOIN hydro h USING (id_ech, id_point)
WHERE pe.dep = '68'
AND r2.leve = '1'
AND vlpl.annee BETWEEN 2017 AND 2023
UNION   --> pas de donnée LEVE en V2
SELECT vlpl.npp, p.idp, r.csa, r2.leve, pe.dep, vlpl.annee, h.dist_tronc AS distance_troncon, h.dist_sh AS distance_surf_hydro--, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
LEFT JOIN hydro h USING (id_ech, id_point)
WHERE pe.dep = '68'
AND r2.leve = '1'
AND vlpl.annee BETWEEN 2017 AND 2023
UNION
SELECT vlpl.npp, p.idp, r.csa, r2.leve, pe.dep, vlpl.annee, h.dist_tronc AS distance_troncon, h.dist_sh AS distance_surf_hydro--, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
LEFT JOIN hydro h USING (id_ech, id_point)
WHERE pe.dep = '68'
AND r2.leve = '1'
AND vlpl.annee BETWEEN 2017 AND 2023
ORDER BY 1;








SELECT p.id_transect, p.id_point, v.id_ech, v.aztrans 
FROM v_liste_points_pi1 v
LEFT JOIN point p USING (id_point)
WHERE v.annee = 2025;
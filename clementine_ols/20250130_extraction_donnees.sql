
SELECT pe.id_ech, p.id_point, p.npp, pl.reco, pl.qreco, r.csa, r2.utip, r2.autut, r2.bois, r2.qbois, r2.leve, r2.qleve, round(st_x(p.geom)) AS x, round(st_y(p.geom)) AS y
FROM campagne c
INNER JOIN echantillon e ON c.id_campagne = e.id_campagne
INNER JOIN point_ech pe ON e.id_ech = pe.id_ech 
INNER JOIN point p ON pe.id_point = p.id_point 
INNER JOIN point_lt pl ON pe.id_ech = pl.id_ech AND pe.id_point = pl.id_point 
INNER JOIN reconnaissance r ON pe.id_ech = r.id_ech AND pe.id_point = r.id_point 
INNER JOIN reco_2015 r2 ON pe.id_ech = r2.id_ech AND pe.id_point = r2.id_point 
WHERE c.millesime BETWEEN 2015 AND 2023;
--ORDER BY id_point;
------------------------------------------------------------------------------------------------

SELECT v1.id_ech, v1.id_point, p.npp, pl.reco, pl.qreco, r.csa, r2.utip, r2.autut, r2.bois, r2.qbois, r2.leve, r2.qleve, round(st_x(p.geom)) AS x, round(st_y(p.geom)) AS y
FROM v_liste_points_lt1 v1
INNER JOIN point p ON v1.id_point = p.id_point 
INNER JOIN point_lt pl ON v1.id_ech = pl.id_ech AND v1.id_point = pl.id_point 
INNER JOIN reconnaissance r ON v1.id_ech = r.id_ech AND v1.id_point = r.id_point 
INNER JOIN reco_2015 r2 ON v1.id_ech = r2.id_ech AND v1.id_point = r2.id_point
WHERE v1.annee BETWEEN 2015 AND 2023
UNION 
SELECT v2.id_ech, v2.id_point, p.npp, pl.reco, pl.qreco, r.csa, r2.utip, r2.autut, r2.bois, r2.qbois, r2.leve, r2.qleve, round(st_x(p.geom)) AS x, round(st_y(p.geom)) AS y
FROM v_liste_points_lt2 v2
INNER JOIN point p ON v2.id_point = p.id_point 
INNER JOIN point_lt pl ON v2.id_ech = pl.id_ech AND v2.id_point = pl.id_point 
INNER JOIN reconnaissance r ON v2.id_ech = r.id_ech AND v2.id_point = r.id_point 
INNER JOIN reco_2015 r2 ON v2.id_ech = r2.id_ech AND v2.id_point = r2.id_point
WHERE v2.annee BETWEEN 2015 AND 2023
UNION 
SELECT v3.id_ech, v3.id_point, p.npp, pl.reco, pl.qreco, r.csa, r2.utip, r2.autut, r2.bois, r2.qbois, r2.leve, r2.qleve, round(st_x(p.geom)) AS x, round(st_y(p.geom)) AS y
FROM v_liste_points_lt1_pi2 v3
INNER JOIN point p ON v3.id_point = p.id_point 
INNER JOIN point_lt pl ON v3.id_ech = pl.id_ech AND v3.id_point = pl.id_point 
INNER JOIN reconnaissance r ON v3.id_ech = r.id_ech AND v3.id_point = r.id_point 
INNER JOIN reco_2015 r2 ON v3.id_ech = r2.id_ech AND v3.id_point = r2.id_point
WHERE v3.annee BETWEEN 2015 AND 2023;
--ORDER BY p.id_point;





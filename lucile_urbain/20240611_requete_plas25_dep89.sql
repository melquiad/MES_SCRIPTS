
SELECT c.millesime AS campagne , p.npp, round(st_x(p.geom)) AS xl93, round(st_y(p.geom)) AS yl93
, r.csa, r2.tform, ep.pro_nm AS propriete, pm.pclos, pm.pdiff, dm.plas25
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe ON e.id_ech = pe.id_ech
INNER JOIN point p ON pe.id_point = p.id_point
INNER JOIN reconnaissance r ON p.id_point = r.id_point
INNER JOIN reco_2015 r2 ON r.id_point = r2.id_point
INNER JOIN point_m1 pm ON r2.id_point = pm.id_point
INNER JOIN descript_m1 dm ON pm.id_point = dm.id_point
INNER JOIN inv_exp_nm.e2point ep ON p.npp = ep.npp
WHERE  r.csa IN ('1', '3', '5')
AND dm.plas25 != '0' --NOT IN ('0', '1')
AND e.phase_stat = 2 AND e.passage = 1
AND pe.dep = '89'
AND c.millesime >= 2019
ORDER BY npp
;



--SELECT DISTINCT ON (npp) p.id_point, p.npp, i.cso, i.dbpi, i.uspi, i.dupi, i.ufpi, i.tfpi
SELECT p.id_point, p.npp, i.cso, i.dbpi, i.uspi, i.dupi, i.ufpi, i.tfpi
, i.phpi, i.pbpi,t.id_transect, f.sl_pi, f.flpi, f.repi, f.disti
, round(st_x(p.geom)) AS xl93, round(st_y(p.geom)) AS yl93
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN transect t USING (id_transect)
INNER JOIN point_pi i USING (id_ech, id_point)
LEFT JOIN fla_pi f USING (id_transect)
WHERE c.millesime BETWEEN 2019 AND 2023
ORDER BY npp, id_point;





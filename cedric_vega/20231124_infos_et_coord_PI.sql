

SELECT p.id_point, i.npp, i.annee, i.npp, i.occ, i.cso, i.dbpi, i.pbpi, i.uspi, i.ufpi, i.tfpi, i.phpi, i.blpi, i.dupi, i.datephoto
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_infos_pi1 i
INNER JOIN point p USING (npp)
INNER JOIN point_ech pe ON  p.id_point = pe.id_point
WHERE pe.dep IN ('07','48')
ORDER BY annee, npp;
-- Sélection des coordonnées des points phase 2 pour les années 2010 à 2015

SELECT ep2.npp, ep2.incref, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
WHERE incref IN (5,6,7,8,9,10,18);
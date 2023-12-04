SELECT DISTINCT ep.idp, gf.npp, gf.incref, ep.zp--, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1point ep
--INNER JOIN inv_exp_nm.e1coord ec ON ep.npp = ec.npp 
INNER JOIN inv_exp_nm.g3flore gf ON ep.npp = gf.npp
WHERE gf.incref = 17
ORDER BY idp;
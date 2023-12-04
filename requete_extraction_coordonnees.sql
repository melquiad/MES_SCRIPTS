(SELECT gf.incref, gf.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.g3foret gf ON ec.npp = gf.npp  
WHERE gf.incref BETWEEN 11 and 15 AND gf.dep IN ('54','57','67','68','88')
ORDER BY gf.incref, gf.dep)
UNION
(SELECT pp.incref, pp.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.p3point pp ON ec.npp = pp.npp
WHERE pp.incref BETWEEN 11 and 15 AND pp.dep IN ('54','57','67','68','88')
ORDER BY pp.incref, pp.dep);

(SELECT gf.incref, gf.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.g3foret gf ON ec.npp = gf.npp  
WHERE gf.incref IN (15,16) AND gf.dep IN ('01','11','24','34','61','66','72','73')
ORDER BY gf.incref, gf.dep)
union
(SELECT pp.incref, pp.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec  
INNER JOIN inv_exp_nm.p3point pp ON ec.npp = pp.npp
WHERE pp.incref IN (15,16) AND pp.dep IN ('01','11','24','34','61','66','72','73')
ORDER BY pp.incref, pp.dep);
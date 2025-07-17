-- En base locale
ALTER TABLE point ADD COLUMN geom GEOMETRY;

SELECT UpdateGeometrySRID('inv_prod_new', 'point', 'geom', 2154);
SELECT Populate_Geometry_Columns('point'::regclass);

-- ou

SELECT AddGeometryColumn ('inv_prod_new','point','geom',2154,'POINT',2);

SET search_path TO inv_prod_new, inv_exp_nm, metaifn, public, topology;

-- en base de production
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
--, r2.leve
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
--INNER JOIN reco_2015 r2 USING (id_ech, id_point)
WHERE pe.dep IN ('08','51','52','88','10','54','55','57', '67','88','68' --> Grand-Est
,'89','58','21','71','39','70','25','90'                           --> Bourgogn-Franche-Comté
,'03','63','15','42','43','69','07','01','38','26','73','74')      --> Auvergne-Rhône-Alpes
--AND r2.leve = '1'
AND vlpl.annee BETWEEN 2013 AND 2023
UNION
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
-- , r2.leve
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
WHERE pe.dep IN ('08','51','52','88','10','54','55','57','67','88','68' --> Grand-Est
,'89','58','21','71','39','70','25','90'                           --> Bourgogn-Franche-Comté
,'03','63','15','42','43','69','07','01','38','26','73','74')      --> Auvergne-Rhône-Alpes
--AND r2.leve = '1'
AND vlpl.annee BETWEEN 2013 AND 2023;


UNION   --> pas de donnée LEVE en V2
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
--, r2.leve
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
--INNER JOIN reco_2015 r2 USING (id_ech, id_point)
WHERE pe.dep IN ('08','51','52','88','10','54','55','57','67','88','68' --> Grand-Est
,'89','58','21','71','39','70','25','90'                           --> Bourgogn-Franche-Comté
,'03','63','15','42','43','69','07','01','38','26','73','74')      --> Auvergne-Rhône-Alpes
-- AND r2.leve = '1'
AND vlpl.annee BETWEEN 2013 AND 2023
ORDER BY 1;

------------------------------------------------------------
-- en base d'exploitation
SELECT ep2.npp, ep2.csa, ep2.dep, ep2.incref , ep2.datepoint, gf.datepoint5, ep2.leve
, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN prod_exp.g3foret gf ON ep2.npp = gf.npp
WHERE incref BETWEEN 8 AND 18
AND leve = '1'
AND dep IN ('08','51','52','88','10','54','55','57','67','88','68'      --> Grand-Est
,'89','58','21','71','39','70','25','90'                           --> Bourgogn-Franche-Comté
,'03','63','15','42','43','69','07','01','38','26','73','74')      --> Auvergne-Rhône-Alpes
UNION 
SELECT ep2.npp, ep2.csa, ep2.dep, ep2.incref , ep2.datepoint, pf.datepoint5, ep2.leve
, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN prod_exp.p3point pf ON ep2.npp = pf.npp
WHERE incref BETWEEN 8 AND 18
AND leve = '1'
AND dep IN ('08','51','52','88','10','54','55','57','67','88','68'      --> Grand-Est
,'89','58','21','71','39','70','25','90'                           --> Bourgogn-Franche-Comté
,'03','63','15','42','43','69','07','01','38','26','73','74')      --> Auvergne-Rhône-Alpes
ORDER BY incref, npp; 





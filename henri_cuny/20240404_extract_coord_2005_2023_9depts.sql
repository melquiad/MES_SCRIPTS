
-- en base de production
SELECT vlpl.npp, p.idp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE pe.dep IN ('07','21','43','52','58','71','73','74','89') AND vlpl.annee BETWEEN 2005 AND 2023
UNION
SELECT vlpl.npp, p.idp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE pe.dep IN ('07','21','43','52','58','71','73','74','89') AND vlpl.annee BETWEEN 2005 AND 2023
UNION
SELECT vlpl.npp, p.idp, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE pe.dep IN ('07','21','43','52','58','71','73','74','89') AND vlpl.annee BETWEEN 2005 AND 2023
ORDER BY 4,1;

-- en base d'exploitation
SELECT ep2.npp, ep2.dep, ep2.datepoint, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
WHERE incref BETWEEN 0 AND 18 AND dep IN ('07','21','43','52','58','71','73','74','89') AND ep2.datepoint IS NOT NULL
ORDER BY 2,3,1;



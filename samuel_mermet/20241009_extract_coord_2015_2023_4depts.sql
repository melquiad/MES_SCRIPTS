
-- en base de production
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
WHERE pe.dep IN ('06','48','83','88','25') AND vlpl.annee BETWEEN 2015 AND 2023
UNION
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
WHERE pe.dep IN ('06','48','83','88','25') AND vlpl.annee BETWEEN 2015 AND 2023
UNION
SELECT vlpl.npp, p.idp, r.csa, pe.dep, vlpl.annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vlpl 
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
WHERE pe.dep IN ('06','48','83','88','25') AND vlpl.annee BETWEEN 2015 AND 2023
ORDER BY 4,1;

-- en base d'exploitation
SELECT ep2.npp, ep2.csa, ep2.dep, ep2.incref , ep2.datepoint, ep2.leve
, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
WHERE incref BETWEEN 10 AND 18 AND dep IN ('06','48','83','88','25');


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- 09/10/2024

SELECT ep2.npp, ep2.csa, ep2.dep, ep2.incref , ep2.datepoint, ep2.leve
, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93, en.nppg, en.xl93 AS xnoeud_l93, en.yl93 AS ynoeud_l93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN inv_exp_nm.e1point ep1 ON ep2.npp = ep1.npp
INNER JOIN inv_exp_nm.e1noeud_coord_l2_l93 en ON ep1.nppg = en.nppg 
WHERE ep2.incref BETWEEN 10 AND 18 AND ep2.dep IN ('06','48','83','88','25')
ORDER BY ep2.npp ;






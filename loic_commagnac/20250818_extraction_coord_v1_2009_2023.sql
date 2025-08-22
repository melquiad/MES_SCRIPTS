-- en base de production
SELECT annee, npp, idp, round(st_x(geom)::numeric) AS xl93, round(st_y(geom)::numeric) AS yl93
FROM inv_prod_new.v_liste_points_lt1
INNER JOIN inv_prod_new.point USING (id_point,npp)
--INNER JOIN inv_prod_new.reco_2015 r USING (id_point)
WHERE annee BETWEEN 2009 AND 2023
--AND r.leve = '1'
ORDER BY annee DESC;

/*-- en base d'exploitation
SELECT e2.incref + 2005 AS annee, e1.idp, e2.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.e2point e2 USING (npp)
INNER JOIN inv_exp_nm.e1point e1 USING (npp)
WHERE e2.incref BETWEEN 4 AND 18
AND e2.leve = '1'
ORDER BY e1.idp;
*/


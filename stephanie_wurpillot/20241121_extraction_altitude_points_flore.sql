SELECT DISTINCT ep.idp, ep.npp, ep.incref, ep.zp--, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1point ep
--INNER JOIN inv_exp_nm.e1coord ec ON ep.npp = ec.npp 
INNER JOIN inv_exp_nm.g3flore gf ON ep.npp = gf.npp
WHERE ep.incref = 18
ORDER BY idp; --> 6083 points , il en manque 228 

------------- version 08/01/2024 suite à remarque de Cédric (en base de  production) -------------------

SET enable_nestloop = FALSE;

SELECT DISTINCT p.idp, vl1.annee, pe.zp
FROM v_liste_points_lt1 vl1
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
INNER JOIN point p ON vl1.npp = p.npp
WHERE annee = 2023
UNION
SELECT DISTINCT p.idp, vl2.annee, pe.zp
FROM v_liste_points_lt2 vl2
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
INNER JOIN point p ON vl2.npp = p.npp
WHERE annee = 2023
UNION
SELECT DISTINCT p.idp, vlp.annee, pe.zp
FROM v_liste_points_lt1_pi2 vlp
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
INNER JOIN point p ON vlp.npp = p.npp
WHERE annee = 2023
ORDER BY idp; --> 6309 points en 2023







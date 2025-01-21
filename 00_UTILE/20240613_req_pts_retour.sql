
SET enable_nestloop = FALSE;

SELECT v.annee, ep.npp, ep.leve
FROM v_liste_points_lt2 v
INNER JOIN inv_exp_nm.e2point ep USING (npp)
WHERE v.annee = 2023
AND ep.leve = '1'
AND ep.us_nm IN ('1', '5');

SELECT ep.incref + 5, count(*)
FROM v_liste_points_lt2 v
INNER JOIN inv_exp_nm.e2point ep USING (npp)
WHERE v.annee between 2010 AND 2023
AND ep.leve = '1'
AND ep.us_nm IN ('1', '5')
GROUP BY incref
ORDER BY incref DESC;

SELECT c.millesime AS annee
, count(*) AS nb_pts_tires
, count(*) FILTER (WHERE COALESCE(pointok5, '0') != '0') AS nb_pts_retrouves
, count(*) FILTER (WHERE COALESCE(pointok5, '0') != '0' AND ep.us_nm IN ('1', '5')) AS nb_pts_foret_prod_retrouves
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_lt pl USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN inv_exp_nm.e2point ep USING (npp)
LEFT JOIN point_m2 p2 USING (id_ech, id_point)
WHERE e.phase_stat = 2
AND e.type_ech = 'IFN'::bpchar
AND e.ech_parent IS NOT NULL
AND millesime BETWEEN 2010 AND 2023
AND EXISTS (
    SELECT p.id_point
    FROM point_lt pl2
    WHERE pl2.id_point = pl.id_point
    AND pl2.id_ech < pl.id_ech
)
GROUP BY annee
ORDER BY annee DESC;

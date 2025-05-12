


SELECT DISTINCT c.millesime AS annee, p.npp, p.id_point, te.id_ech, t.id_transect, t.aztrans  
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN transect_ech te USING (id_ech)
INNER JOIN transect t USING (id_transect)
INNER JOIN point p USING (id_transect)
INNER JOIN point_lt pl USING (id_point)
WHERE e.phase_stat = 2
AND e.type_ue = 'T'
AND c.millesime BETWEEN 2008 AND 2023
--AND c.millesime = 2023
ORDER BY id_transect DESC;



-----------------------------------------------------------------------------------------
SELECT t.id_transect, t.aztrans, v.annee, v.npp, v.id_point, p.idp
FROM v_liste_points_lt1 v
INNER JOIN point_lt USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN transect t USING (id_transect)
--WHERE v.annee = 2023
WHERE v.annee BETWEEN 2008 AND 2023
ORDER BY id_transect DESC;




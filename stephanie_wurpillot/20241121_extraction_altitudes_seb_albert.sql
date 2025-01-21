SET enable_nestloop = FALSE;

-- données issues du premier passage
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.zp
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
ORDER BY 1, 2; --> 6210
-----------------------------------------------------
-- données issues du deuxième passage 
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.zp
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
ORDER BY 1, 2; --> 5587



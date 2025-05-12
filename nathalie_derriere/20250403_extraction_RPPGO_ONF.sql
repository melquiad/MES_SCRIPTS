
 -- EXPORT DES DONNÉES POUR placette                  

SET enable_nestloop = FALSE;


SELECT c.millesime AS campagne   -- données issues du premier passage
, p.idp::INT4 AS idp
, d1.fouil
, d1.predom
, d1.prnr
, d1.tcnr
, d1.ornr
, d1.dispnr
, '1' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
UNION
SELECT c.millesime AS campagne  -- données issues du deuxième passage
, p.idp::INT4 AS idp
, d1.fouil
, d1.predom
, d1.prnr
, d1.tcnr
, d1.ornr
, d1.dispnr
, '2' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
AND p.idp IS NOT NULL
AND (d1.fouil, d1.predom, d1.prnr, d1.tcnr, d1.ornr, d1.dispnr) IS DISTINCT FROM  (NULL, NULL, NULL, NULL, NULL, NULL)
ORDER BY 1, 2;


--------------------------------------------------------------------
 -- EXPORT DES DONNÉES POUR sous-placette

SELECT c.millesime AS campagne  -- données issues du premier passage
, p.idp::INT4 AS idp
, r.nsnr
, r.libnr_sp
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN renouv r USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
UNION
SELECT c.millesime AS campagne  -- données issues du deuxième passage
, p.idp::INT4 AS idp
, r.nsnr
, r.libnr_sp
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN renouv r USING (id_ech, id_point)
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
AND p.idp IS NOT NULL
AND (r.nsnr, r.libnr_sp) IS DISTINCT FROM (NULL, NULL)
ORDER BY 1, 2, 3;


--------------------------------------------------------------------
 -- EXPORT DES DONNÉES POUR brin_nr

SELECT c.millesime AS campagne   -- données issues du premier passage
, p.idp::INT4 AS idp
, er.nsnr 
, er.espar
, er.chnr
, er.nint
, er.nbrou
, er.nfrot 
, er.nmixt
, a.libelle
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN espar_renouv er USING (id_ech, id_point)
LEFT JOIN metaifn.abmode a ON er.espar = a.mode AND a.unite = 'ESPAR1'
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
UNION 
SELECT c.millesime AS campagne  -- données issues du deuxième passage
, p.idp::INT4 AS idp
, er.nsnr 
, er.espar
, er.chnr
, er.nint
, er.nbrou
, er.nfrot 
, er.nmixt
, a.libelle
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN espar_renouv er USING (id_ech, id_point)
LEFT JOIN metaifn.abmode a ON er.espar = a.mode AND a.unite = 'ESPAR1'
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
AND p.idp IS NOT NULL
AND (er.nsnr , er.espar, er.chnr, er.nint, er.nbrou, er.nfrot , er.nmixt) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL)
ORDER BY 1, 2, 3;



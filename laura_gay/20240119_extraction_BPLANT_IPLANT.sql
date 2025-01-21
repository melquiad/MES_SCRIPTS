
SELECT p.npp, c.millesime, d.tplant, pl.bplant_dm, pl.iplant_dm, pl.tpespar1, pl.tpespar2--, a.a, a.age13
FROM plantations pl
INNER JOIN description d USING (id_ech, id_point)
--INNER JOIN "age" a USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
iNNER JOIN point p ON pe.id_point = p.id_point 
INNER JOIN echantillon e ON pe.id_ech = e.id_ech
INNER JOIN campagne c ON e.id_campagne = c.id_campagne
WHERE c.millesime BETWEEN 2018 AND 2022;





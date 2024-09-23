

SELECT DISTINCT ON (nppr) annee, npp, nppr, nph, vlp.id_ech, vlp.id_point, datepi, datephoto, occ, cso, dbpi, pbpi, uspi, ufpi, tfpi, phpi, blpi, dupi, evof
FROM v_liste_points_lt1_pi2 vlp
INNER JOIN point_pi pp ON vlp.id_point = pp.id_point
INNER JOIN echantillon e ON pp.id_ech = e.id_ech AND e.passage > 1
WHERE annee = 2025
ORDER BY nppr, pp.id_ech DESC;

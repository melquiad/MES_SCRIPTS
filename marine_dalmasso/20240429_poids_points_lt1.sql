

SELECT v.npp, v.annee, idp, id_campagne, millesime, lib_campagne, poids
FROM v_liste_points_lt1 v
--FROM point_LT
LEFT JOIN point_ech USING (id_ech, id_point)
LEFT JOIN point USING (id_point)
LEFT JOIN echantillon USING (id_ech)
LEFT JOIN campagne USING (id_campagne);



SELECT annee, npp, csa, tplant, tpespar1, tpespar2, dc, dcespar1
FROM inv_prod_new.v_liste_points_lt1
INNER JOIN inv_prod_new.reconnaissance USING (id_point, id_ech)
LEFT JOIN inv_prod_new.description USING (id_point, id_ech)
LEFT JOIN inv_prod_new.plantations USING (id_point, id_ech)
LEFT JOIN inv_prod_new.coupes USING (id_point, id_ech)
WHERE annee = 2015
AND csa = '5'
AND tpespar1 = '19' -- là ça ne fonctionne pas
ORDER BY annee, npp

SELECT annee, npp, csa, tplant, tpespar1, tpespar2, dc, dcespar1
FROM inv_prod_new.v_liste_points_lt1
INNER JOIN inv_prod_new.reconnaissance USING (id_point, id_ech)
LEFT JOIN inv_prod_new.description USING (id_point, id_ech)
LEFT JOIN inv_prod_new.plantations USING (id_point, id_ech)
LEFT JOIN inv_prod_new.coupes USING (id_point, id_ech)
WHERE annee = 2015
AND csa = '5'
AND tpespar1 LIKE '19%' -- là ça fonctionne
ORDER BY annee, npp

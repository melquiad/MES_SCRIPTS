
SELECT v.npp, id_ech, id_point, a, dpr_cm 
FROM arbre_m1 am
INNER JOIN v_liste_points_lt1 v USING (id_ech, id_point)
WHERE am.dpr_cm > 2500
ORDER BY npp;

SELECT npp, a, dpr
FROM g3arbre_coord
WHERE dpr > 25
ORDER BY npp;
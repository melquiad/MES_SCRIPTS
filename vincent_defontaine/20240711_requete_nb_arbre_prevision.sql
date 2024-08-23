SET enable_nestloop = FALSE; 

SELECT v.id_ech, v.npp, v.id_point, ne.id_noeud, n.tirmax, count(am.a), am.id_ech, am.simplif
FROM v_liste_points_lt2 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN noeud n ON ne.id_noeud = n.id_noeud
LEFT JOIN arbre_m1 am USING (id_point)
WHERE v.annee = 2025
GROUP BY n.tirmax, v.id_ech, v.npp, v.id_point, ne.id_noeud, am.a, am.id_ech, am.simplif;

-- nb d'arbres groupés par tirmax de l'echantillon 139 (V2 campagne 2025)
SELECT n.tirmax, count(am.a)
FROM v_liste_points_lt2 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN noeud n ON ne.id_noeud = n.id_noeud
LEFT JOIN arbre_m1 am USING (id_point)
WHERE v.annee = 2025
AND am.veget = '0' -- arbres vifs
GROUP BY n.tirmax;

-- nb d'arbres groupés par tirmax de l'echantillon 139 (V2 campagne 2025) où simplif = '0'
SELECT n.tirmax, count(am.a)
FROM v_liste_points_lt2 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN noeud n ON ne.id_noeud = n.id_noeud
LEFT JOIN arbre_m1 am USING (id_point)
WHERE v.annee = 2025
AND am.simplif = '0'
AND am.veget = '0'   -- arbres vifs
GROUP BY n.tirmax;

-- nb d'arbres groupés par tirmax de l'echantillon 139 (V2 campagne 2025) où simplif = '1'
SELECT n.tirmax, count(am.a)
FROM v_liste_points_lt2 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN noeud n ON ne.id_noeud = n.id_noeud
LEFT JOIN arbre_m1 am USING (id_point)
WHERE v.annee = 2025
AND am.simplif = '1'
AND am.veget = '0'  -- arbres vifs
GROUP BY n.tirmax;





-----------------------------------------------------------------


SELECT v.id_ech, v.npp, v.id_point, n.id_noeud, n.tirmax
FROM v_liste_points_lt2 v
LEFT JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN noeud n ON ne.id_noeud = n.id_noeud
WHERE v.annee = 2025;




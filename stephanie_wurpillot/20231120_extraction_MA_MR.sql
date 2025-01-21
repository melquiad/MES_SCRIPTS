
SET enable_nestloop = FALSE;

-- DONNÉES DES ARBRES SUR POINTS PREMIÈRE VISITE (LT1)
SELECT p.idp, vp1.annee, 'LT1' AS visite, a.a, s.ma, s.mr, s.mortb
FROM v_liste_points_lt1 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE vp1.annee = 2023
AND s.mr IS NOT NULL OR s.ma IS NOT NULL
UNION 
SELECT p.idp, vp1.annee, 'LT1' AS visite, a.a, s.ma, s.mr, s.mortb
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE vp1.annee = 2023
AND s.mr IS NOT NULL OR s.ma IS NOT NULL
ORDER BY annee DESC, idp, a;


-- DONNÉES DES ARBRES SUR POINTS DEUXIÈME VISITE (LT2)
SELECT p.idp, vp2.annee, 'LT2' AS visite, a.a, s.ma, s.mr, s.mortb
FROM v_liste_points_lt2 vp2
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE vp2.annee = 2023 --AND a.c13_mm IS NOT NULL
AND s.mr IS NOT NULL OR s.ma IS NOT NULL
ORDER BY annee, idp, a;




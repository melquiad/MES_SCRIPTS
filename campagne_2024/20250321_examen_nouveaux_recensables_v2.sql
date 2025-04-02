
SET enable_nestloop = FALSE;

SELECT v2.annee, count(*) AS nb_arbres
FROM v_liste_points_lt2 v2
INNER JOIN arbre a2 USING (id_ech, id_point)
WHERE NOT EXISTS (
			SELECT 1
			FROM v_liste_points_lt1 v1
			INNER JOIN arbre a1 USING (id_ech, id_point)
			WHERE v1.annee = v2.annee - 5
			AND v1.id_point = v2.id_point
			AND a1.a = a2.a
				)
GROUP BY annee
ORDER BY annee;
---------------------------------------------------------

SELECT v2.annee, v2.npp, v2.id_point, a2.a, am.agrafc
FROM v_liste_points_lt2 v2
INNER JOIN arbre a2 USING (id_ech, id_point)
INNER JOIN arbre_m1_2014 am USING (id_ech, id_point, a)
WHERE NOT EXISTS (
			SELECT 1
			FROM v_liste_points_lt1 v1
			INNER JOIN arbre a1 USING (id_ech, id_point)
			WHERE v1.annee = v2.annee - 5
			AND v1.id_point = v2.id_point
			AND a1.a = a2.a
				)
AND v2.annee = 2024
ORDER BY annee, npp, a;
---------------------------------------------------------------

SELECT v2.annee, count(a2.a) AS nb_arbres
, count(DISTINCT v2.id_point) AS nb_points
, round((1.0 * count(a2.a) / count(DISTINCT v2.id_point))::NUMERIC, 2) AS ratio
FROM v_liste_points_lt2 v2
LEFT JOIN arbre a2 ON v2.id_ech = a2.id_ech 
    AND v2.id_point = a2.id_point
    AND NOT EXISTS (
        SELECT 1
        FROM v_liste_points_lt1 v1
        INNER JOIN arbre a1 USING (id_ech, id_point)
        WHERE v1.annee = v2.annee - 5
        AND v1.id_point = v2.id_point
        AND a1.a = a2.a
    )
WHERE v2.annee >= 2015
GROUP BY annee
ORDER BY annee;



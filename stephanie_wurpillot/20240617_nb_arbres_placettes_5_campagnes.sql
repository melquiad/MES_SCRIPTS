
SET enable_nestloop = FALSE;

WITH t AS (
		SELECT vp1.annee, vp1.id_point, vp1.npp, count(a.a) AS nb
		FROM v_liste_points_lt1 vp1
		--INNER JOIN point p USING (id_point)
		INNER JOIN arbre a USING (id_ech, id_point)
		--WHERE vp1.annee = 2023
		WHERE vp1.annee BETWEEN 2019 AND 2023
		GROUP BY vp1.annee, vp1.id_point, vp1.npp
		UNION
		SELECT vp2.annee, vp2.id_point, vp2.npp, count(a.a)
		FROM v_liste_points_lt1_pi2 vp2
		--INNER JOIN point p USING (id_point)
		INNER JOIN arbre a USING (id_ech, id_point)
		--WHERE vp2.annee = 2023
		WHERE vp2.annee BETWEEN 2019 AND 2023
		GROUP BY vp2.annee, vp2.id_point, vp2.npp
		UNION
		SELECT vp1.annee, vp1.id_point, vp1.npp, count(a.a) AS nb
		FROM v_liste_points_lt2 vp1
		--INNER JOIN point p USING (id_point)
		INNER JOIN arbre a USING (id_ech, id_point)
		--WHERE vp1.annee = 2023
		WHERE vp1.annee BETWEEN 2019 AND 2023
		GROUP BY vp1.annee, vp1.id_point, vp1.npp
		ORDER BY annee, id_point
		)
SELECT t.annee, avg(t.nb)
FROM t
GROUP BY t.annee;


		
		
		

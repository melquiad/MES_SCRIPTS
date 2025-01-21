
SELECT v.npp, pp.id_point, pp.datephoto, d.datephoto
FROM v_liste_points_lt1_pi2 v
LEFT JOIN inv_prod_new.point_pi pp USING (id_point)
LEFT JOIN public.date_photo_point d USING (npp)
WHERE v.annee = 2025
AND pp.datephoto IS NOT NULL
AND d.datephoto IS NULL
ORDER BY v.id_point


------------------------------------------------------
SET enable_nestloop = FALSE;

WITH t AS
		(
		SELECT v.npp, v.id_point, d.datephoto
		FROM v_liste_points_lt1_pi2 v
		LEFT JOIN public.date_photo_point d USING (npp)
		WHERE v.annee = 2025 AND d.datephoto IS NULL
		ORDER BY v.npp
		)
SELECT t.npp, pp.id_point, pp.datephoto
FROM inv_prod_new.point_pi pp
INNER JOIN t USING (id_point)
WHERE t.id_point = pp.id_point AND pp.datephoto IS NOT NULL
ORDER BY t.npp;



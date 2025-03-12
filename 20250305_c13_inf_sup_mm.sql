UPDATE inv_prod_new.arbre
SET suppl = CASE 
    WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
    ELSE NULL END
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (vp.a, vp.c13_mm, vp.c13_inf_mm, vp.c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL);
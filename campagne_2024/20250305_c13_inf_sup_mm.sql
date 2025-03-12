SET enable_nestloop = FALSE;

CREATE TEMPORARY TABLE states AS (
	SELECT npp, MAX(state) AS state
	FROM soif.point_states
	WHERE anref = 2024
	GROUP BY npp
);

ALTER TABLE states ADD CONSTRAINT states_pkey PRIMARY KEY (npp);
ANALYZE states;

-- 1ere visite
WITH t AS (
		SELECT vp.npp, vp.a, v1.id_point, v1.id_ech,
					CASE  WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL)
					THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
					ELSE NULL END AS suppl
		FROM soif.v1e3arbre vp
		INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
		INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
		WHERE v1.annee = 2024
		AND (vp.a, vp.c13_mm, vp.c13_inf_mm, vp.c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
			)
--SELECT id_ech, id_point, npp, a, suppl FROM t WHERE suppl IS NOT NULL;
UPDATE inv_prod_new.arbre a
SET suppl = t.suppl
FROM t
WHERE a.id_point = t.id_point AND a.a = t.a;

--contrôle
SELECT  id_ech, id_point, a, suppl
FROM arbre
WHERE suppl IS NOT NULL
AND id_ech = 114;


--2ème visite
WITH t AS (
		SELECT vp.npp, vp.a, v1.id_point, v1.id_ech,
					CASE  WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL)
					THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
					ELSE NULL END AS suppl
		FROM soif.v2e5arbre vp
		INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
		INNER JOIN inv_prod_new.v_liste_points_lt2 v1 ON vp.npp = v1.npp
		WHERE v1.annee = 2024
		AND (vp.a, vp.c13_mm, vp.c13_inf_mm, vp.c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
			)
--SELECT id_ech, id_point, npp, a, suppl FROM t WHERE suppl IS NOT NULL;
UPDATE inv_prod_new.arbre a
SET suppl = t.suppl
FROM t
WHERE a.id_point = t.id_point AND a.a = t.a;

--contrôle
SELECT  id_ech, id_point, a, suppl
FROM arbre
WHERE suppl IS NOT NULL
AND id_ech = 115;





/*
UPDATE inv_prod_new.arbre
SET suppl = CASE 
    WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
    ELSE NULL END
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024 AND v1.id_ech = 114
AND (vp.a, vp.c13_mm, vp.c13_inf_mm, vp.c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL);
*/




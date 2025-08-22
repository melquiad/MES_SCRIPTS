
SELECT pp.id_ech, id_point, cso AS cso_2021
FROM v_liste_points_lt1_pi2 v
INNER JOIN point_pi pp  USING (id_point)
WHERE v.annee = 2026
AND pp.id_ech = 50;

SELECT pp.id_ech, id_point, cso AS cso_2024
FROM v_liste_points_lt1_pi2 v
INNER JOIN point_pi pp  USING (id_point)
WHERE v.annee = 2026
AND pp.id_ech = 111;

SELECT pp.id_ech, id_point, cso AS cso_2025
FROM v_liste_points_lt1_pi2 v
INNER JOIN point_pi pp  USING (id_point)
WHERE v.annee = 2026
AND pp.id_ech = 142; 

SELECT *
FROM point_pi
WHERE id_point = 1039311;

---------------------------------------------------------------------------------
--CREATE TEMPORARY TABLE echants AS (
WITH echants AS (
	SELECT c.id_campagne, c.millesime, e.id_ech, e.nom_ech, e.ech_parent, e.type_ue, e.type_ech, e.phase_stat, e.passage --> récupération des 2 échantillons
	FROM echantillon e
	INNER JOIN campagne c USING(id_campagne)
	INNER JOIN (
			SELECT e.id_campagne, e.id_ech, e.nom_ech, e.ech_parent
			FROM echantillon e
			INNER JOIN campagne c USING(id_campagne)
			INNER JOIN echantillon e1 ON e.ech_parent  = e1.id_ech AND e1.phase_stat = 1 AND e1.type_ue = 'P' AND e1.type_ech = 'IFN'
			WHERE c.millesime = 2026
	) e2 ON e.ech_parent = e2.ech_parent
)
--CREATE TEMPORARY TABLE echant_pts AS (
, echant_pts AS (
		SELECT DISTINCT pen.id_ech, pen.id_point, en.ech_parent, pen.dep
    	FROM echants en
    	INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    	INNER JOIN point_ech pen ON en.id_ech = pen.id_ech
    	INNER JOIN point_pi ppo ON pen.id_ech = ppo.id_ech AND pen.id_point = ppo.id_point 
    	INNER JOIN point po ON ppo.id_point = po.id_point
    	WHERE en.type_ue = 'P'
	    AND en.type_ech = 'IFN'
	    AND en.phase_stat = 1
	    AND (ppo.id_point) NOT IN (
			SELECT pp.id_point
			FROM point_pi pp 
			INNER JOIN echants e USING (id_ech)
			INNER JOIN campagne c1 ON e.id_campagne = c1.id_campagne
			WHERE c1.millesime = 2026
	    )
		UNION
	    SELECT pen.id_ech, pen.id_point, en.ech_parent, pen.dep
    	FROM echants en
    	INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    	INNER JOIN point_ech pen ON en.id_ech = pen.id_ech
    	INNER JOIN point_pi ppo ON pen.id_ech = ppo.id_ech AND pen.id_point = ppo.id_point 
    	INNER JOIN point po ON ppo.id_point = po.id_point
    	WHERE en.type_ue = 'P'
	    AND en.type_ech = 'IFN'
	    AND en.phase_stat = 1
	    AND c.millesime = 2026
--		ORDER BY id_ech, id_point
)
--CREATE TEMPORARY TABLE pts_potentiels_foret_new AS (			
, pts_potentiels_foret_new AS (
		SELECT p.npp, ppo.id_ech, ppo.id_point, ppo.cso
		FROM point_pi ppo
		INNER JOIN (SELECT DISTINCT ech_parent FROM echant_pts) ep ON ppo.id_ech = ep.ech_parent
		INNER JOIN point p ON ppo.id_point = p.id_point
		WHERE LEFT(ppo.cso, 1) = '6'
		AND NOT EXISTS (
		        SELECT 1
		        FROM fla_pi fp
		        WHERE fp.id_transect = p.id_transect
		        --AND fp.flpi NOT IN ('0','6')
		        AND fp.flpi NOT IN ('0','A')
		        AND ABS(fp.disti) <= 25)
		UNION    
		SELECT p.npp, ppo.id_ech, ppo.id_point, ppo.cso
		FROM point_pi ppo
		INNER JOIN (SELECT DISTINCT ech_parent FROM echant_pts) ep ON ppo.id_ech = ep.ech_parent
		INNER JOIN point p ON ppo.id_point = p.id_point
		WHERE ppo.cso = '7'
		AND ppo.ufpi = '1'
)	
--INSERT INTO point_lt (id_ech, id_point, formation, azpoint, decli_pt, echelon_init)
SELECT DISTINCT t.id_ech, pp.id_point, pp.cso
FROM pts_potentiels_foret_new ppfn
INNER JOIN echant_pts ep ON ppfn.id_point = ep.id_point
INNER JOIN point_pi pp ON ppfn.id_point = pp.id_point AND ep.id_ech = pp.id_ech
INNER JOIN point p ON ppfn.id_point = p.id_point
INNER JOIN point_lt pl ON p.id_point = pl.id_point
CROSS JOIN (
    SELECT id_ech
    FROM echantillon
    INNER JOIN campagne USING (id_campagne)
    WHERE type_ech = 'IFN'
    AND phase_stat = 2
    AND type_ue = 'P'
    AND passage = 2
    AND millesime = 2026
	) t
WHERE pp.evof IN ('1', '2')
AND pp.uspi = 'X';



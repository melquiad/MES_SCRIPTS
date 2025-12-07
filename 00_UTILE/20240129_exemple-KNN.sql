
-- exemple de requête utilisant la fonction "<->" k nearest neighbours

INSERT INTO inv_exp_nm.point_aurelhy (npp, id_pt)
SELECT c.npp, p.id_pt
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point e USING (npp)
JOIN LATERAL (
    SELECT id_pt
    FROM carto_exo.aurelhy_pt a
    ORDER BY c.geom <-> a.geom --> fonction KNN
    LIMIT 1 --> pour ne prendre que le plus proche
) p ON TRUE
WHERE e.incref IN (15,16,17);

----------------------------------------------------
SELECT npp, st_transform(geom,27572) AS geom_l2
FROM ifn_prod.point p;

SELECT npp, st_transform(ST_SetSRID(ST_MakePoint(xl,yl),27572),2154) AS geom
FROM soif.e1point e;

	
-----------------------------------------------------------

WITH lot AS 
		(
		SELECT p1.npp, p1.state, p.geom
		FROM ifn_prod.point p
		INNER JOIN soif.point_states p1 USING (npp)
		WHERE anref = 2025 AND state = 'E'
		)
SELECT DISTINCT l.npp, l.state, l.geom, pr.npp, pr.distance, pr.distance2, pr.geom_proche
FROM lot l
JOIN LATERAL (
		SELECT p.npp, st_distance(p.geom,l.geom) AS distance, (p.geom <-> l.geom) AS distance2, ST_ClosestPoint(p.geom,l.geom) AS geom_proche
		FROM ifn_prod.point p
		WHERE st_distance(p.geom,l.geom) > 0
		ORDER BY p.geom <-> l.geom
		LIMIT 2) pr ON TRUE;  --> PB : dans la table point il faut récupérer uniquement les points de la campagne 2025
		
------------------------------------------		
WITH lot AS 
		(
		SELECT p1.npp, p1.state, p.geom
		FROM ifn_prod.point p
		INNER JOIN soif.point_states p1 USING (npp)
		WHERE anref = 2025 AND state = 'E'
		)
SELECT DISTINCT l.npp, l.state, l.geom, pr.npp, pr.distance, pr.distance2, pr.geom_proche
FROM lot l
JOIN LATERAL (
		SELECT p.npp, st_distance(p.geom,l.geom) AS distance, (p.geom <-> l.geom) AS distance2, ST_ClosestPoint(p.geom,l.geom) AS geom_proche
		FROM campagne c
		INNER JOIN echantillon e USING (id_campagne)
		INNER JOIN point_ech pe USING (id_ech)
		INNER JOIN point p USING (id_point)
		INNER JOIN point_lt pl USING (id_ech, id_point)
		WHERE c.millesime = 2025
		AND st_distance(p.geom,l.geom) > 0
		ORDER BY p.geom <-> l.geom ASC
		LIMIT 2) pr ON TRUE;
		
		
		
		
		
		
		
		SELECT p.npp, p.geom
		FROM campagne c
		INNER JOIN echantillon e USING (id_campagne)
		INNER JOIN point_ech pe USING (id_ech)
		INNER JOIN point p USING (id_point)
		INNER JOIN point_lt pl USING (id_ech, id_point)
		WHERE c.millesime = 2025







	
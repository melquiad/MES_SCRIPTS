BEGIN;

-- pour les points 2ème visite terrain, recopie des infos hydro croisées 5 ans auparavant
INSERT INTO hydro (id_ech, id_point, dist_tronc, x_tronc, y_tronc, z_tronc, dist_sh, x_sh, y_sh, z_sh, type_sh, indrivmnt, topo_tronc)
SELECT v.id_ech, v.id_point, h.dist_tronc, h.x_tronc, h.y_tronc, h.z_tronc, h.dist_sh, h.x_sh, h.y_sh, h.z_sh, h.type_sh, h.indrivmnt, h.topo_tronc
FROM v_liste_points_lt2 v
INNER JOIN hydro h ON v.id_point = h.id_point
WHERE v.annee = 2026
ORDER BY id_ech, id_point;

-- table des points nouveaux à visiter sur le terrain sans les infos hydrographique, avec leurs coordonnées et leur numéro d'échantillon
CREATE TEMPORARY TABLE pts AS 
SELECT v.id_ech, v.id_point, p.geom, NULL::int2 AS zp
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE v.annee = 2026
UNION 
SELECT v.id_ech, v.id_point, p.geom, NULL::int2 AS zp
FROM v_liste_points_lt1_pi2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE v.annee = 2026
ORDER BY id_ech, id_point;

ALTER TABLE pts ADD CONSTRAINT pts_pkey PRIMARY KEY (id_ech, id_point);
CREATE INDEX idx_pts_geom ON pts USING GIST(geom);
ANALYZE pts;

SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
FROM geometry_columns
WHERE f_table_name = 'pts';

-- récupération de l'altitude BDAlti 2011
UPDATE pts p
SET zp = ST_Value(m.rast, p.geom)
FROM bdalti2011.mnt m
WHERE ST_Intersects(p.geom, ST_ConvexHull(m.rast));

ANALYZE pts;

-- CROISEMENT AVEC LES TRONÇONS HYDROLOGIQUES
-- tronçons les plus proches des points d'inventaire
CREATE TEMPORARY TABLE troncons_proches AS 
WITH prox AS (
	SELECT p.id_ech, p.id_point, p.zp 
	, pr.gid, pr.toponyme1, pr.distance, pr.distance2, pr.geom_proche
	FROM pts p
	JOIN LATERAL (
	   SELECT t.gid, t.toponyme1, ST_Distance(p.geom, t.geom) AS distance, p.geom <-> t.geom AS distance2, ST_ClosestPoint(t.geom, p.geom) AS geom_proche
	   FROM sig_ign.troncon_carthage_2010 t
	   ORDER BY p.geom <-> t.geom
	   LIMIT 1
	) pr ON TRUE 
)
SELECT id_ech, id_point, zp, gid, toponyme1, ROUND(distance::NUMERIC) AS distance, ROUND(distance2::NUMERIC) AS distance2, RANK() OVER(PARTITION BY id_ech, id_point ORDER BY distance) AS rang, RANK() OVER(PARTITION BY id_ech, id_point ORDER BY distance2) AS rang2
, geom_proche
FROM prox
ORDER BY id_ech, id_point;

SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
FROM geometry_columns
WHERE f_table_name = 'troncons_proches';

ALTER TABLE troncons_proches ADD CONSTRAINT troncons_proches_pkey PRIMARY KEY (id_ech, id_point);
CREATE INDEX idx_troncons_proches_geom ON troncons_proches USING GIST(geom_proche);
ANALYZE troncons_proches;

-- UPDATE troncons_proches SET geom_proche = st_makevalid(geom_proche) WHERE NOT st_isvalid(geom_proche);
CREATE TEMPORARY TABLE alti AS
SELECT tp.id_ech, tp.id_point, ST_Value(m.rast, tp.geom_proche) AS zp_troncon
FROM troncons_proches tp
INNER JOIN bdalti2011.mnt m ON ST_Intersects(tp.geom_proche, ST_ConvexHull(m.rast))
ORDER BY 1;

INSERT INTO hydro (id_ech, id_point, topo_tronc, dist_tronc, x_tronc, y_tronc, z_tronc)
WITH t0 AS (
	SELECT id_ech, id_point, min(zp_troncon) AS zp_troncon
	FROM alti
	GROUP BY id_ech, id_point
)
SELECT tp.id_ech, tp.id_point, tp.toponyme1, tp.distance, ROUND(ST_X(tp.geom_proche)) AS x_troncon, ROUND(ST_Y(tp.geom_proche)) AS y_troncon
, t0.zp_troncon
FROM troncons_proches tp
INNER JOIN t0 USING (id_ech, id_point)
ORDER BY id_ech, id_point
ON CONFLICT ON CONSTRAINT pk_hydro DO NOTHING;

DROP TABLE alti;
DROP TABLE troncons_proches;


-- CROISEMENT AVEC LES SURFACES HYDROLOGIQUES

-- tronçons les plus proches des points d'inventaire
CREATE TEMPORARY TABLE surf_proches AS 
WITH prox AS (
    SELECT p.id_ech, p.id_point, p.zp 
    , pr.gid, pr."type", pr.distance, pr.distance2, pr.geom_proche
    FROM pts p
    JOIN LATERAL (
       SELECT t.gid, t."type", ST_Distance(p.geom, t.geom) AS distance, p.geom <-> t.geom AS distance2, ST_ClosestPoint(t.geom, p.geom) AS geom_proche
       FROM sig_ign.hydro_surf_carthage_2010 t
       ORDER BY p.geom <-> t.geom
       LIMIT 1
    ) pr ON TRUE 
)
SELECT id_ech, id_point, zp, gid, "type", ROUND(distance::NUMERIC) AS distance, ROUND(distance2::NUMERIC) AS distance2, RANK() OVER(PARTITION BY id_ech, id_point ORDER BY distance) AS rang, RANK() OVER(PARTITION BY id_ech, id_point ORDER BY distance2) AS rang2
, geom_proche
FROM prox
ORDER BY id_ech, id_point;


SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
FROM geometry_columns
WHERE f_table_name = 'surf_proches';

ALTER TABLE surf_proches ADD CONSTRAINT surf_proches_pkey PRIMARY KEY (id_ech, id_point);
CREATE INDEX idx_surf_proches_geom ON surf_proches USING GIST(geom_proche);

ANALYZE surf_proches;

CREATE TEMPORARY TABLE alti AS
SELECT tp.id_ech, tp.id_point, ST_Value(m.rast, tp.geom_proche) AS zp_surf
FROM surf_proches tp
INNER JOIN bdalti2011.mnt m ON ST_Intersects(tp.geom_proche, ST_ConvexHull(m.rast))
ORDER BY 1;

WITH t0 AS (
	SELECT id_ech, id_point, min(zp_surf) AS zp_surf
	FROM alti
	GROUP BY id_ech, id_point
)
, t1 AS (
	SELECT tp.id_ech, tp.id_point
	, CASE tp."type"
		WHEN $$Bassin portuaire$$ THEN 'BP'
		WHEN $$Bassin portuaire fluvial$$ THEN 'BF'
		WHEN $$Cours d'eau$$ THEN 'CE'
		WHEN $$Ecoulement d'eau$$ THEN 'EE'
		WHEN $$En attente de mise à jour$$ THEN 'MJ'
		WHEN $$Ensemble de petits plans d'eau$$ THEN 'PP'
		WHEN $$Gravier, galet$$ THEN 'GG'
		WHEN $$Marais salant$$ THEN 'MS'
		WHEN $$Nappe d'eau$$ THEN 'NE'
		WHEN $$Plan d'eau, bassin, réservoir$$ THEN 'PE'
		WHEN $$Pleine mer$$ THEN 'PM'
		WHEN $$Rocher, sable$$ THEN 'RS'
		WHEN $$Sable humide$$ THEN 'SH'
		WHEN $$Sable, gravier$$ THEN 'SG'
		WHEN $$Traitement des eaux$$ THEN 'TE'
		WHEN $$Vase$$ THEN 'VA'
		WHEN $$Zone recouverte d'eau$$ THEN 'ZE'
		WHEN $$Zone rocheuse$$ THEN 'ZR'
		ELSE 'XX'
	  END AS type_sh
	, tp.distance, ROUND(ST_X(tp.geom_proche)) AS x_surf, ROUND(ST_Y(tp.geom_proche)) AS y_surf
	, t0.zp_surf
	FROM surf_proches tp
	INNER JOIN t0 USING (id_ech, id_point)
)
UPDATE hydro h
SET type_sh = t1.type_sh, dist_sh = t1.distance, x_sh = t1.x_surf, y_sh = t1.y_surf, z_sh = t1.zp_surf
FROM t1
WHERE h.id_ech = t1.id_ech AND h.id_point = t1.id_point;

DROP TABLE alti;
DROP TABLE surf_proches;

-- calcul de INDRIVMNT
WITH denivs AS (
	SELECT h.id_ech, h.id_point, pe.zp, h.dist_tronc, h.z_tronc, ABS(pe.zp - h.z_tronc) AS deniv_tronc
	, h.dist_sh, h.z_sh, ABS(pe.zp - h.z_sh) AS deniv_sh
	FROM hydro h
	INNER JOIN pts pe USING (id_ech, id_point)
	WHERE h.indrivmnt IS NULL
)
, min_deniv AS (
	SELECT id_ech, id_point, deniv_tronc, deniv_sh, dist_tronc, dist_sh
	, LEAST(deniv_tronc, deniv_sh) AS deniv
	, CASE 
		WHEN deniv_tronc < deniv_sh THEN dist_tronc
		WHEN deniv_tronc > deniv_sh THEN dist_sh
		ELSE LEAST(dist_tronc, dist_sh)
	  END AS dist
	FROM denivs
)
UPDATE hydro h
SET indrivmnt = 
CASE
	WHEN deniv >= 20 OR dist > 500 THEN '6'
	WHEN dist > 200 THEN '5'
	WHEN dist > 50 THEN '4'
	WHEN deniv >= 10 THEN '7'
	WHEN deniv >= 3 THEN '3'
	WHEN dist > 25 THEN '2'
	WHEN dist > 15 THEN '1'
	WHEN dist >= 0 THEN '0'
	ELSE 'X'
END
FROM min_deniv md
WHERE h.id_ech = md.id_ech
AND h.id_point = md.id_point;

DROP TABLE pts;

COMMIT;
TABLE hydro;


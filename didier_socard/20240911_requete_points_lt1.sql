
SET enable_nestloop = FALSE;
SET enable_nestloop = TRUE;

WITH t AS
	(
	SELECT v2.annee, v2.npp, v2.id_ech, v2.id_point, round(st_x(p.geom)) AS x2, round(st_y(p.geom)) AS y2
	FROM inv_prod_new.v_liste_points_lt2 v2
	INNER JOIN inv_prod_new.point p ON v2.id_point = p.id_point
	WHERE v2.annee BETWEEN 2019 AND 2024
	),
	u AS
	(
	SELECT v.annee, v.npp, v.id_ech, v.id_point, round(st_x(pt.geom)) AS x1, round(st_y(pt.geom)) AS y1
	FROM inv_prod_new.v_liste_points_lt1 v
	INNER JOIN inv_prod_new.point pt ON v.id_point = pt.id_point
	WHERE v.annee BETWEEN 2019 AND 2024
	)
SELECT u.annee, count(u.npp) --, u.id_ech, u.id_point, u.x1-t.x2, u.y1-t.y2
FROM u
INNER JOIN t ON u.annee = t.annee
WHERE abs(u.x1-t.x2) < 1000 AND abs(u.y1-t.y2) < 1000
GROUP BY u.annee;
---------------------------------------------------------------------------------------------------------------------------








WITH t AS
	(
	SELECT v.annee, v.npp, v.id_ech, v.id_point, round(st_x(pt.geom)), round(st_y(pt.geom))
	, round(st_x(pt.geom))-1000 AS xmin, round(st_y(pt.geom))-1000 AS ymin
	, round(st_x(pt.geom))+1000 AS xmax, round(st_y(pt.geom))+1000 AS ymax
	FROM inv_prod_new.v_liste_points_lt1 v
	INNER JOIN inv_prod_new.point pt ON v.id_point = pt.id_point
	WHERE v.id_point = 915027
	)
SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(xmin ymax
,xmax ymax
,xmax ymin
,xmin ymin
,xmin ymax)'));


SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(st_x(pt.geom)-1000 st_y(pt.geom)+1000,st_x(pt.geom)+1000 st_y(pt.geom)+1000  )'))
FROM inv_prod_new.point pt;






SELECT ST_MakePolygon( ST_GeomFromText('LINESTRING(75 29,77 29,77 29, 75 29)'));

	


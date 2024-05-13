/*
EXEMPLE 1

# -s use srid 4326
# -I create spatial index
# -C use standard raster constraints
# -M vacuum analyze after load
# *.tif load all these files
# -F include a filename column in the raster table
# -t tile the output 100x100
# public.demelevation load into this table
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation > elev.sql
#suivi de
psql -d gisdb -f elev.SQL
# -d connect to this database
# -f read this file after connecting

# en une seule fois
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation | psql -d gisdb
---------------------------------------------------------------------------------------
EXEMPLE 2 : création BDA ALTI 20211

raster2pgsql -s 910001 -I -C -M *.asc -F -t 50x50 bdalti2011.mnt > bdalti.sql
psql -h inv-exp.ign.fr -d exploitation -f bdalti.sql -U duprez

ou

raster2pgsql -s 910001 -I -C -M *.asc -F -t 50x50 bdalti2011.mn | psql -h inv-exp.ign.fr -d exploitation -U duprez


CREATE TABLE public.pts_new_10 AS (SELECT * FROM pts_new LIMIT 10);

CREATE TEMPORARY TABLE alti AS
SELECT npp, xl, yl, rid, (gv).val AS zp
FROM (
    SELECT p.npp, p.xl, p.yl, m.rid, ST_Intersection(st_transform(m.rast,2154), p.geom93) AS gv
    FROM pts_new_10 p
    INNER JOIN bdalti2011.mnt m ON ST_Intersects(st_transform(m.rast,2154), p.geom93)
) foo
ORDER BY 1;
*/

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--> pour les rasters hors DB
SET postgis.enable_outdb_rasters TO TRUE; 
SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = TRUE;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';


raster2pgsql -s 931007 -I -C -M -t 210x210 ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff -F public.dist_210 | psql -d inventaire -p 5433
raster2pgsql -s 931007 -I -C -M -t 210x210 ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff -F public.dist_210 | psql -h inv-dev.ign.fr -d inventaire -p 5432 -U haugomat
-- ou
raster2pgsql -s 931007 -I -C -R -M -t 256x256 ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff -F public.dist_210_out_db | psql -d inventaire -p 5433
--> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS
--> chmod -R 777 pour rendre les rasters out-db utilisables dans les croisements

SELECT ST_SRID(rast) As srid
FROM dist_210 WHERE rid=1;

/*
SELECT rid, st_valuecount(rast)
FROM public.dist_210
GROUP BY rid;

SELECT st_valuecount(st_union(rast))
FROM public.dist_210
--WHERE rid = 1;
*/

-- en base d'exploitation
SELECT campagne, npp, (gv).val AS val_tif 
FROM (
	SELECT ep.incref+2005 AS campagne, ep.npp, ST_Intersection(r.rast,st_transform(e.geom,931007)) AS gv
	FROM inv_exp_nm.e1point ep
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN public.dist_210 r ON ST_Intersects(r.rast,st_transform(e.geom,931007))
	WHERE ep.incref = 17 --BETWEEN 0 AND 18
	) foo --> alias obligatoire pour sous-requête
ORDER BY 1;

/*
SELECT rid, st_valuecount(rast)
FROM public.dist_210
GROUP BY rid;

SELECT st_valuecount(st_union(rast)) FROM public.dist_210;
*/

-- en base de production (plus de points) ------------------------------------------------------------------
SELECT idp, npp, nincid, incid, deper50, (gv).val AS val_tif
FROM (
	SELECT p.idp, p.npp, d.nincid, d.incid, gf.deper50, ug.u_tfv_in, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM v_liste_points_lt1 lt1
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN description d USING (id_ech,id_point)
	INNER JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	INNER JOIN inv_exp_nm.u_g3foret ug ON p.npp = gf.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2017 AND pe.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT p.idp, p.npp, d.nincid, d.incid, pp.deper50, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM description d
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2017 AND pe.dep IN ('45','18','41','37','28','36')
	) foo
ORDER BY 1;

-- version avec seulement les points lt1 et lt2 premier levé
SELECT annee, idp, nincid, incid, deper50, deperis50, tfv, (gv).val AS val_tif, xl, yl
FROM (
	SELECT lt.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_deperis50,up.u_deperis50) AS deperis50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	, round(st_x(n.geom)) AS xl, round(st_y(n.geom)) AS yl
	FROM v_liste_points_lt1 lt
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN noeud n USING (id_noeud)
	INNER JOIN point p USING (id_point)	
	INNER JOIN ecologie e2 USING (id_ech,id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE date_part('year',e2.dateeco) IN ('2021','2020') AND lt.annee = 2021 AND pe.dep IN ('45','18','41','37','28','36')
	UNION -- pas de données en LT1_PI2
	SELECT lp.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_deperis50,up.u_deperis50) AS deperis50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	, round(st_x(n.geom)) AS xl, round(st_y(n.geom)) AS yl
	FROM v_liste_points_lt2 lp
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)	
	INNER JOIN point p USING (id_point)
	INNER JOIN noeud n USING (id_noeud)
	INNER JOIN ecologie e2 USING (id_ech,id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE date_part('year',e2.dateeco) IN ('2021','2020') AND lp.annee = 2021 AND pe.dep IN ('45','18','41','37','28','36')	
	) foo
	ORDER BY 2;



	


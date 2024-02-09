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
*/

CREATE TABLE public.pts_new_10 AS (SELECT * FROM pts_new LIMIT 10);

CREATE TEMPORARY TABLE alti AS
SELECT npp, xl, yl, rid, (gv).val AS zp
FROM (
    SELECT p.npp, p.xl, p.yl, m.rid, ST_Intersection(st_transform(m.rast,2154), p.geom93) AS gv
    FROM pts_new_10 p
    INNER JOIN bdalti2011.mnt m ON ST_Intersects(st_transform(m.rast,2154), p.geom93)
) foo
ORDER BY 1;

--------------------------------------------------------------------------------------------------------
--> pour les rasters hors DB
SET postgis.enable_outdb_rasters TO TRUE; 
SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = TRUE;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';


raster2pgsql -s 2154 -I -C -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2022_2classes_2y_CR.tif -F public.2022_rec | psql -d inventaire -p 5433
-- ou
raster2pgsql -s 2154 -I -C -R -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2019_2classes_2y_CR.tif -F public.2019_rec_out_db | psql -d inventaire -p 5433
--> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS
--> chmod -R 777 pour rendre les rasters out-db utilisables dans les croisements

-- en base d'exploitation
SELECT campagne, npp, deper50, tfv, (gv).val AS val_tif 
FROM (
	SELECT g.incref+2005 AS campagne, g.npp, g.deper50, ug.u_tfv_in AS tfv, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.g3foret g
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e2point ep USING (npp)
	INNER JOIN inv_exp_nm.u_g3foret ug USING (npp)
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE g.incref = 12 AND ep.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT p.incref+2005 AS campagne, p.npp, p.deper50, up.u_tfv_in, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.p3point p
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e2point ep USING (npp)
	INNER JOIN inv_exp_nm.u_p3point up USING (npp)
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE p.incref = 12 AND ep.dep IN ('45','18','41','37','28','36')
	) foo --> alias obligatoire pour sous-requête
ORDER BY 1;

/*
SELECT rid, st_valuecount(rast)
FROM public."2019_rec"
GROUP BY rid;

SELECT st_valuecount(st_union(rast)) FROM public."2019_rec";
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

-- version avec seulemnt les points lt1 et pi2lt1
SELECT annee, idp, nincid, incid, deper50, tfv, (gv).val AS val_tif
FROM (
	SELECT lt.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM v_liste_points_lt1 lt
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE lt.annee  = 2017 AND pe.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT lp.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM v_liste_points_lt1_pi2 lp
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE lp.annee  = 2017 AND pe.dep IN ('45','18','41','37','28','36')	
	) foo
ORDER BY 2;

--------------------------- Contrôles -----------------------------------
SELECT p.idp, d.nincid, d.incid
FROM point p
INNER JOIN description d USING (id_point)
WHERE p.idp = '840937';

--SELECT v.npp, ug.npp, ug.u_tfv_in, ug.u_tfv
SELECT v.npp, up.npp, up.u_tfv_in, up.u_tfv
FROM v_liste_points_lt1 v
--INNER JOIN inv_exp_nm.u_g3foret ug ON v.npp = ug.npp
INNER JOIN inv_exp_nm.u_p3point up ON v.npp = up.npp
WHERE annee = 2021
ORDER BY 1;

 --test sur 2 points de 2017 qui apparaissent en 2022 pour Nathalie
SELECT p.idp, p.id_point, v.id_point, v.npp, v.annee
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point, npp)
WHERE p.idp IN ('1202145', '1210672');
	
	
	


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


raster2pgsql -s 2154 -I -C -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2019_2classes_2y_CR.tif -F public.2019_rec | psql -d inventaire -p 5433
-- ou
raster2pgsql -s 2154 -I -C -R -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2019_2classes_2y_CR.tif -F public.2019_rec_out_db | psql -d inventaire -p 5433
--> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS
--> chmod -R 777 pour rendre les rasters out-db utilisables dans les croisements

-- en base d'exploitation
SELECT npp, deper50, (gv).val AS val_tif 
FROM (
	SELECT r.rid, g.npp, g.deper50, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.g3foret g
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e1point ep USING (npp)
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE g.incref = 12 AND ep.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT r.rid, p.npp, p.deper50, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.p3point p
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e1point ep USING (npp)
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
	SELECT p.idp, p.npp, d.nincid, d.incid, gf.deper50, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM description d
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2021 AND pe.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT p.idp, p.npp, d.nincid, d.incid, pp.deper50, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM description d
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2021 AND pe.dep IN ('45','18','41','37','28','36')
	) foo
ORDER BY 1;











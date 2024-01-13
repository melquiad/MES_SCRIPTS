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
SET postgis.enable_outdb_rasters = true; 
SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = true;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';


raster2pgsql -s 2154 -I -C -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2019_2classes_2y_CR.tif -F public.2019_rec | psql -d inventaire -p 5433
-- ou
raster2pgsql -s 2154 -I -C -R -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2018_2classes_2y_CR.tif -F public.2018_rec | psql -d inventaire -p 5433
--> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS


SELECT npp, deper25, deper50, (gv).val AS val_tif
FROM (
	SELECT r.rid, g.npp, g.deper25, g.deper50, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.g3foret g
	INNER JOIN inv_exp_nm.e2point e USING (npp)
	INNER JOIN sig_ign.deps_2002 d ON ST_Intersects(st_transform(d.geom,2154),st_transform(e.geom,2154))
	INNER JOIN public."2018_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE e.leve = 1, g.incref = 12 AND d.dep IN ('45','18','41','37','28','36')
	) foo --> alias obligatoire pour sous-requête
ORDER BY 1;

SELECT rid, st_valuecount(rast)
FROM public."2019_rec"
GROUP BY rid;

SELECT st_valuecount(st_union(rast)) FROM public."2019_rec";






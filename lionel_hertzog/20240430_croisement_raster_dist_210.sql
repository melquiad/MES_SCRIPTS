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
--> pour les rasters hors DB --> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS
SET postgis.enable_outdb_rasters TO TRUE; 
SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = TRUE;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

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
	INNER JOIN public.dist_210 r ON ST_Intersects(r.rast,st_convexhull(st_transform(e.geom,931007)))
	WHERE ep.incref = 17 --BETWEEN 0 AND 18
	) foo --> alias obligatoire pour sous-requête
ORDER BY 1;

/*
SELECT rid, st_valuecount(rast)
FROM public.dist_210
GROUP BY rid;

SELECT st_valuecount(st_union(rast)) FROM public.dist_210;
*/

-----------------------------------------------------------------------------------------------------
-- VERSION DE CEDRIC ------------------------------------------------------------------

-- CROISEMENT DES ZONES PERTURBÉES

-- gdalinfo ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff


-- import des fichiers raster (en local) --> il faut éviter de reprojeter un raster => on garde son SRID d'origine

raster2pgsql -s 3035 -t 32x32 -I -C ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff public.raster_dist_210 | psql -d inventaire -p 5433;
raster2pgsql -s 3035 -t 32x32 -I -C ~/Documents/MES_SCRIPTS/lionel_hertzog/dist_210.tiff public.raster_dist_210 | psql -h inv-dev.ign.fr -d inventaire -p 5432 -U haugomat


SELECT DISTINCT ST_NumBands(rast)
FROM public.raster_dist_210;

SELECT ST_Summary(rast)
FROM public.raster_dist_210;


-- Croisement avec les points d'inventaire nouvelle méthode levés (depuis le début)

CREATE TEMPORARY TABLE pts_nm AS
SELECT npp, st_transform(geom, 3035) AS geom
FROM inv_exp_nm.e1coord;

CREATE INDEX pts_nm_idx ON pts_nm USING gist(geom);


SELECT p.npp
, ST_Value(rt.rast, 1, p.geom) AS band1, ST_Value(rt.rast, 2, p.geom) AS band2, ST_Value(rt.rast, 3, p.geom) AS band3, ST_Value(rt.rast, 4, p.geom) AS band4, ST_Value(rt.rast, 5, p.geom) AS band5, ST_Value(rt.rast, 6, p.geom) AS band6, ST_Value(rt.rast, 7, p.geom) AS band7, ST_Value(rt.rast, 8, p.geom) AS band8, ST_Value(rt.rast, 9, p.geom) AS band9, ST_Value(rt.rast, 10, p.geom) AS band10
, ST_Value(rt.rast, 11, p.geom) AS band11, ST_Value(rt.rast, 12, p.geom) AS band12, ST_Value(rt.rast, 13, p.geom) AS band13, ST_Value(rt.rast, 14, p.geom) AS band14, ST_Value(rt.rast, 15, p.geom) AS band15, ST_Value(rt.rast, 16, p.geom) AS band16, ST_Value(rt.rast, 17, p.geom) AS band17, ST_Value(rt.rast, 18, p.geom) AS band18, ST_Value(rt.rast, 19, p.geom) AS band19, ST_Value(rt.rast, 20, p.geom) AS band20
, ST_Value(rt.rast, 21, p.geom) AS band21, ST_Value(rt.rast, 22, p.geom) AS band22, ST_Value(rt.rast, 23, p.geom) AS band23, ST_Value(rt.rast, 24, p.geom) AS band24, ST_Value(rt.rast, 25, p.geom) AS band25, ST_Value(rt.rast, 26, p.geom) AS band26, ST_Value(rt.rast, 27, p.geom) AS band27, ST_Value(rt.rast, 28, p.geom) AS band28, ST_Value(rt.rast, 29, p.geom) AS band29, ST_Value(rt.rast, 30, p.geom) AS band30
, ST_Value(rt.rast, 31, p.geom) AS band31, ST_Value(rt.rast, 32, p.geom) AS band32, ST_Value(rt.rast, 33, p.geom) AS band33, ST_Value(rt.rast, 34, p.geom) AS band34, ST_Value(rt.rast, 35, p.geom) AS band35, ST_Value(rt.rast, 36, p.geom) AS band36, ST_Value(rt.rast, 37, p.geom) AS band37, ST_Value(rt.rast, 38, p.geom) AS band38, ST_Value(rt.rast, 39, p.geom) AS band39
FROM pts_nm p
INNER JOIN public.raster_dist_210 rt ON ST_Intersects(p.geom, ST_ConvexHull(rt.rast))
ORDER BY npp;


DROP TABLE pts_nm;

DROP TABLE public.raster_dist_210;


-- on ne garde que les points où il y a une info sur une des bandes (via DuckDB)

SELECT count(*), count (npp), count(band1)
FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Hertzog/croisement_raster_dist_210.csv');


COPY (
SELECT *
FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Hertzog/croisement_raster_dist_210.csv')
WHERE band1 IS NOT NULL OR band2 IS NOT NULL OR band3 IS NOT NULL OR band4 IS NOT NULL OR band5 IS NOT NULL OR band6 IS NOT NULL OR band7 IS NOT NULL OR band8 IS NOT NULL OR band9 IS NOT NULL OR band10 IS NOT NULL OR band11 IS NOT NULL OR band12 IS NOT NULL OR band13 IS NOT NULL OR band14 IS NOT NULL OR band15 IS NOT NULL OR band16 IS NOT NULL OR band17 IS NOT NULL OR band18 IS NOT NULL OR band19 IS NOT NULL
OR band20 IS NOT NULL OR band21 IS NOT NULL OR band22 IS NOT NULL OR band23 IS NOT NULL OR band24 IS NOT NULL OR band25 IS NOT NULL OR band26 IS NOT NULL OR band27 IS NOT NULL OR band28 IS NOT NULL OR band29 IS NOT NULL OR band30 IS NOT NULL OR band31 IS NOT NULL OR band32 IS NOT NULL OR band33 IS NOT NULL OR band34 IS NOT NULL OR band35 IS NOT NULL OR band36 IS NOT NULL OR band37 IS NOT NULL OR band38 IS NOT NULL OR band39 IS NOT NULL
)
TO '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Hertzog/croisement_zones_perturbees.csv' (HEADER, DELIMITER ';');





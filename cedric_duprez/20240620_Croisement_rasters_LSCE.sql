-- RASTERS 2005 - 2023
/*
# Analyse des rasters avec GDALINFO
gdalinfo --formats

gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/DLT_2018_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Lesiv.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_proba_Lesiv.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Xu.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/parc_ou_reserve_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/proximite_route_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/publique_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/unite_urbaine_30m.tif

/home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/

*/

-- import des fichiers raster (en local) version out
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = true;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';

raster2pgsql -s 2154 -t 32x32 -I -R /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Lesiv.tif public.raster_out_lesiv | psql service=inventaire-local;

DROP TABLE public.raster_out_lesiv;

/*
SELECT count(*) FROM public.raster_out_lesiv; -- 631 lignes
SELECT (ST_SummaryStatsAgg(rast, 1, true)).* FROM public.raster_out_lesiv;
*/


-- import des fichiers raster (en local) version in
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Lesiv.tif public.raster_in_lesiv | psql service=inventaire-local;

CREATE TEMPORARY TABLE points1 AS 
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
UNION
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
ORDER BY id_point;

CREATE INDEX points1_id_point_idx ON points1 (id_point);

/*
SELECT p1.idp, ST_Value(rt.rast, p.geom) AS lesiv
FROM points1 p1
INNER JOIN point p USING (id_point)
INNER JOIN public.raster_out_lesiv rt ON ST_Intersects(p.geom, ST_ConvexHull(rt.rast)); -- 3'33"

SELECT p1.idp, ST_Value(rt.rast, p.geom) AS lesiv
FROM points1 p1
INNER JOIN point p USING (id_point)
INNER JOIN public.raster_in_lesiv rt ON ST_Intersects(p.geom, ST_ConvexHull(rt.rast)); -- 4"
*/

DROP TABLE public.raster_in_lesiv;

-- import de tous les rasters
--raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Lesiv.tif public.raster_in_lesiv | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Lesiv.tif public.raster_lesiv | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_proba_Lesiv.tif public.raster_proba_lesiv | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/managment_classes_Xu.tif public.raster_xu | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/parc_ou_reserve_30m.tif public.raster_parc | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/proximite_route_30m.tif public.raster_route | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/publique_30m.tif public.raster_publique | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2005_2023/unite_urbaine_30m.tif public.raster_urbaine | psql service=inventaire-local

CREATE TEMPORARY TABLE points1 AS 
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE p.idp IS NOT NULL
UNION
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE p.idp IS NOT NULL
ORDER BY id_point;

CREATE INDEX points1_id_point_idx ON points1 (id_point);

SELECT p1.idp
, ST_Value(rl.rast, p.geom) AS lesiv
, ST_Value(rpl.rast, p.geom) AS proba_lesiv
, ST_Value(rx.rast, p.geom) AS xu
, ST_Value(rp.rast, p.geom) AS parc
, ST_Value(rr.rast, p.geom) AS route
, ST_Value(rpu.rast, p.geom) AS publique
, ST_Value(ru.rast, p.geom) AS urbaine
FROM points1 p1
INNER JOIN point p USING (id_point)
LEFT JOIN public.raster_lesiv rl ON ST_Intersects(p.geom, ST_ConvexHull(rl.rast))
LEFT JOIN public.raster_proba_lesiv rpl ON ST_Intersects(p.geom, ST_ConvexHull(rpl.rast))
LEFT JOIN public.raster_xu rx ON ST_Intersects(p.geom, ST_ConvexHull(rx.rast))
LEFT JOIN public.raster_parc rp ON ST_Intersects(p.geom, ST_ConvexHull(rp.rast))
LEFT JOIN public.raster_route rr ON ST_Intersects(p.geom, ST_ConvexHull(rr.rast))
LEFT JOIN public.raster_publique rpu ON ST_Intersects(p.geom, ST_ConvexHull(rpu.rast))
LEFT JOIN public.raster_urbaine ru ON ST_Intersects(p.geom, ST_ConvexHull(ru.rast))
ORDER BY idp; 

DROP TABLE points1;
DROP TABLE public.raster_lesiv;
DROP TABLE public.raster_proba_lesiv;
DROP TABLE public.raster_xu;
DROP TABLE public.raster_parc;
DROP TABLE public.raster_route;
DROP TABLE public.raster_publique;
DROP TABLE public.raster_urbaine;

-- RASTERS 2017 - 2022

/*
# Analyse des rasters avec GDALINFO
gdalinfo --formats

gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/FORMS-H_Height_30m_cm_mode.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_0_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_1_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_2_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/planet_tree_cover_30m.tif
gdalinfo /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Tree_cover_density_Copernicus_30m.tif

/home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/

*/

-- import de tous les rasters
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/FORMS-H_Height_30m_cm_mode.tif public.raster_height | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_0_30m.tif public.raster_hill0 | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_1_30m.tif public.raster_hill1 | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Hill_number_2_30m.tif public.raster_hill2 | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/planet_tree_cover_30m.tif public.raster_planet_tc | psql service=inventaire-local
raster2pgsql -s 2154 -t 32x32 -I /home/ign.fr/CDuprez/Documents/Temp/Carto/LSCE/2017_2022/Tree_cover_density_Copernicus_30m.tif public.raster_copernicus_tc | psql service=inventaire-local

SET enable_nestloop = FALSE;

CREATE TEMPORARY TABLE points1 AS 
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE p.idp IS NOT NULL
AND annee BETWEEN 2017 AND 2022
UNION
SELECT p.idp::int4, p.id_point
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point p USING (id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE p.idp IS NOT NULL
AND annee BETWEEN 2017 AND 2022
ORDER BY id_point;

SET enable_nestloop = TRUE;

CREATE INDEX points1_id_point_idx ON points1 (id_point);

SELECT p1.idp
, ST_Value(rh.rast, p.geom) AS height
, ST_Value(rh0.rast, p.geom) AS hill0
, ST_Value(rh1.rast, p.geom) AS hill1
, ST_Value(rh2.rast, p.geom) AS hill2
, ST_Value(rpt.rast, p.geom) AS planet_tc
, ST_Value(rct.rast, p.geom) AS copernicus_tc
FROM points1 p1
INNER JOIN point p USING (id_point)
LEFT JOIN public.raster_height rh ON ST_Intersects(p.geom, ST_ConvexHull(rh.rast))
LEFT JOIN public.raster_hill0 rh0 ON ST_Intersects(p.geom, ST_ConvexHull(rh0.rast))
LEFT JOIN public.raster_hill1 rh1 ON ST_Intersects(p.geom, ST_ConvexHull(rh1.rast))
LEFT JOIN public.raster_hill2 rh2 ON ST_Intersects(p.geom, ST_ConvexHull(rh2.rast))
LEFT JOIN public.raster_planet_tc rpt ON ST_Intersects(p.geom, ST_ConvexHull(rpt.rast))
LEFT JOIN public.raster_copernicus_tc rct ON ST_Intersects(p.geom, ST_ConvexHull(rct.rast))
ORDER BY idp; 

DROP TABLE points1;
DROP TABLE public.raster_height;
DROP TABLE public.raster_hill0;
DROP TABLE public.raster_hill1;
DROP TABLE public.raster_hill2;
DROP TABLE public.raster_planet_tc;
DROP TABLE public.raster_copernicus_tc;

-- xport des points et géométries dans un fichier CSV
SET enable_nestloop = FALSE;

\copy (
    SELECT p.idp::int4, st_astext(p.geom) AS geom
    FROM v_liste_points_lt1 vp
    INNER JOIN point p USING (id_point)
    INNER JOIN description d USING (id_ech, id_point)
    WHERE p.idp IS NOT NULL
    AND annee BETWEEN 2017 AND 2022
    UNION
    SELECT p.idp::int4, st_astext(p.geom) AS geom
    FROM v_liste_points_lt1_pi2 vp
    INNER JOIN point p USING (id_point)
    INNER JOIN description d USING (id_ech, id_point)
    WHERE p.idp IS NOT NULL
    AND annee BETWEEN 2017 AND 2022
)
TO '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Wurpillot/points_LSCE_2017_2022_geom.csv' CSV HEADER DELIMITER ';';

SET enable_nestloop = TRUE;

-- import dans DryadesDB via DuckDB
LOAD postgres;

ATTACH 'host=inv-exp.ign.fr port=5432 user=CDuprez dbname=dryadesdb' AS pg (TYPE postgres);

CREATE TABLE pg.public.points1 (idp int4, geom_text TEXT);

COPY pg.public.points1 FROM '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Wurpillot/points_LSCE_2017_2022_geom.csv';

-- croisement sous PostgreSQL
ALTER TABLE public.points1 ADD COLUMN geom geometry('Point', 2154);

UPDATE public.points1 SET geom = st_geometryfromtext(geom_text);

SELECT Populate_Geometry_Columns('points1'::regclass);

CREATE INDEX points1_geom_gist ON public.points1 USING GIST (geom);

CREATE TEMPORARY TABLE deps AS 
WITH deps_millesimes AS (
    SELECT le.cleabs,  le.code_insee, le.nom_lot, le.cleabs_profil, p.nom_profil, le.millesime, rank() OVER (PARTITION BY code_insee ORDER BY millesime DESC) AS rang
    FROM lot_exploitation le
        JOIN profil p ON le.cleabs_profil::text = p.cleabs::TEXT
)
SELECT cleabs AS cleabs_lot, code_insee, nom_lot, cleabs_profil, rang
FROM deps_millesimes
WHERE rang = 1;

REFRESH MATERIALIZED VIEW exploitation.rgfor_32classes;

SELECT p1.idp, rg.tfv
FROM public.points1 p1
INNER JOIN exploitation.rgfor_32classes rg ON st_intersects(p1.geom, rg.geometrie)
INNER JOIN moteur.appartient a ON rg.cleabs = a.cleabs_veget
INNER JOIN deps d ON a.cleabs_meta_lot = d.cleabs_lot
ORDER BY idp;

DROP TABLE public.points1;


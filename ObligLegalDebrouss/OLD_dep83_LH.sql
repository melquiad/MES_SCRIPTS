SELECT ST_BufferedUnion(ST_ExteriorRing((ST_Dump(ST_Union(geom))).geom), 10) geom
FROM su_44.for_44;

create table su_44.extring as
SELECT ST_ExteriorRing((ST_Dump(ST_Union(geom))).geom) as geom
FROM su_44.for_44;

--      ) foo
-- crée une TABLE cONtenant les buffer 12.5 m, champ surface cONtenant la surface de la zONe nON bufferisée.

DROP TABLE IF EXISTS su_44.temp_0_dep_44 ;
CREATE TABLE su_44.temp_0_dep_44 AS 
SELECT tfv, st_buffer(a.geom, 12.5) AS geom , st_area(a.geom) AS surface
FROM su_44.for_44 a;
-- 3 min 5 s pour dép 44

-- crée une TABLE temporaire qui regroupe les zONes qui se touchent en clusters et leur affecte un identifiant cid 
DROP TABLE IF EXISTS su_44.temp_cluster_44 ;
CREATE  TABLE su_44.temp_cluster_44 AS
SELECT ST_ClusterDBSCAN(geom, eps := 0, minpoints := 1) over () AS cid, geom, surface
FROM su_44.temp_0_dep_44 ;
-- 40 min sur dép 83
-- 25 min sur dép 13
-- INDEX spatial sur cette TABLE
CREATE INDEX temp_cluster_geomidx ON su_44.temp_cluster_44 USING GIST (geom);

--fusiON des zONes par cluster en faisant la somme des surfaces
DROP TABLE IF EXISTS su_44.temp_cluster_fus_44 ;
CREATE  TABLE su_44.temp_cluster_fus_44 AS
	SELECT *, Row_Number() Over() AS id
	FROM 
		(SELECT ST_UniON(geom) AS geom, sum(surface) AS sum_surf 
		FROM su_44.temp_cluster_44 
		GROUP by cid) a;
-- 3 minutes sur dép 13
-- une nuit ? sur dép 83, je me demande si je n'ai pas oublié l'index!!
	
---------------------> suite si pAS de multigeom
CREATE TABLE su_44.temp_44_final AS
SELECT st_buffer(geom, 187.5)
FROM su_44.temp_cluster_fus_44
WHERE sum_surf > 40000;

GRANT SELECT ON temp_cluster_44 to PUBLIC;
GRANT SELECT ON temp_cluster_fus_44 to PUBLIC;
GRANT SELECT ON temp_44_final to PUBLIC;

create table su_44.final_fus_44 as
select (st_dump(st_union(st_buffer))).geom as geom
from su_44.temp_44_final;

GRANT SELECT ON temp_44_final to PUBLIC;
-- crée une TABLE cONtenant les buffer 12.5 m, champ surface cONtenant la surface de la zONe nON bufferisée.
DROP TABLE IF EXISTS public.temp_0_dep_06 ;
CREATE TABLE public.temp_0_dep_06 AS 
SELECT cleabs, st_buffer(a.geometrie, 12.5) AS geometrie , st_area(a.geometrie) AS surface , a.code_insee 
FROM exploitatiON.rgfor_32clASses a 
where a.code_insee = '06' 
;
-- 3 min 5 s pour dép 06

-- créer une TABLE temporaire qui regroupe les zONes qui se touchent en clusters et leur affecte un identifiant cid 
DROP TABLE IF EXISTS public.temp_cluster_06 ;
CREATE  TABLE temp_cluster_06 AS SELECT ST_ClusterDBSCAN(geometrie, eps := 0, minpoints := 1) over () AS cid, geometrie, surface FROM temp_0_dep_06 ;
-- 40 min sur dép 83
-- 25 min sur dép 13
-- INDEX spatial sur cette TABLE
CREATE INDEX temp_cluster_geomidx ON temp_cluster_06 USING GIST (geometrie);

--fusiON des zONes par cluster en faisant la somme des surfaces
DROP TABLE IF EXISTS public.temp_cluster_fus_06 ;
CREATE  TABLE temp_cluster_fus_06 AS SELECT *, Row_Number() Over() AS id FROM (SELECT ST_UniON(geometrie) AS geometrie, sum(surface) AS sum_surf FROM temp_cluster_06 GROUP by cid) a;
-- 3 minutes sur dép 13
-- une nuit ? sur dép 83, je me demande si je n'ai pas oublié l'index!!
---------------------> suite si pAS de multigeom
CREATE TABLE temp_06_final AS SELECT st_buffer(geometrie, 187.5) FROM temp_cluster_fus_06 where sum_surf > 40000;
GRANT SELECT ON temp_cluster_06 to PUBLIC;
GRANT SELECT ON temp_cluster_fus_06 to PUBLIC;
GRANT SELECT ON temp_06_final to PUBLIC;
create table public.final_fus_06 as select (st_dump(st_union(st_buffer))).geom as geometrie from temp_06_final;
GRANT SELECT ON temp_06_final to PUBLIC;
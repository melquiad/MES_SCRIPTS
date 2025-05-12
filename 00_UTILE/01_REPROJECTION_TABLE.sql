create table pro_2022_932006 as
	(select p.gid as id_onf ,p.code_onf ,(st_dump(st_makevalid(st_transform(geom,932006)))).geom
	from pro_2022 p) ; 
select updategeometrysrid('public','pro_2022_932006','geom',932006) ;

------------------------------------------------------------------------------------------------------
---- ajout d'une géométrie en lambert93----------------------------------
ALTER TABLE public.pts_new ADD COLUMN geom93 GEOMETRY;
UPDATE public.pts_new SET geom93 = ST_Transform(geom, 2154);
SELECT UpdateGeometrySRID('public', 'pts_new', 'geom93', 2154);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

ou

SELECT AddGeometryColumn ('public', 'pts_new', 'geom93', 2154,'POINT',2);

-------------------------------------------------------------------------------------------------------
ALTER TABLE inv_prod_new.transect ALTER COLUMN geom TYPE  geometry(LineString, 2154) USING public.ST_SetSRID(geom,2154);

-------------------------------------------------------------------------------------------------------------------------
SELECT ST_SRID(rast) As srid
FROM dist_210 WHERE rid=1;

--------------------------------------------------------------------------------------------------------------------------
SELECT ST_SetSRID(geom,2154) FROM carto_refifn.pro_2025;
SELECT UpdateGeometrySRID('carto_refifn', 'pro_2025', 'geom', 2154);

----------------------------------------------------------------------------------------------------------------
-- ajout et transfo geometrie dans e1coord dans base locale
SELECT AddGeometryColumn ('inv_exp_nm', 'e1coord', 'geom', 2154,'POINT',2);

UPDATE inv_exp_nm.e1coord c
SET geom = st_transform(st_setsrid(st_point(c.xl, c.yl),27572),2154);

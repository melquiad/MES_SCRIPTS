create table pro_2022_932006 as
	(select p.gid as id_onf ,p.code_onf ,(st_dump(st_makevalid(st_transform(geom,932006)))).geom
	from pro_2022 p) ; 
select updategeometrysrid('public','pro_2022_932006','geom',932006) ;
------------------------------------------------------------------------------------------------------
---- ajout d'une géométrie en lambert93----------------------------------
UPDATE public.pts_new SET geom93 = ST_Transform(geom, 2154);
SELECT UpdateGeometrySRID('public', 'pts_new', 'geom93', 2154);
SELECT Populate_Geometry_Columns('pts_new'::regclass);
-------------------------------------------------------------------------------------------------------
ALTER TABLE inv_prod_new.transect ALTER COLUMN geom TYPE  geometry(LineString, 2154) USING public.ST_SetSRID(geom,2154);

SELECT PostGIS_Full_Version();
SELECT PostGIS_Version();
ALTER DATABASE neosig SET postgis.gdal_enabled_drivers = 'ENABLE_ALL';
SELECT ST_GDALDrivers();
SELECT * FROM spatial_ref_sys;

select updategeometrysrid('su_44','dep_44','geom',27582);
select updategeometrysrid('su_44','for_44','geom',27582);
select updategeometrysrid('su_44','pro_44','geom',27582);
select updategeometrysrid('su_44','psg_44','geom',27582);

CREATE TABLE su_44.depraster_44_1500 AS
	SELECT ST_AsRaster(d.geom,1500,1500) rast
	FROM su_44.dep_44 d;

CREATE TABLE su_44.depraster_44 AS
	--synopsys utilisé
	--> ST_AsRaster(géométrie geom , double précision scalex , double précision scaley , texte pixeltype , double précision value=1 , double précision nodataval=0 , double précision upperleftx=NULL , double précision upperlefty=NULL , double précision skewx=0 , double précision skewy=0 , booléen touché=faux) ;
	SELECT ST_AsRaster(d.geom,100,100,'1BB',1,0,NULL,NULL,0,0,false) as rast
	FROM su_44.dep_44 d;
--	WHERE m.foret = 1;
SELECT AddRasterConstraints('su_44'::name, 'depraster_44'::name, 'rast'::name);
--SELECT AddRasterConstraints('su_44'::name, 'foraster_44'::name, 'rast'::name,'932006','out_db','extent');


CREATE TABLE su_44.foraster100_44 AS
	SELECT ST_AsRaster(st_union(m.geom),100,100) AS rast
	FROM su_44.for_44 m;

CREATE TABLE su_44.foraster_44_png AS
	SELECT m.id AS rid ,ST_AsPng(ST_AsRaster(m.geom,50,50,'1BB',1,0,NULL,NULL,0,0,false)) AS rast
	FROM su_44.massifor_44 m;

CREATE TABLE su_44.foraster_44_jpeg AS
	SELECT m.id AS rid ,ST_AsJPEG(ST_AsRaster(m.geom,10,10))
	FROM su_44.massifor_44 m;

CREATE TABLE su_44.foraster_44_tiff AS
	SELECT m.id AS rid ,ST_AsTIFF(ST_AsRaster(m.geom,10,10))
	FROM su_44.massifor_44 m;

CREATE TABLE su_44.foraster_44_tiff AS
	SELECT ST_AsTIFF(ST_AsRaster(m.geom,10,10))
	FROM su_44.massifor_44 m;


-------------------------------------------------------------------------------------------
CREATE TABLE su_44.test_raster2 AS
SELECT ST_asjpeg(ST_AsRaster(ST_Buffer(ST_Point(1,5),10),150, 150));

CREATE TABLE su_44.test_raster1 AS
SELECT ST_AsRaster(ST_Buffer(ST_Point(1,5),10),1000, 1000,'1BB');

-------------------------------------------------------------------------------------------
SELECT ST_AsRaster(ST_Buffer(ST_GeomFromText('POLYGON((-30 40, -20 30, -25 20, -23 10, -30 40))', 4326), 50),100,100,ARRAY['1BB'],ARRAY[118]);

SELECT ST_asPNG(ST_AsRaster(ST_Buffer(ST_Point(1,5),10),150, 150));


SELECT 
    ST_AsRaster(
        ST_Buffer(
            ST_GeomFromText('LINESTRING(50 50,150 150,150 50)'), 10,'join=bevel'),
            200,200,ARRAY['1BB', '1BB', '1BB'], ARRAY[118,154,118], ARRAY[0,0,0]);
           
SELECT ST_AsRaster(f.geom,100,100,ARRAY['1BB'],ARRAY[118]);

SELECT ST_AsRaster(ST_Buffer(ST_GeomFromText('POLYGON((-30 40, -20 30, -25 20, -23 10, -30 40))', 4326), 50),100,100,ARRAY['1BB'],ARRAY[118]);

SELECT ST_AsRaster(ST_Buffer(ST_GeomFromText('POLYGON((-30 40, -20 30, -25 20, -23 10, -30 40))', 4326), 50),100,100);

SELECT ST_AsRaster(
   ST_Buffer(ST_GeomFromText('POLYGON((-30 40, -20 30, -25 20, -23 10, -30 40))', 4326), 50),
   100,            -- width 
   100,            -- height
   ARRAY['1BB'],  -- pixeltype
   ARRAY[118]      -- value
 ); -- using ST_AsRaster signature (geometry,int,int,text[],float[])

select ST_MakeEmptyRaster(integer width, integer height, float8 upperleftx, float8 upperlefty, float8 scalex, float8 scaley, float8 skewx, float8 skewy, integer srid=unknown);
            
  
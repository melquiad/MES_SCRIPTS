-- Install the required extensions (déjà fait)
CREATE EXTENSION postgis;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION ogr_fdw;
DROP EXTENSION ogr_fdw;

SELECT ogr_fdw_version();
SELECT unnest(ogr_fdw_drivers());

SET ROLE = lhaugomat;
SHOW ROLE;
------------------------------------------------------------------------------------------------

CREATE SERVER meteo FOREIGN DATA WRAPPER ogr_fdw
	OPTIONS (datasource '/home/lhaugomat/Documents/MES_SCRIPTS/lionel_hertzog/safran_grid.shp',
			format 'ESRI Shapefile');
-------------------------------------------------------------------------------------------------

CREATE SERVER onf_2023 FOREIGN DATA WRAPPER ogr_fdw
	OPTIONS (datasource '/home/lhaugomat/Documents/DATA_SIG/ONF2023/REFFOR_PUB_2023.shp',
			format 'ESRI Shapefile');
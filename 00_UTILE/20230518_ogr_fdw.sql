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


CREATE SERVER onf_2025 FOREIGN DATA WRAPPER ogr_fdw
	OPTIONS (datasource '/home/lhaugomat/Documents/ECHANGES/SIG/ONF2025/REFFOR_PUB_ONF2025.shp',
			format 'ESRI Shapefile');
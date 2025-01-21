ALTER EXTENSION postgis UPDATE;

ALTER EXTENSION oggr_fdw UPDATE;

SELECT postgis_extensions_upgrade();

ALTER EXTENSION postgis UPDATE TO "3.3.1";

SELECT PostGIS_Full_Version();
SELECT PostGIS_Version();

SELECT ogr_fdw_Version();

SELECT POSTGIS_PROJ_VERSION();
-------------------------------------------------------------
SHOW shared_buffers;

--------------------------------------------------------------------
ALTER DATABASE travail SET search_path = "$user", work, public;
SHOW SEARCH_PATH;

SELECT postgis_proj_version();
SELECT postgis_full_version();
SELECT postgis_version();


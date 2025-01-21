alter extension postgis update;

SELECT postgis_extensions_upgrade();

ALTER EXTENSION postgis UPDATE TO "3.3.1";

SELECT PostGIS_Full_Version();
SELECT PostGIS_Version();

SELECT POSTGIS_PROJ_VERSION();

SET search_path = inv_prod_new, metaifn, inv_exp_nm, public, topology;
SHOW search_path;
--------------------------------------------------------------------------------------------

SELECT VERSION();

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
CREATE EXTENSION postgis_topology;

SELECT postgis_full_version();
SELECT POSTGIS_PROJ_VERSION();

SELECT PostGIS_Extensions_Upgrade();


SHOW ROLE;
SET ROLE = lhaugomat;
-----------------------------------------------

DROP EXTENSION IF EXISTS postgis_topology;
DROP EXTENSION IF EXISTS postgis_raster;
DROP EXTENSION IF EXISTS postgis;

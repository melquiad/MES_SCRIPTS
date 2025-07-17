
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

----------- Déplacer l'extension postgis vers un autre schéma : ici vers public ------------
UPDATE pg_extension SET extrelocatable = TRUE WHERE extname = 'postgis';

ALTER EXTENSION postgis SET SCHEMA public;

ALTER ROLE lhaugomat SET search_path = 'public';

SELECT * FROM pg_db_role_setting;

SELECT current_user;



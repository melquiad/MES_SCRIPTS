

SET ROLE = exploitation_admin;
GRANT exploitation_u_datawriter TO "LHaugomat";
GRANT exploitation_datareader TO "LHaugomat";
GRANT carto_datareader TO "SDelhaye";
GRANT carto_datareader TO "IBonheme";
RESET ROLE;
SHOW ROLE;
---------------------------------------------------

ALTER USER "LHaugomat" WITH superuser;
ALTER USER "LHaugomat" WITH nosuperuser;
---------------------------------------------------------

ALTER VIEW metaifn.v_habitats OWNER TO exploitation_admin;

-------------- Tests sur inv-dev -------------------------

SET ROLE = postgres;

CREATE ROLE lhaugomat WITH 
	SUPERUSER
	CREATEDB
	CREATEROLE
	INHERIT
	LOGIN
	NOREPLICATION
	NOBYPASSRLS
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

GRANT pg_read_all_data TO "lhaugomat";
REVOKE pg_read_all_data FROM "lhaugomat";

SHOW ROLE;
RESET ROLE;

---------------- Tests sur dot-map-dba ---------------------
SET ROLE = "admin";
SHOW ROLE;
SET ROLE = postgres;
ALTER ROLE "admin" WITH noinherit;

SHOW ROLE;
RESET ROLE;
SET ROLE = "admin";
SET ROLE = "postgres";
SET SEARCH_PATH TO bases_dot,public; -- saute à la déconnexion
ALTER ROLE "CDuprez" SET search_path TO bases_dot,public;
ALTER DATABASE bases_dot SET search_path = "$user", bases_dot, public;
SHOW SEARCH_PATH;
RESET SEARCH_PATH;
SET ROLE = "LHaugomat";
ALTER TABLE public.serveurs OWNER TO "admin";

--------------- Attribution de droits en lecture sur e1coord pour Claire Bastik --------------------

SET ROLE = postgres;

CREATE ROLE cbastik WITH 
	INHERIT
	LOGIN
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

GRANT coord_datareader TO "cbastik";
REVOKE coord_datareader FROM "cbastik";

SHOW ROLE;
RESET ROLE;

------------------ Création du rôle de Benjamin Servel -------------------------------------
SET ROLE = exploitation_admin;

CREATE ROLE "BServel" WITH 
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	LOGIN
	NOREPLICATION
	NOBYPASSRLS
	CONNECTION LIMIT -1;

GRANT carto_datareader TO "BServel";
GRANT exploitation_datareader TO "BServel";



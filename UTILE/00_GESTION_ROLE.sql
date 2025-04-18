
SET ROLE = "LHaugomat";
SET ROLE = exploitation_admin;
GRANT exploitation_u_datawriter TO "LHaugomat";
GRANT exploitation_datareader TO "LHaugomat";
GRANT carto_datareader TO "SDelhaye";
GRANT carto_datareader TO "LGay";
GRANT SELECT ON TABLE carto_inpn.apg_2023 TO carto_datareader;
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

ALTER ROLE lhaugomat WITH ENCRYPTED PASSWORD 'password';

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

--------------- Attribution de droits en lecture sur g3arbre et p3arbre pour Laura --------------------

SET ROLE = exploitation_admin;
SHOW ROLE;
GRANT exploitation_datareader TO "LGay";
RESET ROLE;
/*
GRANT SELECT ON TABLE inv_exp_nm.g3arbre TO "LGay";
GRANT SELECT ON TABLE inv_exp_nm.p3arbre TO "LGay";
*/

--------------- Attribution de droits en écriture sur famille_echantillon, s5stratif et famille_stratification  pour Laura --------------------
SET ROLE = "LHaugomat";
SHOW ROLE;

GRANT INSERT,SELECT ON TABLE inv_exp_nm.famille_echantillon TO "LGay";
GRANT INSERT, SELECT ON TABLE inv_exp_nm.famille_stratification TO "LGay";
GRANT INSERT, SELECT ON TABLE inv_exp_nm.s5stratif TO "LGay";
GRANT INSERT, SELECT ON TABLE inv_exp_nm.s5var TO "LGay";
GRANT INSERT,SELECT ON TABLE inv_exp_nm.echantillon TO "LGay";

REVOKE INSERT,SELECT ON TABLE inv_exp_nm.famille_echantillon FROM "LGay";
REVOKE INSERT,SELECT ON TABLE inv_exp_nm.famille_stratification FROM "LGay";
REVOKE INSERT,SELECT ON TABLE inv_exp_nm.s5stratif FROM "LGay";







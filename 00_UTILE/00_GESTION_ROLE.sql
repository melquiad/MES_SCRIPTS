
SET ROLE = "LHaugomat";
SET ROLE = exploitation_admin;
GRANT exploitation_u_datawriter TO "LHaugomat";
GRANT exploitation_datareader TO "WMarchand";
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

CREATE ROLE "LHaugomat" WITH 
	SUPERUSER
	CREATEDB
	CREATEROLE
	INHERIT
	LOGIN
	NOREPLICATION
	NOBYPASSRLS
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

ALTER ROLE LHaugomat WITH ENCRYPTED PASSWORD 'password';

GRANT pg_read_all_data TO "LHaugomat";
REVOKE pg_read_all_data FROM "LHaugomat";

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
SET ROLE = exploitation_admin;
SHOW ROLE;

GRANT INSERT,SELECT ON TABLE inv_exp_nm.echantillon TO "LGay";
REVOKE INSERT, SELECT ON TABLE inv_exp_nm.echantillon FROM "LGay";

GRANT exploitation_u_datawriter TO "LGay";
GRANT exploitation_datareader TO "LGay";
GRANT exploitation_datawriter TO "LGay";
GRANT prod_exp_datawriter TO "LGay";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE inv_exp_nm.echantillon_id_ech_seq TO "LGay";
GRANT SELECT, UPDATE, USAGE ON SEQUENCE inv_exp_nm.s5strate_n_str_seq TO "LGay";

GRANT SELECT ON ALL TABLES IN SCHEMA carto_exo TO exploitation_datareader;

SET ROLE = exploitation_admin;
GRANT INSERT,SELECT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER ON TABLE utilisateur.autorisation_groupe_donnee TO exploitation_admin;

--------------------- Attribution de droits à Benjamin Detourbet ----------------------------------------------------------------------------------------------------
SET ROLE = exploitation_admin;

DROP ROLE bdetourbet;

CREATE ROLE BDetourbet WITH 
	INHERIT
	LOGIN
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

GRANT exploitation_u_datawriter TO "bdetourbet";
GRANT exploitation_datareader TO "bdetourbet";

--------------------- Attribution de droits coord_datareader à Marine Dalmasso en test-exp  --------------------------------------------------------------------
SET ROLE = exploitation_admin;
SHOW ROLE;

GRANT coord_datareader TO "MDalmasso";

-------------------- Attribution droit de lecture sur la table agent_lt  (demande de Julien) --------------------------------------------------------------------
SET ROLE = production_admin;
GRANT SELECT ON TABLE inv_prod_new.agent_lt TO production_datareader;

RESET ROLE;
SHOW ROLE;

-------------------- Attribution droit de lecture sur la table tarifs  (demande de Amael Le Squin) --------------------------------------------------------------------
SET ROLE = exploitation_admin;
GRANT SELECT ON TABLE prod_exp.tarifs TO prod_exp_datareader;

RESET ROLE;
SHOW ROLE;

SET ROLE = exploitation_admin;
SET ROLE = postgres;

DROP ROLE "tmoreal-de-brevans";

CREATE ROLE "tmoreal-de-brevans" WITH 
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	LOGIN
	NOREPLICATION
	NOBYPASSRLS
	CONNECTION LIMIT -1;

GRANT exploitation_datareader TO "tmoreal-de-brevans";
GRANT prod_exp_datareader TO "tmoreal-de-brevans";
GRANT exploitation_u_datawriter TO "tmoreal-de-brevans";

SHOW ROLE;
RESET ROLE;

----------- Attribution de droits sur les tables renouv et espar_renouv ------------------
SET ROLE = production_admin;
GRANT SELECT ON TABLE inv_prod_new.espar_renouv TO production_datareader;
GRANT SELECT ON TABLE inv_prod_new.renouv TO production_datareader;

RESET ROLE;
SHOW ROLE;

-------------------- Attribution droit à Emilie Vautier et Luigi Ramirez-Parra --------------------------------------------------------------------
SET ROLE = exploitation_admin;

DROP ROLE evautier;

CREATE ROLE evautier WITH 
	INHERIT
	LOGIN
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

GRANT exploitation_u_datawriter TO "evautier";
GRANT prod_exp_datareader TO "evautier";
GRANT exploitation_datareader TO "evautier";



DROP ROLE lramirez-parra;

CREATE ROLE "lramirez-parra" WITH 
	INHERIT
	LOGIN
	CONNECTION LIMIT -1
	VALID UNTIL 'infinity';

GRANT exploitation_u_datawriter TO "lramirez-parra";
GRANT prod_exp_datareader TO "lramirez-parra";
GRANT exploitation_datareader TO "lramirez-parra";

---------------------------------------------------------------------------
SET ROLE = exploitation_admin;
GRANT coord_datareader TO "MDassot";
GRANT exploitation_datareader TO "MDassot";

-----------------------------------------------------------------
SET ROLE = production_admin;

CREATE ROLE "SMermet" WITH 
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	LOGIN
	NOREPLICATION
	NOBYPASSRLS
	CONNECTION LIMIT -1;

GRANT metaifn_reader TO "SMermet";
GRANT production_datareader TO "SMermet";
GRANT sig_datareader TO "SMermet";






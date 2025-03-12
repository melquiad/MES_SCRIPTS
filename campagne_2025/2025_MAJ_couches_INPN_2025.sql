-- Données à vérifier pour mise à jour éventuelle.
-- NATURA2000   PARC_NAT   PNR   ZNIEFF   U_APB   U_APG   U_APHN   U_CEN_PRO   U_COLITT   U_RAMSAR   U_RB   U_RES_BIO   U_RNC   U_RNCFS   U_RNN   U_RNR   U_ZICO  


-- ARRÊTÉS DE PROTECTION DE BIOTOPE -->  Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.apb_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apb_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apb_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apb_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.apb;
CREATE OR REPLACE VIEW carto_inpn.apb AS
SELECT * FROM carto_inpn.apb_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.apb OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apb TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apb TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apb TO carto_datareader;


-- croisement des points
WITH croise AS (
    SELECT c.npp, i.gid, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.apb_2024 i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET apb = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'apb';

-----------------------------------------------------------------------------
-- ARRÊTÉS DE PROTECTION DE GEOTOPE  --> Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apg/N_ENP_APG_S_000.shp carto_inpn.apg_2024 | psql  -p 5433 -U lhaugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apg/N_ENP_APG_S_000.shp carto_inpn.apg_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apg/N_ENP_APG_S_000.shp carto_inpn.apg_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/apg/N_ENP_APG_S_000.shp carto_inpn.apg_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.apg_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apg_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apg_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apg_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.apg;
CREATE OR REPLACE VIEW carto_inpn.apg AS
SELECT * FROM carto_inpn.apg_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.apg OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apg TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apg TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apg TO carto_datareader;

-- création de la colonne u_apg dans la table u_e2point
ALTER TABLE inv_exp_nm.u_e2point
ADD COLUMN u_apg bpchar(1);

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.apg_2024 i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_apg = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_apg';

---------------------------------------------------------------------------------
-- ARRÊTÉS DE PROTECTION D'HABITAT NATUREL  -->  Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/aphn/N_ENP_APHN_S_000.shp carto_inpn.aphn_2024 | psql  -p 5433 -U lhaugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/aphn/N_ENP_APHN_S_000.shp carto_inpn.aphn_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/aphn/N_ENP_APHN_S_000.shp carto_inpn.aphn_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/aphn/N_ENP_APHN_S_000.shp carto_inpn.aphn_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.aphn_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.aphn_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.aphn_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.aphn_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.aphn;
CREATE OR REPLACE VIEW carto_inpn.aphn AS
SELECT * FROM carto_inpn.aphn_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.aphn OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.aphn TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.aphn TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.aphn TO carto_datareader;

-- création de la colonne u_apnh dans la table u_e2point
ALTER TABLE inv_exp_nm.u_e2point
ADD COLUMN u_aphn bpchar(1);

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.aphn_2024 i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_aphn = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_aphn';

-----------------------------------------------------------------------------
-- SITES DU CONSERVATOIRE DU LITTORAL -->  Nouvelle couche en 2024
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cdl/N_ENP_SCL_S_000.shp carto_inpn.cdl_2024 | psql  -p 5433 -U lhaugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cdl/N_ENP_SCL_S_000.shp carto_inpn.cdl_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cdl/N_ENP_SCL_S_000.shp carto_inpn.cdl_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cdl/N_ENP_SCL_S_000.shp carto_inpn.cdl_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.cdl_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.cdl_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.cdl_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.cdl_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.cdl;
CREATE OR REPLACE VIEW carto_inpn.cdl AS
SELECT * FROM carto_inpn.cdl_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.cdl OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.cdl TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.cdl TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.cdl TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.cdl i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_colitt = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_colitt';

-----------------------------------------------------------------------------
-- SITES DES CONSERVATOIRES DES ESPACES NATURELS -->  Nouvelle couche en 2024
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cen/N_ENP_SCEN_S_SA.shp carto_inpn.cen_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cen/N_ENP_SCEN_S_SA.shp carto_inpn.cen_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cen/N_ENP_SCEN_S_SA.shp carto_inpn.cen_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/cen/N_ENP_SCEN_S_SA.shp carto_inpn.cen_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.cen_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.cen_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.cen_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.cen_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.cen;
CREATE OR REPLACE VIEW carto_inpn.cen AS
SELECT * FROM carto_inpn.cen_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.cen OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.cen TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.cen TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.cen TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.cen i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_cen_pro = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_cen_pro';

------------------------------------------------------------------------------
-- PARCS NATIONAUX -->  Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du code id_local du parc naturel des forêts
UPDATE carto_inpn.pn_2024
SET id_local = 'AA_PNF'
WHERE ppn_asso = 'FR3400011';

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.pn_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pn_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pn_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pn_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.pn;
CREATE OR REPLACE VIEW carto_inpn.pn AS
SELECT * FROM carto_inpn.pn_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.pn OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pn TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pn TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pn TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN regexp_replace(UPPER(i.id_local), '(COEUR\_|CT\_)', '') ELSE 'HORS_PN' END AS mode_parc
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.pn i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET parc_nat = c.mode_parc
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
-- /*\ Pas besoin de mettre à jour la nomenclature des parcs nationaux, la différence avec la version précédente ne portant que sur des géométries
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'parc_nat';


-- PARCS NATURELS RÉGIONAUX -->  Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.pnr_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pnr_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pnr_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pnr_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.pnr;
CREATE OR REPLACE VIEW carto_inpn.pnr AS
SELECT * FROM carto_inpn.pnr_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.pnr OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pnr TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pnr TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pnr TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NULL THEN 'HP' ELSE RIGHT(id_mnhn, 2) END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.pnr i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET pnr = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
DELETE FROM metaifn.abgroupe
WHERE unite = 'PNR';

DELETE FROM metaifn.abmode
WHERE unite = 'PNR';

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT 'PNR' AS unite, RIGHT(id_mnhn, 2) AS mode, DENSE_RANK() OVER(ORDER BY RIGHT(id_mnhn, 2)) AS position, DENSE_RANK() OVER(ORDER BY RIGHT(id_mnhn, 2)) AS classe
, 1 AS etendue, nom_site AS libelle, 'Parc naturel régional ' || nom_site AS definition
FROM carto_inpn.pnr
UNION
SELECT 'PNR', 'HP', 0, 0, 1, 'Point HORS parc naturel régional', 'Point HORS parc naturel régional'
ORDER BY classe;

INSERT INTO metaifn.abgroupe (gunite, gmode, unite, mode)
SELECT 'PNRG' AS gunite
, CASE WHEN "mode" = 'HP' THEN '0' ELSE '1' END AS gmode
, unite, mode
FROM metaifn.abmode
WHERE unite = 'PNR'
ORDER BY classe;

UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'pnr';

------------------------------------------------------------------------------------
-- NATURA 2000
-- chargement des shapefiles --> nouvelles couches depuis 12/2023
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/sic.shp carto_inpn.sic_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/sic.shp carto_inpn.sic_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/sic.shp carto_inpn.sic_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/sic.shp carto_inpn.sic_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/zps/zps.shp carto_inpn.zps_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/zps/zps.shp carto_inpn.zps_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/zps/zps.shp carto_inpn.zps_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/zps/zps.shp carto_inpn.zps_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.sic_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.sic_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.sic_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.sic_2024 TO carto_datareader;

ALTER TABLE carto_inpn.zps_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.zps_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.zps_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.zps_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.sic;
CREATE OR REPLACE VIEW carto_inpn.sic AS
SELECT * FROM carto_inpn.sic_2024;

DROP VIEW IF EXISTS carto_inpn.zps;
CREATE OR REPLACE VIEW carto_inpn.zps AS
SELECT * FROM carto_inpn.zps_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.sic OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.sic TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.sic TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.sic TO carto_datareader;

ALTER TABLE carto_inpn.zps OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.zps TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.zps TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.zps TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT DISTINCT c.npp, CASE WHEN s.gid IS NOT NULL THEN '1' ELSE NULL END AS sic, CASE WHEN z.gid IS NOT NULL THEN '1' ELSE NULL END AS zps
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.sic s ON ST_Intersects(c.geom, s.geom)
    LEFT JOIN carto_inpn.zps z ON ST_Intersects(c.geom, z.geom)
)
UPDATE inv_exp_nm.e2point p2
SET natura2000 = 
    CASE 
        WHEN COALESCE(c.sic, c.zps) IS NULL THEN 'HN2'
        WHEN c.sic IS NOT NULL AND c.zps IS NOT NULL THEN 'ZSI'
        WHEN c.sic IS NOT NULL THEN 'SIC'
        WHEN c.zps IS NOT NULL THEN 'ZPS'
    END 
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'natura2000';

-----------------------------------------------------------------------------------
-- ZONES PROTÉGÉES RAMSAR (MISE À JOUR DE U_RAMSAR) -->  Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/ramsar/N_ENP_RAMSAR_S_000.shp carto_inpn.ramsar_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/ramsar/N_ENP_RAMSAR_S_000.shp carto_inpn.ramsar_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/ramsar/N_ENP_RAMSAR_S_000.shp carto_inpn.ramsar_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/ramsar/N_ENP_RAMSAR_S_000.shp carto_inpn.ramsar_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.ramsar_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.ramsar_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.ramsar_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.ramsar_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.ramsar;
CREATE OR REPLACE VIEW carto_inpn.ramsar AS
SELECT * FROM carto_inpn.ramsar_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.ramsar OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.ramsar TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.ramsar TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.ramsar TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.ramsar i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_ramsar = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_ramsar';

/*--------------------------------------------------------------------------------
-- RÉSERVES DE BIOSPHÈRE (MISE À JOUR DE U_RES_BIOS)   --> pas de nouvelles couche depuis 07/2022
-- chargement des shapefiles 
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h inv-bdd-dev.ign.fr -U duprez -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h test-inv-exp.ign.fr -U CDuprez -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h inv-exp.ign.fr -U CDuprez -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.bios_2022 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.bios_2022 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.bios_2022 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.bios_2022 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.bios;
CREATE OR REPLACE VIEW carto_inpn.bios AS
SELECT *
FROM carto_inpn.bios_2022;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.bios OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.bios TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.bios TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.bios TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT p2.npp, SUBSTRING(r.nom_site FROM '\((zone.+)\)') AS zrbios
    FROM inv_exp_nm.e2point p2
    INNER JOIN inv_exp_nm.e1coord c USING (npp)
    LEFT JOIN carto_inpn.bios r ON r.geom && c.geom AND _ST_INTERSECTS(r.geom, c.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_res_bio = 
    CASE
        WHEN zrbios = 'zone centrale' THEN '1'
        WHEN zrbios = 'zone tampon' THEN '2'
        WHEN zrbios = 'zone de transition' THEN '3'
        ELSE '0'
    END
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_res_bio';
*/

-----------------------------------------------------------------------------
-- ZNIEFF 1 ET 2 -->  Nouvelles couches en 2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.znieff1_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.znieff1_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.znieff1_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.znieff1_2024 TO carto_datareader;

ALTER TABLE carto_inpn.znieff2_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.znieff2_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.znieff2_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.znieff2_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.znieff1;
CREATE OR REPLACE VIEW carto_inpn.znieff1 AS
SELECT * FROM carto_inpn.znieff1_2024;

DROP VIEW IF EXISTS carto_inpn.znieff2;
CREATE OR REPLACE VIEW carto_inpn.znieff2 AS
SELECT * FROM carto_inpn.znieff2_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.znieff1 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.znieff1 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.znieff1 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.znieff1 TO carto_datareader;

ALTER TABLE carto_inpn.znieff2 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.znieff2 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.znieff2 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.znieff2 TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT DISTINCT c.npp, CASE WHEN z1.gid IS NOT NULL THEN '1' ELSE NULL END AS znieff1, CASE WHEN z2.gid IS NOT NULL THEN '1' ELSE NULL END AS znieff2
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.znieff1 z1 ON ST_Intersects(c.geom, z1.geom)
    LEFT JOIN carto_inpn.znieff2 z2 ON ST_Intersects(c.geom, z2.geom)
)
UPDATE inv_exp_nm.e2point p2
SET znieff = 
    CASE 
        WHEN COALESCE(c.znieff1, c.znieff2) IS NULL THEN 'HZNIEFF'
        WHEN c.znieff1 IS NOT NULL AND c.znieff2 IS NOT NULL THEN 'ZNIEF12'
        WHEN c.znieff1 IS NOT NULL THEN 'ZNIEFF1'
        WHEN c.znieff2 IS NOT NULL THEN 'ZNIEFF2'
    END 
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'znieff';

/*------------------------------------------------------------------------------------------
-- RÉSERVES BIOLOGIQUES (MISE À JOUR DE U_RB) --> pas de nouvelle couche depuis 10/2020
-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN LEFT(i.CODE_R_ENP,1) ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.rb i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_rb = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_rb';

--------------------------------------------------------------------------------------------
-- RESERVES INTEGRALES DE PARC NATIONAL --> pas de nouvelle couche depuis 03/2022
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/ripn/N_ENP_RIPN_S_000.shp carto_inpn.ripn_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/ripn/N_ENP_RIPN_S_000.shp carto_inpn.ripn_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/ripn/N_ENP_RIPN_S_000.shp carto_inpn.ripn_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/ripn/N_ENP_RIPN_S_000.shp carto_inpn.ripn_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.ripn_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.ripn_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.ripn_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.ripn_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.ripn;
CREATE OR REPLACE VIEW carto_inpn.ripn AS
SELECT *
FROM carto_inpn.ripn_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.ripn OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.ripn TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.ripn TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.ripn TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.ripn i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_ripn = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_ripn';

----------------------------------------------------------------------------------------------------
-- RÉSERVES NATURELLES DE CORSE (MISE À JOUR DE U_RNC) --> pas de nouvelle couche depuis 03/2021
-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.rnc i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_rnc = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_rnc';
*/

-----------------------------------------------------------------------------------------------------------
-- RÉSERVES NATIONALES DE CHASSE ET FAUNE SAUVAGE (MISE À JOUR DE U_RNCFS) --> Nouvelle couche en 2024
-- chargement des shapefiles 
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rncfs/N_ENP_RNCFS_S_000.shp carto_inpn.rncfs_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rncfs/N_ENP_RNCFS_S_000.shp carto_inpn.rncfs_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rncfs/N_ENP_RNCFS_S_000.shp carto_inpn.rncfs_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rncfs/N_ENP_RNCFS_S_000.shp carto_inpn.rncfs_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.rncfs_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rncfs_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rncfs_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rncfs_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.rncfs;
CREATE OR REPLACE VIEW carto_inpn.rncfs AS
SELECT * FROM carto_inpn.rncfs_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.rncfs OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rncfs TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rncfs TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rncfs TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.rncfs i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_rncfs = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_rncfs';

------------------------------------------------------------------------------------
-- RÉSERVES NATURELLES NATIONALES (MISE À JOUR DE U_RNN) --> Nouvelle couche en 07/2024
-- chargement des shapefiles
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/rnn/N_ENP_RNN_S_000.shp carto_inpn.rnn_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/rnn/N_ENP_RNN_S_000.shp carto_inpn.rnn_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/rnn/N_ENP_RNN_S_000.shp carto_inpn.rnn_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/rnn/N_ENP_RNN_S_000.shp carto_inpn.rnn_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.rnn_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rnn_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rnn_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rnn_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.rnn;
CREATE OR REPLACE VIEW carto_inpn.rnn AS
SELECT * FROM carto_inpn.rnn_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.rnn OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rnn TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rnn TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rnn TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.rnn i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_rnn = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_rnn';

--------------------------------------------------------------------------------------
-- RÉSERVES NATURELLES RÉGIONALES (MISE À JOUR DE U_RNR) --> Nouvelle couche en 2024
-- chargement des shapefiles 
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rnr/N_ENP_RNR_S_000.shp carto_inpn.rnr_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rnr/N_ENP_RNR_S_000.shp carto_inpn.rnr_2024 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rnr/N_ENP_RNR_S_000.shp carto_inpn.rnr_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/rnr/N_ENP_RNR_S_000.shp carto_inpn.rnr_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.rnr_2024 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rnr_2024 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rnr_2024 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rnr_2024 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.rnr;
CREATE OR REPLACE VIEW carto_inpn.rnr AS
SELECT * FROM carto_inpn.rnr_2024;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.rnr OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.rnr TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.rnr TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.rnr TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.rnr i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.u_e2point p2
SET u_rnr = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'u_rnr';

/*-----------------------------------------------------------------------------------------------------------------------
-- ZONE D'IMPORTANCE POUR LA CONSERVATION DES OISEAUX (MISE À JOUR DE ZICO) --> pas de nouvelle couche depuis 1994
-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.zico i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET zico = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'zico';
*/


--------------------------------------------------------------------------------------
-- REGIONS BIOGEOGRAPHIQUES --> Nouvelle couche en 2022
-- chargement des shapefiles 
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/regbiofr/regbiofr.shp carto_inpn.regbiofr_2002 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/regbiofr/regbiofr.shp carto_inpn.regbiofr_2002 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/regbiofr/regbiofr.shp carto_inpn.regbiofr_2002 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_08_2024/regbiofr/regbiofr.shp carto_inpn.regbiofr_2002 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.regbiofr_2002 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.regbiofr_2002 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.regbiofr_2002 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.regbiofr_2002 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.regbiofr_2002;
CREATE OR REPLACE VIEW carto_inpn.regbioff AS
SELECT * FROM carto_inpn.regbiofr_2002;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.regbiofr OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.regbiofr TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.regbiofr TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.regbiofr TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.regbiofr i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET biogeo2002 = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'biogeo2002';


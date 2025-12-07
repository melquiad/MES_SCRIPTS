

-- BIOGEO2002 -------------------------------------------------
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp carto_refifn.regbiofr | psql service=inv-local
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp carto_refifn.regbiofr | psql service=inv-bdd
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp carto_refifn.regbiofr | psql service=test-exp
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp carto_refifn.regbiofr | psql service=exp

BEGIN;

-- réalisation du croisement
WITH biog AS (
    SELECT p2.npp, rb.domaine::bpchar AS biog
    FROM inv_exp_nm.e1coord c1
    INNER JOIN inv_exp_nm.e2point p2 USING (npp)
    INNER JOIN public.regbiofr rb ON ST_Intersects(c1.geom, rb.geom)
    WHERE p2.incref = 19
)
UPDATE inv_exp_nm.e2point p2
SET biogeo2002 = b.biog
FROM biog b
WHERE p2.npp = b.npp;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 19, validin = 0, validout = 18, defin = 0, defout = NULL
WHERE famille = 'INV_EXP_NM'
AND format = 'TE2POINT'
AND donnee = 'BIOGEO2002';

DROP TABLE public.regbiofr;

COMMIT;

-- Correction des points NULL
SELECT NPP, BIOGEO2002
FROM INV_EXP_NM.E2POINT
WHERE INCREF = 19
AND BIOGEO2002 IS NULL

--controles
SELECT count(biogeo2002), biogeo2002, incref
FROM inv_exp_nm.e2point
GROUP BY incref, biogeo2002
ORDER BY incref DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Calcul de la donnée RES_BIO (inclusion dans une réserve biologique)
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql service=inv-local
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h inv-bdd-dev.ign.fr -U duprez -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h test-inv-exp.ign.fr -U CDuprez -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_06_2024/sic/bios/N_ENP_MAB_S_000.shp carto_inpn.bios_2022 | psql -h inv-exp.ign.fr -U CDuprez -d exploitation


WITH croise AS (
    SELECT c.npp, SUBSTRING(r.nom_site FROM '\((zone.+)\)') AS zrbios
    FROM inv_exp_nm.e1coord c
    INNER JOIN carto_inpn.bios r ON r.geom && c.geom AND ST_Intersects(r.geom, c.geom)
				)
UPDATE inv_exp_nm.e2point e2
SET res_bio = 
    CASE
        WHEN zrbios = 'zone centrale' THEN '1'
        WHEN zrbios = 'zone tampon' THEN '2'
        WHEN zrbios = 'zone de transition' THEN '3'
        ELSE '0'
    END
FROM croise c
WHERE e2.npp = c.npp AND e2.incref = 18;

UPDATE inv_exp_nm.e2point
SET res_bio = '0'
WHERE res_bio IS NULL;


-- contrôle : nombre de points dans zone centrale de RES_BIO par incref
SELECT res_bio, count(res_bio), incref
FROM inv_exp_nm.e2point
--WHERE res_bio = '1'
GROUP BY incref, res_bio
ORDER BY incref DESC;

UPDATE inv_exp_nm.e2point
SET res_bio = '0'
WHERE res_bio IS NULL;


------------------------------------------------------------------------------------------------
-- ARRÊTÉS DE PROTECTION DE BIOTOPE -->  Nouvelle couche en 05/205
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2025 | psql service= inv-local -- -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2025 | psql service=inv-bdd -- -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2025 | psql service=test-exp -- -p test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/apb/N_ENP_APB_S_000.shp carto_inpn.apb_2025 | psql service=exp -- -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.apb_2025 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apb_2025 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apb_2025 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apb_2025 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW carto_inpn.apb;
CREATE OR REPLACE VIEW carto_inpn.apb AS
SELECT * FROM carto_inpn.apb_2025;

-- mise à jour du propriétaire et des droits sur la vue
ALTER TABLE carto_inpn.apb OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.apb TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.apb TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.apb TO carto_datareader;

-- croisement des points
WITH croise AS (
    SELECT c.npp, i.gid, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.apb_2025 i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET apb = c.dedans
FROM croise c
WHERE p2.npp = c.npp;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'apb';
----------------------------------------------------------------------------------------------------------------------

-- PARCS NATIONAUX -->  Nouvelle couche en 05/205
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2025 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2025 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2025 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pn/N_ENP_PN_S_000.shp carto_inpn.pn_2025 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du code id_local du parc naturel des forêts
UPDATE carto_inpn.pn_2025
SET id_local = 'AA_PNF'
WHERE ppn_asso = 'FR3400011';

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.pn_2025 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pn_2025 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pn_2025 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pn_2025 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.pn;
CREATE OR REPLACE VIEW carto_inpn.pn AS
SELECT * FROM carto_inpn.pn_2025;

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
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'parc_nat';
--------------------------------------------------------------------------------------------------------------------------------------------

-- PARCS NATURELS RÉGIONAUX -->  Nouvelle couche en 05/2025 : nouveau PNR => modalité à ajouter dans abmode
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2025 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2025 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2025 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/INPN_05_2025/pnr/N_ENP_PNR_S_000.shp carto_inpn.pnr_2025 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.pnr_2025 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.pnr_2025 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.pnr_2025 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.pnr_2025 TO carto_datareader;

-- vue sur la dernière version
DROP VIEW IF EXISTS carto_inpn.pnr;
CREATE OR REPLACE VIEW carto_inpn.pnr AS
SELECT * FROM carto_inpn.pnr_2025;

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
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'pnr';

------------------------------------------------------------------------------------
-- NATURA 2000
-- chargement des shapefiles --> nouvelles couches depuis 12/2023
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/sic/sic.shp carto_inpn.sic_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/sic/sic.shp carto_inpn.sic_2024 | psql -h inv-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/sic/sic.shp carto_inpn.sic_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/sic/sic.shp carto_inpn.sic_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/zps/zps.shp carto_inpn.zps_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/zps/zps.shp carto_inpn.zps_2024 | psql -h inv-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/zps/zps.shp carto_inpn.zps_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/zps/zps.shp carto_inpn.zps_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

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
WHERE p2.npp = c.npp
AND incref = 19;

-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'natura2000';

-----------------------------------------------------------------------------------
-- ZNIEFF 1 ET 2 -->  Nouvelles couches en 2024
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h inv-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff1/znieff1.shp carto_inpn.znieff1_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h inv-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/SIG/INPN_202406/znieff2/znieff2.shp carto_inpn.znieff2_2024 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

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
WHERE p2.npp = c.npp
AND incref = 19;

/*-- documentation dans MetaIFN
DELETE FROM metaifn.abgroupe
WHERE unite = 'ZNIEFF';

DELETE FROM metaifn.abmode
WHERE unite = 'ZNIEFF';

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('ZNIEFF', 'HZNIEFF', 0, 0, 1, 'Terrain ni en ZNIEFF de type I, ni en ZNIEFF de type II')
, ('ZNIEFF', 'ZNIEFF1', 1, 1, 1, 'Terrain en ZNIEFF de type I (Zones Naturelles d’Intérêt Ecologique Faunistique et Floristique ; Secteurs de grand intérêt biologique ou écologique)')
, ('ZNIEFF', 'ZNIEFF2', 2, 2, 1, 'Terrain en ZNIEFF de type II (Zones Naturelles d’Intérêt Ecologique Faunistique et Floristique ; Grands ensembles naturels riches et peu modifiés, offrant des potentialités biologiques importantes)')
, ('ZNIEFF', 'ZNIEFF12', 3, 3, 1, 'Terrain en ZNIEFF1 et ZNIEFF2', 'Terrain en ZNIEFF de type I et de type II');

INSERT INTO metaifn.abgroupe (gunite, gmode, unite, mode)
VALUES ('ZNIEFF1', '0', 'ZNIEFF', 'HZNIEFF')
, ('ZNIEFF1', '0', 'ZNIEFF', 'ZNIEFF2')
, ('ZNIEFF1', '1', 'ZNIEFF', 'ZNIEFF1')
, ('ZNIEFF1', '1', 'ZNIEFF', 'ZNIEF12')
, ('ZNIEFF2', '0', 'ZNIEFF', 'HZNIEFF')
, ('ZNIEFF2', '0', 'ZNIEFF', 'ZNIEFF1')
, ('ZNIEFF2', '1', 'ZNIEFF', 'ZNIEFF2')
, ('ZNIEFF2', '1', 'ZNIEFF', 'ZNIEF12');


UPDATE metaifn.afchamp
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'pnr';
UPDATE metaifn.afchamp
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'znieff';*/

-----------------------------------------------------------------------------------------------------------------------
-- ZONE D'IMPORTANCE POUR LA CONSERVATION DES OISEAUX (MISE À JOUR DE U_ZICO) --> pas de nouvelle couche depuis 1994

-- croisement des points
WITH croise AS (
    SELECT c.npp, CASE WHEN i.gid IS NOT NULL THEN '1' ELSE '0' END AS dedans
    FROM inv_exp_nm.e1coord c
    LEFT JOIN carto_inpn.zico i ON ST_Intersects(c.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p2
SET zico = c.dedans
FROM croise c
WHERE p2.npp = c.npp
AND incref = 19;

/*
-- documentation dans MetaIFN
UPDATE metaifn.afchamp
SET calcout = 19, validout = 19, defout = NULL
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~~* 'zico';
*/
---------------------------------------------------------------

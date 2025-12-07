
-- Création de l'extension postgres_fdw
SET ROLE = postgres;

CREATE EXTENSION postgres_fdw;

SHOW ROLE;
RESET ROLE;

SET ROLE = lhaugomat;
SHOW ROLE;

-- Création du serveur externe
DROP SERVER IF EXISTS foreign_visu CASCADE;

CREATE SERVER IF NOT EXISTS foreign_visu
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5433', dbname 'visu');


-- on déclare se connecter en tant qu'utilisateur mon_utilisateur externe lorsqu'on récupère des données
DROP USER MAPPING IF EXISTS FOR lhaugomat SERVER foreign_visu;

CREATE USER MAPPING FOR "lhaugomat"
SERVER foreign_visu
OPTIONS (user 'lhaugomat', password 'L@urent1969');


-- on stocke les tables étrangères dans un schéma spécifique pour les isoler des autres schémas locaux en dur
DROP SCHEMA IF EXISTS visu_donnees CASCADE;
CREATE SCHEMA IF NOT EXISTS visu_donnees;

DROP SCHEMA IF EXISTS visu_metadonnees CASCADE;
CREATE SCHEMA IF NOT EXISTS visu_metadonnees;


-- importer automatiquement les tables d'un schéma de la base distante
IMPORT FOREIGN SCHEMA donnees
FROM SERVER foreign_visu
INTO visu_donnees;

IMPORT FOREIGN SCHEMA metadonnees
FROM SERVER foreign_visu
INTO visu_metadonnees


-- Tester
SELECT * FROM visu_donnees.placette LIMIT 10;

SELECT * FROM visu_metadonnees.donnee LIMIT 10;


-- changement du SRID de la table placette liée à la vue v_placette_gp --> dans la base visu
DROP VIEW IF EXISTS donnees.v_placette_gp;

SELECT UpdateGeometrySRID('donnees', 'placette', 'geom93', 2154);

CREATE OR REPLACE VIEW donnees.v_placette_gp
AS SELECT p.campagne,
    p.idp,
    p.dep,
    p.ser,
    p.csa,
    p.def5,
    p.uta1,
    p.uta2,
    p.utip,
    p.bois,
    p.autut,
    p.tm2,
    p.tform,
    p.plisi,
    p.cslisi,
    p.elisi,
    p.nlisi5,
    p.sfo,
    p.sver,
    p.gest,
    p.nincid,
    p.incid,
    p.peupnr,
    p.entp,
    p.dc,
    p.dcespar1,
    p.dcespar2,
    p.prelev5,
    p.tplant,
    p.tpespar1,
    p.tpespar2,
    p.iplant,
    p.bplant,
    p.videplant,
    p.videpeuplier,
    p.elag,
    p.instp5,
    p.dist,
    p.acces,
    p.iti,
    p.pentn,
    p.pentexp,
    p.portn,
    p.portance,
    p.asperite,
    p.tcat10,
    p.orniere,
    p.abrou,
    p.cam,
    p.andain,
    p.bord,
    p.integr,
    p.pbuis,
    p.dpyr,
    p.anpyr,
    p.geom93,
    p.visite,
    p.passage,
    g1.code_g::character(1) AS greco,
    g2.code_g::character(2) AS rad13
   FROM donnees.placette p
     JOIN metadonnees.groupe g1 ON g1.unite_g = 'GRECO'::text AND g1.unite = 'SER'::text AND p.ser::text = g1.code
     JOIN metadonnees.groupe g2 ON g2.unite_g = 'RAD13'::text AND g2.unite = 'DP'::text AND p.dep::text = g2.code;


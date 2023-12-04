-- Création du serveur externe
DROP SERVER IF EXISTS foreign_inv_dev CASCADE;

CREATE SERVER IF NOT EXISTS foreign_inv_dev
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'inv-dev.ign.fr', port '5432', dbname 'inventaire');

-- on déclare se connecter en tant qu'utilisateur mon_utilisateur externe lorsqu'on récupère des données
CREATE USER MAPPING FOR "lhaugomat"
SERVER foreign_inv_dev
OPTIONS (user 'haugomat', password 'Boo1eewa6e');

--DROP USER MAPPING IF EXISTS FOR lhaugomat SERVER foreign_inv_dev;

-- on stocke les tables étrangères dans un schéma spécifique pour isoler des autres schémas en dur
DROP SCHEMA IF EXISTS fdw_inv_dev CASCADE;
CREATE SCHEMA IF NOT EXISTS fdw_inv_dev;

SET ROLE = lhaugomat;
SHOW ROLE;

-- importer automatiquement les tables d'un schéma de la base distante
IMPORT FOREIGN SCHEMA "inv_prod_new"
LIMIT TO ("campagne", "echantillon")
FROM SERVER foreign_inv_dev
INTO fdw_inv_dev;

-- Tester
SELECT * FROM fdw_inv_dev.echantillon LIMIT 10;

ALTER DATABASE bases_dot SET search_path = "$user", bases_dot, public;
SHOW SEARCH_PATH;


---------- CREATION DES TABLES -------------
--------------------------------------------
CREATE TABLE DBA(
   id_dba SERIAL2,
   nom_dba VARCHAR(50)  NOT NULL,
   prenom_dba VARCHAR(50) ,
   PRIMARY KEY(nom_dba,prenom_dba)
);

CREATE TABLE SGBD(
   id_sgbd SMALLINT,
   nom_sgbd VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_sgbd)
);

CREATE TABLE Serveurs(
   id_serveur SMALLINT,
   nom_serveur VARCHAR(50)  NOT NULL,
   ip_serveur VARCHAR(15)  NOT NULL,
   id_dba VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_serveur),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);

CREATE TABLE Serveurs_DBA(
   id_serveur SMALLINT,
   id_dba INTEGER,
   FOREIGN KEY(id_serveur) REFERENCES serveurs(id_serveur),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);


CREATE TABLE Instance(
   id_serveur SMALLINT,
   id_sgbd INTEGER,
   port VARCHAR(5) ,
   version_sgbd VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_serveur, id_sgbd, port),
   FOREIGN KEY(id_serveur) REFERENCES Serveurs(id_serveur),
   FOREIGN KEY(id_sgbd) REFERENCES SGBD(id_sgbd)
);

CREATE TABLE Services(
   id_service SMALLINT,
   nom_service VARCHAR(50) ,
   id_dba VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_service),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);

CREATE TABLE Produits(
   id_produit SMALLINT,
   nom_produit VARCHAR(50)  NOT NULL,
   chef_produit VARCHAR(50) ,
   id_service SMALLINT,
   PRIMARY KEY(id_produit),
   FOREIGN KEY(id_service) REFERENCES Services(id_service)
);

CREATE TABLE Bases(
   id_base SMALLINT,
   nom_base VARCHAR(50)  NOT NULL,
   id_serveur SMALLINT NOT NULL,
   id_sgbd INTEGER NOT NULL,
   port VARCHAR(5)  NOT NULL,
   id_produit SMALLINT NOT NULL,
   PRIMARY KEY(id_base),
   FOREIGN KEY(id_serveur, id_sgbd, port) REFERENCES Instance(id_serveur, id_sgbd, port),
   FOREIGN KEY(id_produit) REFERENCES Produits(id_produit)
);
-----------------------------------------------------------------------------------------------
----------------------------- Import du fichier csv des données -------------------------------------
CREATE TABLE bases_dot.liste_bdd
(
	id INT2 NOT NULL,
    service VARCHAR(50) NOT NULL,
    produit VARCHAR(50) NOT NULL,
    chef_produit VARCHAR(50) NOT NULL,
    nom_serveur VARCHAR(50) NOT NULL,
    ip_serveur VARCHAR(15) NOT NULL,
    sgbd VARCHAR(50) NOT NULL,
    version_sgbd VARCHAR(50) NOT NULL,
    bdd VARCHAR(50) NOT NULL,
    prenom_dba VARCHAR(50) NOT NULL,
    nom_dba VARCHAR(50) NOT NULL,
    PRIMARY KEY(id)
)
WITH (
  OIDS=FALSE
);
ANALYZE 

-- dans psql ---
\COPY bases_dot.liste_bdd FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/Liste_serveurs_BDD_DOT_new.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

---------------------------- import données DBA ---------------------------------------------------------------------
INSERT INTO bases_dot.dba (nom_dba, prenom_dba)
SELECT nom_dba, prenom_dba
FROM bases_dot.liste_bdd
ON CONFLICT (nom_dba, prenom_dba) DO NOTHING;
ALTER TABLE dba DROP CONSTRAINT dba_pkey;
ALTER TABLE dba ADD PRIMARY KEY (id_dba);
--ou--
ALTER TABLE dba ADD CONSTRAINT dba_pkey UNIQUE (id_dba);

















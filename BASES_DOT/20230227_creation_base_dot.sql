
ALTER DATABASE bases_dot SET search_path = "$user", bases_dot, public;
SHOW SEARCH_PATH;

SET ROLE = "admin";
SHOW ROLE;

GRANT "admin" TO "LHaugomat";
GRANT "admin" TO "CDuprez";


---------- CREATION DES TABLES -------------
--------------------------------------------
CREATE TABLE DBA(
   id_dba SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_dba VARCHAR(50)  NOT NULL,
   prenom_dba VARCHAR(50) ,
   PRIMARY KEY(id_dba)
);

CREATE TABLE SGBD(
   id_sgbd SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_sgbd VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_sgbd)
);

CREATE TABLE Serveurs(
   id_serveur SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_serveur VARCHAR(50)  NOT NULL,
   ip_serveur VARCHAR(15)  NOT NULL,
   id_dba SMALLINT NOT NULL,
   PRIMARY KEY(id_serveur),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);

CREATE TABLE Serveurs_DBA(
   id_serveur SMALLINT,
   id_dba INTEGER,
   FOREIGN KEY(id_serveur) REFERENCES serveurs(id_serveur),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);

CREATE TABLE Instances(
   id_serveur SMALLINT,
   id_sgbd SMALLINT,
   port VARCHAR(5) ,
   version_sgbd VARCHAR(50)  NOT NULL,
   PRIMARY KEY(id_serveur, id_sgbd, port),
   FOREIGN KEY(id_serveur) REFERENCES Serveurs(id_serveur),
   FOREIGN KEY(id_sgbd) REFERENCES SGBD(id_sgbd)
);
ALTER TABLE instances ALTER COLUMN port TYPE int2 USING port::integer;
ALTER TABLE instances ADD PRIMARY KEY (id_serveur, id_sgbd, port);
ALTER TABLE instances ADD FOREIGN KEY (id_serveur) REFERENCES serveurs;
ALTER TABLE instances ADD FOREIGN KEY (id_sgbd) REFERENCES sgbd;
--ALTER TABLE instances DROP CONSTRAINT instances_id_serveur_fkey;
--ALTER TABLE instances DROP CONSTRAINT instances_id_sgbd_fkey;


CREATE TABLE Services(
   id_service SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_service VARCHAR(50) ,
   id_dba SMALLINT NOT NULL,
   PRIMARY KEY(id_service),
   FOREIGN KEY(id_dba) REFERENCES DBA(id_dba)
);

CREATE TABLE Produits(
   id_produit SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_produit VARCHAR(50)  NOT NULL,
   chef_produit VARCHAR(50) ,
   id_service SMALLINT,
   PRIMARY KEY(id_produit),
   FOREIGN KEY(id_service) REFERENCES Services(id_service)
);

CREATE TABLE Bases(
   id_base SMALLINT GENERATED ALWAYS AS IDENTITY,
   nom_base VARCHAR(50)  NOT NULL,
--   id_serveur SMALLINT NOT NULL,
--   id_sgbd SMALLINT NOT NULL,
--  port VARCHAR(5)  NOT NULL,
--  id_produit SMALLINT NOT NULL,
   PRIMARY KEY(id_base)
--   FOREIGN KEY(id_serveur, id_sgbd, port) REFERENCES Instance(id_serveur, id_sgbd, port),
--   FOREIGN KEY(id_produit) REFERENCES Produits(id_produit)
);

-----------------------------------------------------------------------------------------------
----------------------------- Import du fichier csv des données -------------------------------------
SET ROLE = "admin";

CREATE TABLE public.liste_bdd
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
ANALYZE public.liste_bdd;

-- dans psql ---
\COPY public.liste_bdd FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/Liste_serveurs_BDD_DOT_new.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

---------------------------------- import des données DBA --------------------------------------------------------------------------------------------
SET ROLE = "admin";
SET ROLE = postgres;
SHOW ROLE;

CREATE TABLE public.liste_dba
(
    prenom_dba VARCHAR(50) NOT NULL,
    nom_dba VARCHAR(50) NOT NULL,
    PRIMARY KEY(prenom_dba, nom_dba)
)
WITH (
  OIDS=FALSE
);
ANALYZE;


\COPY public.liste_bda FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_DBA.csv' WITH HEADER CSV DELIMITER ',' NULL AS 'NA'

INSERT INTO bases_dot.dba (nom_dba, prenom_dba)
SELECT nom_dba, prenom_dba
FROM public.liste_dba;


UPDATE dba
SET id_service = services.id_service
FROM services
INNER JOIN liste_services_dba ls ON ls.nom_service = services.nom_service
WHERE ls.nom_dba = dba.nom_dba ;

---------------------------------- import des données services------------------------------------------------------------------------------------------

CREATE TABLE public.liste_services
(
	nom_service VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

CREATE TABLE public.liste_services_dba
(
	nom_service VARCHAR(50) NOT NULL,
	prenom_dba VARCHAR(50) NOT NULL,
	nom_dba VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_services FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_services.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'
\COPY public.liste_services_dba FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_services_dba.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

DELETE FROM public.liste_services WHERE nom_service = 'DIFE'

INSERT INTO bases_dot.services (nom_service)
SELECT nom_service
FROM public.liste_services;

INSERT INTO services (nom_service)
VALUES ('DIFE');



-------------------------------- import données SGBD -------------------------------------------------------------------------------

CREATE TABLE public.liste_sgbd
(
	nom_sgbd VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_sgbd FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_sgbd.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

INSERT INTO bases_dot.sgbd (nom_sgbd)
SELECT nom_sgbd
FROM public.liste_sgbd;

-------------------------------- import données serveurs -------------------------------------------------------------------------------
CREATE TABLE public.liste_serveurs
(
	nom_serveur VARCHAR(50) NOT NULL,
	ip_serveur VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

CREATE TABLE public.liste_serveurs_dba
(
	ip_serveur VARCHAR(50) NOT NULL,
	nom_serveur VARCHAR(50) NOT NULL,
	prenom_dba VARCHAR(50) NOT NULL,
	nom_dba VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_serveurs FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_serveurs.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'
\COPY public.liste_serveurs_dba FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_serveurs_dba.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

INSERT INTO serveurs (nom_serveur, ip_serveur)
SELECT nom_serveur, ip_serveur 
FROM public.liste_serveurs;

UPDATE dba
SET id_serveur = serveurs.id_serveur
FROM serveurs
INNER JOIN liste_serveurs_dba ls ON ls.nom_serveur = serveurs.nom_serveur
WHERE ls.nom_dba = dba.nom_dba ;

-- Import table serveurs_dba
INSERT INTO serveurs_dba (id_serveur, id_dba)
SELECT DISTINCT s.id_serveur, dba.id_dba
FROM serveurs s
INNER JOIN public.liste_serveurs_dba ls ON ls.ip_serveur = s.ip_serveur
INNER JOIN dba ON ls.nom_dba = dba.nom_dba ;

--------------------- Import table Produits ----------------------------------------------------------
SET ROLE = "admin";

CREATE TABLE public.liste_produits
(
	nom_produit VARCHAR(50) NOT NULL,
	chef_produit VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

CREATE TABLE public.liste_produits_bases
(
	produit VARCHAR(50) NOT NULL,
	base VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

CREATE TABLE public.liste_produits_services
(
	service VARCHAR(50) NOT NULL,
	produit VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_produits FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_produits.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'
\COPY public.liste_produits_bases FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_produits_bases.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'
\COPY public.liste_produits_services FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_produits_services.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

INSERT INTO produits(nom_produit, chef_produit)
SELECT DISTINCT nom_produit, chef_produit
FROM public.liste_produits;

UPDATE produits
SET id_service  = services.id_service
FROM services
INNER JOIN liste_produits_services lps ON lps.service  = services.nom_service 
WHERE lps.produit = produits.nom_produit;

UPDATE produits
SET id_service = 47
WHERE nom_produit = 'E-Forest';

------------------- IMPORT DONNEES BASES ----------------------------------------------------
SET ROLE = "admin";

CREATE TABLE public.liste_bases
(
	nom_base VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_bases FROM '/home/lhaugomat/Documents/mes_scripts/BASES_DOT/liste_bases.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'
---------------------------------------

CREATE TABLE public.bases_produits AS
SELECT DISTINCT base, produit
FROM liste_produits_bases 
ORDER BY base;

ALTER TABLE public.bases_produits
ADD COLUMN id_produit SMALLINT;

UPDATE public.bases_produits
SET id_produit = p.id_produit
FROM bases_dot.produits p
WHERE p.nom_produit = produit;

--DROP TABLE public.bases_produits;

--------------- Import table bases_serveurs ---------------------------------------
CREATE TABLE public.liste_bases_serveurs
(
	base VARCHAR(50) NOT NULL,
	serveur VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

DROP TABLE public.liste_bases_serveurs;

\COPY public.liste_bases_serveurs FROM '/home/lhaugomat/Documents/MES_SCRIPTS/BASES_DOT/liste_bases_serveurs.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

ALTER TABLE public.liste_bases_serveurs
ADD COLUMN id_serveur SMALLINT;

UPDATE public.liste_bases_serveurs
SET id_serveur = s.id_serveur
FROM bases_dot.serveurs s
WHERE s.nom_serveur = serveur;

CREATE TABLE public.bases_serveurs AS
SELECT DISTINCT base, serveur, id_serveur
FROM liste_bases_serveurs
ORDER BY base;

--------------- Import table bases_SGBD ---------------------------------------
SET ROLE = "admin";

CREATE TABLE public.liste_bases_sgbd
(
	base VARCHAR(50) NOT NULL,
	sgbd VARCHAR(50) NOT NULL
)
WITH (
  OIDS=FALSE
);
ANALYZE;

\COPY public.liste_bases_sgbd FROM '/home/lhaugomat/Documents/MES_SCRIPTS/BASES_DOT/liste_bases_sgbd.csv' WITH HEADER CSV DELIMITER ';' NULL AS 'NA'

ALTER TABLE public.liste_bases_sgbd
ADD COLUMN id_sgbd SMALLINT;

UPDATE public.liste_bases_sgbd
SET id_sgbd = s.id_sgbd
FROM bases_dot.sgbd s
WHERE s.nom_sgbd = sgbd;

CREATE TABLE public.bases_sgbd AS
SELECT DISTINCT base, sgbd, id_sgbd
FROM liste_bases_sgbd
ORDER BY base;

DELETE FROM public.bases_sgbd WHERE id_sgbd IS NULL;
UPDATE sgbd  SET nom_sgbd = REPLACE(nom_sgbd, 'Mysql', 'inconnu') WHERE id_sgbd = 4;

DROP TABLE public.liste_bases_sgbd;
DROP TABLE public.bases_sgbd;

ALTER TABLE bases DROP COLUMN id_produit;
ALTER TABLE bases DROP COLUMN id_serveur;
ALTER TABLE bases DROP COLUMN id_sgbd;
ALTER TABLE bases DROP COLUMN port;

INSERT INTO bases(nom_base)
SELECT nom_base FROM public.liste_bases;

CREATE TABLE bases_dot.bases_produits AS
(
SELECT b.id_base, bp.id_produit 
FROM public.bases_produits bp
LEFT JOIN bases_dot.bases b ON bp.base = b.nom_base
);
ALTER TABLE bases_produits ADD PRIMARY KEY (id_base,id_produit);
ALTER TABLE bases_produits ADD FOREIGN KEY (id_base) REFERENCES bases;
ALTER TABLE bases_produits ADD FOREIGN KEY (id_produit) REFERENCES produits;











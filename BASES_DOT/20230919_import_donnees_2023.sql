------------------------------------------------
------ IMPORT DU FICHIER DES DONNÉES 2023 ------
------------------------------------------------
SET ROLE = "admin";

CREATE TABLE public.liste_donnees_2023 (
    service TEXT,
    produit TEXT,
    chef_produit TEXT,
    nom_serveur TEXT,
    ip_serveur TEXT,
    sgbd TEXT,
    version_sgbd TEXT,
    base_donnees TEXT,
    dba1 TEXT,
    dba2 TEXT
);

-- DROP TABLE public.liste_donnees_2023;

-- sous PSQL
\COPY public.liste_donnees_2023 FROM '/home/lhaugomat/Documents/GITLAB/serveurs_bdd_dot/Liste_serveurs_202309.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

-- on enlève la base eforest, qui n'est pas une base d'un service de production
DELETE FROM public.liste_donnees_2023
WHERE service = 'DIFE';

-- on remplace dryades par nonapus ( modification demandée par Béatrice Burlin)
UPDATE public.liste_donnees_2023
SET nom_serveur = 'nonapus.ign.fr'
WHERE nom_serveur = 'dryades.ign.fr';

UPDATE serveurs
SET nom_serveur = 'nonapus.ign.fr'
WHERE nom_serveur = 'dryades.ign.fr';

-- Mise à jour des services
INSERT INTO services (nom_service)
SELECT DISTINCT service 
FROM public.liste_donnees_2023
WHERE service IS NOT NULL AND service NOT IN (SELECT nom_service FROM services)
ORDER BY 1;

-- Mise à jour des sgbd
INSERT INTO sgbd (nom_sgbd)
SELECT DISTINCT sgbd
FROM public.liste_donnees_2023
WHERE sgbd IS NOT NULL AND sgbd NOT IN (SELECT nom_sgbd FROM sgbd)
ORDER BY 1;

-- Mise à jour des serveurs
INSERT INTO serveurs (nom_serveur, ip_serveur, id_service)
SELECT DISTINCT lower(nom_serveur), ip_serveur, s.id_service
FROM public.liste_donnees_2023 l
INNER JOIN services s ON l.service = s.nom_service
WHERE l.nom_serveur IS NOT NULL AND lower(l.nom_serveur) NOT IN (SELECT nom_serveur FROM serveurs)
ORDER BY 1;

-- Mise à jour des instances (-- on triche sur les n° de port qu'on ne connaît pas forcément... en triant par ordre croissant alphabétique de version)
WITH insts AS (
    SELECT DISTINCT s.id_serveur::SMALLINT, g.id_sgbd::SMALLINT, g.nom_sgbd::varchar(50)
    , l.version_sgbd::varchar(50)
    , TRUE AS actif
    FROM public.liste_donnees_2023 l
    INNER JOIN sgbd g ON l.sgbd = g.nom_sgbd
    INNER JOIN serveurs s ON lower(l.nom_serveur) = s.nom_serveur
    ORDER BY 1, 2
)
INSERT INTO instances (id_serveur, id_sgbd, version_sgbd, actif, port)
SELECT id_serveur, id_sgbd, version_sgbd, actif
, CASE 
    WHEN nom_sgbd = 'PostgreSQL' THEN 5432
    WHEN nom_sgbd = 'MySQL' THEN 3306
    WHEN nom_sgbd = 'MariaDB' THEN 3306
    WHEN nom_sgbd = 'Microsoft Access' THEN 0
    WHEN nom_sgbd = 'ORACLE' THEN 1
    WHEN nom_sgbd = 'mon_sgbd' THEN 2
END + row_number() over(PARTITION BY id_serveur, id_sgbd ORDER BY version_sgbd) - 1 AS port
FROM insts i
ON CONFLICT DO NOTHING;

-- Mise à jour des dba
WITH dbas_new AS (
    SELECT dba1 AS nom_dba, service
    FROM public.liste_donnees_2023
    WHERE dba1 IS NOT NULL
    UNION 
    SELECT dba2, service
    FROM public.liste_donnees_2023
    WHERE dba2 IS NOT NULL
),
dbas AS (
    SELECT dba1 AS nom_dba, service
    FROM public.liste_donnees
    WHERE dba1 IS NOT NULL
    UNION 
    SELECT dba2, service
    FROM public.liste_donnees
    WHERE dba2 IS NOT NULL
)
INSERT INTO dba (prenom_dba, nom_dba, id_service)
SELECT 
    CASE 
        WHEN array_length(string_to_array(d.nom_dba, ' '), 1) > 1 
            THEN (string_to_array(d.nom_dba, ' '))[1]
    END AS prenom
, CASE 
        WHEN array_length(string_to_array(d.nom_dba, ' '), 1) > 1 
            THEN array_to_string((string_to_array(upper(d.nom_dba), ' '))[2:array_length(string_to_array(d.nom_dba, ' '), 1)], ' ')
        ELSE d.nom_dba
  END AS nom
, s.id_service
FROM dbas_new d
INNER JOIN services s ON d.service = s.nom_service
WHERE lower(d.nom_dba) NOT IN (SELECT lower(dbas.nom_dba) FROM dbas);

-- on enlève le SDM du SIA
UPDATE dba
SET id_service = NULL
WHERE nom_dba = 'SDM';

-- mise à jour de dba / serveurs
INSERT INTO serveur_dba (id_dba, id_serveur)
SELECT DISTINCT d.id_dba, s.id_serveur
FROM dba d
INNER JOIN public.liste_donnees_2023 ld ON CASE WHEN d.prenom_dba IS NULL THEN d.nom_dba ELSE d.prenom_dba || ' ' || d.nom_dba END = ld.dba1
INNER JOIN serveurs s ON lower(ld.nom_serveur) = s.nom_serveur
ON CONFLICT DO NOTHING;

-- Mise à jour des produits
INSERT INTO produits (nom_produit, chef_produit, id_service)
SELECT DISTINCT produit, chef_produit, id_service
FROM public.liste_donnees_2023 ld
INNER JOIN services s ON ld.service = s.nom_service
WHERE produit IS NOT NULL AND ld.produit NOT IN (SELECT nom_produit FROM produits);

-- Mise à jour des bases
WITH insts AS
	(
    SELECT DISTINCT s.id_serveur, g.id_sgbd, g.nom_sgbd, s.nom_serveur
    , l.version_sgbd
    , TRUE AS actif
    FROM public.liste_donnees_2023 l
    INNER JOIN sgbd g ON l.sgbd = g.nom_sgbd
    INNER JOIN serveurs s ON lower(l.nom_serveur) = s.nom_serveur
    WHERE l.base_donnees NOT IN (SELECT nom_base FROM bases)
    )
, insts2 AS
	(
    SELECT id_serveur, id_sgbd, i.version_sgbd, actif, i.nom_serveur, i.nom_sgbd
    , CASE 
        WHEN nom_sgbd = 'PostgreSQL' THEN 5432
    WHEN nom_sgbd = 'MySQL' THEN 3306
    WHEN nom_sgbd = 'MariaDB' THEN 3306
    WHEN nom_sgbd = 'Microsoft Access' THEN 0
    WHEN nom_sgbd = 'ORACLE' THEN 1
    WHEN nom_sgbd = 'mon_sgbd' THEN 2
    END + row_number() over(PARTITION BY id_serveur, id_sgbd ORDER BY i.version_sgbd) - 1 AS port
    FROM insts i
	)
INSERT INTO bases (nom_base, id_serveur, id_sgbd, port)
SELECT DISTINCT l.base_donnees AS nom_base, i.id_serveur, i.id_sgbd, i.port
FROM public.liste_donnees_2023 l
INNER JOIN insts2 i ON l.sgbd = i.nom_sgbd AND lower(l.nom_serveur) = lower(i.nom_serveur) AND l.version_sgbd = i.version_sgbd
WHERE l.base_donnees IS NOT NULL
ORDER BY id_serveur, port, nom_base;

-- Mises à jour de bases / produits
INSERT INTO bases_produits (id_base, id_produit)
SELECT b.id_base, p.id_produit
FROM bases b
INNER JOIN instances i USING (id_serveur, id_sgbd, port)
INNER JOIN sgbd g USING (id_sgbd)
INNER JOIN serveurs s USING (id_serveur)
INNER JOIN public.liste_donnees_2023 ld ON b.nom_base = ld.base_donnees AND g.nom_sgbd = ld.sgbd AND i.version_sgbd = ld.version_sgbd AND s.nom_serveur = lower(ld.nom_serveur) AND s.ip_serveur = ld.ip_serveur
INNER JOIN produits p ON ld.produit = p.nom_produit AND COALESCE(ld.chef_produit, 'XXX') = COALESCE(p.chef_produit, 'XXX') AND s.id_service = p.id_service
ORDER BY id_base
ON CONFLICT DO NOTHING;


-- PRÉPARATION DES DONNÉES ET TABLES POUR CROISEMENT VIA DUCKDB

LOAD postgres;

ATTACH 'host=inventaire-forestier-admin.ign.fr port=5432 user=cduprez dbname=visu' AS pgd (TYPE postgres);
ATTACH 'host=inv-prod.ign.fr port=5432 user=CDuprez dbname=production' AS pgp (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=CDuprez dbname=exploitation' AS pge (TYPE postgres);

/*
-- Contrôle de la cohérence du nombre de points
SELECT *
FROM postgres_query('pgp', 'SELECT count(*)
FROM description d
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2023
AND e.type_ech = ''IFN''
AND e.type_ue = ''P''
AND e.phase_stat = 2');

SELECT *
FROM postgres_query('pgd', 'SELECT count(*)
FROM donnees.placette
WHERE campagne = 2023');
*/

-- Création d'une table UNLOGGED en base d'exploitation pour y mettre les points dataIFN 2023 avec leur géométrie
CALL postgres_execute('pge', 'CREATE UNLOGGED TABLE public.dataifn_pts_2023 (idp TEXT, geom GEOMETRY(POINT, 2154))');

-- Transfert des points dataIFN 2023 dans cette table
INSERT INTO pge.public.dataifn_pts_2023 (idp, geom)
SELECT * 
FROM postgres_query('pgp', '
SELECT p.idp, st_setsrid(p.geom, 2154)
FROM inv_prod_new.description d
INNER JOIN inv_prod_new.point p USING (id_point)
INNER JOIN inv_prod_new.echantillon e USING (id_ech)
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE c.millesime = 2023
AND e.type_ech = ''IFN''
AND e.type_ue = ''P''
AND e.phase_stat = 2
ORDER BY p.idp;');


-- CROISEMENT EN BASE D'EXPLOITATION
-- BDForet V2
CREATE INDEX dataifn_pts_2023_geom_idx ON public.dataifn_pts_2023 USING gist (geom);

CREATE TEMP TABLE dep_annee AS 
SELECT DISTINCT code_insee, millesime
FROM dryades_exploit.rgfor_32classes 
ORDER BY code_insee, millesime;

SELECT code_insee, millesime, rank() over(PARTITION BY code_insee ORDER BY millesime DESC) AS rang
FROM dep_annee
ORDER BY code_insee, rang;

CREATE TEMPORARY TABLE dep_annee1 AS 
WITH t AS (
    SELECT code_insee, millesime, rank() over(PARTITION BY code_insee ORDER BY millesime DESC) AS rang
    FROM dep_annee
)
SELECT code_insee, millesime
FROM t
WHERE rang = 1;

SELECT p.idp, r.tfv
FROM public.dataifn_pts_2023 p
INNER JOIN dryades_exploit.rgfor_32classes r ON p.geom && r.geometrie AND st_intersects(p.geom, r.geometrie)
INNER JOIN dep_annee1 d ON r.code_insee = d.code_insee AND r.millesime = d.millesime
ORDER BY p.idp;

-- Propriété
SELECT UpdateGeometrySRID('exploitation', 'public', 'dataifn_pts_2023', 'geom', 931007);

/*
SELECT d.donnee, d.unite, i.incref, i.dcunite, d.libelle
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P'
WHERE d.donnee ~~* 'pro_nm'
ORDER BY incref;

SELECT DISTINCT gunite, unite
FROM metaifn.abgroupe
WHERE unite ~~* 'pro_2015'
ORDER BY gunite;
*/

SELECT p.idp, g.gmode AS propriete
FROM public.dataifn_pts_2023 p
INNER JOIN carto_refifn.pro_2024 pr ON p.geom && pr.geom AND st_intersects(p.geom, pr.geom)
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g."mode" = pr.code_onf
ORDER BY p.idp;

DROP TABLE public.dataifn_pts_2023;

-- AJOUT DE L'ALTITUDE VIA DUCKDB
COPY (
SELECT p.idp, p.zp, f.tfv, COALESCE(pr.propriete, '4') AS propriete
FROM postgres_query('pgp', 'SELECT p.idp, pe.zp, pe.pro
FROM inv_prod_new.description d
INNER JOIN inv_prod_new.point_ech pe USING (id_ech, id_point)
INNER JOIN inv_prod_new.point p USING (id_point)
INNER JOIN inv_prod_new.echantillon e USING (id_ech)
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE c.millesime = 2023
AND e.type_ech = ''IFN''
AND e.type_ue = ''P''
AND e.phase_stat = 2
ORDER BY p.idp;') AS p
LEFT JOIN read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Vallet/bd_foret_2023.csv') f USING (idp)
LEFT JOIN read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Vallet/pro_2023.csv') pr USING (idp)
ORDER BY idp) TO '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Vallet/dataIFN2023.csv' (HEADER, DELIMITER ';');

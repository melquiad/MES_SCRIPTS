-- AJOUT DE LA NOUVELLE CAMPAGNE ANNUELLE
INSERT INTO campagne (millesime, lib_campagne)
VALUES (2027, $$Campagne annuelle d inventaire forestier national, année 2027$$);

-- CRÉATION DES ÉCHANTILLONS DE PREMIÈRE PHASE ASSOCIÉS
INSERT INTO ifn_prod.echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent, descript_ech, stat, type_ue, passage)
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, NULL::INT4 AS ech_parent
, $$Échantillon statistique de phase 1 des points de l‘inventaire forestier national, campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 1 AS passage
FROM campagne c
WHERE c.millesime = 2027
UNION 
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || (c.millesime - 5) AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, e.id_ech AS ech_parent
, $$Échantillon statistique de phase 1 des points de l‘inventaire forestier national issus initialement de la campagne $$ || (c.millesime - 5) || $$, nouveau passage lors de la campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 3 AS passage -- /!\ ATTENTION, AVEC LA DENSIFICATION PI 2024, C'EST UN TROISIÈME PASSAGE !!!
FROM campagne c
CROSS JOIN echantillon e
INNER JOIN campagne cp ON e.id_campagne = cp.id_campagne
WHERE c.millesime = 2027
AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage = 1 AND cp.millesime = c.millesime - 5
ORDER BY nom_ech DESC;


-- AJOUT DES NŒUDS NOUVEAUX UTILISÉS DANS LA TABLE NOEUD_ECH
-- On reprend les nœuds de la 1ème grille d'échantillonnage, Incref 2
INSERT INTO noeud_ech (id_noeud, id_ech)
SELECT n.id_noeud, e.id_ech
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
CROSS JOIN noeud n
WHERE n.id_grille = 1
AND n.incref = 2
AND c.millesime = 2027
AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
ORDER BY id_noeud;


DROP TABLE IF EXISTS public.croise;

WITH croise AS (
    SELECT ne.id_ech, ne.id_noeud, ne.depn, d.dep
    FROM noeud_ech ne
    INNER JOIN echantillon e USING (id_ech)
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN noeud n USING (id_noeud)
    INNER JOIN sig_ign.deps_2002 d ON st_intersects (d.geom, st_transform(n.geom,27572))
    WHERE c.millesime = 2027
    AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
)
UPDATE noeud_ech ne
SET depn = c.dep
FROM croise c
WHERE ne.id_ech = c.id_ech
AND ne.id_noeud = c.id_noeud; --> 1 noeud hors territoire en 2027 dans le 56 à Séné --> id_noeud = 7136 AND id_ech = 147;

-- Pour les nœuds sans département, on récupère le département le plus proche 
WITH empty_nodes AS (
    SELECT id_ech, id_noeud, depn, st_transform(geom,27572) AS geom
    FROM noeud_ech
    INNER JOIN echantillon USING (id_ech)
    INNER JOIN campagne USING (id_campagne)
    INNER JOIN noeud USING (id_noeud)
    WHERE millesime = 2027
    AND type_ech = 'IFN' AND phase_stat = 1 AND type_ue = 'P' AND passage = 1
    AND depn IS NULL
)
, proche_dep AS (
    SELECT en.id_ech, en.id_noeud, pd.dep, pd.distance
    FROM empty_nodes en
    CROSS JOIN LATERAL (
        SELECT d.dep,
        ST_Distance(en.geom, d.geom) AS distance
        FROM sig_ign.deps_2002 d
        ORDER BY ST_Distance(en.geom, d.geom)
        LIMIT 1
    ) AS pd
)
UPDATE noeud_ech ne
SET depn = pd.dep
FROM proche_dep pd
WHERE ne.id_ech = pd.id_ech
AND ne.id_noeud = pd.id_noeud;

/*-- contrôle -----------------------------------------
SELECT ne.id_noeud, count(ne.id_noeud)
FROM noeud_ech ne
WHERE id_ech = 147 AND ne.depn IS NULL
GROUP BY ne.id_noeud;

SELECT ne.depn, count(ne.id_noeud)
FROM noeud_ech ne
WHERE id_ech = 147
GROUP BY depn
ORDER BY depn;
*/
------------------------------------------------------------
-- Mise à jour de la région forestière
WITH croise AS (
    SELECT ne.id_ech, ne.id_noeud, r.regn
    FROM noeud_ech ne
    INNER JOIN echantillon e USING (id_ech)
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN noeud n USING (id_noeud)
    INNER JOIN sig_inventaire.regn r ON st_intersects (r.geom, n.geom)
    WHERE c.millesime = 2027
    AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
)
UPDATE noeud_ech ne
SET regn = c.regn
FROM croise c
WHERE ne.id_ech = c.id_ech
AND ne.id_noeud = c.id_noeud;

-- Pour les nœuds sans région forestière, on récupère la région la plus proche --> 18 noeuds en 2027
WITH empty_nodes AS (
    SELECT id_ech, id_noeud, regn, geom
    FROM noeud_ech
    INNER JOIN echantillon USING (id_ech)
    INNER JOIN campagne USING (id_campagne)
    INNER JOIN noeud USING (id_noeud)
    WHERE millesime = 2027
    AND type_ech = 'IFN' AND phase_stat = 1 AND type_ue = 'P' AND passage = 1
    AND regn IS NULL
)
, proche_regn AS (
    SELECT en.id_ech, en.id_noeud, pr.regn, pr.distance
    FROM empty_nodes en
    CROSS JOIN LATERAL (
        SELECT r.regn,
        ST_Distance(en.geom, r.geom) AS distance
        FROM sig_inventaire.regn r
        ORDER BY ST_Distance(en.geom, r.geom)
        LIMIT 1
    ) AS pr
)
UPDATE noeud_ech ne
SET regn = pr.regn
FROM proche_regn pr
WHERE ne.id_ech = pr.id_ech
AND ne.id_noeud = pr.id_noeud;

-----------------------------------------------------------------------------------------
-- CROISEMENT AVEC LE RGE ALTI
DROP TABLE IF EXISTS public.nds_rge;

CREATE UNLOGGED TABLE public.nds_rge AS 
SELECT id_ech, id_noeud, geom, NULL::int4 AS zp
FROM noeud_ech pe 
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN noeud p USING (id_noeud)
WHERE c.millesime = 2027
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 1
AND e.passage = 1;

CALL ifn_prod.croise_rge_alti('public.nds_rge', '{"id_ech", "id_noeud"}', 'geom', 200, 'zp', TRUE);

/*
-- si plantage => on relance l'appel de la procédure
SELECT count(*), count(zp)
FROM public.nds_rge;
-- si tous les noeuds n'ont pas une altitude, on relance l'appel de la procédure
*/

UPDATE public.nds_rge
SET zp = 0
WHERE zp < -400;

UPDATE noeud_ech ne
SET zp = pr.zp
FROM nds_rge pr
WHERE ne.id_ech = pr.id_ech
AND ne.id_noeud = pr.id_noeud;

DROP TABLE public.nds_rge;


-- à partir d'ici, en TEST et en PROD on passe au script 01 et on y importe les points créés dans ce script : pts22_geom.csv
----------------------------------------------------------------------------------------------------------------------------------------------------
-- TIRAGE L'ÉCHANTILLON DE POINTS NOUVEAUX
-- initialisation de la racine des valeurs aléatoires (répétabilité du tirage)
DROP TABLE IF EXISTS public.nds;

SELECT SETSEED(0.2027); -- campagne 2027

CREATE TABLE public.nds AS 
SELECT n.nppg, n.id_noeud, c.millesime, ne.depn, ST_X(ST_Transform(n.geom, 27572)) AS xlt, ST_Y(ST_Transform(n.geom, 27572)) AS ylt, m.absc, m.ord, n.tirmax
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY c.millesime ORDER BY 3 * m.absc + m.ord), '000')) AS pos_absc
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY c.millesime ORDER BY 3 * m.ord - m.absc), '000')) AS pos_ord
, RANDOM() AS rx, RANDOM() AS ry
FROM noeud n
INNER JOIN noeud_ech ne USING (id_noeud)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN maille m ON ST_Intersects(n.geom, m.geom)
WHERE c.millesime = 2027
AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
ORDER BY id_noeud;

-- tirage initial
DROP TABLE IF EXISTS public.pts_new;

CREATE TABLE public.pts_new AS 
SELECT right(millesime::TEXT, 2) || '-' || n.depn || '-' || n.pos_absc || '-1-' || n.pos_ord || 'T' AS npp
, right(millesime::TEXT, 2) || n.pos_absc || '1' || n.pos_ord AS nph
, nppg, id_noeud
, '1'::CHAR(1) AS poi
, n.xlt + 1000 * (n.Rx - 0.5) AS xl
, n.ylt + 1000 * (n.Ry - 0.5) AS yl
, 1::SMALLINT AS poids
FROM nds n
ORDER BY absc, ord;

SELECT * FROM public.pts_new WHERE npp IS NULL;

-- ajout d'une colonne geometry pour croisements carto et indexation
ALTER TABLE public.pts_new ADD COLUMN geom GEOMETRY;
ALTER TABLE public.pts_new ADD CONSTRAINT pts_new_pk PRIMARY KEY (npp);
UPDATE public.pts_new SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom', 27572);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom_gist ON public.pts_new USING GIST (geom);

----------------------------------------------------------------------
-- croisement avec la couche du territoire
ALTER TABLE public.pts_new ADD COLUMN territoire SMALLINT;

ANALYZE public.pts_new;

DROP TABLE IF EXISTS croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM public.pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON (ST_Intersects(p.geom, t.geom))
ORDER BY p.npp;

UPDATE public.pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE public.pts_new
SET territoire = 0
WHERE territoire IS NULL;

-- liste des points qui tombent en dehors du territoire
SELECT *
FROM public.pts_new
WHERE territoire = 0;
-- => 122 points en 2027

-- C'EST LÀ QUE JE MODIFIE LA PROCÉDURE !
-- Dans chaque nœud concerné, on tire 20 points aléatoirement (et on numérote leur ordre de 1 à 20)
DROP TABLE IF EXISTS public.pts_new_ht;

SELECT SETSEED(0.20271);

CREATE TABLE public.pts_new_ht AS 
SELECT npp, pn.nppg, id_noeud, i AS rang, n.xlt + 1000 * (RANDOM() - 0.5) AS xlp2, n.ylt + 1000 * (RANDOM() - 0.5) AS ylp2
FROM public.pts_new pn
INNER JOIN public.nds n USING (id_noeud)
CROSS JOIN generate_series(1, 20) i
WHERE territoire = 0;

-- On calcule leur géométrie et on l'indexe
ALTER TABLE public.pts_new_ht ADD COLUMN geom GEOMETRY;
ALTER TABLE public.pts_new_ht ADD CONSTRAINT pts_new_ht_pk PRIMARY KEY (npp, rang);
UPDATE public.pts_new_ht SET geom = ST_SetSRID(ST_MakePoint(xlp2, ylp2), 27572);

SELECT UpdateGeometrySRID('public', 'pts_new_ht', 'geom', 27572);
SELECT Populate_Geometry_Columns('pts_new_ht'::regclass);

CREATE INDEX pts_new_ht_geom_gist ON public.pts_new_ht USING GIST (geom);

ALTER TABLE public.pts_new_ht ADD COLUMN territoire SMALLINT;

ANALYZE public.pts_new_ht;

-- On croise ces points avec le territoire
DROP TABLE IF EXISTS croise_ht;

CREATE TEMPORARY TABLE croise_ht AS
SELECT p.npp, p.rang, t.gid
FROM public.pts_new_ht p
INNER JOIN sig_inventaire.vt50p2 t ON (ST_Intersects(p.geom, t.geom))
ORDER BY p.npp;

UPDATE public.pts_new_ht p
SET territoire = 1
FROM croise_ht c
WHERE p.npp = c.npp
AND p.rang = c.rang;

UPDATE public.pts_new_ht
SET territoire = 0
WHERE territoire IS NULL;

SELECT count(DISTINCT npp) - count(DISTINCT npp) FILTER (WHERE territoire = 1) AS nb_pts_hors_territoire
FROM public.pts_new_ht; -- 0 point => c'est bon ! 

DROP TABLE croise_ht;

-- On remplace les coordonnées du point hors territoire par le premier des 20 points correspondant dans le territoire
WITH rang_1 AS (
    SELECT npp, nppg, id_noeud, xlp2, ylp2, geom, rank() over(PARTITION BY npp ORDER BY rang) AS pos
    FROM public.pts_new_ht
    WHERE territoire = 1
)
, remplace AS (
    SELECT *
    FROM rang_1
    WHERE pos = 1
)
UPDATE public.pts_new pn
SET xl = r.xlp2, yl = r.ylp2, geom = r.geom
FROM remplace r
WHERE pn.id_noeud = r.id_noeud;

DROP TABLE public.pts_new_ht;

-- on recroise tous les points avec le territoire pour vérifier que c'est bon 
ANALYZE public.pts_new;

DROP TABLE croise;

UPDATE public.pts_new p
SET territoire = NULL;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM public.pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
ORDER BY p.npp;

UPDATE public.pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE public.pts_new
SET territoire = 0
WHERE territoire IS NULL;

SELECT npp, xl, yl, geom
FROM public.pts_new
WHERE territoire = 0
ORDER BY npp; -- => 0 point

DROP TABLE croise;

ALTER TABLE public.pts_new ADD COLUMN geom93 GEOMETRY;
--ALTER TABLE public.pts_new ADD COLUMN zp SMALLINT;

UPDATE public.pts_new SET geom93 = ST_Transform(geom, 2154);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom93', 2154);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom93_gist ON public.pts_new USING GIST (geom93);


-- croisements avec les régions forestières
ANALYZE public.pts_new;

ALTER TABLE public.pts_new 
   ADD COLUMN campagne int2,
   ADD COLUMN regn CHAR(3), 
   ADD COLUMN ser_86 CHAR(3),
   ADD COLUMN ser_alluv CHAR(2),
   ADD COLUMN dep CHAR(2),
   ADD COLUMN commune CHAR(5);

UPDATE public.pts_new p
SET regn = r.regn
FROM sig_inventaire.regn r
WHERE ST_Intersects(p.geom93, r.geom); --12 points sans région forestière

-- Pour les points sans région forestière, on récupère la région la plus proche
WITH empty_pts AS (
    SELECT npp, regn, geom93
    FROM public.pts_new
    WHERE regn IS NULL
)
, proche_regn AS (
    SELECT ep.npp, pr.regn, pr.distance
    FROM empty_pts ep
    CROSS JOIN LATERAL (
        SELECT r.regn,
        ST_Distance(ep.geom93, r.geom) AS distance
        FROM sig_inventaire.regn r
        ORDER BY ST_Distance(ep.geom93, r.geom)
        LIMIT 1
    ) AS pr
)
UPDATE public.pts_new p
SET regn = pr.regn
FROM proche_regn pr
WHERE p.npp = pr.npp;

-- croisement avec les sylvoécorégions
UPDATE pts_new p
SET ser_86 = s.codeser
FROM sig_inventaire.ser_86 s
WHERE ST_Intersects(p.geom93, s.geom);

SELECT * FROM pts_new WHERE ser_86 IS NULL;

UPDATE pts_new p
SET ser_alluv = s.codeser
FROM sig_inventaire.ser_al s
WHERE ST_Intersects(p.geom93, s.geom);

ANALYZE pts_new;

-- croisement avec les communes et départements

UPDATE pts_new p
SET commune = c.num_com, dep = c.num_dep
FROM sig_ign.communes2002 c
WHERE ST_Intersects(p.geom, c.geom);

UPDATE pts_new SET campagne = 2027;

SELECT * FROM pts_new WHERE commune IS NULL;
SELECT * FROM pts_new WHERE dep IS NULL;

SELECT npp, nph, poi, id_noeud
, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 2027 AS campagne
, poids, regn, ser_86, ser_alluv, dep, commune, geom93 AS geom 
FROM pts_new 
ORDER BY npp

--> la copie est inutile, la table public.pts_new peut directement être importée dans ifn_prod.point dans le script 01_tirage_phase1 !

-- dans psql : on exporte les points tirés dans un fichier
--\COPY (SELECT npp, nph, poi, id_noeud, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 2027 AS campagne, poids, regn, ser_86, ser_alluv, dep, commune, geom93 AS geom FROM pts_new ORDER BY npp) TO '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2027/donnees/pts22_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

-- \COPY (SELECT npp, nph, poi, id_noeud, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 2027 AS campagne, poids, regn, ser_86, ser_alluv, dep, commune, geom93 AS geom FROM pts_new ORDER BY npp) TO '/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/Campagne_2027/pts22_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''


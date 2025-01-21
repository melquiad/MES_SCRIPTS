-- AJOUT DE LA NOUVELLE CAMPAGNE ANNUELLE
INSERT INTO campagne (millesime, lib_campagne)
VALUES (2026, $$Campagne annuelle d inventaire forestier national, année 2026$$);

-- CRÉATION DES ÉCHANTILLONS DE PREMIÈRE PHASE ASSOCIÉS
INSERT INTO inv_prod_new.echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent, descript_ech, stat, type_ue, passage)
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, NULL::INT4 AS ech_parent
, $$Échantillon statistique de phase 1 des points de l'inventaire forestier national, campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 1 AS passage
FROM campagne c
WHERE c.millesime = 2026
UNION 
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || (c.millesime - 5) AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, e.id_ech AS ech_parent
, $$Échantillon statistique de phase 1 des points de l'inventaire forestier national issus initialement de la campagne $$ || (c.millesime - 5) || $$, nouveau passage lors de la campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 3 AS passage -- /!\ ATTENTION, AVEC LA DENSIFICATION PI 2024, C'EST UN TROISIÈME PASSAGE !!!
FROM campagne c
CROSS JOIN echantillon e
INNER JOIN campagne cp ON e.id_campagne = cp.id_campagne
WHERE c.millesime = 2026
AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage = 1 AND cp.millesime = c.millesime - 5
ORDER BY nom_ech DESC;

/*-- correction a posteriori du passage sur l'échantillon rephoto-interprété (le script a été corrigé ci-dessus)
UPDATE echantillon e
SET passage = 3
FROM campagne c
WHERE e.id_campagne = c.id_campagne
AND c.millesime = 2025
AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage = 2;
*/

-- AJOUT DES NŒUDS NOUVEAUX UTILISÉS DANS LA TABLE NOEUD_ECH
-- On reprend les nœuds de la 2ème grille d'échantillonnage, Incref 1
INSERT INTO noeud_ech (id_noeud, id_ech)
SELECT n.id_noeud, e.id_ech
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
CROSS JOIN noeud n
WHERE n.id_grille = 1
AND n.incref = 1
AND c.millesime = 2026
AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
ORDER BY id_noeud;

-- Mise à jour du département
-- SELECT UpdateGeometrySRID('sig_ign', 'deps_2002', 'geom', 27572);

DROP TABLE IF EXISTS public.croise;

WITH croise AS (
    SELECT ne.id_ech, ne.id_noeud, ne.depn, d.dep
    FROM noeud_ech ne
    INNER JOIN echantillon e USING (id_ech)
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN noeud n USING (id_noeud)
    INNER JOIN sig_ign.deps_2002 d ON st_intersects (d.geom, st_transform(n.geom,27572))
    WHERE c.millesime = 2026
    AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
)
UPDATE noeud_ech ne
SET depn = c.dep
FROM croise c
WHERE ne.id_ech = c.id_ech
AND ne.id_noeud = c.id_noeud; --> aucun noeud hors territoire en 2026

-- contrôle -----------------------------------------
/*
SELECT count(ne.id_noeud)
FROM noeud_ech ne
WHERE id_ech = 141 AND ne.depn IS NULL;

SELECT ne.depn, count(ne.id_noeud)
FROM noeud_ech ne
WHERE id_ech = 141
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
    WHERE c.millesime = 2026
    AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
)
UPDATE noeud_ech ne
SET regn = c.regn
FROM croise c
WHERE ne.id_ech = c.id_ech
AND ne.id_noeud = c.id_noeud;

-- Pour les nœuds sans région forestière, on récupère la région la plus proche --> 20 noeuds en 2026
WITH empty_nodes AS (
    SELECT id_ech, id_noeud, regn, geom --, st_transform(geom,2154) AS geom
    FROM noeud_ech
    INNER JOIN echantillon USING (id_ech)
    INNER JOIN campagne USING (id_campagne)
    INNER JOIN noeud USING (id_noeud)
    WHERE millesime = 2026
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


-- Mise à jour de l'altitude des nœuds à partir du croisement avec le RGE Alti (API Rest de la Géoplateforme) et documentation
-- Croisement avec le RGE Alti... fait par le script Python croisement_noeuds_rge_alti.py
CREATE TABLE public.alti_noeuds (
    id_grille INT4, 
    id_noeud INT4,
    zp numeric(7, 2),
    CONSTRAINT alti_noeuds_2026_pkey PRIMARY KEY (id_grille, id_noeud)
);

\COPY public.alti_noeuds FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/altitude_noeud_grille1_incref1.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

SELECT id_noeud, zp
FROM alti_noeuds
WHERE zp < 0;

UPDATE alti_noeuds
SET zp = 0
WHERE zp < -400;

UPDATE noeud_ech ne
SET zp = round(an.zp)
FROM alti_noeuds an
INNER JOIN noeud_ech nd USING (id_noeud)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2026
AND e.type_ech = 'IFN' AND e.phase_stat = 1 AND e.type_ue = 'P' AND e.passage = 1
AND ne.id_ech = nd.id_ech AND ne.id_noeud = nd.id_noeud;

SELECT id_noeud, zp
FROM noeud_ech
WHERE zp < 0;

DROP TABLE alti_noeuds;

-- à partir d'ici, en TEST et en PROD on passe au script 01 et on y importe les points créés dans ce script : pts21_geom.csv
----------------------------------------------------------------------------------------------------------------------------------------------------
-- TIRAGE L'ÉCHANTILLON DE POINTS NOUVEAUX
-- initialisation de la racine des valeurs aléatoires (répétabilité du tirage)
DROP TABLE IF EXISTS public.nds;

SELECT SETSEED(0.2026); -- campagne 2026

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
WHERE c.millesime = 2026
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

-- ajout d'une colonne geometry pour croisements carto et indexation
ALTER TABLE public.pts_new ADD COLUMN geom GEOMETRY;
--ALTER TABLE public.pts_new REPLICA IDENTITY FULL; --> commande nécessaire lors de l'exécution du script sur inv-bdd-dev
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
-- => 94 points en 2026

-- première passe de correction en décalant Y dans l'autre sens de celui d'origine
WITH pbs AS (
    SELECT p.npp, p.yl - n.ylt AS gapy
    FROM public.pts_new p
    INNER JOIN public.nds n USING (id_noeud)
    WHERE p.territoire = 0
)
UPDATE public.pts_new pt
SET yl = yl - 2 * gapy
FROM pbs pb
WHERE pt.npp = pb.npp;

-- on recroise avec le territoire...
UPDATE public.pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572)
WHERE territoire = 0;

ANALYZE public.pts_new;

DROP TABLE croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM public.pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
WHERE p.territoire = 0
ORDER BY p.npp;

UPDATE public.pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

SELECT npp, xl, yl, geom
FROM public.pts_new
WHERE territoire = 0
ORDER BY npp;
-- =>47 points hors territoire en 2026

-- deuxième passe de correction en décalant X dans l'autre sens de celui d'origine
WITH pbs AS (
    SELECT p.npp, p.xl - n.xlt AS gapx
    FROM public.pts_new p
    INNER JOIN public.nds n USING (id_noeud)
    WHERE p.territoire = 0
)
UPDATE public.pts_new pt
SET xl = xl - 2 * gapx
FROM pbs pb
WHERE pt.npp = pb.npp;

-- on recroise avec le territoire...
UPDATE public.pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572)
WHERE territoire = 0;

ANALYZE public.pts_new;

DROP TABLE croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM public.pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
WHERE p.territoire = 0
ORDER BY p.npp;

UPDATE public.pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

SELECT npp, xl, yl, geom
FROM public.pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 5 points hors territoire en 2026

/* pour affichage dans QGIS
CREATE TABLE public.hors_territoire AS
SELECT npp, xl, yl, geom
FROM public.pts_new
WHERE territoire = 0;

SELECT npp, id_noeud, st_x(n.geom) as xlt, st_y(n.geom) as ylt, st_transform(n.geom, 27572) AS geom
FROM public.pts_new
INNER JOIN noeud n USING (id_noeud)
WHERE territoire = 0;
*/

-- troisième correction plus manuelle
UPDATE public.pts_new SET xl = 50066, yl = 2408892 WHERE npp = '26-29-001-1-137T';
UPDATE public.pts_new SET xl = 204526, yl = 2300612 WHERE npp = '26-56-052-1-154T';
UPDATE public.pts_new SET xl = 213195, yl = 2297598 WHERE npp = '26-56-055-1-154T';
UPDATE public.pts_new SET xl = 978465, yl = 2282599 WHERE npp = '26-68-286-1-082T';
UPDATE public.pts_new SET xl = 942750, yl = 2157735 WHERE npp = '26-74-288-1-123T';


-- on recroise avec le territoire...
UPDATE public.pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572);

ANALYZE public.pts_new;

DROP TABLE IF EXISTS croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM public.pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
ORDER BY p.npp;

UPDATE public.pts_new SET territoire = NULL;

UPDATE public.pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE public.pts_new
SET territoire = 0
WHERE territoire IS NULL;

SELECT npp, xl, yl
FROM public.pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 0 points hors territoire

DROP TABLE croise;

ALTER TABLE public.pts_new ADD COLUMN geom93 GEOMETRY;
ALTER TABLE public.pts_new ADD COLUMN zp SMALLINT;

UPDATE public.pts_new SET geom93 = ST_Transform(geom, 2154);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom93', 2154);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom93_gist ON public.pts_new USING GIST (geom93);

-- Croisement avec le RGE Alti... fait par le script Python croisement_points_rge_alti.py
CREATE TABLE public.alti_points (
    npp TEXT, 
    zp numeric(7, 2),
    CONSTRAINT alti_points_2026__pkey PRIMARY KEY (npp)
);

\COPY public.alti_points FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/altitude_points_2026.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

SELECT npp, zp
FROM public.alti_points
WHERE zp < 0;

UPDATE public.alti_points
SET zp = 0
WHERE zp < -400;

UPDATE public.pts_new pn
SET zp = round(ap.zp)
FROM public.alti_points ap
WHERE pn.npp = ap.npp;

DROP TABLE public.alti_points;

-- croisements avec les régions forestières
ANALYZE public.pts_new;

ALTER TABLE public.pts_new 
   ADD COLUMN regn CHAR(3), 
   ADD COLUMN ser_86 CHAR(3),
   ADD COLUMN ser_alluv CHAR(2),
   ADD COLUMN dep CHAR(2),
   ADD COLUMN commune CHAR(5);

UPDATE public.pts_new p
SET regn = r.regn
FROM sig_inventaire.regn r
WHERE ST_Intersects(p.geom93, r.geom);

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
SELECT UpdateGeometrySRID('sig_inventaire', 'ser_86', 'geom', '2154');

UPDATE pts_new p
SET ser_86 = s.codeser
FROM sig_inventaire.ser_86 s
WHERE ST_Intersects(p.geom93, s.geom);

SELECT * FROM pts_new WHERE ser_86 IS NULL;

SELECT UpdateGeometrySRID('sig_inventaire', 'ser_al', 'geom', '2154');

UPDATE pts_new p
SET ser_alluv = s.codeser
FROM sig_inventaire.ser_al s
WHERE ST_Intersects(p.geom93, s.geom);

ANALYZE pts_new;

-- croisement avec les communes et départements
SELECT UpdateGeometrySRID('sig_ign', 'communes2002', 'geom', '27572');

UPDATE pts_new p
SET commune = c.num_com, dep = c.num_dep
FROM sig_ign.communes2002 c
WHERE ST_Intersects(p.geom, c.geom);

SELECT * FROM pts_new WHERE commune IS NULL;
SELECT * FROM pts_new WHERE dep IS NULL;

-- dans psql : on exporte les points tirés dans un fichier
\COPY (SELECT npp, nph, poi, id_noeud, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 2026 AS campagne, poids, zp, regn, ser_86, ser_alluv, dep, commune, geom93 AS geom FROM pts_new ORDER BY npp) TO '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/pts21_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''



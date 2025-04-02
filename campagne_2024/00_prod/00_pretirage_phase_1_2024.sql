-- FAIT SUR UN SERVEUR DE DÉVELOPPEMENT... (machine locale pour avoir QGIS sous la main)

-- AJOUT DE LA NOUVELLE CAMPAGNE ANNUELLE
INSERT INTO campagne (millesime, lib_campagne)
VALUES (2024, $$Campagne annuelle d inventaire forestier national, année 2024$$);

-- CRÉATION DES ÉCHANTILLONS DE PREMIÈRE PHASE ASSOCIÉS
INSERT INTO echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent)
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'P' AS type_ech, 1 AS phase_stat, NULL::INT4 AS ech_parent
FROM campagne c
WHERE c.millesime = 2024
UNION 
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || (c.millesime - 5) AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'P' AS type_ech, 1 AS phase_stat, e.id_ech AS ech_parent
FROM campagne c
CROSS JOIN echantillon e
WHERE c.millesime = 2024
AND e.nom_ech = 'FR_IFN_ECH_' || (c.millesime - 5) || '_PH1_PTS_' || (c.millesime - 5)
ORDER BY nom_ech DESC;

-- AJOUT DES NŒUDS NOUVEAUX UTILISÉS DANS LA TABLE NOEUD_ECH
-- on s'appuie sur l'ancienne base de production pour récupérer les infos issues des croisements carto, déjà présentes
INSERT INTO noeud_ech (id_ech, id_noeud, zp, depn, zpopifn, regn, zforifn, zforifnd)
SELECT e.id_ech AS id_ech, n.id_noeud, en.zp, en.depn, cp."mode" AS zpopifn, en.regn, cf."mode" AS zforifn, cd."mode" AS zforifnd
FROM inv_prod_new.noeud n
INNER JOIN inv_prod.e1noeud en USING (nppg)
INNER JOIN inv_prod.e1situation esf ON en.nppg = esf.nppg
INNER JOIN inv_prod.c0attribut cf ON esf.nppu = cf.nppu AND cf.donnee = 'ZFORIFN'
INNER JOIN inv_prod.e1situation esp ON en.nppg = esp.nppg
INNER JOIN inv_prod.c0attribut cp ON esp.nppu = cp.nppu AND cp.donnee = 'ZPOPIFN'
INNER JOIN inv_prod.e1situation esd ON en.nppg = esd.nppg
INNER JOIN inv_prod.c0attribut cd ON esd.nppu = cd.nppu AND cd.donnee = 'ZFORIFND'
INNER JOIN inv_prod_new.campagne c ON c.millesime = n.incref + 2005
INNER JOIN inv_prod_new.echantillon e ON c.id_campagne = e.id_campagne AND e.nom_ech = 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime
WHERE n.incref = 19
ORDER BY id_noeud;


-- TIRAGE L'ÉCHANTILLON DE POINTS NOUVEAUX
-- initialisation de la racine des valeurs aléatoires (répétabilité du tirage)
DROP TABLE IF EXISTS nds;

SELECT SETSEED(0.2024); -- campagne 2024

CREATE TEMPORARY TABLE nds AS 
SELECT n.nppg, n.id_noeud, n.incref, ne.depn, ST_X(ST_Transform(n.geom, 932006)) AS xlt, ST_Y(ST_Transform(n.geom, 932006)) AS ylt, m.absc, m.ord, n.tirmax
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY n.incref ORDER BY 3 * m.absc + m.ord), '000')) AS pos_absc
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY n.incref ORDER BY 3 * m.ord - m.absc), '000')) AS pos_ord
, RANDOM() AS rx, RANDOM() AS ry
FROM noeud n
INNER JOIN noeud_ech ne USING (id_noeud)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN maille m ON ST_Intersects(n.geom, m.geom)
WHERE c.millesime = 2024
AND e.nom_ech = 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime
ORDER BY id_noeud;

-- tirage initial
DROP TABLE IF EXISTS public.pts_new;

CREATE TABLE public.pts_new AS 
SELECT (n.incref + 5)::CHAR(2) || '-' || n.depn || '-' || n.pos_absc || '-1-' || n.pos_ord || 'T' AS npp
, (n.incref + 5)::CHAR(2) || n.pos_absc || '1' || n.pos_ord AS nph
, nppg, id_noeud
, '1'::CHAR(1) AS poi
, n.xlt + 1000 * (n.Rx - 0.5) AS xl
, n.ylt + 1000 * (n.Ry - 0.5) AS yl
, 1::SMALLINT AS poids
FROM nds n
ORDER BY absc, ord;

-- ajout d'une colonne geometry pour croisements carto et indexation
ALTER TABLE pts_new ADD COLUMN geom GEOMETRY;

UPDATE pts_new SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 932006);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom', 932006);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom_gist ON pts_new USING GIST (geom);

-- croisement avec la couche du territoire
ALTER TABLE pts_new ADD COLUMN territoire SMALLINT;

ANALYZE pts_new;

DROP TABLE IF EXISTS croise;

--SELECT UpdateGeometrySRID('sig_inventaire', 'vt50p2', 'geom', 932006);

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON (ST_Intersects(p.geom, t.geom))
ORDER BY p.npp;

UPDATE pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE pts_new
SET territoire = 0
WHERE territoire IS NULL;

-- liste des points qui tombent en dehors du territoire
SELECT *
FROM pts_new
WHERE territoire = 0;
-- => 113 points

-- première passe de correction en décalant Y dans l'autre sens de celui d'origine
WITH pbs AS (
    SELECT p.npp, p.yl - n.ylp AS gapy
    FROM pts_new p
    INNER JOIN inv_prod.e1noeud n USING (nppg)
    WHERE p.territoire = 0
)
UPDATE pts_new pt
SET yl = yl - 2 * gapy
FROM pbs pb
WHERE pt.npp = pb.npp;

-- on recroise avec le territoire...
UPDATE pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 932006)
WHERE territoire = 0;

ANALYZE pts_new;

DROP TABLE croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
WHERE p.territoire = 0
ORDER BY p.npp;

UPDATE pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

SELECT npp, xl, yl, geom
FROM pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 46 points hors territoire

-- deuxième passe de correction en décalant X dans l'autre sens de celui d'origine
WITH pbs AS (
    SELECT p.npp, p.xl - n.xlp AS gapx
    FROM pts_new p
    INNER JOIN inv_prod.e1noeud n USING (nppg)
    WHERE p.territoire = 0
)
UPDATE pts_new pt
SET xl = xl - 2 * gapx
FROM pbs pb
WHERE pt.npp = pb.npp;

-- on recroise avec le territoire...
UPDATE pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 932006)
WHERE territoire = 0;

ANALYZE pts_new;

DROP TABLE croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
WHERE p.territoire = 0
ORDER BY p.npp;

UPDATE pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

SELECT npp, xl, yl, geom
FROM pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 8 points hors territoire

/* pour affichage dans QGIS
SELECT npp, xl, yl, geom
FROM pts_new
WHERE territoire = 0;

SELECT id_noeud, st_x(n.geom) as xlt, st_y(n.geom) as ylt, st_transform(n.geom, 932006) AS geom
FROM pts_new
INNER JOIN noeud n USING (id_noeud)
WHERE territoire = 0;
*/

-- troisième correction plus manuelle
UPDATE pts_new SET xl = 88474,  yl = 2421540 WHERE npp = '23-29-006-1-130T';
UPDATE pts_new SET xl = 284195,  yl = 2419732 WHERE npp = '23-35-065-1-111T';
UPDATE pts_new SET xl = 191442,  yl = 2300497 WHERE npp = '23-56-049-1-156T';
UPDATE pts_new SET xl = 207052,  yl = 2298260 WHERE npp = '23-56-054-1-155T';
UPDATE pts_new SET xl = 213070,  yl = 2296445 WHERE npp = '23-56-056-1-155T';
UPDATE pts_new SET xl = 969950,  yl = 1837628 WHERE npp = '23-83-329-1-217T';
UPDATE pts_new SET xl = 1178261,  yl = 1621426 WHERE npp = '23-2A-369-1-261T';
UPDATE pts_new SET xl = 1181384,  yl = 1620843 WHERE npp = '23-2A-370-1-261T';


-- on recroise avec le territoire...
UPDATE pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 932006);

ANALYZE pts_new;

DROP TABLE IF EXISTS croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
ORDER BY p.npp;

UPDATE pts_new SET territoire = NULL;

UPDATE pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE pts_new
SET territoire = 0
WHERE territoire IS NULL;

SELECT npp, xl, yl
FROM pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 0 points hors territoire

-- vérification de la distance avec les points des campagnes précédentes : points à moins de 50 m
ALTER TABLE pts_new ADD COLUMN geom93 GEOMETRY;
ALTER TABLE pts_new ADD COLUMN zp SMALLINT;

UPDATE pts_new SET geom93 = ST_Transform(geom, 931007);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom93', 931007);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom93_gist ON pts_new USING GIST (geom93);

DROP TABLE IF EXISTS proches;

CREATE TEMPORARY TABLE proches AS 
SELECT pn.npp, pp.id_point, pp.distance
FROM pts_new pn
CROSS JOIN LATERAL (
    SELECT p.id_point,
    ST_Distance(pn.geom93, p.geom) AS distance
    FROM point p
    WHERE ST_DWithin(pn.geom93, p.geom, 50)
    ORDER BY ST_Distance(pn.geom93, p.geom)
    LIMIT 1
) AS pp
ORDER BY pp.distance;
-- 597 points

-- on les place à 51 m du point le plus proche
WITH ab AS (
    SELECT pn.npp, p.id_point, pn.xl AS xa, pn.yl AS ya, ST_X(ST_Transform(p.geom, 932006)) AS xb, ST_Y(ST_Transform(p.geom, 932006)) AS yb
    , SQRT(POWER(pn.xl - ST_X(ST_Transform(p.geom, 932006)), 2) + POWER(pn.yl - ST_Y(ST_Transform(p.geom, 932006)), 2)) AS dist_ab, pr.distance
    FROM proches pr
    INNER JOIN pts_new pn ON pr.npp = pn.npp
    INNER JOIN point p ON pr.id_point = p.id_point
)
UPDATE pts_new p
SET xl = CASE WHEN xb > xa THEN ROUND((xb - 51.0 * COS(ATAN(1.0 * (yb-ya) / (xb-xa))))::NUMERIC, 0)
              WHEN xb < xa THEN ROUND((xb - 51.0 * COS(ATAN(1.0 * (yb-ya) / (xb-xa))))::NUMERIC, 0)
              ELSE xb
         END
, yl = CASE WHEN xb > xa THEN ROUND((yb - 51.0 * SIN(atan(1.0 * (yb-ya) / (xb-xa))))::NUMERIC, 0)
            WHEN xa < yb THEN ROUND((yb + 51.0 * SIN(atan(1.0 * (yb-ya) / (xb-xa))))::NUMERIC, 0)
            WHEN yb > ya THEN yb - 51.0
            ELSE yb + 51.0
       END
FROM ab
WHERE p.npp = ab.npp;

SELECT * FROM proches ORDER BY distance;

-- on recalcule la distance au plus proche dans un rayon de 50 m
UPDATE pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 932006);

UPDATE pts_new SET geom93 = ST_Transform(geom, 931007);

DROP TABLE proches;

CREATE TEMPORARY TABLE proches AS 
SELECT pn.npp, pp.id_point, pp.distance
FROM pts_new pn
CROSS JOIN LATERAL (
    SELECT p.id_point,
    ST_Distance(pn.geom93, p.geom) AS distance
    FROM point p
    WHERE ST_DWithin(pn.geom93, p.geom, 50)
    ORDER BY ST_Distance(pn.geom93, p.geom)
    LIMIT 1
) AS pp
ORDER BY pp.distance;

--SELECT * FROM proches ORDER BY distance;
-- => il n'y en a plus

-- points sortis de la maille de 1 km²
SELECT npp, xl, yl
, ST_X(ST_Transform(n.geom, 932006)) AS xlp, ST_Y(ST_Transform(n.geom, 932006)) AS ylp
, xl - ST_X(ST_Transform(n.geom, 932006)) AS gapx, yl - ST_Y(ST_Transform(n.geom, 932006)) AS gapy
FROM pts_new
INNER JOIN noeud n USING (id_noeud)
WHERE ABS(xl - ST_X(ST_Transform(n.geom, 932006))) > 500
OR ABS(yl - ST_Y(ST_Transform(n.geom, 932006))) > 500;
-- => il n'y en a pas

-- on recroise avec le territoire...
DROP TABLE IF EXISTS croise;

CREATE TEMPORARY TABLE croise AS
SELECT p.npp, t.gid
FROM pts_new p
INNER JOIN sig_inventaire.vt50p2 t ON ST_Intersects(p.geom, t.geom)
ORDER BY p.npp;

UPDATE pts_new SET territoire = NULL;

UPDATE pts_new p
SET territoire = 1
FROM croise c
WHERE p.npp = c.npp;

UPDATE pts_new
SET territoire = 0
WHERE territoire IS NULL;

SELECT npp, xl, yl
FROM pts_new
WHERE territoire = 0
ORDER BY npp;
-- => 0 points hors territoire

DROP TABLE croise;

-- croisement avec le MNT pour avoir l'altitude des points
CREATE TEMPORARY TABLE alti AS
SELECT npp, xl, yl, rid, (gv).val AS zp
FROM (
    SELECT p.npp, p.xl, p.yl, m.rid, ST_Intersection(m.rast, p.geom93) AS gv
    FROM pts_new p
    INNER JOIN bdalti2011.mnt m ON ST_Intersects(m.rast, p.geom93)
) foo
ORDER BY 1;

WITH t0 AS (
    SELECT npp, MIN(zp) AS zp
    FROM alti
    GROUP BY npp
)
UPDATE pts_new p
SET zp = t0.zp
FROM t0
WHERE p.npp = t0.npp;

-- croisements avec les régions forestières
/*
shp2pgsql -s 931007 -D -i -I -W latin1 /home/CDuprez/Documents/IGN/Formation/Carto/rnifn250_l93.shp sig_inventaire.regn > /home/CDuprez/Documents/IGN/Formation/Carto/regn.sql
psql service=ubuntu -f /home/CDuprez/Documents/IGN/Formation/Carto/regn.sql
psql service=test-inv-prod -f /home/CDuprez/Documents/IGN/Formation/Carto/regn.sql
psql service=inv-prod -f /home/CDuprez/Documents/IGN/Formation/Carto/regn.sql
*/

ANALYZE pts_new;

ALTER TABLE pts_new 
    ADD COLUMN regn CHAR(3), 
    ADD COLUMN ser_86 CHAR(3), 
    ADD COLUMN ser_alluv CHAR(2), 
    ADD COLUMN dep CHAR(2), 
    ADD COLUMN commune CHAR(5);

UPDATE pts_new p
SET regn = r.regn
FROM sig_inventaire.regn r
WHERE ST_Intersects(p.geom93, r.geom);

-- points sans région forestière
SELECT npp, geom93 FROM pts_new WHERE regn IS NULL ORDER BY npp; -- 18 points

-- mise à jour "manuelle" sur ces points
UPDATE pts_new SET regn = '175' WHERE npp IN ('23-44-075-1-166T');
UPDATE pts_new SET regn = '223' WHERE npp IN ('23-22-041-1-115T', '23-35-065-1-111T');
UPDATE pts_new SET regn = '296' WHERE npp IN ('23-29-002-1-139T', '23-29-004-1-139T', '23-29-0020-1-139T');
UPDATE pts_new SET regn = '404' WHERE npp IN ('23-33-125-1-242T');
UPDATE pts_new SET regn = '503' WHERE npp IN ('23-50-069-1-094T');
UPDATE pts_new SET regn = '565' WHERE npp IN ('23-56-054-1-155T', '23-56-051-165T');
UPDATE pts_new SET regn = '572' WHERE npp IN ('23-57-246-1-028T');
UPDATE pts_new SET regn = '732' WHERE npp IN ('23-73-298-1-144T');
UPDATE pts_new SET regn = '2A0' WHERE npp IN ('23-2A-357-1-254T');
UPDATE pts_new SET regn = '2AS' WHERE npp IN ('23-2A-361-1-260T', '23-2A-369-1-261T', '23-2A-370-1-261T');
UPDATE pts_new SET regn = '2B1' WHERE npp IN ('23-2B-352-1-214T');
UPDATE pts_new SET regn = '2B5' WHERE npp IN ('23-2B-347-1-219T');

SELECT npp, geom93 FROM pts_new WHERE regn IS NULL ORDER BY npp; -- 18 points

-- croisement avec les sylvoécorégions
SELECT UpdateGeometrySRID('sig_inventaire', 'ser_86', 'geom', '931007');

UPDATE pts_new p
SET ser_86 = s.codeser
FROM sig_inventaire.ser_86 s
WHERE ST_Intersects(p.geom93, s.geom);

SELECT * FROM pts_new WHERE ser_86 IS NULL;

SELECT UpdateGeometrySRID('sig_inventaire', 'ser_al', 'geom', '931007');

UPDATE pts_new p
SET ser_alluv = s.codeser
FROM sig_inventaire.ser_al s
WHERE ST_Intersects(p.geom93, s.geom);

ANALYZE pts_new;

-- croisement avec les communes et départements
SELECT UpdateGeometrySRID('sig_ign', 'communes2002', 'geom', '932006');

UPDATE pts_new p
SET commune = c.num_com, dep = c.num_dep
FROM sig_ign.communes2002 c
WHERE ST_Intersects(p.geom, c.geom);

SELECT * FROM pts_new WHERE commune IS NULL;
SELECT * FROM pts_new WHERE dep IS NULL;

-- on exporte les points tirés dans un fichier
\COPY (SELECT npp, nph, nppg, poi, id_noeud, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 19 AS incref, poids, zp, regn, ser_86, ser_alluv, dep, commune, geom93 AS geom FROM pts_new ORDER BY npp) TO '/home/lhaugomat/Documents/tirage/pts19_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''



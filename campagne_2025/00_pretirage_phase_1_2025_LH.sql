-- FAIT SUR UN SERVEUR DE DÉVELOPPEMENT... (machine locale pour avoir QGIS sous la main)

-- AJOUT DE LA NOUVELLE CAMPAGNE ANNUELLE
INSERT INTO campagne (millesime, lib_campagne)
VALUES (2025, $$Campagne annuelle d inventaire forestier national, année 2025$$);

-- CRÉATION DES ÉCHANTILLONS DE PREMIÈRE PHASE ASSOCIÉS
INSERT INTO echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent, descript_ech, stat, type_ue, passage)
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, NULL::INT4 AS ech_parent
, $$Échantillon statistique de phase 1 des points de l'inventaire forestier national, campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 1 AS passage
FROM campagne c
WHERE c.millesime = 2025
UNION 
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || (c.millesime - 5) AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 1 AS phase_stat, e.id_ech AS ech_parent
, $$Échantillon statistique de phase 1 des points de l'inventaire forestier national issus initialement de la campagne $$ || (c.millesime - 5) || $$, nouveau passage lors de la campagne $$ || c.millesime AS descript_ech
, TRUE AS stat, 'P' AS type_ue, 2 AS passage
FROM campagne c
CROSS JOIN echantillon e
INNER JOIN campagne cp ON e.id_campagne = cp.id_campagne
WHERE c.millesime = 2025
AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage = 1 AND cp.millesime = c.millesime - 5
ORDER BY nom_ech DESC;



-- AJOUT DES NŒUDS NOUVEAUX UTILISÉS DANS LA TABLE NOEUD_ECH
-- on s'appuie sur l'ancienne base de production pour récupérer les infos issues des croisements carto, déjà présentes
INSERT INTO noeud_ech (id_ech, id_noeud)--, zp, depn, zpopifn, regn, zforifn, zforifnd)
SELECT e.id_ech , n.id_noeud--, en.zp, en.depn, cp."mode" AS zpopifn, en.regn, cf."mode" AS zforifn, cd."mode" AS zforifnd
FROM inv_prod_new.noeud n
CROSS JOIN inv_prod_new.echantillon e
INNER JOIN inv_prod_new.campagne c ON e.id_campagne = c.id_campagne 
WHERE n.incref = 0 AND n.id_grille = 1 AND c.millesime = 2025 AND e.passage = 1 AND e.ech_parent IS NULL 
ORDER BY id_noeud;

-- remplissage des champs vide à partir des données de l'écahntillon 1
WITH zones AS
	(
	SELECT id_ech, id_noeud, zp, depn, zpopifn, regn, zforifn, zforifnd
	FROM noeud_ech
	WHERE id_ech = 1
	)
UPDATE noeud_ech ne
SET zp = z.zp, depn = z.depn, zpopifn = z.zpopifn, regn = z.regn, zforifn = z.zforifn, zforifnd = z.zforifnd
FROM zones z
WHERE ne.id_ech = 134 AND ne.id_noeud = z.id_noeud;

-- ou
-- remplissage via croisement carto (ici avec la couche regn uniquement)
UPDATE noeud_ech ne
SET regn = re.regn
FROM sig_inventaire.regn re
INNER JOIN noeud n ON st_intersects(n.geom,re.geom) 
WHERE ne.id_noeud = n.id_noeud AND ne.id_ech = 134;


-- à partir d'ici, en TEST et en PROD on passe au script 01 et on y importe les points créés dans ce script : pts20_geom.csv
----------------------------------------------------------------------------------------------------------------------------------------------------
-- TIRAGE L'ÉCHANTILLON DE POINTS NOUVEAUX
-- initialisation de la racine des valeurs aléatoires (répétabilité du tirage)
DROP TABLE IF EXISTS nds;

SELECT SETSEED(0.2025); -- campagne 2025

CREATE TEMPORARY TABLE nds AS 
SELECT n.nppg, n.id_noeud, 20 AS incref, ne.depn, ST_X(ST_Transform(n.geom, 27572)) AS xlt, ST_Y(ST_Transform(n.geom, 27572)) AS ylt, m.absc, m.ord, n.tirmax
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY n.incref ORDER BY 3 * m.absc + m.ord), '000')) AS pos_absc
, LTRIM(TO_CHAR(DENSE_RANK() OVER (PARTITION BY n.incref ORDER BY 3 * m.ord - m.absc), '000')) AS pos_ord
, RANDOM() AS rx, RANDOM() AS ry
FROM noeud n
INNER JOIN noeud_ech ne USING (id_noeud)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN maille m ON ST_Intersects(n.geom, m.geom)
WHERE c.millesime = 2025
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

UPDATE pts_new SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572);

SELECT UpdateGeometrySRID('public', 'pts_new', 'geom', 27572);
SELECT Populate_Geometry_Columns('pts_new'::regclass);

CREATE INDEX pts_new_geom_gist ON pts_new USING GIST (geom);

-- croisement avec la couche du territoire
ALTER TABLE pts_new ADD COLUMN territoire SMALLINT;

ANALYZE pts_new;

DROP TABLE IF EXISTS croise;


/*
CREATE TABLE  public.vt50p2 as
	(SELECT p.gid, p.area ,p.perimeter, p.vt50p2_, vt50p2_id, p.code, st_makevalid(st_transform(geom,27572)) AS geom
	from sig_inventaire.vt50p2 p); 
SELECT updategeometrysrid('public','vt50p2','geom',27572);
*/

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
-- => 93 points en campagne 2025

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
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572)
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
-- => 40 points hors territoire

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
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572)
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
-- => 6 points hors territoire

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
UPDATE pts_new SET xl = 125597,  yl = 2319570 WHERE npp = '25-29-026-1-157T';
UPDATE pts_new SET xl = 327880,  yl = 2118210 WHERE npp = '25-17-107-1-197T';
UPDATE pts_new SET xl = 849038,  yl = 1801594 WHERE npp = '25-13-295-1-240T';
UPDATE pts_new SET xl = 890347,  yl = 2144608 WHERE npp = '25-01-273-1-133T';
UPDATE pts_new SET xl = 1004077,  yl = 1866475 WHERE npp = '25-06-335-1-205T';
UPDATE pts_new SET xl = 1181052,  yl = 1617497 WHERE npp = '25-2A-369-1-262T';


-- on recroise avec le territoire...
UPDATE pts_new
SET geom = ST_SetSRID(ST_MakePoint(xl, yl), 27572);

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

/*  --------------------------- ON NE FAIT PLUS CETTE VERIFICATION ------------------------------
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
-- 634 points

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
*/  ----------------------------------------------------------------------------------------------

-- points sortis de la maille de 1 km²
SELECT npp, xl, yl
, ST_X(ST_Transform(n.geom, 27572)) AS xlp, ST_Y(ST_Transform(n.geom, 27572)) AS ylp
, xl - ST_X(ST_Transform(n.geom, 27572)) AS gapx, yl - ST_Y(ST_Transform(n.geom, 27572)) AS gapy
FROM pts_new
INNER JOIN noeud n USING (id_noeud)
WHERE ABS(xl - ST_X(ST_Transform(n.geom, 27572))) > 500
OR ABS(yl - ST_Y(ST_Transform(n.geom, 27572))) > 500;
-- => pas de points hors maille

-- correction manuelle --> pasde points en campagne 2025
UPDATE pts_new SET xl = 570767,  yl = 1824842 WHERE npp = '24-31-210-1-260T';
UPDATE pts_new SET xl = 557752,  yl = 2615580 WHERE npp = '24-62-127-1-024T';
UPDATE pts_new SET xl = 919731,  yl = 2272010 WHERE npp = '24-25-270-1-091T';

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

SELECT ST_SRID(geom) FROM pts_new LIMIT 1; -- on passe la géométrie en 2154 (lambert93)
ALTER TABLE public.pts_new ALTER COLUMN geom TYPE geometry(point,2154) USING ST_Transform(ST_SetSRID(geom,27572),2154);

DROP TABLE IF EXISTS alti ;

CREATE TEMPORARY TABLE alti AS
SELECT npp, xl, yl, rid, (gv).val AS zp
FROM (
    SELECT p.npp, p.xl, p.yl, m.rid, ST_Intersection(m.rast, p.geom) AS gv
    FROM pts_new p
    INNER JOIN bdalti2011.mnt m ON ST_Intersects(m.rast, p.geom)
) foo
ORDER BY 1;
----> plantage en 2024 ==>  import d'un fichier alti_2024.csv généré par Cédric

CREATE TABLE public.alti_2025 (
    npp CHAR(16),
    zp SMALLINT,   
    CONSTRAINT alti_2025_pkey PRIMARY KEY (npp)
    )
WITHOUT OIDS;
-- dans psql------------------------------------------------------------------------------------------------------------------------------
\COPY alti_2025 FROM '/home/lhaugomat/Documents/GITLAB/production/Incref19/donnees/altitudes_2025.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

ANALYZE alti_2025;


WITH t0 AS (
    SELECT npp, MIN(zp) AS zp
    FROM alti_2025
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
WHERE ST_Intersects(p.geom, st_transform(r.geom,2154));

-- points sans région forestière
SELECT npp, geom FROM pts_new WHERE regn IS NULL ORDER BY npp; -- 10 points

-- mise à jour "manuelle" sur ces points
UPDATE pts_new SET regn = '061' WHERE npp IN ('25-06-324-1-190T');
UPDATE pts_new SET regn = '834' WHERE npp IN ('25-13-295-1-240T');
UPDATE pts_new SET regn = '175' WHERE npp IN ('25-17-107-1-197T');
UPDATE pts_new SET regn = '253' WHERE npp IN ('25-25-279-1-088T');
UPDATE pts_new SET regn = '296' WHERE npp IN ('25-29-013-1-150T');
UPDATE pts_new SET regn = '296' WHERE npp IN ('25-29-026-1-157T');
UPDATE pts_new SET regn = '2AS' WHERE npp IN ('25-2A-369-1-262T');
UPDATE pts_new SET regn = '330' WHERE npp IN ('25-33-119-1-246T');
UPDATE pts_new SET regn = '666' WHERE npp IN ('25-66-240-1-288T');
UPDATE pts_new SET regn = '175' WHERE npp IN ('25-85-085-1-181T');

SELECT npp, geom FROM pts_new WHERE regn IS NULL ORDER BY npp; -- il n'y en a plus!

-- croisement avec les sylvoécorégions
SELECT UpdateGeometrySRID('sig_inventaire', 'ser_86', 'geom', '2154');

UPDATE pts_new p
SET ser_86 = s.codeser
FROM sig_inventaire.ser_86 s
WHERE ST_Intersects(p.geom, s.geom);

SELECT * FROM pts_new WHERE ser_86 IS NULL; -- l n'y en a pas!

SELECT UpdateGeometrySRID('sig_inventaire', 'ser_al', 'geom', '2154');

UPDATE pts_new p
SET ser_alluv = s.codeser
FROM sig_inventaire.ser_al s
WHERE ST_Intersects(p.geom, s.geom);

ANALYZE pts_new;

-- croisement avec les communes et départements
SELECT UpdateGeometrySRID('sig_ign', 'communes2002', 'geom', '27572');

UPDATE pts_new p
SET commune = c.num_com, dep = c.num_dep
FROM sig_ign.communes2002 c
WHERE ST_Intersects(p.geom, st_transform(c.geom,2154));

SELECT * FROM pts_new WHERE commune IS NULL;
SELECT * FROM pts_new WHERE dep IS NULL;

-- dans psql : on exporte les points tirés dans un fichier
\COPY (SELECT npp, nph, nppg, poi, id_noeud, ROUND(xl::NUMERIC, 0) AS xl, ROUND(yl::NUMERIC, 0) AS yl, 20 AS incref, poids, regn, ser_86, ser_alluv, dep, commune, geom FROM pts_new ORDER BY npp) TO '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/pts20_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''



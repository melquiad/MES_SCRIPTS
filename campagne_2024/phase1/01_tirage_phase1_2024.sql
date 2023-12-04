
-- MISE À JOUR DE QUELQUES SRID
--SELECT UpdateGeometrySRID('sig_inventaire', 'vt50p2', 'geom', 932006);
--SELECT UpdateGeometrySRID('sig_inventaire', 'ser_86', 'geom', 931007);
--SELECT UpdateGeometrySRID('sig_inventaire', 'ser_al', 'geom', 931007);
--SELECT UpdateGeometrySRID('sig_ign', 'communes2002', 'geom', 932006);

-- CONSTITUTION DE L'ÉCHANTILLON DE POINTS NOUVEAUX
-- import des données issue du script de création des points
CREATE TABLE public.pts_2024 (
    npp CHAR(16),
    nph CHAR(9),
    nppg CHAR(16),
    poi CHAR(1),
    id_noeud INT4, 
    xl INT4,
    yl INT4,
    incref SMALLINT,
    poids FLOAT8,
    zp SMALLINT,
    regn CHAR(3),
    ser_86 CHAR(3),
    ser_alluv CHAR(2),
    dep CHAR(2),
    commune CHAR(5),
    geom GEOMETRY(Point,931007),
    CONSTRAINT pts_2024_pkey PRIMARY KEY (npp)
)
WITHOUT OIDS;

\COPY pts_2024 FROM '/home/lhaugomat/Documents/tirage/pts18_geom.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

ANALYZE pts_2024;

-- insertion dans la table POINT
ALTER TABLE point ALTER COLUMN id_maille DROP NOT NULL;

INSERT INTO point (npp, nph, code_pt, geom)
SELECT npp, nph, poi, geom
FROM pts_2024
ORDER BY npp;

-- rattachement à la maille la plus proche
WITH rattach AS (
    SELECT p.id_point, cn.id_maille, cn.distance 
    FROM point p
    INNER JOIN pts_2024 p2 USING (npp)
    CROSS JOIN LATERAL (
        SELECT m.id_maille, 
        ST_Distance(m.geom, p.geom) AS distance
        FROM inv_prod_new.maille m
        WHERE ST_DWithin(m.geom, p.geom, 1415)
        ORDER BY ST_Distance(m.geom, p.geom)
        LIMIT 2
    ) AS cn
)
, rangs AS (
    SELECT id_point, id_maille, distance, DENSE_RANK() OVER(PARTITION BY id_point ORDER BY distance) AS rg_prox
    FROM rattach
)
UPDATE point pt
SET id_maille = r.id_maille
FROM rangs r
WHERE pt.id_point = r.id_point
AND rg_prox = 1;

-- mise à jour de IDP
WITH calc_idp AS (
    SELECT npp, incref, RANK() OVER(PARTITION BY incref ORDER BY DIGEST(npp, 'sha1')) AS pos
    FROM pts_2024
)
, def_idp AS (
    SELECT npp, incref || LPAD(pos::VARCHAR, 5, '0') AS idp
    FROM calc_idp
)
UPDATE point p
SET idp = d.idp
FROM def_idp d
WHERE p.npp = d.npp;

-- remplissage de la table POINT_ECH
WITH echant AS (
    SELECT e.id_ech
    FROM echantillon e
    INNER JOIN campagne c USING (id_campagne)
    WHERE c.millesime = 2024
    AND e.type_ech = 'P'
    AND e.phase_stat = 1
    AND e.ech_parent IS NULL
)
INSERT INTO point_ech (id_ech, id_point, id_ech_nd, id_noeud, poids, commune, dep, zp, regn, ser_86, ser_alluv)
SELECT e.id_ech, p.id_point, e.id_ech, p2.id_noeud, p2.poids, p2.commune, p2.dep, p2.zp, p2.regn, p2.ser_86, p2.ser_alluv
FROM point p
INNER JOIN pts_2024 p2 USING (npp)
CROSS JOIN echant e
ORDER BY id_point;

DROP TABLE pts_2024;

-- TIRAGE DES POINTS PREMIÈRE PI (ÉCHANTILLON COMPLET)


INSERT INTO point_pi(id_ech, id_point)
SELECT pe.id_ech, pe.id_point
FROM point_ech pe
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2024
AND e.type_ech = 'P'
AND e.phase_stat = 1
AND e.ech_parent IS NULL
ORDER BY id_point;


-- AJOUT DES NŒUDS REVISITÉS UTILISÉS DANS LA TABLE NOEUD_ECH
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
INNER JOIN inv_prod_new.campagne c ON c.millesime = n.incref + 2010
INNER JOIN inv_prod_new.echantillon e ON c.id_campagne = e.id_campagne AND e.nom_ech = 'FR_IFN_ECH_' || c.millesime || '_PH1_PTS_' || c.millesime - 5
WHERE n.incref = 14
ORDER BY id_noeud;



-- CONSTITUTION DE L'ÉCHANTILLON COMPLET DES POINTS DEUXIÈME PI
WITH echant AS (
    SELECT e.id_ech
    FROM echantillon e
    INNER JOIN campagne c USING (id_campagne)
    WHERE c.millesime = 2024
    AND e.type_ech = 'P'
    AND e.phase_stat = 1
    AND e.ech_parent IS NOT NULL
)
INSERT INTO point_ech (id_ech, id_point, id_ech_nd, id_noeud, poids, commune, dep, zp, regn, ser_86, ser_alluv)
SELECT e.id_ech, pe.id_point, e.id_ech, pe.id_noeud, pe.poids, pe.commune, pe.dep, pe.zp, pe.regn, pe.ser_86, pe.ser_alluv
FROM point_ech pe
INNER JOIN echantillon ex ON pe.id_ech = ex.id_ech
INNER JOIN campagne c ON ex.id_campagne = c.id_campagne
CROSS JOIN echant e
WHERE c.millesime = 2024 - 5
AND ex.type_ech = 'P'
AND ex.phase_stat = 1
AND ex.ech_parent IS NULL
ORDER BY pe.id_point;

-- TIRAGE DES POINTS DEUXIÈME PI (ÉCHANTILLON PARTIEL)
SET enable_nestloop = FALSE;

INSERT INTO point_pi(id_ech, id_point)
SELECT pen.id_ech, pen.id_point
FROM point_ech pen
INNER JOIN echantillon en ON pen.id_ech = en.id_ech
INNER JOIN campagne c ON en.id_campagne = c.id_campagne
INNER JOIN point_ech peo ON en.ech_parent = peo.id_ech AND pen.id_point = peo.id_point
INNER JOIN point_pi ppo ON peo.id_ech = ppo.id_ech AND peo.id_point = ppo.id_point
INNER JOIN point po ON ppo.id_point = po.id_point
WHERE c.millesime = 2024
AND en.type_ech = 'P'
AND en.phase_stat = 1
AND LEFT(ppo.cso, 1) = '6' 
AND NOT EXISTS (
    SELECT 1
    FROM fla_pi fp
    INNER JOIN fla_pi_2005 fp2 ON fp.id_ech = fp2.id_ech AND fp.id_transect = fp2.id_transect AND fp.sl_pi = fp2.sl_pi
    WHERE fp.id_transect = po.id_transect
    AND fp.flpi NOT IN ('0', '6')
    AND ABS(fp.disti) <= 25
);

SET enable_nestloop = TRUE;


-- CONSTITUTION DE L'ÉCHANTILLON DES TRANSECTS (TOUT L'ÉCHANTILLON)
-- création de l'échantillon
INSERT INTO echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat)
SELECT id_campagne, 'FR_IFN_ECH_' || millesime || '_TR_PI', 'IFN', NOW()::DATE, 'T', 1
FROM campagne
WHERE millesime = 2024;

-- création des transects
DROP TABLE IF EXISTS pts_tr

SELECT SETSEED(0.2024);

CREATE TEMPORARY TABLE pts_tr AS 
SELECT p.npp
, ROUND(ST_X(p.geom)::NUMERIC) AS xl_centre, ROUND(ST_Y(p.geom)::NUMERIC) AS yl_centre
, radians(random()*180) AS aztrans
, p.geom
FROM point p
INNER JOIN maille m USING (id_maille)
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2024
AND e.type_ech = 'P'
AND e.phase_stat = 1
AND e.ech_parent IS NULL;

INSERT INTO transect (xl_centre, yl_centre, aztrans, geom)
SELECT xl_centre, yl_centre, aztrans
, ST_SetSRID(ST_MakeLine(
    ST_MakePoint(ST_X(geom)::NUMERIC - 30.0 * COS(PI() / 2 - aztrans), ST_Y(geom)::NUMERIC  - 30.0 * SIN(PI() / 2  - aztrans))
  , ST_MakePoint(ST_X(geom)::NUMERIC + 30.0 * COS(PI() / 2 - aztrans), ST_Y(geom)::NUMERIC  + 30.0 * SIN(PI() / 2  - aztrans))
), 931007) AS geom
FROM pts_tr
ORDER BY npp;

-- rattachement aux points
ALTER TABLE pts_tr
    ADD COLUMN id_transect INT4;

UPDATE pts_tr p
SET id_transect = t.id_transect
FROM transect t
WHERE t.xl_centre = ROUND(ST_X(p.geom)::NUMERIC) AND t.yl_centre = ROUND(ST_Y(p.geom)::NUMERIC);

UPDATE point p
SET id_transect = pt.id_transect
FROM pts_tr pt
WHERE p.npp = pt.npp;

DROP TABLE pts_tr;

-- rattachement des transects à l'échantillon
INSERT INTO inv_prod_new.transect_ech (id_ech, id_transect, poids)
SELECT et.id_ech, t.id_transect, 1::FLOAT8 AS poids
FROM transect t
INNER JOIN point p USING (id_transect)
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN echantillon et USING (id_campagne)
WHERE c.millesime = 2024
AND e.type_ech = 'P'
AND e.phase_stat = 1
AND e.ech_parent IS NULL
AND et.type_ech = 'T'
AND et.phase_stat = 1
ORDER BY id_ech, id_transect;

-- correction du numéro d'échantillon dans transect_ech pour 2024
UPDATE transect_ech
SET id_ech = 95
WHERE id_ech = 93;



-- TABLE echantillon;






-- Correction a posteriori sur 2024 : trop de points à rephoto-interpréter tirés, dû à l'arrêt en 2018 de TLHF1 remplacé par FLPI
-- On supprime les points qui n'auraient pas dû être concernés
SET enable_nestloop = FALSE;

WITH en_trop AS (
    SELECT pen.id_ech, pen.id_point
    FROM point_ech pen
    INNER JOIN echantillon en ON pen.id_ech = en.id_ech
    INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    INNER JOIN point_ech peo ON en.ech_parent = peo.id_ech AND pen.id_point = peo.id_point
    INNER JOIN point_pi ppo ON peo.id_ech = ppo.id_ech AND peo.id_point = ppo.id_point
    INNER JOIN point po ON ppo.id_point = po.id_point
    WHERE c.millesime = 2024
    AND en.type_ech = 'P'
    AND en.phase_stat = 1
    AND LEFT(ppo.cso, 1) = '6' 
    AND EXISTS (
        SELECT 1
        FROM fla_pi fp
        WHERE fp.id_transect = po.id_transect
        AND fp.flpi NOT IN ('0', 'A')
        AND ABS(fp.disti) <= 25
    )
)
DELETE FROM point_pi pp
USING en_trop et
WHERE pp.id_ech = et.id_ech
AND pp.id_point = et.id_point;

SET enable_nestloop = TRUE;


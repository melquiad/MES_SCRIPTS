
CREATE TEMPORARY TABLE points AS 
WITH plhf AS (
    SELECT DISTINCT p.id_point
    FROM point p
    INNER JOIN transect t USING (id_transect)
    INNER JOIN transect_ech te USING (id_transect)
    INNER JOIN echantillon e USING (id_ech)
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN fla_pi fp USING (id_ech, id_transect)
    WHERE abs(fp.disti) <= 25 AND fp.flpi NOT IN ('0', 'A')
    AND c.millesime = 2026
)
SELECT c.millesime, et.id_ech AS id_ech_ph2, epi.id_ech AS id_ech_ph1
, net.id_noeud, n.tirmax, net.depn, net.zp AS zpn, net.ztir, net.zforifn
, pepi.id_point, p.npp, p.geom
, CASE
    WHEN pp.occ = '0' THEN 0                                        -- pas d'occultés
    WHEN pp.uspi = 'U' THEN 0                                       -- pas d'utilisation récréative
    WHEN pp.uspi IN ('V', 'I') THEN 0                               -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
    ELSE
    CASE
        WHEN pp.cso IN ('1', '3') THEN 14                           -- couverture boisée
        WHEN pp.cso = '4L' THEN 16                                  -- lande
        WHEN pp.cso = '5' THEN 32                                   -- peupleraie
        WHEN l.id_point IS NOT NULL THEN 960                        -- présence de LHF à moins de 25m
        ELSE 0                                                      -- autre
    END
  END::INT AS formation
, CASE WHEN l.id_point IS NOT NULL THEN '1' ELSE '0' END AS plhf
, CASE
    WHEN pp.occ = '0' THEN 'pas tir'                                -- pas d'occultés
    WHEN pp.uspi = 'U' THEN 'pas tir'                               -- pas d'utilisation récréative
    WHEN pp.uspi IN ('V', 'I') THEN 'pas tir'                       -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
    WHEN l.id_point IS NOT NULL THEN 'tir'                          -- présence de LHF à moins de 25m
    WHEN pp.cso IN ('1', '3') THEN 'tir'                            -- couverture boisée
    WHEN pp.cso = '4L' THEN 'tir'                                   -- lande
    WHEN pp.cso = '5' THEN 'tir'                                    -- peupleraie
    ELSE 'pas tir'                                                  -- autre
  END AS tire
, pepi.poids, pp.cso, ST_X(p.geom), ST_Y(p.geom)
FROM echantillon et
INNER JOIN campagne c USING (id_campagne)
INNER JOIN echantillon epi ON et.ech_parent_stat = epi.id_ech
INNER JOIN noeud_ech net ON et.id_ech = net.id_ech
INNER JOIN noeud n USING (id_noeud)
INNER JOIN point_ech pepi ON epi.id_ech = pepi.id_ech AND pepi.id_noeud = net.id_noeud
INNER JOIN point p USING (id_point)
LEFT JOIN plhf l USING (id_point)
INNER JOIN point_pi pp ON pp.id_ech = pepi.id_ech AND pp.id_point = pepi.id_point
WHERE et.type_ech = 'IFN'
AND et.type_ue = 'P'
AND et.phase_stat = 2
AND et.ech_parent IS NULL
AND c.millesime = 2026
ORDER BY id_point;

--DROP TABLE points;

ANALYZE points;

CREATE TEMPORARY TABLE points_tir AS 
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.npp, p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, power(2, t.niveau - 1)::real AS poids, round(p.st_x) AS X, round(p.st_y) AS Y, p.geom AS geom
FROM points p
INNER JOIN tirage t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
ORDER BY id_ech, id_point, t.formation;                     -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir ADD CONSTRAINT points_tir_pkey PRIMARY KEY (id_ech, id_point);


SET enable_nestloop = FALSE;

-- Lot 10 : points V1 LHF
SELECT 10 AS lot, npp, id_ech, id_point
FROM points_tir pt
WHERE formation > 50 --> 479 points
UNION
-- Lot 11 : points sur les îles
SELECT 11 AS lot, npp, id_ech, id_point--, x, y
FROM points_tir pt
INNER JOIN sig_inventaire.vt50p2 vp ON vp.area < 10^9
--AND pt.geom && vp.geom
AND st_intersects(pt.geom,st_transform(vp.geom,2154)) --> 6
UNION
-- Lot 12 : points lande en-dessous de 10m ou au-dessus de 1600m 
SELECT 12 AS lot, npp, pt.id_ech, pt.id_point--, pep.zp
FROM points_tir pt
INNER JOIN echantillon e ON pt.id_ech = e.id_ech
INNER JOIN echantillon ep ON e.ech_parent_stat = ep.id_ech
INNER JOIN point_ech pep ON ep.id_ech = pep.id_ech AND pt.id_point = pep.id_point
WHERE pt.formation = 16
AND (pep.zp < 10 OR pep.zp > 1600)  --> 33
UNION
-- Lot 13 : bosquets autre utilisation
SELECT 13 AS lot, npp, pt.id_ech, pt.id_point--, pp.tfpi, pp.uspi
FROM points_tir pt
INNER JOIN echantillon e ON pt.id_ech = e.id_ech
INNER JOIN echantillon ep ON e.ech_parent_stat = ep.id_ech
INNER JOIN point_pi pp ON ep.id_ech = pp.id_ech AND pt.id_point = pp.id_point
WHERE pt.formation IN (14, 32) AND pp.uspi = 'X' AND pp.tfpi = '1'  --> 162
UNION
-- lot 14 : bosquets autre utilisation en premier passage
SELECT 14 AS lot, npp, pt.id_ech, pt.id_point--, rp.csa, rp15.utip, rp15.tform
FROM v_liste_points_lt2 pt
INNER JOIN echantillon e ON pt.id_ech = e.id_ech
INNER JOIN echantillon ep ON e.ech_parent = ep.id_ech
INNER JOIN reconnaissance rp ON ep.id_ech = rp.id_ech AND pt.id_point = rp.id_point
INNER JOIN reco_2015 rp15 ON rp.id_ech = rp15.id_ech AND rp.id_point = rp15.id_point
WHERE pt.annee = 2026
AND rp.csa IN ('1', '3', '5')
AND rp15.utip = 'X'
AND rp15.tform = '1'  --> 84
UNION
-- lot 15 : landes et herbes non ambiguës
SELECT 15 AS lot, npp, pt.id_ech, pt.id_point--, rp.csa, rp.obscsa
FROM v_liste_points_lt2 pt
INNER JOIN echantillon e ON pt.id_ech = e.id_ech
INNER JOIN echantillon ep ON e.ech_parent = ep.id_ech
INNER JOIN reconnaissance rp ON ep.id_ech = rp.id_ech AND pt.id_point = rp.id_point
WHERE pt.annee = 2026
AND rp.csa IN ('4L', '6H')
AND rp.obscsa = '0'
ORDER BY lot, npp;   --> 90

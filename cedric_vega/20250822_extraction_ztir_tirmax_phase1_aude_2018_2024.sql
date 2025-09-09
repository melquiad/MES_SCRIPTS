
-- C’est ZTIR et NIVEAU (dans la table TIRAGE) pour chaque ZTIR.
-- L’allègement est fourni par NVX_ALLEGES de la table TIRAGE. 

/*
SELECT DISTINCT pe.dep, p.npp, v.annee, ne.ztir, t.niveau--, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_pi1 v
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
--INNER JOIN noeud n USING (id_noeud)
INNER JOIN noeud_ech ne USING (id_noeud)
INNER JOIN tirage t ON ne.id_ech = t.id_ech AND ne.ztir = t.code_zone
WHERE v.annee BETWEEN 2018 AND 2024
AND pe.dep = '11'
AND ne.ztir IS NOT NULL;
*/
---------------------------------------------------------------------

-- pour 2022 à 2024
CREATE TEMPORARY TABLE points1 AS 
WITH plhf AS (
    SELECT DISTINCT p.id_point
    FROM point p
    INNER JOIN transect t USING (id_transect)
    INNER JOIN transect_ech te USING (id_transect)
    INNER JOIN echantillon e USING (id_ech)
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN fla_pi fp USING (id_ech, id_transect)
    WHERE abs(fp.disti) <= 25 AND fp.flpi NOT IN ('0', 'A')
    AND c.millesime BETWEEN 2022 AND 2024
)
SELECT c.millesime, p.npp, pepi.id_point, net.depn, et.id_ech AS id_ech_ph2, epi.id_ech AS id_ech_ph1
, n.tirmax, net.ztir--, net.zforifn, net.zp AS zpn, net.id_noeud
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
, pepi.poids, pp.cso
FROM echantillon et
INNER JOIN campagne c USING (id_campagne)
INNER JOIN echantillon epi ON et.ech_parent_stat = epi.id_ech
INNER JOIN noeud_ech net ON et.id_ech = net.id_ech
INNER JOIN noeud n USING (id_noeud)
INNER JOIN point_ech pepi ON epi.id_ech = pepi.id_ech AND pepi.id_noeud = net.id_noeud
INNER JOIN point p USING (id_point)
LEFT JOIN plhf l USING (id_point)
INNER JOIN point_pi pp ON pp.id_ech = pepi.id_ech AND pp.id_point = pepi.id_point
--INNER JOIN tirage t ON net.ztir = t.code_zone AND net.id_ech = t.id_ech
WHERE et.type_ech = 'IFN'
AND et.type_ue = 'P'
AND et.phase_stat = 2
AND et.ech_parent IS NULL
AND c.millesime BETWEEN 2022 AND 2024
AND pepi.dep = '11'
ORDER BY id_point, ztir;


SELECT pts.millesime, pts.npp, pts.ztir, t.formation, t.niveau, t.nvx_alleges, pts.cso 
FROM points1 pts
LEFT JOIN tirage t ON pts.id_ech_ph2 = t.id_ech AND pts.ztir = t.code_zone AND pts.formation = t.formation
WHERE pts.millesime BETWEEN 2022 AND 2024
ORDER BY id_point, ztir;

DROP TABLE points1;

------------------------------------------------------------------------------------------------------------
-- pour 2021

CREATE TEMPORARY TABLE points2 AS 
WITH noeuds AS (
    SELECT nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode AS zfor
    --, c2.mode AS zpop
    , nd.regn, nd.idmaille, nd.depn
    FROM inv_prod.e1noeud nd
    INNER JOIN inv_prod.e1point pt ON nd.nppg = pt.nppg AND nd.incref = 16 AND nd.inv = 'T'
    INNER JOIN inv_prod.e1situation e1s ON nd.nppg = e1s.nppg
--    INNER JOIN inv_prod.e1situation e2s ON nd.nppg = e2s.nppg
    INNER JOIN inv_prod.c0attribut c1 ON c1.nppu = e1s.nppu AND c1.donnee = 'ZFORIFN'
--    INNER JOIN inv_prod.c0attribut c2 ON c2.nppu = e2s.nppu AND c2.donnee = 'ZPOPIFN'
    GROUP BY nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode, nd.regn, nd.idmaille, nd.depn--, c2.mode
)
, plhf AS (
    SELECT DISTINCT l.npp
    FROM inv_prod.l1intersect l
    INNER JOIN inv_prod.e1point pt ON l.npp = pt.npp
    INNER JOIN inv_prod.e1noeud nd ON pt.nppg = nd.nppg AND nd.incref = 16 AND nd.inv = 'T'
    WHERE ABS(l.disti) <= 25 AND l.flpi NOT IN ('0', 'A')
)
SELECT ne.id_ech, p.npp, n.tirmax, n.incref + 2005 AS millesime
, CASE
    WHEN p.occ = '0' THEN 0                                                                    -- pas d'occultés
    WHEN p.uspi = 'U' THEN 0                                                                    -- pas d'utilisation récréative
    WHEN p.uspi IN ('V', 'I') THEN 0                                                        -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
--    WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 0                                                -- pas d'utilisation agricole en couverture boisée  /!\ MODALITÉ QUI N'EXISTE PLUS !!!
    ELSE
    CASE
        WHEN p.cso IN ('1', '3') THEN 14                                                        -- couverture boisée
        WHEN p.cso = '4L' THEN 16                                                                -- lande
        WHEN p.cso = '5' THEN 32                                                                -- peupleraie
        ELSE 0                                                                                    -- autre
    END
    | (CASE WHEN l.npp IS NOT NULL THEN 960 ELSE 0 END)                                            -- présence de LHF à moins de 25m
  END::INT AS formation
, CASE WHEN l.npp IS NOT NULL THEN '1' ELSE '0' END AS plhf
, CASE
    WHEN p.occ = '0' THEN 'pas tir'                                                                -- pas d'occultés
    WHEN p.uspi = 'U' THEN 'pas tir'                                                            -- pas d'utilisation récréative
    WHEN p.uspi IN ('V', 'I') THEN 'pas tir'                                                -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
    WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 'pas tir'                                        -- pas d'utilisation agricole en couverture boisée
    WHEN l.npp IS NOT NULL THEN 'tir'                                                            -- présence de LHF à moins de 25m
    WHEN p.cso IN ('1', '3') THEN 'tir'                                                            -- couverture boisée
    WHEN p.cso = '4L' THEN 'tir'                                                                -- lande
    WHEN p.cso = '5' THEN 'tir'                                                                    -- peupleraie
    ELSE 'pas tir'                                                                                -- autre
  END AS tire
, n.depn, n.ztir, p.poids, p.poi$, p.cso
FROM inv_prod.e1point p
INNER JOIN noeuds n ON p.nppg = n.nppg
INNER JOIN noeud nd ON n.nppg = nd.nppg
INNER JOIN noeud_ech ne ON nd.id_noeud = ne.id_noeud AND ne.id_ech = 52
LEFT JOIN plhf l ON p.npp = l.npp
WHERE p.dep = '11'
ORDER BY p.npp;

SELECT pts.millesime, pts.npp, pts.ztir, t.formation, t.niveau, t.nvx_alleges, pts.cso 
FROM points2 pts
LEFT JOIN tirage t ON pts.ztir = t.code_zone AND pts.formation = t.formation AND pts.id_ech = t.id_ech
WHERE pts.millesime = 2021
ORDER BY npp, ztir;

DROP TABLE points2;

------------------------------------------------------------------------------------------------------------
-- pour 2020

CREATE TEMPORARY TABLE points4 AS 
WITH noeuds AS (
    SELECT nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode AS zfor
    , nd.regn, nd.idmaille, nd.depn
    FROM inv_prod.e1noeud nd
    INNER JOIN inv_prod.e1point pt ON nd.nppg = pt.nppg AND nd.incref = 15 AND nd.inv = 'T'
    INNER JOIN inv_prod.e1situation e1s ON nd.nppg = e1s.nppg
    INNER JOIN inv_prod.c0attribut c1 ON c1.nppu = e1s.nppu AND c1.donnee = 'ZFORIFN'
    GROUP BY nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode, nd.regn, nd.idmaille, nd.depn
)
, plhf AS (
    SELECT DISTINCT l.npp
    FROM inv_prod.l1intersect l
    INNER JOIN inv_prod.e1point pt ON l.npp = pt.npp
    INNER JOIN inv_prod.e1noeud nd ON pt.nppg = nd.nppg AND nd.incref = 15 AND nd.inv = 'T'
    WHERE ABS(l.disti) <= 25 AND l.flpi NOT IN ('0', 'A')
)
SELECT ne.id_ech, p.npp, n.tirmax, n.incref + 2005 AS millesime
, CASE
    WHEN p.occ = '0' THEN 0                                                                    -- pas d'occultés
    WHEN p.uspi = 'U' THEN 0                                                                    -- pas d'utilisation récréative
    WHEN p.uspi IN ('V', 'I') THEN 0                                                        -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
    WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 0                                                -- pas d'utilisation agricole en couverture boisée
    ELSE
    CASE
        WHEN p.cso IN ('1', '3') THEN 14                                                        -- couverture boisée
        WHEN p.cso = '4L' THEN 16                                                                -- lande
        WHEN p.cso = '5' THEN 32                                                                -- peupleraie
        ELSE 0                                                                                    -- autre
    END
    | (CASE WHEN l.npp IS NOT NULL THEN 960 ELSE 0 END)                                            -- présence de LHF à moins de 25m
  END::INT AS formation
, n.ztir
, CASE WHEN l.npp IS NOT NULL THEN '1' ELSE '0' END AS plhf
, CASE
    WHEN p.occ = '0' THEN 'pas tir'                                                                -- pas d'occultés
    WHEN p.uspi = 'U' THEN 'pas tir'                                                            -- pas d'utilisation récréative
    WHEN p.uspi IN ('V', 'I') THEN 'pas tir'                                                -- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
    WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 'pas tir'                                        -- pas d'utilisation agricole en couverture boisée
    WHEN l.npp IS NOT NULL THEN 'tir'                                                            -- présence de LHF à moins de 25m
    WHEN p.cso IN ('1', '3') THEN 'tir'                                                            -- couverture boisée
    WHEN p.cso = '4L' THEN 'tir'                                                                -- lande
    WHEN p.cso = '5' THEN 'tir'                                                                    -- peupleraie
    ELSE 'pas tir'                                                                                -- autre
  END AS tire
, p.poids, p.poi$, p.cso
, n.depn
FROM inv_prod.e1point p
INNER JOIN noeuds n ON p.nppg = n.nppg
INNER JOIN noeud nd ON n.nppg = nd.nppg
INNER JOIN noeud_ech ne ON nd.id_noeud = ne.id_noeud AND ne.id_ech = 48
LEFT JOIN plhf l ON p.npp = l.npp
WHERE p.dep = '11'
ORDER BY p.npp;

SELECT pts.millesime, pts.npp, pts.ztir, t.formation, t.niveau, t.nvx_alleges, pts.cso 
FROM points4 pts
LEFT JOIN tirage t ON pts.ztir = t.code_zone AND pts.formation = t.formation AND pts.id_ech = t.id_ech
WHERE pts.millesime = 2020
ORDER BY npp, ztir;

DROP TABLE points4;


------------------------------------------------------------------------------------------------------------
-- pour 2018 à 2019

CREATE TEMPORARY TABLE points3 AS 
WITH noeuds AS (
	SELECT nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode AS zfor, c2.mode AS zpop, nd.regn, nd.idmaille, nd.depn--, COUNT(pt.npp) AS dobs	-- DOBS = densité observée (ne sert plus à rien en 2016)
	FROM inv_prod.e1noeud nd
	INNER JOIN inv_prod.e1point pt ON nd.nppg = pt.nppg AND nd.incref IN (13,14) AND nd.inv = 'T'
	INNER JOIN inv_prod.e1situation e1s ON nd.nppg = e1s.nppg
	INNER JOIN inv_prod.e1situation e2s ON nd.nppg = e2s.nppg
	INNER JOIN inv_prod.c0attribut c1 ON c1.nppu = e1s.nppu AND c1.donnee = 'ZFORIFN'
	INNER JOIN inv_prod.c0attribut c2 ON c2.nppu = e2s.nppu AND c2.donnee = 'ZPOPIFN'
	GROUP BY nd.nppg, nd.incref, nd.tirmax, nd.cyc, nd.inv, nd.zp, nd.ztir, c1.mode, c2.mode, nd.regn, nd.idmaille, nd.depn
)
, plhf AS (
	SELECT DISTINCT l.npp
	FROM inv_prod.l1intersect l
	INNER JOIN inv_prod.e1point pt ON l.npp = pt.npp
	INNER JOIN inv_prod.e1noeud nd ON pt.nppg = nd.nppg AND nd.incref = 13 AND nd.inv = 'T'
	WHERE ABS(l.disti) <= 25 AND l.flpi NOT IN ('0', 'A')
)
--select * from noeuds
SELECT ne.id_ech, p.npp, n.incref + 2005 AS millesime
, CASE
	WHEN p.occ = '0' THEN 0																		-- pas d'occultés
	WHEN p.uspi = 'U' THEN 0																	-- pas d'utilisation récréative
	WHEN p.uspi IN ('V', 'I', 'T') THEN 0														-- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
	WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 0												-- pas d'utilisation agricole en couverture boisée
	ELSE
	CASE
		WHEN p.cso IN ('1', '3') THEN 14														-- couverture boisée
		WHEN p.cso = '4L' THEN 16																-- lande
		WHEN p.cso = '5' THEN 32																-- peupleraie
		ELSE 0																					-- autre
	END
	| (CASE WHEN l.npp IS NOT NULL THEN 960 ELSE 0 END)											-- présence de LHF à moins de 25m
  END::INT AS formation
, n.ztir
, CASE WHEN l.npp IS NOT NULL THEN '1' ELSE '0' END AS plhf
, CASE
	WHEN p.occ = '0' THEN 'pas tir'																-- pas d'occultés
	WHEN p.uspi = 'U' THEN 'pas tir'															-- pas d'utilisation récréative
	WHEN p.uspi IN ('V', 'I', 'T') THEN 'pas tir'												-- pas d'utilisation particulière (verger, emprise d'infrastructure, réseau)
	WHEN p.uspi = 'A' AND cso IN ('1', '3') THEN 'pas tir'										-- pas d'utilisation agricole en couverture boisée
	WHEN l.npp IS NOT NULL THEN 'tir'															-- présence de LHF à moins de 25m
	WHEN p.cso IN ('1', '3') THEN 'tir'															-- couverture boisée
	WHEN p.cso = '4L' THEN 'tir'																-- lande
	WHEN p.cso = '5' THEN 'tir'																	-- peupleraie
	ELSE 'pas tir'																				-- autre
  END AS tire
, p.poids, p.poi$
, n.depn, p.cso
FROM inv_prod.e1point p
INNER JOIN noeuds n ON p.nppg = n.nppg
INNER JOIN noeud nd ON n.nppg = nd.nppg
INNER JOIN noeud_ech ne ON nd.id_noeud = ne.id_noeud AND ne.id_ech IN (40,44)
LEFT JOIN plhf l ON p.npp = l.npp
WHERE p.dep = '11'
ORDER BY p.npp;


SELECT pts.millesime, pts.npp, pts.ztir, t.formation, t.niveau, t.nvx_alleges, pts.cso 
FROM points3 pts
LEFT JOIN tirage t ON pts.ztir = t.code_zone AND pts.formation = t.formation AND pts.id_ech = t.id_ech
WHERE pts.millesime IN (2018,2019)
ORDER BY npp, ztir;

DROP TABLE points3;

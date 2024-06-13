BEGIN;

-- CRÉATION DES ÉCHANTILLONS DE DEUXIÈME PHASE ASSOCIÉS
-- échantillons de points
INSERT INTO echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent_stat, ech_parent, descript_ech, stat, type_ue, passage)
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH2_PTS_' || c.millesime AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 2 AS phase_stat, e.id_ech AS ech_parent_stat, NULL::INT4 AS ech_parent
, $$Échantillon statistique de phase 2 des points de l'inventaire forestier national, campagne $$ || c.millesime
, TRUE AS stat, 'P' AS type_ue, 1 AS passage
FROM campagne c
CROSS JOIN echantillon e
WHERE c.millesime = 2025
AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage = 1 AND e.id_campagne = c.id_campagne
UNION
SELECT c.id_campagne, 'FR_IFN_ECH_' || c.millesime || '_PH2_PTS_' || (c.millesime - 5) AS nom_ech
, 'IFN' AS proprietaire, NOW()::DATE AS date_tirage, 'IFN' AS type_ech, 2 AS phase_stat, e.id_ech AS ech_parent_stat, e2.id_ech AS ech_parent
, $$Échantillon statistique de phase 2 des points de l'inventaire forestier national issus initialement de la campagne $$ || (c.millesime - 5) || $$, nouveau passage lors de la campagne $$ || c.millesime
, TRUE AS stat, 'P' AS type_ue, 2 AS passage
FROM campagne c
CROSS JOIN echantillon e
INNER JOIN echantillon ep ON e.ech_parent = ep.id_ech AND e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage > 1 AND e.id_campagne = c.id_campagne
INNER JOIN campagne cp ON ep.id_campagne = cp.id_campagne AND cp.millesime = c.millesime - 5
INNER JOIN echantillon e2 ON e2.id_campagne = cp.id_campagne AND e2.type_ech = 'IFN' AND e2.type_ue = 'P' AND e2.phase_stat = 2 AND e2.passage = 1
WHERE c.millesime = 2025
ORDER BY nom_ech DESC;

-- échantillon de transects
INSERT INTO inv_prod_new.echantillon (id_campagne, nom_ech, proprietaire, date_tirage, type_ech, phase_stat, ech_parent_stat, descript_ech, stat, type_ue, passage)
SELECT id_campagne, REPLACE(nom_ech, 'PI', 'RE') AS nom_ech, proprietaire, now()::date AS date_tirage, type_ech, 2 AS phase_stat, id_ech AS ech_parent_stat
, $$Échantillon de phase 2 des transects associés aux points de l'inventaire forestier national, campagne $$ || millesime
, TRUE AS stat, 'T' AS type_ue, 1 AS passage
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
WHERE type_ech = 'IFN'
AND type_ue = 'T'
AND phase_stat = 1
AND millesime = 2025;

-- AJOUT DES NŒUDS NOUVEAUX UTILISÉS DANS LA TABLE NOEUD_ECH
INSERT INTO noeud_ech (id_ech, id_noeud, zp, depn, zpopifn, regn, zforifn, zforifnd, ztir)
SELECT e.id_ech, ne.id_noeud, ne.zp, ne.depn, ne.zpopifn, ne.regn, ne.zforifn, ne.zforifnd
, CASE
    -- zone de maquis Corse
    WHEN depn IN ('2A', '2B') AND regn IN ('2A8', '2B7', '2B3') AND zp < 550 THEN '5'
    WHEN depn IN ('2A', '2B') AND regn NOT IN ('2A8', '2B7', '2B3') AND zp < 800 THEN '5'
    -- zone d'altitude Corse
    WHEN depn IN ('2A', '2B') AND NOT (regn IN ('2A8', '2B7', '2B3') AND zp < 550) THEN '6'
    WHEN depn IN ('2A', '2B') AND NOT (regn NOT IN ('2A8', '2B7', '2B3') AND zp < 800) THEN '6'
    -- zone montagne
    WHEN zforifn = '6' THEN '3'
    -- zone de garrigue ou maquis
    WHEN zforifn = '4' THEN '2'
    -- zone de forêt homogène
    WHEN zforifn = '1' THEN '1'
    -- zone des régions forestières du Sud-Est
    WHEN regn IN ('041', '042', '043', '044', '045', '046', '049', '051', '052', '053', '054', '055', '056', '057', '059', '061', '062', '063', '064', '067', '2A0', '2A8', '2A9', '2AS', '2B1', '2B2', '2B3', '2B4', '2B5', '2B6', '2B7'
                    , '841', '842', '845', '847', '263', '265', '266', '267', '268', '269', '072', '073', '074', '075', '076', '077', '303', '343', '485', '124', '126', '811', '812', '114', '116', '118', '664', '665', '666', '667', '668', '669', '092', '094', '097')
        THEN '4'
    WHEN regn IN ('832', '833', '834', '835', '836', '837') AND depn <> '13' THEN '4'
    -- zone non allégée
    ELSE '0'
  END AS ztir
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN noeud_ech ne ON ne.id_ech = e.ech_parent_stat
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND phase_stat = 2
AND ech_parent IS NULL
AND millesime = 2025
ORDER BY id_noeud;

-- AJOUT DES NŒUDS REVISITÉS UTILISÉS DANS LA TABLE NOEUD_ECH
INSERT INTO noeud_ech (id_ech, id_noeud, zp, depn, zpopifn, regn, zforifn, zforifnd)
SELECT e.id_ech, ne.id_noeud, ne.zp, ne.depn, ne.zpopifn, ne.regn, ne.zforifn, ne.zforifnd
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN noeud_ech ne ON ne.id_ech = e.ech_parent_stat
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND ech_parent IS NOT NULL
AND millesime = 2025
ORDER BY id_noeud;

/*
SELECT id_ech, ztir, count(*)
FROM noeud_ech
WHERE ztir IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- TIRAGE DES POINTS À REVISITER
BEGIN;


-- recopie de l'échantillon première visite, 5 ans avant, rattaché au nouvel échantillon
--/!\ À PARTIR DE 2025, LE RATTACHEMENT À L'ÉCHANTILLON PARENT D'UN ÉCHANTILLON TERRAIN A CHANGÉ, IL FAUDRA REVOIR LES JOINTURES POUR LE TIRAGE DE LA CAMPAGNE 2025
INSERT INTO inv_prod_new.point_ech (id_ech, id_point, id_ech_nd, id_noeud, poids, commune, dep, zp, pro, regn, ser_86, ser_alluv, rbi, proba_hetre, angle_gams)
SELECT e.id_ech, pet1.id_point, e.id_ech AS id_ech_nd, pet1.id_noeud, pet1.poids, pet1.commune, pet1.dep
, pet1.zp, pet1.pro, pet1.regn, pet1.ser_86, pet1.ser_alluv, pet1.rbi, pet1.proba_hetre, pet1.angle_gams
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN echantillon ep2 ON e.ech_parent = ep2.id_ech AND ep2.type_ue = 'P' AND ep2.type_ech = 'IFN' AND ep2.phase_stat = 2
INNER JOIN point_ech pet1 ON ep2.id_ech = pet1.id_ech
WHERE e.type_ue = 'P'
AND e.type_ech = 'IFN'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
AND c.millesime = 2025
ORDER BY id_point;

-- récupération des points à revisiter sur le terrain

-- /!\ À PARTIR DE 2025, les points à revisiter changent parce qu'on a levé hors UTIP = X, BOIS = 1 en 2020 (cf plus bas)
-- /!\ À PARTIR DE 2025, inclure dans les points à revisiter les CSA = 6H

DROP TABLE IF EXISTS pts_retour;

--/!\ À PARTIR DE 2025, LE RATTACHEMENT À L'ÉCHANTILLON PARENT D'UN ÉCHANTILLON TERRAIN A CHANGÉ, IL FAUDRA REVOIR LES JOINTURES POUR LE TIRAGE DE LA CAMPAGNE 2025
CREATE TEMPORARY TABLE pts_retour AS
WITH echants AS (
    SELECT e.id_ech AS ech_actuel, et1.id_ech AS ech_terr_prec, et1.ech_parent_stat AS ech_pi_prec
    , e.nom_ech, et1.nom_ech, et1.*
    FROM echantillon e
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et1 ON e.ech_parent = et1.id_ech --AND et1.type_ue = 'P' AND et1.type_ech = 'IFN' AND et1.phase_stat = 2
    --INNER JOIN echantillon et1 ON et1.type_ue = 'P' AND et1.type_ech = 'IFN' AND et1.phase_stat = 2 --AND et1.ech_parent_stat = ep2.ech_parent AND et1.ech_parent IS NULL
    WHERE e.type_ue = 'P'
    AND e.type_ech = 'IFN'
    AND e.phase_stat = 2
    AND e.ech_parent IS NOT NULL
    AND c.millesime = 2025
)
, pts_pi AS (
    SELECT pp.id_ech, pp.id_point, pp.cso
    FROM point_pi pp
    INNER JOIN echants e ON pp.id_ech = e.ech_pi_prec
)
, pts_terrain AS (
    SELECT e.ech_actuel, e.ech_terr_prec, pl.id_point, pl.reco, r.csa, r.obscsa, r5.utip, r5.bois, r5.leve
    FROM echants e
    INNER JOIN point_lt pl ON e.ech_terr_prec = pl.id_ech
    LEFT JOIN reconnaissance r ON pl.id_ech = r.id_ech AND pl.id_point = r.id_point 
    LEFT JOIN reco_2015 r5 ON pl.id_ech = r5.id_ech AND pl.id_point = r5.id_point
--    LEFT JOIN reco_m1 r1 ON pl.id_ech = r1.id_ech AND pl.id_point = r1.id_point --> reco_m1 n'existe plus !
)
, plhf AS (
    SELECT p.id_point
    FROM point p
    INNER JOIN pts_terrain pt USING (id_point)
    WHERE EXISTS (
        SELECT 1
        FROM fla_lt f
        WHERE f.id_transect = p.id_transect
    )
)
SELECT pt.ech_actuel, pt.id_point
, CASE
    WHEN coalesce(pt.reco, '0') != '1' THEN '0' --> ok
    WHEN pt.csa IN ('7', '8', '9') THEN '0' --> ok
    WHEN pt.csa IN ('6A') AND pt.obscsa IN ('0', '6') AND l.id_point IS NULL THEN '0'   -- Attention, à partir de la prochaine campagne, ON garde les 6H --> ok    
    WHEN pt.csa IN ('1', '3', '5') AND COALESCE(pt.leve, '0') != '1' THEN '0'                          -- Attention, à partir de la prochaine campagne, ON revisite tous les LEVE = 1, quels que soient UTIP et BOIS, sauf sur landes 4L (on garde UTIP = X seulement)
    WHEN pt.csa IN ('1', '3', '5') AND pt.utip NOT IN ('X', 'A')  THEN '0'              -- Attention, à partir de la prochaine campagne, ON revisite tous les LEVE = 1, quels que soient UTIP et BOIS, sauf sur landes 4L (on garde UTIP = X seulement) 
    WHEN pt.csa ='4L' AND pt.utip != 'X' THEN '0'
    WHEN pt.csa IN ('1', '3', '5') AND pt.bois NOT IN ('1', '0') THEN '0'                       
    WHEN l.id_point IS NOT NULL AND pt.csa NOT IN ('1', '3', '5', '4L', '6H') AND pp.cso NOT IN ('1', '3', '5', '4L', '6H') AND pt.obscsa IN ('0', '6') THEN '0' -- Attention, à partir de la prochaine campagne, ON garde les 6H
    ELSE '1'
  END AS tir5
, CASE
    WHEN coalesce(pt.reco, '0') != '1' THEN '1_RECO != 1'
    WHEN pt.csa IN ('7', '8', '9') THEN '2_CSA improductif'    
    WHEN pt.csa IN ('6A') AND pt.obscsa IN ('0', '6') AND l.id_point IS NULL THEN '3_OBSCSA 0/6 sans LHF' -- Attention, à partir de la prochaine campagne, ON garde les 6H
    WHEN pt.csa IN ('1', '3', '5') AND COALESCE(pt.leve, '0') != '1' THEN '6_LEVE != 1' --> COALESCE car il y a des points avec leve à NULL
    WHEN pt.csa IN ('1', '3', '5') AND pt.utip NOT IN ('X', 'A') THEN '4_UTIP != X AND A'                             -- Attention, à partir de la prochaine campagne, ON revisite tous les LEVE = 1, quels que soient UTIP et BOIS, sauf sur landes 4L (on garde UTIP = X seulement)
    WHEN pt.csa ='4L' AND pt.utip != 'X' THEN '8_UTIP != X'
    WHEN pt.csa IN ('1', '3', '5') AND pt.bois NOT IN ('1', '0') THEN '5_BOIS != 1 et != 0'                   -- Attention, à partir de la prochaine campagne, ON revisite tous les LEVE = 1, quels que soient UTIP et BOIS, sauf sur landes 4L (on garde UTIP = X seulement)    
    WHEN l.id_point IS NOT NULL AND pt.csa NOT IN ('1', '3', '5', '4L', '6H') AND pp.cso NOT IN ('1', '3', '5', '4L', '6H') AND pt.obscsa IN ('0', '6') THEN '7_LHF sans évolution possible' -- Attention, à partir de la prochaine campagne, ON garde les 6H
    ELSE 'tiré'
  END AS cause
FROM pts_terrain pt
INNER JOIN pts_pi pp USING (id_point)
LEFT JOIN plhf l USING (id_point)
ORDER BY id_point;

/*
SELECT count(*) FROM pts_retour WHERE tir5 = '1';
SELECT * FROM pts_retour WHERE tir5 = '1';


-- REQUÊTES DE CONTRÔLES MULTIPLES
-- nombre de points tirés
SELECT tir5, cause, COUNT(*)
FROM pts_retour
GROUP BY 1, 2
ORDER BY 1, 2;

-- nombre de points tirés par campagne
SELECT c.millesime AS campagne, count(*) AS nb_pts
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN point_lt pl USING (id_ech)
WHERE e.type_ue = 'P'
AND e.type_ech = 'IFN'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
AND EXISTS (
    SELECT 1
    FROM point_lt pl2
    WHERE pl2.id_point = pl.id_point
    AND pl2.id_ech < pl.id_ech
)
GROUP BY 1
ORDER BY 1 DESC;


SELECT c.millesime AS campagne, count(*) AS nb_pts
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN point_lt pl USING (id_ech)
WHERE e.type_ue = 'P'
AND e.type_ech = 'IFN'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
AND EXISTS (
    SELECT 1
    FROM point_lt pl2
    WHERE pl2.id_point = pl.id_point
    AND pl2.id_ech < pl.id_ech
)
GROUP BY 1
UNION ALL 
SELECT c.millesime AS campagne, COUNT(*)
FROM pts_retour p
INNER JOIN echantillon e ON p.ech_actuel = e.id_ech
INNER JOIN campagne c USING (id_campagne)
WHERE tir5 = '1'
GROUP BY campagne
ORDER BY campagne DESC;

-- représentation spatiale
SELECT p.id_point, p.npp
, st_x(st_transform(p.geom, 932006)) AS xl2
, st_y(st_transform(p.geom, 932006)) AS yl2
, st_x(p.geom) AS xl93
, st_y(p.geom) AS yl93
FROM pts_retour pt
INNER JOIN point p USING (id_point)
WHERE tir5 = '1'
ORDER BY id_point;

-- nombre de points tirés par DIR (initiale) -->  /!\ à jouer après INSERTION dans point_lt
SELECT 
  CASE 
    WHEN pl.echelon_init = '01' THEN 'DIRSO'
    WHEN pl.echelon_init = '02' THEN 'DIRNO'
    WHEN pl.echelon_init = '03' THEN 'Nogent'
    WHEN pl.echelon_init = '04' THEN 'DIRCE'
    WHEN pl.echelon_init = '05' THEN 'DIRSE'
    WHEN pl.echelon_init = '06' THEN 'DIRNE'
    ELSE 'X_Problème' 
  END AS dir_init
, count(*) AS nb_pts_terrain
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN point_lt pl USING (id_ech)
WHERE e.type_ue = 'P'
AND e.type_ech = 'IFN'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
AND c.millesime = 2025
AND EXISTS (
    SELECT 1
    FROM point_lt pl2
    WHERE pl2.id_point = pl.id_point
    AND pl2.id_ech < pl.id_ech
)
GROUP BY 1
ORDER BY 1;

SELECT 
  CASE 
    WHEN d.ex = '01' THEN 'DIRSO'
    WHEN d.ex = '02' THEN 'DIRNO'
    WHEN d.ex = '03' THEN 'Nogent'
    WHEN d.ex = '04' THEN 'DIRCE'
    WHEN d.ex = '05' THEN 'DIRSE'
    WHEN d.ex = '06' THEN 'DIRNE'
    ELSE 'X_Problème' 
  END AS dir_init
, count(*) AS nb_pts_terrain
FROM pts_retour p
INNER JOIN point pt USING (id_point)
INNER JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, pt.geom)
WHERE tir5 = '1'
GROUP BY 1
ORDER BY 1;

*/

-- insertion des points dans POINT_LT
INSERT INTO point_lt (id_ech, id_point, echelon_init)
SELECT ech_actuel, id_point, d.ex
FROM pts_retour p
INNER JOIN point pt USING (id_point)
INNER JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, pt.geom)
WHERE tir5 = '1'
ORDER BY 1, 2;

DROP TABLE pts_retour;

-- mise à jour de la déclinaison sur les points
CREATE UNLOGGED TABLE public.declinaison2 (
    id_transect INT4 PRIMARY KEY,
    decli FLOAT8
);

\COPY public.declinaison2 FROM '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/decli_revPI_2025.csv' WITH CSV DELIMITER ';' NULL AS ''

UPDATE point_lt pl
SET decli_pt = d.decli
FROM public.declinaison2 d
INNER JOIN point USING (id_transect)
INNER JOIN v_liste_points_lt2 v USING (id_point)
WHERE pl.id_ech = v.id_ech AND pl.id_point = v.id_point
AND v.annee = 2025;

DROP TABLE public.declinaison2;

COMMIT;

VACUUM ANALYZE point_lt;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TIRAGE DES POINTS PASSÉS À LA FORÊT

-- /!\ En 2025, il faut tirer les points passés à la forêt sur l'échantillon PI 2024 sur campagne 2020 dans les départements suivants :
-- '01', '02', '03', '04', '05', '08', '09', '10', '11', '12', '15', '17', '22', '24', '27', '29', '2A', '2B', '30', '31', '32', '33'
--, '34', '38', '40', '42', '43', '44', '46', '47', '49', '50', '51', '52', '53', '54', '55', '56', '57', '59', '60', '62', '63', '64'
--, '65', '66', '67', '68', '72', '73', '75', '76', '77', '78', '80', '81', '82', '84', '85', '91', '92', '93', '94', '95'


BEGIN;

-- import de la déclinaison des transects
CREATE UNLOGGED TABLE public.declinaison2 (
    id_transect INT4 PRIMARY KEY,
    decli FLOAT8
);

\COPY public.declinaison2 FROM '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/decli_revPI_2025.csv' WITH CSV DELIMITER ';' NULL AS ''

/*--contrôles
SELECT count(*)
FROM point_pi
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE id_ech = 135; --AND dep NOT IN ('06','07','13','14','16','18','19','20','21','23','25','26','28'
--,'35','36','37','39','41','45','48','58','61','69','70','71','74','79','83','86','87','88','89');

SELECT count(*)
FROM point_pi
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE id_ech = 110 --AND dep NOT IN ('01', '02', '03', '04', '05', '08', '09', '10', '11', '12', '15', '17', '22', '24', '27', '29', '2A', '2B', '30', '31', '32', '33'
--, '34', '38', '40', '42', '43', '44', '46', '47', '49', '50','51', '52', '53', '54', '55', '56', '57', '59', '60', '62', '63', '64', '65', '66'
--, '67', '68', '72', '73', '75', '76', '77', '78', '80', '81', '82', '84', '85', '91', '92', '93', '94', '95');
*/
----------------------------- ZONE DE TEST ---------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
SET enable_nestloop = FALSE;
	        
-- à poursuivre
	        
--> Version Cédric de la récupération des 2 écahntillons
/*	        
SELECT c.id_campagne, e.id_ech, e.nom_ech, e.ech_parent
FROM echantillon e
INNER JOIN campagne c ON e.id_campagne = c.id_campagne
INNER JOIN echantillon ep ON e.ech_parent = ep.id_ech
INNER JOIN campagne cp ON ep.id_campagne = cp.id_campagne
WHERE e.type_ech = 'IFN' AND e.type_ue = 'P' AND e.phase_stat = 1 AND e.passage > 1
AND cp.millesime = 2025 - 5;
*/
	             
CREATE TEMPORARY TABLE echants AS (
--WITH echants AS (
				SELECT c.id_campagne, c.millesime, e.id_ech, e.nom_ech, e.ech_parent, e.type_ue, e.type_ech, e.phase_stat --> récupération des 2 échantillons
				FROM echantillon e
				INNER JOIN campagne c USING(id_campagne)
				INNER JOIN (
						SELECT e.id_campagne, e.id_ech, e.nom_ech, e.ech_parent
						FROM echantillon e
						INNER JOIN campagne c USING(id_campagne)
						INNER JOIN echantillon e1 ON e.ech_parent  = e1.id_ech AND e1.phase_stat = 1 AND e1.type_ue = 'P' AND e1.type_ech = 'IFN'
						WHERE c.millesime = 2025) e2 ON e.ech_parent = e2.ech_parent
				);
CREATE TEMPORARY TABLE echant_pts AS (
--echant_pts AS (
		SELECT DISTINCT pen.id_ech, pen.id_point, en.ech_parent, pen.dep
    	FROM echants en
    	INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    	INNER JOIN point_ech pen ON en.id_ech = pen.id_ech
    	INNER JOIN point_pi ppo ON pen.id_ech = ppo.id_ech AND pen.id_point = ppo.id_point 
    	INNER JOIN point po ON ppo.id_point = po.id_point
    	WHERE en.type_ue = 'P'
	    AND en.type_ech = 'IFN'
	    AND en.phase_stat = 1
	    AND (ppo.id_point) NOT IN (
	    				SELECT pp.id_point
	    				FROM point_pi pp 
	    				INNER JOIN echants e USING (id_ech)
	    				INNER JOIN campagne c1 ON e.id_campagne = c1.id_campagne
	    				WHERE c1.millesime = 2025
	    				)
		UNION
	    SELECT pen.id_ech, pen.id_point, en.ech_parent, pen.dep
    	FROM echants en
    	INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    	INNER JOIN point_ech pen ON en.id_ech = pen.id_ech
    	INNER JOIN point_pi ppo ON pen.id_ech = ppo.id_ech AND pen.id_point = ppo.id_point 
    	INNER JOIN point po ON ppo.id_point = po.id_point
    	WHERE en.type_ue = 'P'
	    AND en.type_ech = 'IFN'
	    AND en.phase_stat = 1
	    AND c.millesime = 2025
		ORDER BY id_ech, id_point
			);

CREATE TEMPORARY TABLE pts_potentiels_foret_new AS (			
--pts_potentiels_foret_new AS (
		SELECT ppo.id_ech, ppo.id_point, ppo.cso
		FROM point_pi ppo
		INNER JOIN (SELECT DISTINCT ech_parent FROM echant_pts) ep ON ppo.id_ech = ep.ech_parent
		INNER JOIN point p ON ppo.id_point = p.id_point
		WHERE LEFT(ppo.cso, 1) = '6'
		AND NOT EXISTS (
		        SELECT 1
		        FROM fla_pi fp
		        WHERE fp.id_transect = p.id_transect
		        AND fp.flpi NOT IN ('0','6')
		        AND ABS(fp.disti) <= 25)
		UNION    
		SELECT ppo.id_ech, ppo.id_point, ppo.cso
		FROM point_pi ppo
		INNER JOIN (SELECT DISTINCT ech_parent FROM echant_pts) ep ON ppo.id_ech = ep.ech_parent
		INNER JOIN point p ON ppo.id_point = p.id_point
		WHERE ppo.cso = '7'
		AND ppo.ufpi = '1');
		
INSERT INTO point_lt (id_ech, id_point, formation, azpoint, decli_pt, echelon_init)
	SELECT DISTINCT t.id_ech, pp.id_point
	, CASE 
    WHEN pp.cso IN ('1', '3') THEN 14
    WHEN pp.cso = '4L' THEN 16
    WHEN pp.cso = '5' THEN 32
    ELSE 0
  	END AS formation
	, tr.aztrans AS azpoint
	, d.decli
	, di.ex
	FROM pts_potentiels_foret_new ppfn
	INNER JOIN echant_pts ep ON ppfn.id_point = ep.id_point
	INNER JOIN point_pi pp ON ppfn.id_point = pp.id_point AND ep.id_ech = pp.id_ech
	INNER JOIN point p ON ppfn.id_point = p.id_point 
	INNER JOIN transect tr ON p.id_transect = tr.id_transect
	INNER JOIN public.declinaison2 d ON tr.id_transect = d.id_transect 
	INNER JOIN sig_inventaire.dir_2024 di ON ST_Intersects(di.geom, p.geom)
	CROSS JOIN (
	    SELECT id_ech
	    FROM echantillon
	    INNER JOIN campagne USING (id_campagne)
	    WHERE type_ech = 'IFN'
	    AND phase_stat = 2
	    AND type_ue = 'P'
	    AND passage = 2
	    AND millesime = 2025
		) t
	WHERE pp.evof IN ('1', '2')
	AND pp.uspi = 'X';
		
DROP TABLE echants;
DROP TABLE echant_pts;
DROP TABLE pts_potentiels_foret_new;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

SET enable_nestloop = FALSE;

-- répartition par DIR
SELECT 
  CASE 
    WHEN d.ex = '01' THEN 'DIRSO'
    WHEN d.ex = '02' THEN 'DIRNO'
    WHEN d.ex = '03' THEN 'Nogent'
    WHEN d.ex = '04' THEN 'DIRCE'
    WHEN d.ex = '05' THEN 'DIRSE'
    WHEN d.ex = '06' THEN 'DIRNE'
    ELSE 'X_Problème' 
  END AS dir_init
, count(*)
FROM v_liste_points_lt1_pi2 v                             -->idem avec lt1 et lt1_pi2 et lt2
INNER JOIN point p USING (id_point)
INNER JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, p.geom)
WHERE v.annee = 2025
GROUP BY 1
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MISE À JOUR DE LA DÉCLINAISON MAGNÉTIQUE SUR L'ÉCHANTILLON DE TRANSECTS 1re PHASE
CREATE UNLOGGED TABLE public.declinaison1 (
    id_transect INT4 PRIMARY KEY,
    decli FLOAT8);

\COPY public.declinaison1 FROM '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/decli_nouv_2025.csv' WITH CSV DELIMITER ';' NULL AS ''

UPDATE transect t
SET decli = d.decli
FROM public.declinaison1 d
WHERE d.id_transect = t.id_transect;

DROP TABLE public.declinaison1;


-- ajout des zonages de tirage sans allègement
INSERT INTO inv_prod_new.tirage (id_ech, id_zonage, code_zone, formation, niveau, nvx_alleges)
VALUES (138, 8, '0', 14, 2, NULL)--'{4, 7}')     -- campagne 2025 (échantillon n°138)
, (138, 8, '1', 14, 3, NULL)--'{5, 8}')
, (138, 8, '2', 14, 3, NULL)--'{5, 8}')
, (138, 8, '3', 14, 3, NULL)--'{5, 8}')
, (138, 8, '4', 14, 3, NULL)--'{5, 8}')
, (138, 8, '5', 14, 4, NULL)--'{6, 9}')
, (138, 8, '6', 14, 2, NULL)--'{4, 7}')
, (138, 8, '0', 16, 3, NULL)
, (138, 8, '1', 16, 4, NULL)
, (138, 8, '2', 16, 4, NULL)
, (138, 8, '3', 16, 4, NULL)
, (138, 8, '4', 16, 4, NULL)
, (138, 8, '5', 16, 4, NULL)
, (138, 8, '6', 16, 3, NULL)
, (138, 1, 'F', 32, 1, NULL)
, (138, 1, 'F', 897, 4, NULL);

--TABLE zonage;

DROP TABLE IF EXISTS points;

-- récupération des points PI avec les informations nécessaires au tirage (l'échantillon doit déjà être créé, les nœuds rattachés)
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
    AND c.millesime = 2025
)
SELECT c.millesime, et.id_ech AS id_ech_ph2, epi.id_ech AS id_ech_ph1
, net.id_noeud, n.tirmax, net.depn, net.zp AS zpn, net.ztir, net.zforifn
, pepi.id_point, p.npp
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
AND c.millesime = 2025
ORDER BY id_point;

TABLE points;

ANALYZE points;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TIRAGE NON ALLÉGÉ
DROP TABLE IF EXISTS points_tir;

-- tirage
CREATE TEMPORARY TABLE points_tir AS 
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, power(2, t.niveau - 1)::real AS poids, p.st_x, p.st_y
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

-- TIRAGE ALLÉGÉ À 17,2% EN FORÊT EN ZONES DE TIRAGE NORMALES (ZTIR = 0 ET 6)
-- table des niveaux allégés
CREATE TEMPORARY TABLE tirage_17
AS SELECT *
FROM tirage
WHERE id_ech = 138;

UPDATE tirage_17
SET nvx_alleges = 
    CASE
        WHEN niveau = 2 THEN array[4, 6, 7]::int2[]
        WHEN niveau = 3 THEN array[5, 7, 8]::int2[]
        WHEN niveau = 4 THEN array[6, 8, 9]::int2[]
    END 
WHERE formation = 14;

SELECT *
FROM tirage_17
ORDER BY formation, code_zone;

-- tirage
DROP TABLE IF EXISTS points_tir_17;

CREATE TEMPORARY TABLE points_tir_17 AS
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, CASE
    WHEN t.nvx_alleges IS NULL THEN power(2, t.niveau - 1)::REAL
    WHEN array_length(t.nvx_alleges, 1) = 1 THEN power(2.0, t.nvx_alleges[1]) / (power(2.0, t.nvx_alleges[1] - t.niveau + 1) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 2 THEN power(2.0, t.nvx_alleges[2]) / (power(2.0, t.nvx_alleges[2] - t.niveau + 1) - power(2.0, t.nvx_alleges[2] - t.nvx_alleges[1]) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 3 THEN power(2.0, t.nvx_alleges[3]) / (power(2.0, t.nvx_alleges[3] - t.niveau + 1) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[2]) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[1]) - 1)
  END AS poids, p.st_x, p.st_y
FROM points p
INNER JOIN tirage_17 t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
    AND array_position(t.nvx_alleges, p.tirmax) IS NULL
ORDER BY id_ech, id_point, t.formation;                     -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir_17 ADD CONSTRAINT points_tir_17_pkey PRIMARY KEY (id_ech, id_point);


-- TIRAGE ALLÉGÉ À 14% EN FORÊT EN ZONES DE TIRAGE NORMALES (ZTIR = 0 ET 6)
-- table des niveaux allégés
DROP TABLE IF EXISTS tirage_14;

CREATE TEMPORARY TABLE tirage_14
AS SELECT *
FROM tirage
WHERE id_ech = 138;

UPDATE tirage_14
SET nvx_alleges = 
    CASE
        WHEN niveau = 2 THEN array[4, 7]::int2[]
        WHEN niveau = 3 THEN array[5, 8]::int2[]
        WHEN niveau = 4 THEN array[6, 9]::int2[]
    END 
WHERE formation = 14;

SELECT *
FROM tirage_14
ORDER BY formation, code_zone;

-- tirage
DROP TABLE IF EXISTS points_tir_14;

CREATE TEMPORARY TABLE points_tir_14 AS
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, CASE
    WHEN t.nvx_alleges IS NULL THEN power(2, t.niveau - 1)::REAL
    WHEN array_length(t.nvx_alleges, 1) = 1 THEN power(2.0, t.nvx_alleges[1]) / (power(2.0, t.nvx_alleges[1] - t.niveau + 1) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 2 THEN power(2.0, t.nvx_alleges[2]) / (power(2.0, t.nvx_alleges[2] - t.niveau + 1) - power(2.0, t.nvx_alleges[2] - t.nvx_alleges[1]) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 3 THEN power(2.0, t.nvx_alleges[3]) / (power(2.0, t.nvx_alleges[3] - t.niveau + 1) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[2]) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[1]) - 1)
  END AS poids, p.st_x, p.st_y
FROM points p
INNER JOIN tirage_14 t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
    AND array_position(t.nvx_alleges, p.tirmax) IS NULL
ORDER BY id_ech, id_point, t.formation;                     -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir_14 ADD CONSTRAINT points_tir_14_pkey PRIMARY KEY (id_ech, id_point);

SELECT count(*)
FROM points_tir_14;


-- TIRAGE ALLÉGÉ À 10% EN FORÊT EN ZONES DE TIRAGE NORMALES (ZTIR = 0 ET 6)
-- table des niveaux allégés
CREATE TEMPORARY TABLE tirage_10
AS SELECT *
FROM tirage
WHERE id_ech = 138;

UPDATE tirage_10
SET nvx_alleges = 
    CASE
        WHEN niveau = 2 THEN array[5, 6, 7]::int2[]
        WHEN niveau = 3 THEN array[6, 7, 8]::int2[]
        WHEN niveau = 4 THEN array[7, 8, 9]::int2[]
    END
WHERE formation = 14;

SELECT *
FROM tirage_10
ORDER BY formation, code_zone;

-- tirage
DROP TABLE IF EXISTS points_tir_10;

CREATE TEMPORARY TABLE points_tir_10 AS
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, CASE
    WHEN t.nvx_alleges IS NULL THEN power(2, t.niveau - 1)::REAL
    WHEN array_length(t.nvx_alleges, 1) = 1 THEN power(2.0, t.nvx_alleges[1]) / (power(2.0, t.nvx_alleges[1] - t.niveau + 1) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 2 THEN power(2.0, t.nvx_alleges[2]) / (power(2.0, t.nvx_alleges[2] - t.niveau + 1) - power(2.0, t.nvx_alleges[2] - t.nvx_alleges[1]) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 3 THEN power(2.0, t.nvx_alleges[3]) / (power(2.0, t.nvx_alleges[3] - t.niveau + 1) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[2]) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[1]) - 1)
  END AS poids, p.st_x, p.st_y
FROM points p
INNER JOIN tirage_10 t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
    AND array_position(t.nvx_alleges, p.tirmax) IS NULL
ORDER BY id_ech, id_point, t.formation;                     -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir_10 ADD CONSTRAINT points_tir_10_pkey PRIMARY KEY (id_ech, id_point);

SELECT count(*)
FROM points_tir_10;


-- TIRAGE ALLÉGÉ À 12,5% EN FORÊT EN ZONES DE TIRAGE NORMALES (ZTIR = 0 ET 6)
-- table des niveaux allégés
CREATE TEMPORARY TABLE tirage_12
AS SELECT *
FROM tirage
WHERE id_ech = 138;

UPDATE tirage_12
SET nvx_alleges = 
    CASE
        WHEN niveau = 2 THEN array[4]::int2[]
        WHEN niveau = 3 THEN array[5]::int2[]
        WHEN niveau = 4 THEN array[6]::int2[]
    END
WHERE formation = 14;


SELECT *
FROM tirage_12
ORDER BY formation, code_zone;

-- tirage
DROP TABLE IF EXISTS points_tir_12;

CREATE TEMPORARY TABLE points_tir_12 AS
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, CASE
    WHEN t.nvx_alleges IS NULL THEN power(2, t.niveau - 1)::REAL
    WHEN array_length(t.nvx_alleges, 1) = 1 THEN power(2.0, t.nvx_alleges[1]) / (power(2.0, t.nvx_alleges[1] - t.niveau + 1) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 2 THEN power(2.0, t.nvx_alleges[2]) / (power(2.0, t.nvx_alleges[2] - t.niveau + 1) - power(2.0, t.nvx_alleges[2] - t.nvx_alleges[1]) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 3 THEN power(2.0, t.nvx_alleges[3]) / (power(2.0, t.nvx_alleges[3] - t.niveau + 1) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[2]) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[1]) - 1)
  END AS poids, p.st_x, p.st_y
FROM points p
INNER JOIN tirage_12 t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
    AND array_position(t.nvx_alleges, p.tirmax) IS NULL
ORDER BY id_ech, id_point, t.formation;                     -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir_12 ADD CONSTRAINT points_tir_12_pkey PRIMARY KEY (id_ech, id_point);

SELECT count(*)
FROM points_tir_12;






-- tirage définitif (allègement à 12.5 %)

UPDATE inv_prod_new.tirage
SET nvx_alleges = 
    CASE
        WHEN niveau = 2 THEN array[4]::int2[]
        WHEN niveau = 3 THEN array[5]::int2[]
        WHEN niveau = 4 THEN array[6]::int2[]
    END
WHERE formation = 14
AND id_ech = 114;


TABLE tirage 
ORDER BY id_ech DESC;

DROP TABLE IF EXISTS points_tir_final;

CREATE TEMPORARY TABLE points_tir_final AS
SELECT DISTINCT ON (p.id_ech_ph2, p.id_point) p.id_ech_ph2 AS id_ech, p.id_point, p.formation
, CASE
    WHEN t.nvx_alleges IS NULL THEN power(2, t.niveau - 1)::REAL
    WHEN array_length(t.nvx_alleges, 1) = 1 THEN power(2.0, t.nvx_alleges[1]) / (power(2.0, t.nvx_alleges[1] - t.niveau + 1) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 2 THEN power(2.0, t.nvx_alleges[2]) / (power(2.0, t.nvx_alleges[2] - t.niveau + 1) - power(2.0, t.nvx_alleges[2] - t.nvx_alleges[1]) - 1)
    WHEN array_length(t.nvx_alleges, 1) = 3 THEN power(2.0, t.nvx_alleges[3]) / (power(2.0, t.nvx_alleges[3] - t.niveau + 1) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[2]) - power(2.0, t.nvx_alleges[3] - t.nvx_alleges[1]) - 1)
  END AS poids, p.st_x, p.st_y
FROM points p
INNER JOIN tirage t ON p.id_ech_ph2 = t.id_ech
WHERE p.formation & t.formation > 0
    AND 
    CASE 
        WHEN t.id_zonage = 1 THEN TRUE                      -- zonage France entière 
        WHEN t.id_zonage = 8 THEN (p.ztir = t.code_zone)    -- zonage ZTIR
    END
    AND p.tirmax >= t.niveau
    AND array_position(t.nvx_alleges, p.tirmax) IS NULL
ORDER BY id_ech, id_point, t.formation;                  -- attention, c'est la formation de la zone de tirage qui permet de privilégier la forêt au LHF quand il y a les deux sur un point

ALTER TABLE points_tir_final ADD CONSTRAINT points_tir_final_pkey PRIMARY KEY (id_ech, id_point);

SELECT count(*)
FROM points_tir_final;

/*
---REQUÊTES DE CONTRÔLES MULTIPLES--------------------------------------------
SELECT CASE 
            WHEN formation & 14 > 0 THEN '1_foret'
            WHEN formation & 16 > 0 THEN '2_lande'
            WHEN formation & 32 > 0 THEN '4_peupl'
            WHEN formation & 960 > 0 THEN '3_LHF'
            ELSE 'X_Problème'
        END AS formation, count(*) AS nb_pts_terrain
FROM points_tir
GROUP BY 1
ORDER BY 1;

SELECT  CASE 
            WHEN formation & 14 > 0 THEN '1_foret'
            WHEN formation & 16 > 0 THEN '2_lande'
            WHEN formation & 32 > 0 THEN '4_peupl'
            WHEN formation & 960 > 0 THEN '3_LHF'
            ELSE 'X_Problème'
        END AS formation
, CASE 
    WHEN d.ex = '01' THEN 'DIRSO'
    WHEN d.ex = '02' THEN 'DIRNO'
    WHEN d.ex = '03' THEN 'Nogent'
    WHEN d.ex = '04' THEN 'DIRCE'
    WHEN d.ex = '05' THEN 'DIRSE'
    WHEN d.ex = '06' THEN 'DIRNE'
    ELSE 'X_Problème' 
  END AS dir_init
, count(*) AS nb_pts_terrain
FROM points_tir_17 p
INNER JOIN point p1 USING (id_point)
LEFT JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, p1.geom)
GROUP BY 1, 2
ORDER BY 1, 2;

SELECT id_ech, id_point, st_x(p1.geom) as xl, st_y(p1.geom) yl
, CASE 
    WHEN d.ex = '01' THEN 'DIRSO'
    WHEN d.ex = '02' THEN 'DIRNO'
    WHEN d.ex = '03' THEN 'Nogent'
    WHEN d.ex = '04' THEN 'DIRCE'
    WHEN d.ex = '05' THEN 'DIRSE'
    WHEN d.ex = '06' THEN 'DIRNE'
    ELSE 'X_Problème' 
  END AS dir_init
FROM points_tir p
INNER JOIN point p1 USING (id_point)
LEFT JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, p1.geom);


--ventilation par dept
SELECT  CASE 
            WHEN p.formation & 14 > 0 THEN '1_foret'
            WHEN p.formation & 16 > 0 THEN '2_lande'
            WHEN p.formation & 32 > 0 THEN '4_peupl'
            WHEN p.formation & 960 > 0 THEN '3_LHF'
            ELSE 'X_Problème'
        END AS formation
, p1.depn, count(*) AS nb_pts_terrain
FROM points_tir p
INNER JOIN points p1 USING (id_point)
INNER JOIN point p2 USING (id_point)
INNER JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, p2.geom)
GROUP BY 1, 2
ORDER BY 1, 2;

WITH totaux_dep AS (
    SELECT  CASE 
                WHEN p1.formation & 14 > 0 THEN '1_foret'
                WHEN p1.formation & 16 > 0 THEN '2_lande'
                WHEN p1.formation & 32 > 0 THEN '4_peupl'
                WHEN p1.formation & 960 > 0 THEN '3_LHF'
                ELSE 'X_Problème'
            END AS formation
    , p1.depn
    , count(*) AS nb_pts_terrain
    FROM points_tir_final p
    INNER JOIN points p1 USING (id_point)
    GROUP BY 1, 2
)
, gp AS (
    SELECT depn, json_object_agg(formation, nb_pts_terrain ORDER BY formation) AS js
    FROM totaux_dep
    GROUP BY depn
)
SELECT depn
, js -> '1_foret' AS "1_foret"
, js -> '2_lande' AS "2_lande"
, js -> '3_LHF' AS "3_LHF"
, js -> '4_peupl' AS "4_peupl"
FROM gp
ORDER BY depn;
*/



-- 2 INSERTIONS À FAIRE : DANS point_ech (TOUT L'ÉCHANTILLON DE POINTS) ET DANS point_lt (POINTS TERRAIN SEULEMENT)
INSERT INTO point_ech (id_ech, id_point, id_ech_nd, id_noeud, poids, commune, dep, zp, pro, regn, ser_86, ser_alluv)
SELECT p.id_ech_ph2 AS id_ech, p.id_point, p.id_ech_ph2 AS id_ech_nd, p.id_noeud, p.poids
, pep.commune, pep.dep, pep.zp, pep.pro, pep.regn, pep.ser_86, pep.ser_alluv
FROM points p
INNER JOIN point_ech pep ON p.id_ech_ph1 = pep.id_ech AND p.id_point = pep.id_point
WHERE tire = 'pas tir'
UNION 
SELECT pt.id_ech, p.id_point, p.id_ech_ph2 AS id_ech_nd, p.id_noeud, pt.poids
, pep.commune, pep.dep, pep.zp, pep.pro, pep.regn, pep.ser_86, pep.ser_alluv
FROM points_tir_final pt
INNER JOIN points p ON pt.id_ech = p.id_ech_ph2 AND pt.id_point = p.id_point
INNER JOIN point_ech pep ON p.id_ech_ph1 = pep.id_ech AND p.id_point = pep.id_point
ORDER BY 1, 2;

INSERT INTO point_lt (id_ech, id_point, formation, azpoint, decli_pt)
SELECT pt.id_ech, pt.id_point, pt.formation, t.aztrans, t.decli
--, d.ex AS echelon_init
FROM points_tir_final pt
INNER JOIN point p USING (id_point)
INNER JOIN transect t USING (id_transect)
--INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, ST_Transform(p.geom, 910002))  --> les deux géométries sont en 931007 en test, pas besoin de transform
--INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
ORDER BY id_ech, id_point;

-- Mise à jour à posteriori de l'échelon dans point_lt

   -- points 1ère visite
SET enable_nestloop = TRUE;

WITH e AS
	(
	SELECT vlp1.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt1 vlp1
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp1.annee = 2025
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 2ème visite
WITH e AS
	(
	SELECT vlp2.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt2 vlp2
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp2.annee = 2025
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 1ère visite 2ème pi
WITH e AS
	(
	SELECT c.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt1_pi2 c
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE c.annee = 2025
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;


-- Mise à jour à posteriori de SECTEURS_CN dans point_lt

   -- points 1ère visite
WITH e AS
	(
	SELECT vlp1.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt1 vlp1
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp1.annee = 2025
	)
UPDATE point_lt pl
SET secteur_cn = e.secteur_cn
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 2ème visite
WITH e AS
	(
	SELECT vlp2.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt2 vlp2
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp2.annee = 2025
	)
UPDATE point_lt pl
SET secteur_cn = e.secteur_cn
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 1ère visite 2ème pi
WITH e AS
	(
	SELECT vplp.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt1_pi2 vplp 
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vplp.annee = 2025
	)
UPDATE point_lt pl
SET secteur_cn = e.secteur_cn
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

/*
SELECT c.millesime AS campagne, count(*) AS nb_points, sum(poids) AS eff_pond
FROM point_ech pe
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND phase_stat = 2
AND ech_parent IS NULL
GROUP BY campagne
ORDER BY campagne DESC;
*/

DROP TABLE IF EXISTS points_tir;
DROP TABLE IF EXISTS points_tir_17;
DROP TABLE IF EXISTS points_tir_14;
DROP TABLE IF EXISTS points_tir_final;
DROP TABLE IF EXISTS points;

COMMIT;

ANALYZE point_ech;
ANALYZE point_lt;


-- Rattachement des points à l'échantillon de transects via le transect
SET enable_nestloop = FALSE;

WITH camp AS (
    SELECT id_campagne, millesime
    FROM inv_prod_new.campagne
    WHERE lib_campagne LIKE 'Campagne annuelle%'
    AND millesime = 2025
)
, ech_pts_1 AS (
    SELECT id_ech, id_campagne, nom_ech
    FROM inv_prod_new.echantillon
    INNER JOIN camp USING (id_campagne)
    WHERE nom_ech = 'FR_IFN_ECH_' || (millesime)::TEXT || '_PH1_PTS_' || (millesime)::TEXT
)
, ech_pts_2 AS (
    SELECT id_ech, id_campagne, nom_ech, ech_parent_stat, millesime
    FROM inv_prod_new.echantillon
    INNER JOIN camp USING (id_campagne)
    WHERE nom_ech = 'FR_IFN_ECH_' || (millesime)::TEXT || '_PH2_PTS_' || (millesime)::TEXT
)
, pts_1 AS (
    SELECT p.npp, pe.id_ech, pe.id_point, ROUND(pe.poids::NUMERIC, 2) AS poids, ne.ztir, COUNT(*) OVER (PARTITION BY ne.id_ech, ne.id_noeud) AS nb_pts_nd
    FROM inv_prod_new.point p
    INNER JOIN inv_prod_new.point_ech pe ON p.id_point = pe.id_point
    INNER JOIN inv_prod_new.noeud_ech ne ON pe.id_ech = ne.id_ech AND pe.id_noeud = ne.id_noeud
    INNER JOIN ech_pts_1 ep ON ne.id_ech = ep.id_ech
)
--INSERT INTO inv_prod_new.transect_ech (id_ech, id_transect, poids)
SELECT e.id_ech, t.id_transect, pe.poids * p1.nb_pts_nd AS poids
FROM inv_prod_new.point_lt pl
INNER JOIN inv_prod_new.point_ech pe USING (id_ech, id_point)
INNER JOIN inv_prod_new.point p USING (id_point)
INNER JOIN inv_prod_new.transect t USING (id_transect)
INNER JOIN ech_pts_2 ep USING (id_ech)
INNER JOIN pts_1 p1 ON ep.ech_parent_stat = p1.id_ech AND pl.id_point = p1.id_point
INNER JOIN inv_prod_new.echantillon e ON ep.id_campagne = e.id_campagne AND e.nom_ech = 'FR_IFN_ECH_' || ep.millesime || '_TR_RE'
INNER JOIN camp c ON e.id_campagne = c.id_campagne
ORDER BY e.id_ech, t.id_transect;

SET enable_nestloop = TRUE;

-- MISE À JOUR DE croisement_carto POUR LA BDCARTO
INSERT INTO croisement_carto (id_couche, num_version, id_ech, date_croisement)
SELECT 9 AS id_couche, 1 AS num_version, e.id_ech, e.date_tirage
FROM echantillon e 
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2025
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1;


/*
-- liste des données valides sur la campagne 2024 en base de production, points nouveaux --> 660
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND COALESCE(c.defin, 0) <= 19
AND COALESCE(c.defout, 99) >= 19
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1NOEUD', 'E1POINT', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.position;

-- liste des données 1re visite arrêtées fin campagne 2023
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defout = 18
ORDER BY pformat, donnee;

-- liste des données 1re visite apparues à la campagne 2024
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defin = 19
AND NOT c.donnee LIKE '%5%'
ORDER BY pformat, donnee;

-- liste des données 2ème visite arrêtées fin campagne 2023
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defout = 13
AND c.donnee LIKE '%5%'
ORDER BY pformat, donnee;

-- liste des données 2ème visite  apparues à la campagne 2024
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defin = 14
AND c.donnee LIKE '%5%'
ORDER BY pformat, donnee;

-- liste des données 1ère visite dont l'unité a changé en 2024  -->3
WITH change_unit AS (
    SELECT f.pformat, d.donnee, d.unite, i.incref, i.dcunite, d.libelle
    , lag(dcunite, 1) OVER(PARTITION BY f.pformat, d.donnee ORDER BY i.incref) AS dcunite_avant
    FROM metaifn.addonnee d
    INNER JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P'
    INNER JOIN metaifn.afchamp c ON d.donnee = c.donnee 
    INNER JOIN metaifn.afformat f ON c.famille = f.famille AND c.format = f.format 
    WHERE f.famille = 'INV_PROD'
    AND NOT c.donnee LIKE '%5%'
    AND i.incref IN (18, 19)
)
SELECT pformat, donnee
FROM change_unit
WHERE incref = 19
AND dcunite != dcunite_avant
ORDER BY pformat, donnee;

-- liste des données 2ème visite dont l'unité a changé en 2024
WITH change_unit AS (
    SELECT f.pformat, d.donnee, d.unite, i.incref, i.dcunite, d.libelle
    , lag(dcunite, 1) OVER(PARTITION BY f.pformat, d.donnee ORDER BY i.incref) AS dcunite_avant
    FROM metaifn.addonnee d
    INNER JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P'
    INNER JOIN metaifn.afchamp c ON d.donnee = c.donnee 
    INNER JOIN metaifn.afformat f ON c.famille = f.famille AND c.format = f.format 
    WHERE f.famille = 'INV_PROD'
    AND c.donnee LIKE '%5%'
    AND i.incref IN (13, 14)
)
SELECT pformat, donnee
FROM change_unit
WHERE incref = 14
AND dcunite != dcunite_avant
ORDER BY pformat, donnee;

-- Liste des données apparues dans Soif
SELECT DISTINCT c.name AS table, d.column_name AS champ, d.field, replace(replace(replace(label, 'foret', ''),'peupleraie',''), 'Peupleraie', '') AS lot 
FROM metadata.view_getdbfield d
INNER JOIN metadata.field_lot f ON d.field = f.field
    AND d.lot = f.lot
INNER JOIN metadata.view_getdbcontainermetadata c ON d.container = c.container
INNER JOIN metadata.process_container p ON c.process = p.process
    AND c.container = p.container
INNER JOIN metadata.process l ON d.lot = l.lot
    AND l.process = p.process
WHERE f.anref_in = 2024
    AND c.subtype = 'TABLE'
    AND (l.lot LIKE 'V2_5%'
        OR l.lot LIKE 'V1_3%'
        OR l.lot IN ('V1E2', 'V2E4'))
ORDER BY 1, 2;


*/

/* 
-- points PI1 LT1
SELECT id_ech, count(*)
FROM inv_prod_new.v_liste_points_lt1
WHERE annee = 2024
GROUP BY id_ech;

-- points PI1 LT2
SELECT id_ech, count(*)
FROM inv_prod_new.v_liste_points_lt2
WHERE annee = 2024
GROUP BY id_ech;

-- points PI2 LT1
SELECT v1.id_ech, v1.id_point, vp2.npp, pd.echelon, vp2.datepoint, vp2.reco, vp2.datereco, vp2.qreco
, CASE WHEN ve2.pobs IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs)) ELSE NULL END AS suppl
FROM soif.v1e2point vp2
LEFT JOIN soif.v1e2observ ve2 ON vp2.npp = ve2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024;
SELECT id_ech, count(*)
FROM inv_prod_new.v_liste_points_lt1_pi2
WHERE annee = 2024
GROUP BY id_ech;
--------------------------------------------------------------------------
-- REQUETES DE JULIEN

SELECT * from metadata.fct_get_soif_column(2024);

-- Données ajoutées :
SELECT * from metadata.fct_get_soif_column(2024) except SELECT * FROM metadata.fct_get_soif_column(2023) order by table_name, position;
-- Données supprimées :
SELECT * from metadata.fct_get_soif_column(2023) except SELECT * FROM metadata.fct_get_soif_column(2024) order by table_name, position;

*/

-------------------------------------------------------------------
-- CHARGEMENT DES POINTS PI1 LT1 (NOUVEAUX)
-------------------------------------------------------------------
BEGIN;

CREATE TEMPORARY TABLE states AS (
	SELECT npp, MAX(state) AS state
	FROM soif.point_states
	WHERE anref = 2024
	GROUP BY npp
);

ALTER TABLE states ADD CONSTRAINT states_pkey PRIMARY KEY (npp);
ANALYZE states;

-------------------------------------------------------------------------------------------------------------------------------
-- --- Remplissage table AGENT_LT pour les points LT1 --> suite à la suppression de auteurlt dans POINT_LT
INSERT INTO agent_lt (id_ech, id_point, matricule, num_auteurlt)
	(
	SELECT v.id_ech, v.id_point, vp.auteurlt AS matricule, 1 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt IS NOT NULL 
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt_2 AS matricule, 2 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt_2 IS NOT NULL
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt_3 AS matricule, 3 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt_3 IS NOT NULL	
	);

---------------------------------------------------------------------------------------------------------------------------------
-- Table POINT_LT  -->  auteurlt a été supprimé, une table de passage entre agent et point_lt a été créée : agent_lt
UPDATE inv_prod_new.point_lt pl
SET datepoint = vp2.datepoint, reco = vp2.reco, datereco = vp2.datereco, qreco = vp2.qreco
, suppl = CASE WHEN ve2.pobs IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs)) ELSE NULL END
FROM soif.v1e2point vp2
LEFT JOIN soif.v1e2observ ve2 ON vp2.npp = ve2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.id_ech = pl.id_ech AND v1.id_point = pl.id_point
AND v1.annee = 2024;

/*
SELECT v1.id_ech, v1.id_point, vp2.npp, pd.echelon, vp2.datepoint, vp2.reco, vp2.datereco, vp2.qreco
, CASE WHEN ve2.pobs IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs)) ELSE NULL END AS suppl
FROM soif.v1e2point vp2
LEFT JOIN soif.v1e2observ ve2 ON vp2.npp = ve2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024;
*/

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DATEPOINT', 'RECO', 'DATERECO', 'QRECO', 'POBS')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_lt p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

/*
SELECT v1.npp
FROM inv_prod_new.v_liste_points_lt1 v1
INNER JOIN inv_prod_new.point_lt pl USING (id_ech, id_point)
WHERE v1.annee = 2024
AND pl.datepoint IS NULL; --> 0 points
*/

-------------------------------------------------------------------------------------------------------------------------------------------
-- Table POINT_M1
INSERT INTO inv_prod_new.point_m1 (id_ech, id_point, duracc, posipr, pclos, pdiff)
SELECT v1.id_ech, v1.id_point, vp2.duracc, vp2.posipr, vp2.pclos, vp2.pdiff
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024
AND (vp2.duracc, vp2.posipr, vp2.pclos, vp2.pdiff) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DURACC', 'POSIPR', 'PCLOS', 'PDIFF')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECONNAISSANCE
INSERT INTO inv_prod_new.reconnaissance (id_ech, id_point, csa, obscsa)
SELECT v1.id_ech, v1.id_point, vp2.csa, vp2.obscsa
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024
AND (vp2.csa, vp2.obscsa) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CSA', 'OBSCSA')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reconnaissance p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECO_2015
INSERT INTO inv_prod_new.reco_2015 (id_ech, id_point, utip, bois, doute_bois, autut, tauf, tform, eflt, rp, azrp_gd, drp_cm, qbois, vegrp, esprp, c13rp_mm, leve, qleve)
SELECT v1.id_ech, v1.id_point, vp2.utip, vp2.bois, vp2.doute_bois, vp2.autut, vp2.tauf, vp2.tform, vp2.eflt, vp2.rp, vp2.azrp_gd, vp2.drp_cm, vp2.qbois, vp2.vegrp, vp2.esprp,
vp2.c13rp_mm, vp2.leve, vp2.qleve
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024
AND (vp2.utip, vp2.bois, vp2.doute_bois, vp2.autut, vp2.tauf, vp2.tform, vp2.eflt, vp2.rp, vp2.azrp_gd, vp2.drp_cm, vp2.qbois, vp2.vegrp, vp2.esprp, vp2.c13rp_mm, vp2.leve, vp2.qleve) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('UTIP', 'BOIS', 'DOUTE_BOIS', 'AUTUT', 'TAUF', 'TFORM', 'EFLT', 'RP', 'AZRP_GD', 'DRP_CM', 'QBOIS', 'VEGRP', 'ESPRP', 'C13RP_MM', 'LEVE', 'QLEVE')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_2015 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

/*--------- RECO_M1 n'existe plus ---------------------------------------
-------------------------------------------------------------------------
-- Table RECO_M1
INSERT INTO inv_prod_new.reco_m1 (id_ech, id_point, leve, qleve)
SELECT v1.id_ech, v1.id_point, vp2.leve, vp2.qleve
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp2.npp = v1.npp
WHERE v1.annee = 2024
AND (vp2.leve, vp2.qleve) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LEVE', 'QLEVE')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;
*/
--------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPTION  --> ajout de TPLANT (transféré depuis DESCRIPT_M1), ajout de tplant, qual_data
INSERT INTO inv_prod_new.description (id_ech, id_point, dc, incid, peupnr, sver, nincid, href_dm, caracthab, tplant, suppl)
SELECT v1.id_ech, v1.id_point, vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.caracthab, vp.tplant
, CASE 
    WHEN (vp.cam, vh.ligneriv, vp.entp) IS DISTINCT FROM  (NULL, NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('cam', vp.cam) || jsonb_build_object('ligneriv', vh.ligneriv) || jsonb_build_object('entp', vp.entp))
    ELSE NULL
  END AS suppl
FROM soif.v1e3point vp
LEFT JOIN soif.v1e3habitat vh ON vp.npp = vh.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.ligneriv, vp.cam, vp.entp, vh.caracthab, vp.tplant) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DC', 'INCID', 'PEUPNR', 'SVER', 'NINCID', 'HREF_DM', 'CARACTHAB', 'TPLANT', 'CAM', 'LIGNERIV', 'ENTP')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.description p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPT_M1  -- arrêt de abrou,  ajout de tcnr, ornr, prnr, dispnr, predom, fouil; et tplant transféré dans description
--ALTER TABLE descript_m1 DROP  COLUMN abrou;
-- OK -->ALTER TABLE descript_m1 ALTER COLUMN tcnr TYPE varchar(2); --> tcnr est de TYPE varchar(2) dans soif

INSERT INTO inv_prod_new.descript_m1 (id_ech, id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr,
bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil)
SELECT v1.id_ech, v1.id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain::boolean, plas25, plas15, deppr,
bord, orniere, tcat10, azdep_gd, ddep_cm, vn.tcnr, vn.ornr, vn.prnr, vn.dispnr, vn.predom, vn.fouil
FROM soif.v1e3point vp
--LEFT JOIN soif.v1e3habitat vh ON vp.npp = vh.npp
LEFT JOIN soif.v1e3nrpoint vn ON vp.npp = vn.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr, bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PLISI', 'CSLISI', 'DIST', 'TPLANT', 'GEST', 'INTEGR', 'ITI', 'PORTANCE', 'ASPERITE', 'PENTEXP', 'ANDAIN', 'PLAS25', 'PLAS15', 'DEPPR', 'BORD', 'ORNIERE', 'TCAT10', 'AZDEP_GD',
    'DDEP_CM', 'TCNR', 'ORNR', 'PRNR', 'DISPNR', 'PREDOM', 'FOUIL')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.descript_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table LIMITES
INSERT INTO inv_prod_new.limites (id_ech, id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd)
SELECT v1.id_ech, v1.id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DLIM_CM', 'DLIM2_CM', 'AZDLIM_GD', 'AZDLIM2_GD', 'DCOI_CM', 'AZDCOI_GD', 'AZLIM1_GD', 'AZLIM2_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.limites p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------------------------
-- Table COUPES
INSERT INTO inv_prod_new.coupes (id_ech, id_point, dcespar1)
SELECT v1.id_ech, v1.id_point, dcespar1
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (dcespar1) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DCESPAR1')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.coupes p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table BUIS -- OK --> ajout de atpyr, ncbuis10, ncbuis_A à E, azdbuis_gd, et suppression de dpyr, anpyr
-- ALTER TABLE buis RENAME COLUMN azdbuis TO azdbuis_gd;

INSERT INTO inv_prod_new.buis (id_ech, id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd)
SELECT v1.id_ech, v1.id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PBUIS', 'ATPYR', 'NCBUIS10', 'NCBUIS_A', 'NCBUIS_B', 'NCBUIS_C', 'NCBUIS_D', 'NCBUIS_E', 'AZDBUIS_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.buis p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------
-- Table PLANTATIONS
INSERT INTO inv_prod_new.plantations (id_ech, id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag, suppl)
SELECT v1.id_ech, v1.id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag
, JSONB_STRIP_NULLS(jsonb_build_object('maille', maille)) AS suppl
FROM soif.v1e3plant vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag, maille) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3plant ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('BPLANT_DM', 'IPLANT_DM', 'VIDEPLANT', 'TPESPAR1', 'TPESPAR2', 'ELAG', 'MAILLE')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.plantations p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-------------------------------------------------------------------------------------------------------------------------------------------
-- Table COUV_R
INSERT INTO inv_prod_new.couv_r (id_ech, id_point, tcar10)
SELECT v1.id_ech, v1.id_point, tcar10
FROM soif.v1e3strate vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (tcar10) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3strate ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TCAR10')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.couv_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------
-- Table ESPAR_R
INSERT INTO inv_prod_new.espar_r (id_ech, id_point, espar, tcr10, tclr10, cible, p7ares)
SELECT v1.id_ech, v1.id_point, RTRIM(espar) AS espar, tcr10, tclr10, cible, p7ares
FROM soif.v1e3essence vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (espar, tcr10, tclr10, cible, p7ares) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, RTRIM(ve.espar) AS espar
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3essence ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3ESSENCE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'TCR10', 'TCLR10', 'CIBLE', 'P7ARES')
)
, json_final AS (
    SELECT id_ech, id_point, espar, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, espar
)
UPDATE inv_prod_new.espar_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.espar = q.espar;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Table RENOUV
INSERT INTO inv_prod_new.renouv (id_ech, id_point, nsnr, libnr_sp, pint_sp)
SELECT v1.id_ech, v1.id_point, 1 AS nsnr, libnr_sp1, pint_sp1
FROM soif.v1e3nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (libnr_sp1, pint_sp1) IS DISTINCT FROM (NULL, NULL)
UNION 
SELECT v1.id_ech, v1.id_point, 2 AS nsnr, libnr_sp2, pint_sp2
FROM soif.v1e3nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (libnr_sp2, pint_sp2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, 1 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP1', 'PINT_SP1')
    UNION
    SELECT v1.id_ech, v1.id_point, 2 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP2', 'PINT_SP2')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr
)
UPDATE inv_prod_new.renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr;

--------------------------------------------------------------------------------------------------------
-- Table ESPAR_RENOUV
INSERT INTO inv_prod_new.espar_renouv (id_ech, id_point, nsnr, espar, chnr, nint, nbrou, nfrot, nmixt)
SELECT v1.id_ech, v1.id_point, nsnr::INT2 AS nsnr, rtrim(espar) AS espar, chnr, nbint AS nint, nbrou, nfrot, nmixt
FROM soif.v1e3nrspot vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (nsnr, chnr, espar, nbint, nbrou, nfrot, nmixt) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, nsnr::INT2, RTRIM(ve.espar) AS espar, chnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrspot ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3NRSPOT'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('NSNR', 'ESPAR', 'CHNR', 'NINT', 'NBROU', 'NFROT', 'NMIXT')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, espar, chnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr, espar, chnr
)
UPDATE inv_prod_new.espar_renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr
AND p.espar = q.espar
AND p.chnr = q.chnr;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE
INSERT INTO inv_prod_new.ecologie (id_ech, id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc, roche, cailloux, cai40, text1, text2, 
    prof1, prof2, pcalc, pcalf, pox, ppseudo, pgley, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo)
SELECT v1.id_ech, v1.id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DATEECO', 'AUTEUREF', 'AZ_FO', 'DI_FO_CM', 'PENT2', 'TOPO', 'MASQUE', 'HERB', 'ST_A1', 'HUMUS', 'AFFROC', 'ROCHE', 'CAILLOUX', 'CAI40', 'TEXT1', 'TEXT2', 
    'PROF1', 'PROF2', 'PCALC', 'PCALF', 'POX', 'PPSEUDO', 'PGLEY', 'TSOL', 'OBSDATE', 'OBSHYDR', 'OBSPEDO', 'OBSPROF', 'OBSTOPO', 'OBSVEGET', 'OBSCHEMIN', 'MOUSSE', 'DISTRIV', 'DENIVRIV', 'EXPO')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE_2017
INSERT INTO inv_prod_new.ecologie_2017 (id_ech, id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext)
SELECT v1.id_ech, v1.id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (msud, oln, olv, olt, ofr, oh, typriv, typcai, htext) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MSUD', 'OLN', 'OLV', 'OLT', 'OFR', 'OH', 'TYPRIV', 'TYPCAI', 'HTEXT')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie_2017 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table LIGNEUX
INSERT INTO inv_prod_new.ligneux (id_ech, id_point, lign1, lign2)
SELECT v1.id_ech, v1.id_point, lign1, lign2
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (lign1, lign2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIGN1', 'LIGN2')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ligneux p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------------------------------------
-- Table FLORE
INSERT INTO inv_prod_new.flore (id_ech, id_point, codesp, abond, inco_flor)
SELECT v1.id_ech, v1.id_point, codesp, abond::INT2, inco_flor
FROM soif.v1e3flore vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (codesp, abond, inco_flor) IS DISTINCT FROM (NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, codesp
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3flore ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CODESP', 'ABOND', 'INCO_FLOR')
)
, json_final AS (
    SELECT id_ech, id_point, codesp, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, codesp
)
UPDATE inv_prod_new.flore p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.codesp = q.codesp;

----------------------------------------------------------------------------------------------------------
-- Table HABITAT
INSERT INTO inv_prod_new.habitat (id_ech, id_point, num_hab, hab, obshab, qualhab, s_hab)
SELECT v1.id_ech, v1.id_point, 1 AS num_hab, hab1 AS hab, obshab1 AS obshab, qualhab1 AS qualhab, s_hab1 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (hab1, obshab1, qualhab1, s_hab1) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v1.id_ech, v1.id_point, 2 AS num_hab, hab2 AS hab, obshab2 AS obshab, qualhab2 AS qualhab, s_hab2 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (hab2, obshab2, qualhab2, s_hab2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v1.id_ech, v1.id_point, 3 AS num_hab, hab3 AS hab, obshab3 AS obshab, qualhab3 AS qualhab, s_hab3 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (hab3, obshab3, qualhab3, s_hab3) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, right(q.donnee, 1) AS num_hab
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3habitat ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('HAB1', 'HAB2', 'HAB3', 'OBSHAB1', 'OBSHAB2', 'OBSHAB3', 'QUALHAB1', 'QUALHAB2', 'QUALHAB3', 'S_HAB1', 'S_HAB2', 'S_HAB3')
)
, json_final AS (
    SELECT id_ech, id_point, num_hab, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, num_hab
)
UPDATE inv_prod_new.habitat p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.num_hab = q.num_hab::INT2;

----------------------------------------------------------------------------------------------------------------------------------------
-- Table BOIS_MORT
INSERT INTO inv_prod_new.bois_mort (id_ech, id_point, a, espar, frepli, decomp, dbm_cm)
SELECT v1.id_ech, v1.id_point, a, espar, frepli, decomp, dbm_cm
FROM soif.v1e3boism vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (a, espar, frepli, decomp, dbm_cm) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3boism ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3BOISM'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'ESPAR', 'FREPLI', 'DECOMP', 'DBM_CM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.bois_mort p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE
INSERT INTO inv_prod_new.arbre (id_ech, id_point, a, c13_mm, suppl)
SELECT v1.id_ech, v1.id_point, a, c13_mm
, CASE 
    WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
    ELSE NULL
  END AS suppl
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (a, c13_mm, c13_inf_mm, c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND q.format = 'TV1E3ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'C13_MM', 'C13_INF_MM', 'C13_SUP_MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_2014
INSERT INTO inv_prod_new.arbre_2014 (id_ech, id_point, a, datearbre)
SELECT v1.id_ech, v1.id_point, a, datearbre
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (datearbre) IS DISTINCT FROM (NULL);

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Table SANTE
INSERT INTO inv_prod_new.sante (id_ech, id_point, a, mortb, sfgui, ma, mr)
SELECT v1.id_ech, v1.id_point, a, mortb, sfgui, ma, mr
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (mortb, sfgui, ma, mr) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MORTB', 'SFGUI', 'MA', 'MR')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.sante p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1
INSERT INTO inv_prod_new.arbre_m1 (id_ech, id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, suppl)
SELECT v1.id_ech, v1.id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm
, CASE WHEN (arbat) IS DISTINCT FROM (NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('arbat', arbat)) ELSE NULL END AS suppl
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, arbat) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND q.format = 'TV1E3ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'ORI', 'VEGET', 'ACCI', 'LIB', 'DPR_CM', 'AZPR_GD', 'HTOT_DM', 'REPERE', 'DECOUPE', 'HDEC_DM', 'SIMPLIF', 'CIBLE', 'DATEMORT'
        , 'QBP', 'HBV_DM', 'HBM_DM', 'HRB_DM', 'ARBAT')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1_2014
INSERT INTO inv_prod_new.arbre_m1_2014 (id_ech, id_point, a, deggib, ddec_cm, mes_c13, hcd_cm)
SELECT v1.id_ech, v1.id_point, a, deggib, ddec_cm, mes_c13, hcd_cm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (deggib, ddec_cm, mes_c13, hcd_cm) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DEGGIB', 'DDEC_CM', 'MES_C13', 'HCD_CM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1_2014 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

----------------------------------------------------------------------------------------------------------------------------------------------
-- Table ACCROISSEMENT
INSERT INTO inv_prod_new.accroissement (id_ech, id_point, a, nir, irn_1_10_mm)
SELECT v1.id_ech, v1.id_point, a, 0 AS nir, ir0_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir0_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 5 AS nir, ir5_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir5_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, ncern AS nir, irn_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (irn_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 1 AS nir, ir1_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir1_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 2 AS nir, ir2_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir2_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 3 AS nir, ir3_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir3_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 4 AS nir, ir4_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (ir4_1_10mm) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a, CASE WHEN q.donnee IN ('NCERN', 'IRN_1_10MM') THEN ve.ncern::text ELSE substr(q.donnee, 3, 1) END AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR0_1_10MM', 'IR5_1_10MM', 'IRN_1_10MM', 'NCERN')
    UNION 
    SELECT v1.id_ech, v1.id_point, a, substr(q.donnee, 3, 1) AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp
    INNER JOIN soif.v1e3arbre_age va ON ve.npp = va.npp AND ve.id_a = va.id_a  AND q.domaine = va.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR1_1_10MM', 'IR2_1_10MM', 'IR3_1_10MM', 'IR4_1_10MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, nir, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a, nir
)
UPDATE inv_prod_new.accroissement p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a
AND p.nir = q.nir::INT2;

/*
À ajouter à la main...
id_ech, id_point, a, nir = NULL, qual_data
48  1003815 4       {"note": "Perçage non possible, gros défaut", "donnee": "NCERN", "qdonnee": "CR4"}
*/

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table AGE
INSERT INTO inv_prod_new.age (id_ech, id_point, numa, a, typdom, age13, ncerncar, longcar, sfcoeur)
SELECT v1.id_ech, v1.id_point, vp.id_a, a, typdom, age13, ncerncar, longcar, sfcoeur
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vp.npp = v1.npp
WHERE v1.annee = 2024
AND (typdom, age13, ncerncar, longcar, sfcoeur) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, id_a AS numa
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre_age ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TYPDOM', 'AGE13', 'NCERNCAR', 'LONGCAR', 'SFCOEUR')
)
, json_final AS (
    SELECT id_ech, id_point, numa, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, numa
)
UPDATE inv_prod_new.age p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.numa = q.numa;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table FLA_LT
INSERT INTO inv_prod_new.fla_lt (id_ech, id_transect, sl_lt, rep, dseg_dm, optersl, tlhf2)
SELECT te.id_ech, te.id_transect, vl.sl, rep, dseg_dm, optersl, tlhf2
FROM inv_prod_new.transect_ech te
INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN' AND e.phase_stat = 2
INNER JOIN inv_prod_new.point p ON te.id_transect = p.id_transect
INNER JOIN soif.v1l2segment vl ON p.npp = vl.npp
INNER JOIN states ps ON vl.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vl.npp = v1.npp
WHERE v1.annee = 2024
AND (vl.rep, vl.dseg_dm, vl.optersl, vl.tlhf2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
ORDER BY te.id_ech, te.id_transect, vl.sl;

WITH quals AS(
    SELECT te.id_ech, te.id_transect, sl AS sl_lt
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1l2segment vl ON q.npp = vl.npp AND q.domaine = vl.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    INNER JOIN inv_prod_new.point p ON q.npp = p.npp
    INNER JOIN transect_ech te ON te.id_transect = p.id_transect
    INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN'AND e.phase_stat = 2
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('REP', 'DSEG_DM', 'OPTERSL', 'TLHF2')
)
, json_final AS (
    SELECT id_ech, id_transect, sl_lt, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_transect, sl_lt
)
UPDATE inv_prod_new.fla_lt p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_transect = q.id_transect
AND p.sl_lt = q.sl_lt;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table FLA
INSERT INTO inv_prod_new.fla (id_ech, id_transect, sl_lt, murl, largs, exploit, longdescr, entfl, azhaie_gd)
SELECT te.id_ech, te.id_transect, vl2.sl, murl, largs, exploit, longdescr, entfl, azhaie_gd
FROM inv_prod_new.transect_ech te
INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN' AND e.phase_stat = 2
INNER JOIN inv_prod_new.point p ON te.id_transect = p.id_transect
INNER JOIN soif.v1l3segment vl ON p.npp = vl.npp
INNER JOIN soif.v1l2segment vl2 ON vl.npp = vl2.npp AND vl.id_sl = vl2.id_sl
INNER JOIN states ps ON vl.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vl.npp = v1.npp
WHERE v1.annee = 2024
AND (murl, largs, exploit, longdescr, entfl, azhaie_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL)
ORDER BY te.id_ech, te.id_transect, vl2.sl;

WITH quals AS(
    SELECT te.id_ech, te.id_transect, sl AS sl_lt
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1l3segment vl ON q.npp = vl.npp AND q.domaine = vl.domaine
    INNER JOIN soif.v1l2segment vl2 ON vl.npp = vl2.npp AND vl.id_sl = vl2.id_sl
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    INNER JOIN inv_prod_new.point p ON q.npp = p.npp
    INNER JOIN transect_ech te ON te.id_transect = p.id_transect
    INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN' AND e.phase_stat = 2
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MURL', 'LARGS', 'EXPLOIT', 'LONGDESCR', 'ENTFL', 'AZHAIE_GD')
)
, json_final AS (
    SELECT id_ech, id_transect, sl_lt, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_transect, sl_lt
)
UPDATE inv_prod_new.fla p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_transect = q.id_transect
AND p.sl_lt = q.sl_lt;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_FLA
INSERT INTO inv_prod_new.arbre_fla (id_ech, id_transect, sl_lt, a, rep, espar, dpr_cm, azpr_gd, c13_mm, htot_dm, hdec_dm, decoupe, mortb, tetard, mes_c13)
SELECT te.id_ech, te.id_transect, vl2.sl, a, vl.rep, espar, dpr_cm, azpr_gd, c13_mm, htot_dm, hdec_dm, decoupe, mortb, tetard, mes_c13
FROM inv_prod_new.transect_ech te
INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN' AND e.phase_stat = 2
INNER JOIN inv_prod_new.point p ON te.id_transect = p.id_transect
INNER JOIN soif.v1l3arbre vl ON p.npp = vl.npp
INNER JOIN soif.v1l2segment vl2 ON vl.npp = vl2.npp AND vl.id_sl = vl2.id_sl
INNER JOIN states ps ON vl.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vl.npp = v1.npp
WHERE v1.annee = 2024
AND (a, vl.rep, espar, dpr_cm, azpr_gd, c13_mm, htot_dm, hdec_dm, decoupe, mortb, tetard, mes_c13) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
ORDER BY te.id_ech, te.id_transect, vl2.sl, a;

WITH quals AS(
    SELECT te.id_ech, te.id_transect, sl AS sl_lt, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1l3arbre vl ON q.npp = vl.npp AND q.domaine = vl.domaine
    INNER JOIN soif.v1l2segment vl2 ON vl.npp = vl2.npp AND vl.id_sl = vl2.id_sl
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON q.npp = v1.npp
    INNER JOIN inv_prod_new.point p ON q.npp = p.npp
    INNER JOIN transect_ech te ON te.id_transect = p.id_transect
    INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ue = 'T' AND e.type_ech = 'IFN' AND e.phase_stat = 2
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('REP', 'ESPAR', 'DPR_CM', 'AZPR_GD', 'C13_MM', 'HTOT_DM', 'HDEC_DM', 'DECOUPE', 'MORTB', 'TETARD', 'MES_C13')
)
, json_final AS (
    SELECT id_ech, id_transect, sl_lt, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_transect, sl_lt, a
)
UPDATE inv_prod_new.arbre_fla p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_transect = q.id_transect
AND p.sl_lt = q.sl_lt
AND p.a = q.a;
*/
DROP TABLE states;

COMMIT;

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- CHARGEMENT DES POINTS REVISITES
BEGIN;

CREATE TEMPORARY TABLE states AS (
	SELECT npp, MAX(state) AS state
	FROM soif.point_states
	WHERE anref = 2024
	GROUP BY npp
);

ALTER TABLE states ADD CONSTRAINT states_pkey PRIMARY KEY (npp);
ANALYZE states;

-------------------------------------------------------------------------------------------------------------------------------
--- Remplissage table AGENT_LT pour les points LT2
INSERT INTO agent_lt (id_ech, id_point, matricule, num_auteurlt)
	(
	SELECT v.id_ech, v.id_point, vp.auteurlt5 AS matricule, 1 AS num_auteurlt
	FROM soif.v2e4point vp
	INNER JOIN v_liste_points_lt2 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt5 IS NOT NULL 
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt5_2 AS matricule, 2 AS num_auteurlt
	FROM soif.v2e4point vp
	INNER JOIN v_liste_points_lt2 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt5_2 IS NOT NULL
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt5_3 AS matricule, 3 AS num_auteurlt
	FROM soif.v2e4point vp
	INNER JOIN v_liste_points_lt2 v USING (npp)
	WHERE v.annee = 2024 AND auteurlt5_3 IS NOT NULL
	);

-- Table POINT_LT --> auteurlt a été supprimé par la création de la table agent_lt
UPDATE inv_prod_new.point_lt pl
SET echelon = pd.echelon, datepoint = vp2.datepoint5, reco = vp2.reco5, datereco = vp2.datereco5, qreco = vp2.qreco5
, suppl = CASE WHEN ve2.pobs5 IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs5)) ELSE NULL END
FROM soif.v2e4point vp2
LEFT JOIN soif.v2e4observ ve2 ON vp2.npp = ve2.npp
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp AND pd.anref = v2.annee
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
WHERE v2.id_ech = pl.id_ech AND v2.id_point = pl.id_point
AND v2.annee = 2024;

/*
SELECT v2.id_ech, v2.id_point, vp2.npp, vp2.auteurlt5, pd.echelon, vp2.datepoint5, vp2.reco5, vp2.datereco5, vp2.qreco5
, CASE WHEN ve2.pobs5 IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs5)) ELSE NULL END AS suppl
FROM soif.v2e4point vp2
LEFT JOIN soif.v2e4observ ve2 ON vp2.npp = ve2.npp
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp AND pd.anref = v2.annee
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
WHERE v2.annee = 2024;
*/

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e4point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('AUTEURLT5', 'DATEPOINT5', 'RECO5', 'DATERECO5', 'QRECO5', 'POBS5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_lt p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------------
-- Table POINT_M2
INSERT INTO inv_prod_new.point_m2 (id_ech, id_point, pointok5)
SELECT v2.id_ech, v2.id_point, pointok5
FROM soif.v2e4point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
WHERE v2.annee = 2024
AND (vp2.pointok5) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e4point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('POINTOK5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_m2 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECONNAISSANCE
INSERT INTO inv_prod_new.reconnaissance (id_ech, id_point, csa, suppl)
SELECT v2.id_ech, v2.id_point, vp2.csa5
, CASE WHEN length(rtrim(err_p)) > 0 THEN JSONB_STRIP_NULLS(jsonb_build_object('err_p', err_p)) ELSE NULL END AS suppl
FROM soif.v2e4point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
WHERE v2.annee = 2024
AND (vp2.csa5) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e4point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CSA5', 'ERR_P')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reconnaissance p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------
-- Table RECO_2015
INSERT INTO inv_prod_new.reco_2015 (id_ech, id_point, utip, bois, doute_bois, autut, tauf, tform, eflt, qbois, leve, qleve)
SELECT v2.id_ech, v2.id_point, vp2.utip5, vp2.bois5, vp2.doute_bois5, vp2.autut5, vp2.tauf5, vp2.tform5, vp2.eflt5, vp2.qbois5, vp2.leve5, vp2.qleve5
FROM soif.v2e4point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
WHERE v2.annee = 2024
AND (vp2.utip5, vp2.bois5, vp2.doute_bois5, vp2.autut5, vp2.tauf5, vp2.tform5, vp2.eflt5, vp2.qbois5, vp2.leve5, vp2.qleve5) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e4point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('UTIP5', 'BOIS5', 'DOUTE_BOIS5', 'AUTUT5', 'TAUF5', 'TFORM5', 'EFLT5', 'QBOIS5', 'LEVE5', 'QLEVE5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_2015 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECO_M2
INSERT INTO inv_prod_new.reco_m2 (id_ech, id_point, evo_csa, evo_bois, evo_utip, def5)
SELECT v2.id_ech, v2.id_point, evo_csa5, evo_bois5, evo_utip5, def5
FROM soif.v2e4point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp2.npp = v2.npp
WHERE v2.annee = 2024
AND (evo_csa5, evo_bois5, evo_utip5, def5) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e4point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('EVO_CSA5', 'EVO_BOIS5', 'EVO_UTIP5', 'DEF5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_m2 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPTION
INSERT INTO inv_prod_new.description (id_ech, id_point, dc, incid, peupnr, sver, nincid, caracthab, tplant)
SELECT v2.id_ech, v2.id_point, dc5, incid5, peupnr5, sver5, nincid5, vh.caracthab, tplant5
FROM soif.v2e5point5 vp5
LEFT JOIN soif.v2e5point vp ON vp5.npp = vp.npp
LEFT JOIN soif.v2e5habitat vh ON vp5.npp = vh.npp
INNER JOIN states ps ON vp5.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp5.npp = v2.npp
WHERE v2.annee = 2024
AND (dc5, incid5, peupnr5, sver5, nincid5, caracthab, tplant5) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO inv_prod_new.description (id_ech, id_point, dc, incid, peupnr, sver, nincid, href_dm, caracthab, tplant, suppl)
SELECT v2.id_ech, v2.id_point, vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.caracthab, vp.tplant
, CASE 
    WHEN (vp.cam, vh.ligneriv, vp.entp) IS DISTINCT FROM  (NULL, NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('cam', vp.cam) || jsonb_build_object('ligneriv', vh.ligneriv) || jsonb_build_object('entp', vp.entp))
    ELSE NULL
  END AS suppl
FROM soif.v2e5point vp
LEFT JOIN soif.v2e5habitat vh ON vp.npp = vh.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.caracthab, vp.tplant, vh.ligneriv, vp.cam, vp.entp) IS DISTINCT FROM (NULL, NULL, null, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point5 ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DC5', 'INCID5', 'PEUPNR5', 'SVER5', 'NINCID5', 'CARACTHAB', 'TPLANT5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.description p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DC', 'INCID', 'PEUPNR', 'SVER', 'NINCID', 'HREF_DM', 'CARACTHAB', 'TPLANT', 'LIGNERIV', 'CAM', 'ENTP')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.description p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPT_M2
INSERT INTO inv_prod_new.descript_m2 (id_ech, id_point, nlisi5, instp5, evo_tplant)
SELECT v2.id_ech, v2.id_point, nlisi5, instp5, evo_tplant5
FROM soif.v2e5point5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (nlisi5, instp5, evo_tplant5) IS DISTINCT FROM (NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point5 ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('NLISI5', 'INSTP5', 'EVO_TPLANT5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.descript_m2 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPT_M1  --> suppression de abrou et transfert de tplant vers description
INSERT INTO inv_prod_new.descript_m1 (id_ech, id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr, bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil)
SELECT v2.id_ech, v2.id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain::boolean, plas25, plas15, deppr, bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil
FROM soif.v2e5point vp        --LEFT JOIN soif.v2e5habitat vh ON vp.npp = vh.npp
LEFT JOIN soif.v2e5nrpoint vn ON vp.npp = vn.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr, bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PLISI', 'CSLISI', 'DIST', 'TPLANT', 'GEST', 'INTEGR', 'ITI', 'PORTANCE', 'ASPERITE', 'PENTEXP', 'ANDAIN', 'PLAS25', 'PLAS15', 'DEPPR', 'BORD', 'ORNIERE', 'TCAT10', 'AZDEP_GD', 'DDEP_CM'
    ,'TCNR', 'ORNR', 'PRNR', 'DISPNR', 'PREDOM', 'FOUIL'))
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.descript_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table LIMITES
INSERT INTO inv_prod_new.limites (id_ech, id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd)
SELECT v2.id_ech, v2.id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd
FROM soif.v2e5point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DLIM_CM', 'DLIM2_CM', 'AZDLIM_GD', 'AZDLIM2_GD', 'DCOI_CM', 'AZDCOI_GD', 'AZLIM1_GD', 'AZLIM2_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.limites p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table COUPES
INSERT INTO inv_prod_new.coupes (id_ech, id_point, dcespar1)
SELECT v2.id_ech, v2.id_point, dcespar1
FROM soif.v2e5point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (dcespar1) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DCESPAR1')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.coupes p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------------------------------
-- Table BUIS  --> ajout de atpyr, ncbuis10, ncbuis_A à E, azdbuis_gd, et suppression de dpyr, anpyr
INSERT INTO inv_prod_new.buis (id_ech, id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd)
SELECT v2.id_ech, v2.id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd
FROM soif.v2e5point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PBUIS', 'ATPYR', 'NCBUIS10', 'NCBUIS_A', 'NCBUIS_B', 'NCBUIS_C', 'NCBUIS_D', 'NCBUIS_E', 'AZDBUIS_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.buis p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------
-- Table PLANTATIONS
INSERT INTO inv_prod_new.plantations (id_ech, id_point, bplant_dm, iplant_dm, tpespar1, tpespar2, videplant)
SELECT v2.id_ech, v2.id_point, bplant5_dm, iplant5_dm, tpespar15, tpespar25, videplant5
FROM soif.v2e5point5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (bplant5_dm, iplant5_dm, tpespar15, tpespar25, videplant5) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

INSERT INTO inv_prod_new.plantations (id_ech, id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag, suppl)
SELECT v2.id_ech, v2.id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag
, JSONB_STRIP_NULLS(jsonb_build_object('maille', maille)) AS suppl
FROM soif.v2e5plant vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag, maille) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5plant ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('BPLANT_DM', 'IPLANT_DM', 'VIDEPLANT', 'TPESPAR1', 'TPESPAR2', 'ELAG', 'MAILLE')
    UNION 
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point5 ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TPESPAR15', 'TPESPAR25', 'BPLANT5_DM', 'IPLANT5_DM', 'VIDEPLANT5')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.plantations p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------
-- Table COUV_R
INSERT INTO inv_prod_new.couv_r (id_ech, id_point, tcar10)
SELECT v2.id_ech, v2.id_point, tcar10
FROM soif.v2e5strate vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (tcar10) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5strate ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TCAR10')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.couv_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Table ESPAR_R
INSERT INTO inv_prod_new.espar_r (id_ech, id_point, espar, tcr10, tclr10, cible, p7ares)
SELECT v2.id_ech, v2.id_point, RTRIM(espar) AS espar, tcr10, tclr10, cible, p7ares
FROM soif.v2e5essence vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (espar, tcr10, tclr10, cible, p7ares) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, RTRIM(ve.espar) AS espar
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5essence ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ESSENCE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'TCR10', 'TCLR10', 'CIBLE', 'P7ARES')
)
, json_final AS (
    SELECT id_ech, id_point, espar, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, espar
)
UPDATE inv_prod_new.espar_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.espar = q.espar;

-------------------------------------------------------------------------------------------------------------------------------------------
-- Table RENOUV
INSERT INTO inv_prod_new.renouv (id_ech, id_point, nsnr, libnr_sp, pint_sp)
SELECT v2.id_ech, v2.id_point, 1 AS nsnr, libnr_sp1, pint_sp1
FROM soif.v2e5nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (libnr_sp1, pint_sp1) IS DISTINCT FROM (NULL, NULL)
UNION 
SELECT v2.id_ech, v2.id_point, 2 AS nsnr, libnr_sp2, pint_sp2
FROM soif.v2e5nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (libnr_sp2, pint_sp2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, 1 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP1', 'PINT_SP1')
    UNION
    SELECT v2.id_ech, v2.id_point, 2 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP2', 'PINT_SP2')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr
)
UPDATE inv_prod_new.renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr;

--------------------------------------------------------------------------------------------------------
-- Table ESPAR_RENOUV
INSERT INTO inv_prod_new.espar_renouv (id_ech, id_point, nsnr, espar, chnr, nint, nbrou, nfrot, nmixt)
SELECT v2.id_ech, v2.id_point, nsnr::INT2 AS nsnr, rtrim(espar) AS espar, chnr, nbint AS nint, nbrou, nfrot, nmixt
FROM soif.v2e5nrspot vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (nsnr, chnr, espar, nbint, nbrou, nfrot, nmixt) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, nsnr::INT2, RTRIM(ve.espar) AS espar, chnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5nrspot ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV1E3NRSPOT'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('NSNR', 'ESPAR', 'CHNR', 'NINT', 'NBROU', 'NFROT', 'NMIXT')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, espar, chnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr, espar, chnr
)
UPDATE inv_prod_new.espar_renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr
AND p.espar = q.espar
AND p.chnr = q.chnr;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE
INSERT INTO inv_prod_new.ecologie (id_ech, id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc, roche, cailloux, cai40, text1, text2, 
    prof1, prof2, pcalc, pcalf, pox, ppseudo, pgley, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo)
SELECT v2.id_ech, v2.id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo
FROM soif.v2e5ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DATEECO', 'AUTEUREF', 'AZ_FO', 'DI_FO_CM', 'PENT2', 'TOPO', 'MASQUE', 'HERB', 'ST_A1', 'HUMUS', 'AFFROC', 'ROCHE', 'CAILLOUX', 'CAI40', 'TEXT1', 'TEXT2', 
    'PROF1', 'PROF2', 'PCALC', 'PCALF', 'POX', 'PPSEUDO', 'PGLEY', 'TSOL', 'OBSDATE', 'OBSHYDR', 'OBSPEDO', 'OBSPROF', 'OBSTOPO', 'OBSVEGET', 'OBSCHEMIN', 'MOUSSE', 'DISTRIV', 'DENIVRIV', 'EXPO')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE_2017
INSERT INTO inv_prod_new.ecologie_2017 (id_ech, id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext)
SELECT v2.id_ech, v2.id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext
FROM soif.v2e5ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (msud, oln, olv, olt, ofr, oh, typriv, typcai, htext) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MSUD', 'OLN', 'OLV', 'OLT', 'OFR', 'OH', 'TYPRIV', 'TYPCAI', 'HTEXT')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie_2017 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------
/*-- Table LIGNEUX
INSERT INTO inv_prod_new.ligneux (id_ech, id_point, lign1, lign2)
SELECT v2.id_ech, v2.id_point, lign15, lign25
FROM soif.v2e5point5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (lign15, lign25) IS DISTINCT FROM (NULL, NULL);*/

INSERT INTO inv_prod_new.ligneux (id_ech, id_point, lign1, lign2)
SELECT v2.id_ech, v2.id_point, lign1, lign2
FROM soif.v2e5ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (lign1, lign2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIGN1', 'LIGN2')
/*    UNION 
    SELECT v2.id_ech, v2.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5point5 ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIGN15', 'LIGN25')*/
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ligneux p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------
-- Table FLORE
INSERT INTO inv_prod_new.flore (id_ech, id_point, codesp, abond, inco_flor)
SELECT v2.id_ech, v2.id_point, codesp, abond::int2, inco_flor
FROM soif.v2e5flore vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (codesp, abond, inco_flor) IS DISTINCT FROM (NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, codesp
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5flore ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2%'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CODESP', 'ABOND', 'INCO_FLOR')
)
, json_final AS (
    SELECT id_ech, id_point, codesp, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, codesp
)
UPDATE inv_prod_new.flore p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.codesp = q.codesp;

--------------------------------------------------------------------------------------------------
-- Table HABITAT
INSERT INTO inv_prod_new.habitat (id_ech, id_point, num_hab, hab, obshab, qualhab, s_hab)
SELECT v2.id_ech, v2.id_point, 1 AS num_hab, hab1 AS hab, obshab1 AS obshab, qualhab1 AS qualhab, s_hab1 AS s_hab
FROM soif.v2e5habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (hab1, obshab1, qualhab1, s_hab1) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, 2 AS num_hab, hab2 AS hab, obshab2 AS obshab, qualhab2 AS qualhab, s_hab2 AS s_hab
FROM soif.v2e5habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (hab2, obshab2, qualhab2, s_hab2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, 3 AS num_hab, hab3 AS hab, obshab3 AS obshab, qualhab3 AS qualhab, s_hab3 AS s_hab
FROM soif.v2e5habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (hab3, obshab3, qualhab3, s_hab3) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, right(q.donnee, 1) AS num_hab
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5habitat ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('HAB1', 'HAB2', 'HAB3', 'OBSHAB1', 'OBSHAB2', 'OBSHAB3', 'QUALHAB1', 'QUALHAB2', 'QUALHAB3', 'S_HAB1', 'S_HAB2', 'S_HAB3')
)
, json_final AS (
    SELECT id_ech, id_point, num_hab, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, num_hab
)
UPDATE inv_prod_new.habitat p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.num_hab = q.num_hab::int2;

------------------------------------------------------------------------------------------------------------------------------------------------
-- Table BOIS_MORT
INSERT INTO inv_prod_new.bois_mort (id_ech, id_point, a, espar, frepli, decomp, dbm_cm)
SELECT v2.id_ech, v2.id_point, a, espar, frepli, decomp, dbm_cm
FROM soif.v2e5boism vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (a, espar, frepli, decomp, dbm_cm) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5boism ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format LIKE 'TV2E5BOISM'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'ESPAR', 'FREPLI', 'DECOMP', 'DBM_CM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.bois_mort p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-----------------------------------------------------------------------------------------------------------------------
-- Table ARBRE
INSERT INTO inv_prod_new.arbre (id_ech, id_point, a, c13_mm, suppl)
SELECT v2.id_ech, v2.id_point, a, c135_mm, NULL
FROM soif.v2e5arbre5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (a, c135_mm) IS DISTINCT FROM (NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, c13_mm
, CASE 
    WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
    ELSE NULL
  END AS suppl
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (a, c13_mm, c13_inf_mm, c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, c13_mm, NULL
FROM soif.v2e5arbre_new5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (a, c13_mm) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'C135_MM')
    UNION
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'C13_MM', 'C13_INF_MM', 'C13_SUP_MM')
    UNION
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre_new5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE_NEW5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'C13_MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_2014
INSERT INTO inv_prod_new.arbre_2014 (id_ech, id_point, a, datearbre)
SELECT v2.id_ech, v2.id_point, a, datearbre5
FROM soif.v2e5arbre5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (datearbre5) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, datearbre
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (datearbre) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, datearbre
FROM soif.v2e5arbre_new5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (datearbre) IS DISTINCT FROM (NULL);

---------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M2
INSERT INTO inv_prod_new.arbre_m2 (id_ech, id_point, a, veget5, mes_c135, suppl)
SELECT v2.id_ech, v2.id_point, a, veget5, mes_c135
, CASE WHEN (typerr_a) IS DISTINCT FROM (NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('typerr_a', typerr_a)) ELSE NULL END AS suppl
FROM soif.v2e5arbre5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (veget5, mes_c135, typerr_a) 
    IS DISTINCT FROM (NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('VEGET5', 'MES_C135', 'TYPERR_A')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m2 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

--------------------------------------------------------------------------------------------------------------------------------------
-- Table SANTE
INSERT INTO inv_prod_new.sante (id_ech, id_point, a, mortb, sfgui, ma, mr)
SELECT v2.id_ech, v2.id_point, a, NULL::char(1) AS mortb, sfgui5, NULL::char(1) AS ma, NULL::char(1) AS mr
FROM soif.v2e5arbre5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (mortb5, sfgui5) IS DISTINCT FROM (NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, mortb, sfgui, ma, mr
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (mortb, sfgui, ma, mr) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('SFGUI5')
    UNION 
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MORTB', 'SFGUI', 'MA', 'MR')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.sante p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1
INSERT INTO inv_prod_new.arbre_m1 (id_ech, id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, suppl)
SELECT v2.id_ech, v2.id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm
, CASE WHEN (arbat) IS DISTINCT FROM (NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('arbat', arbat)) ELSE NULL END AS suppl
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, arbat) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, NULL AS repere, decoupe, hdec_dm, NULL AS simplif, cible, NULL AS datemort, NULL AS qbp, NULL AS hbv_dm, NULL AS hbm_dm, NULL AS hrb_dm
, NULL AS suppl
FROM soif.v2e5arbre_new5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, decoupe, hdec_dm, cible) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'ORI', 'VEGET', 'ACCI', 'LIB', 'DPR_CM', 'AZPR_GD', 'HTOT_DM', 'REPERE', 'DECOUPE', 'HDEC_DM', 'SIMPLIF', 'CIBLE', 'DATEMORT'
        , 'QBP', 'HBV_DM', 'HBM_DM', 'HRB_DM', 'ARBAT')
    UNION 
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre_new5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE_NEW5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'ORI', 'VEGET', 'ACCI', 'LIB', 'DPR_CM', 'AZPR_GD', 'HTOT_DM', 'DECOUPE', 'HDEC_DM', 'CIBLE')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1_2014
INSERT INTO inv_prod_new.arbre_m1_2014 (id_ech, id_point, a, deggib, ddec_cm, mes_c13, hcd_cm, agrafc)
SELECT v2.id_ech, v2.id_point, a, deggib, ddec_cm, mes_c13, hcd_cm, NULL AS agrafc
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (deggib, ddec_cm, mes_c13, hcd_cm) IS DISTINCT FROM (null, NULL, NULL, NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, NULL AS deggib, ddec_cm AS ddec_cm, mes_c13, NULL AS hcd_cm, vp.agrafc
FROM soif.v2e5arbre_new5 vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (mes_c13, agrafc) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DEGGIB', 'DDEC_CM', 'MES_C13', 'AGRAFC')
    UNION 
    SELECT v2.id_ech, v2.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre_new5 ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE_NEW5'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MES_C13', 'AGRAFC')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1_2014 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-------------------------------------------------------------------------------------------------------------------
-- Table ACCROISSEMENT
INSERT INTO inv_prod_new.accroissement (id_ech, id_point, a, nir, irn_1_10_mm)
SELECT v2.id_ech, v2.id_point, a, 0 AS nir, ir0_1_10mm
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir0_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, 5 AS nir, ir5_1_10mm
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir5_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, ncern AS nir, irn_1_10mm
FROM soif.v2e5arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (irn_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, 1 AS nir, ir1_1_10mm
FROM soif.v2e5arbre_age vp
INNER JOIN soif.v2e5arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir1_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, 2 AS nir, ir2_1_10mm
FROM soif.v2e5arbre_age vp
INNER JOIN soif.v2e5arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir2_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, 3 AS nir, ir3_1_10mm
FROM soif.v2e5arbre_age vp
INNER JOIN soif.v2e5arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir3_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v2.id_ech, v2.id_point, a, 4 AS nir, ir4_1_10mm
FROM soif.v2e5arbre_age vp
INNER JOIN soif.v2e5arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (ir4_1_10mm) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, a, CASE WHEN q.donnee IN ('NCERN', 'IRN_1_10MM') THEN ve.ncern::text ELSE substr(q.donnee, 3, 1) END AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR0_1_10MM', 'IR5_1_10MM', 'IRN_1_10MM', 'NCERN')
    UNION 
    SELECT v2.id_ech, v2.id_point, a, substr(q.donnee, 3, 1) AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre ve ON q.npp = ve.npp
    INNER JOIN soif.v2e5arbre_age va ON ve.npp = va.npp AND ve.id_a = va.id_a  AND q.domaine = va.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND q.format = 'TV2E5ARBRE_AGE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR1_1_10MM', 'IR2_1_10MM', 'IR3_1_10MM', 'IR4_1_10MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, nir, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a, nir
)
UPDATE inv_prod_new.accroissement p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a
AND p.nir = q.nir::int2;

----------------------------------------------------------------------------------------------------------------
-- Table AGE
INSERT INTO inv_prod_new.age (id_ech, id_point, numa, a, typdom, age13, ncerncar, longcar, sfcoeur)
SELECT v2.id_ech, v2.id_point, vp.id_a, a, typdom, age13, ncerncar, longcar, sfcoeur
FROM soif.v2e5arbre_age vp
INNER JOIN soif.v2e5arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
WHERE v2.annee = 2024
AND (typdom, age13, ncerncar, longcar, sfcoeur) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v2.id_ech, v2.id_point, id_a AS numa
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v2e5arbre_age ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON q.npp = v2.npp
    WHERE v2.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TYPDOM', 'AGE13', 'NCERNCAR', 'LONGCAR', 'SFCOEUR')
)
, json_final AS (
    SELECT id_ech, id_point, numa, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, numa
)
UPDATE inv_prod_new.age p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.numa = q.numa;

DROP TABLE states;

COMMIT;

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- CHARGEMENT DES POINTS REVISITES PI
BEGIN;

CREATE TEMPORARY TABLE states AS (
	SELECT npp, MAX(state) AS state
	FROM soif.point_states
	WHERE anref = 2024
	GROUP BY npp
);

ALTER TABLE states ADD CONSTRAINT states_pkey PRIMARY KEY (npp);
ANALYZE states;

--------------------------------------------------------------------------------------------------------------------------------------
--- Remplissage table AGENT_LT pour les points LT1_PI2
INSERT INTO agent_lt (id_ech, id_point, matricule, num_auteurlt)
	(
	SELECT v.id_ech, v.id_point, vp.auteurlt AS matricule, 1 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1_pi2 v ON vp.npp = v.nppr
	WHERE v.annee = 2024 AND auteurlt IS NOT NULL 
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt_2 AS matricule, 2 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1_pi2 v ON vp.npp = v.nppr
	WHERE v.annee = 2024 AND auteurlt_2 IS NOT NULL
	UNION
	SELECT v.id_ech, v.id_point, vp.auteurlt_3 AS matricule, 3 AS num_auteurlt
	FROM soif.v1e2point vp
	INNER JOIN v_liste_points_lt1_pi2 v ON vp.npp = v.nppr
	WHERE v.annee = 2024 AND auteurlt_3 IS NOT NULL
	);

-- Table POINT_LT  -- AUTEURLT a été supprimé
UPDATE inv_prod_new.point_lt pl
SET echelon = pd.echelon, datepoint = vp2.datepoint, reco = vp2.reco, datereco = vp2.datereco, qreco = vp2.qreco
, suppl = CASE WHEN ve2.pobs IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs)) ELSE NULL END
FROM soif.v1e2point vp2
LEFT JOIN soif.v1e2observ ve2 ON vp2.npp = ve2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.id_ech = pl.id_ech AND v1.id_point = pl.id_point
AND v1.annee = 2024;

/*
SELECT v1.id_ech, v1.id_point, vp2.npp, vp2.auteurlt, pd.echelon, vp2.datepoint, vp2.reco, vp2.datereco, vp2.qreco
, CASE WHEN ve2.pobs IS NOT NULL THEN JSONB_STRIP_NULLS(jsonb_build_object('pobs', ve2.pobs)) ELSE NULL END AS suppl
FROM soif.v1e2point vp2
LEFT JOIN soif.v1e2observ ve2 ON vp2.npp = ve2.npp
INNER JOIN soif.point_dir pd ON vp2.npp = pd.npp
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.annee = 2024;
*/

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('AUTEURLT', 'DATEPOINT', 'RECO', 'DATERECO', 'QRECO', 'POBS')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_lt p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

/*
SELECT v1.npp
FROM inv_prod_new.v_liste_points_lt1 v1
INNER JOIN inv_prod_new.point_lt pl USING (id_ech, id_point)
WHERE v1.annee = 2024
AND pl.datepoint IS NULL; --> 0 pts
*/

-----------------------------------------------------------------------------------------------------------------
-- Table POINT_M1
INSERT INTO inv_prod_new.point_m1 (id_ech, id_point, duracc, posipr, pclos, pdiff)
SELECT v1.id_ech, v1.id_point, vp2.duracc, vp2.posipr, vp2.pclos, vp2.pdiff
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.annee = 2024
AND (vp2.duracc, vp2.posipr, vp2.pclos, vp2.pdiff) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DURACC', 'POSIPR', 'PCLOS', 'PDIFF')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.point_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECONNAISSANCE
INSERT INTO inv_prod_new.reconnaissance (id_ech, id_point, csa, obscsa)
SELECT v1.id_ech, v1.id_point, vp2.csa, vp2.obscsa
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.annee = 2024
AND (vp2.csa, vp2.obscsa) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CSA', 'OBSCSA')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reconnaissance p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Table RECO_2015
INSERT INTO inv_prod_new.reco_2015 (id_ech, id_point, utip, bois, doute_bois, autut, tauf, tform, eflt, rp, azrp_gd, drp_cm, qbois, vegrp, esprp, c13rp_mm, leve, qleve)
SELECT v1.id_ech, v1.id_point, vp2.utip, vp2.bois, vp2.doute_bois, vp2.autut, vp2.tauf, vp2.tform, vp2.eflt, vp2.rp, vp2.azrp_gd, vp2.drp_cm, vp2.qbois, vp2.vegrp, vp2.esprp, vp2.c13rp_mm
, vp2.leve, vp2.qleve
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.annee = 2024
AND (vp2.utip, vp2.bois, vp2.doute_bois, vp2.autut, vp2.tauf, vp2.tform, vp2.eflt, vp2.rp, vp2.azrp_gd, vp2.drp_cm, vp2.qbois, vp2.vegrp, vp2.esprp, vp2.c13rp_mm, vp2.leve, vp2.qleve) 
IS DISTINCT FROM (NULL, null, null, null, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('UTIP', 'BOIS', 'DOUTE_BOIS', 'AUTUT', 'TAUF', 'TFORM', 'EFLT', 'RP', 'AZRP_GD', 'DRP_CM', 'QBOIS','VEGRP', 'ESPRP', 'C13RP_MM', 'LEVE', 'QLEVE')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_2015 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

/*--------- RECO_M1 n'existe plus ---------------------------------------
-------------------------------------------------------------------------
-- Table RECO_M1
INSERT INTO inv_prod_new.reco_m1 (id_ech, id_point, leve, qleve)
SELECT v1.id_ech, v1.id_point, vp2.leve, vp2.qleve
FROM soif.v1e2point vp2
INNER JOIN states ps ON vp2.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp2.npp = v1.nppr
WHERE v1.annee = 2024
AND (vp2.leve, vp2.qleve) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e2point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LEVE', 'QLEVE')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.reco_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;
*/
-------------------------------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPTION  -> ajout de TPLANT (transféré depuis DESCRIPT_M1), ajout de tplant
INSERT INTO inv_prod_new.description (id_ech, id_point, dc, incid, peupnr, sver, nincid, href_dm, caracthab, tplant, suppl)
SELECT v1.id_ech, v1.id_point, vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.caracthab, vp.tplant
, CASE 
  WHEN (vp.cam, vh.ligneriv, vp.entp) IS DISTINCT FROM  (NULL, NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('cam', vp.cam) || jsonb_build_object('ligneriv', vh.ligneriv) || jsonb_build_object('entp', vp.entp))
    ELSE NULL
  END AS suppl
FROM soif.v1e3point vp
LEFT JOIN soif.v1e3habitat vh ON vp.npp = vh.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (vp.dc, vp.incid, vp.peupnr, vp.sver, vp.nincid, vp.href_dm, vh.caracthab, vp.tplant, vh.ligneriv, vp.cam, vp.entp) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DC', 'INCID', 'PEUPNR', 'SVER', 'NINCID', 'HREF_DM', 'CARACTHAB', 'TPLANT', 'CAM', 'LIGNERIV', 'ENTP')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.description p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table DESCRIPT_M1 --> suppression de TPLANT et de ABROU, ajout de tcnr, ornr, prnr, dispnr, predom, fouil
-- ALTER TABLE descript_m1 DROP  COLUMN abrou;
-- ALTER TABLE descript_m1 ALTER COLUMN tcnr TYPE varchar(2); --> tcnr est de TYPE varchar(2) dans soif

INSERT INTO inv_prod_new.descript_m1 (id_ech, id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr,
bord, orniere, tcat10, azdep_gd, ddep_cm, tcnr, ornr, prnr, dispnr, predom, fouil)
SELECT v1.id_ech, v1.id_point, plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain::boolean, plas25, plas15, deppr,
bord, orniere, tcat10, azdep_gd, ddep_cm, vn.tcnr, vn.ornr, vn.prnr, vn.dispnr, vn.predom, vn.fouil
FROM soif.v1e3point vp
LEFT JOIN soif.v1e3habitat vh ON vp.npp = vh.npp
LEFT JOIN soif.v1e3nrpoint vn ON vp.npp = vn.npp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (plisi, cslisi, dist, gest, integr, iti, portance, asperite, pentexp, andain, plas25, plas15, deppr, bord, orniere, abrou, tcat10, azdep_gd, ddep_cm,
tcnr, ornr, prnr, dispnr, predom, fouil) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PLISI', 'CSLISI', 'DIST', 'GEST', 'INTEGR', 'ITI', 'PORTANCE', 'ASPERITE', 'PENTEXP', 'ANDAIN', 'PLAS25', 'PLAS15', 'DEPPR', 'BORD', 'ORNIERE', 'TCAT10', 'AZDEP_GD', 'DDEP_CM',
    'TCNR', 'ORNR', 'PRNR', 'DISPNR', 'PREDOM', 'FOUIL')
	)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.descript_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table LIMITES
INSERT INTO inv_prod_new.limites (id_ech, id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd)
SELECT v1.id_ech, v1.id_point, dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (dlim_cm, dlim2_cm, azdlim_gd, azdlim2_gd, dcoi_cm, azdcoi_gd, azlim1_gd, azlim2_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DLIM_CM', 'DLIM2_CM', 'AZDLIM_GD', 'AZDLIM2_GD', 'DCOI_CM', 'AZDCOI_GD', 'AZLIM1_GD', 'AZLIM2_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.limites p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------------
-- Table COUPES
INSERT INTO inv_prod_new.coupes (id_ech, id_point, dcespar1)
SELECT v1.id_ech, v1.id_point, dcespar1
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (dcespar1) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DCESPAR1')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.coupes p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table BUIS  --> ajout de atpyr, ncbuis10, ncbuis_A à E, azdbuis_gd, et suppression de dpyr, anpyr
INSERT INTO inv_prod_new.buis (id_ech, id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd)
SELECT v1.id_ech, v1.id_point, pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd
FROM soif.v1e3point vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (pbuis, atpyr, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, azdbuis_gd) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3point ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('PBUIS', 'ATPYR', 'NCBUIS10', 'NCBUIS_A', 'NCBUIS_B', 'NCBUIS_C', 'NCBUIS_D', 'NCBUIS_E', 'AZDBUIS_GD')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.buis p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------
-- Table PLANTATIONS
INSERT INTO inv_prod_new.plantations (id_ech, id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag, suppl)
SELECT v1.id_ech, v1.id_point, bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag
, JSONB_STRIP_NULLS(jsonb_build_object('maille', maille)) AS suppl
FROM soif.v1e3plant vp
--INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (bplant_dm, iplant_dm, videplant, tpespar1, tpespar2, elag) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3plant ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('BPLANT_DM', 'IPLANT_DM', 'VIDEPLANT', 'TPESPAR1', 'TPESPAR2', 'ELAG')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.plantations p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

----------------------------------------------------------------------------------------------------------------------------------------
-- Table COUV_R
INSERT INTO inv_prod_new.couv_r (id_ech, id_point, tcar10)
SELECT v1.id_ech, v1.id_point, tcar10
FROM soif.v1e3strate vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (tcar10) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3strate ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TCAR10')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.couv_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-----------------------------------------------------------------------------------------------------------------------
-- Table ESPAR_R
INSERT INTO inv_prod_new.espar_r (id_ech, id_point, espar, tcr10, tclr10, cible, p7ares)
SELECT v1.id_ech, v1.id_point, RTRIM(espar) AS espar, tcr10, tclr10, cible, p7ares
FROM soif.v1e3essence vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (espar, tcr10, tclr10, cible, p7ares) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, RTRIM(ve.espar) AS espar
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3essence ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3ESSENCE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'TCR10', 'TCLR10', 'CIBLE', 'P7ARES')
)
, json_final AS (
    SELECT id_ech, id_point, espar, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, espar
)
UPDATE inv_prod_new.espar_r p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.espar = q.espar;

-------------------------------------------------------------------------------------------------------------------------------------------
-- Table RENOUV
INSERT INTO inv_prod_new.renouv (id_ech, id_point, nsnr, libnr_sp, pint_sp)
SELECT v1.id_ech, v1.id_point, 1 AS nsnr, libnr_sp1, pint_sp1
FROM soif.v1e3nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (libnr_sp1, pint_sp1) IS DISTINCT FROM (NULL, NULL)
UNION 
SELECT v1.id_ech, v1.id_point, 2 AS nsnr, libnr_sp2, pint_sp2
FROM soif.v1e3nrpoint vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (libnr_sp2, pint_sp2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, 1 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP1', 'PINT_SP1')
    UNION
    SELECT v1.id_ech, v1.id_point, 2 AS nsnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', LEFT(RTRIM(COALESCE(f."attribute", q.donnee)), -1)) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrpoint ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIBNR_SP2', 'PINT_SP2')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr
)
UPDATE inv_prod_new.renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr;

--------------------------------------------------------------------------------------------------------
-- Table ESPAR_RENOUV
INSERT INTO inv_prod_new.espar_renouv (id_ech, id_point, nsnr, espar, chnr, nint, nbrou, nfrot, nmixt)
SELECT v1.id_ech, v1.id_point, nsnr::INT2 AS nsnr, rtrim(espar) AS espar, chnr, nbint AS nint, nbrou, nfrot, nmixt
FROM soif.v1e3nrspot vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (nsnr, chnr, espar, nbint, nbrou, nfrot, nmixt) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, nsnr::INT2, RTRIM(ve.espar) AS espar, chnr
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3nrspot ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3NRSPOT'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('NSNR', 'ESPAR', 'CHNR', 'NINT', 'NBROU', 'NFROT', 'NMIXT')
)
, json_final AS (
    SELECT id_ech, id_point, nsnr, espar, chnr, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, nsnr, espar, chnr
)
UPDATE inv_prod_new.espar_renouv p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.nsnr = q.nsnr
AND p.espar = q.espar
AND p.chnr = q.chnr;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE
INSERT INTO inv_prod_new.ecologie (id_ech, id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc, roche, cailloux, cai40, text1, text2, 
    prof1, prof2, pcalc, pcalf, pox, ppseudo, pgley, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo)
SELECT v1.id_ech, v1.id_point, dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (dateeco, auteuref, az_fo, di_fo_cm, pent2, topo, masque, herb, st_a1, humus, affroc_2017, roche, cailloux_2017, cai40_2017, text1, text2, 
    prof1, prof2, pcalc_2017, pcalf_2017, pox_2017, ppseudo_2017, pgley_2017, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv, expo) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DATEECO', 'AUTEUREF', 'AZ_FO', 'DI_FO_CM', 'PENT2', 'TOPO', 'MASQUE', 'HERB', 'ST_A1', 'HUMUS', 'AFFROC', 'ROCHE', 'CAILLOUX', 'CAI40', 'TEXT1', 'TEXT2', 
    'PROF1', 'PROF2', 'PCALC', 'PCALF', 'POX', 'PPSEUDO', 'PGLEY', 'TSOL', 'OBSDATE', 'OBSHYDR', 'OBSPEDO', 'OBSPROF', 'OBSTOPO', 'OBSVEGET', 'OBSCHEMIN', 'MOUSSE', 'DISTRIV', 'DENIVRIV', 'EXPO')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

---------------------------------------------------------------------------------------------------------------------
-- Table ECOLOGIE_2017
INSERT INTO inv_prod_new.ecologie_2017 (id_ech, id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext)
SELECT v1.id_ech, v1.id_point, msud, oln, olv, olt, ofr, oh, typriv, typcai, htext
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (msud, oln, olv, olt, ofr, oh, typriv, typcai, htext) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MSUD', 'OLN', 'OLV', 'OLT', 'OFR', 'OH', 'TYPRIV', 'TYPCAI', 'HTEXT')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ecologie_2017 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

-------------------------------------------------------------------------------------------------------------
-- Table LIGNEUX
INSERT INTO inv_prod_new.ligneux (id_ech, id_point, lign1, lign2)
SELECT v1.id_ech, v1.id_point, lign1, lign2
FROM soif.v1e3ecologie vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (lign1, lign2) IS DISTINCT FROM (NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3ecologie ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('LIGN1', 'LIGN2')
)
, json_final AS (
    SELECT id_ech, id_point, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point
)
UPDATE inv_prod_new.ligneux p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point;

------------------------------------------------------------------------------------------------------------------------------------
-- Table FLORE
INSERT INTO inv_prod_new.flore (id_ech, id_point, codesp, abond, inco_flor)
SELECT v1.id_ech, v1.id_point, codesp, abond::int2, inco_flor
FROM soif.v1e3flore vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (codesp, abond, inco_flor) IS DISTINCT FROM (NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, codesp
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3flore ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('CODESP', 'ABOND', 'INCO_FLOR')
)
, json_final AS (
    SELECT id_ech, id_point, codesp, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, codesp
)
UPDATE inv_prod_new.flore p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.codesp = q.codesp;

-----------------------------------------------------------------------------------------------------------------------------
-- Table HABITAT
INSERT INTO inv_prod_new.habitat (id_ech, id_point, num_hab, hab, obshab, qualhab, s_hab)
SELECT v1.id_ech, v1.id_point, 1 AS num_hab, hab1 AS hab, obshab1 AS obshab, qualhab1 AS qualhab, s_hab1 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (hab1, obshab1, qualhab1, s_hab1) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v1.id_ech, v1.id_point, 2 AS num_hab, hab2 AS hab, obshab2 AS obshab, qualhab2 AS qualhab, s_hab2 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (hab2, obshab2, qualhab2, s_hab2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
UNION
SELECT v1.id_ech, v1.id_point, 3 AS num_hab, hab3 AS hab, obshab3 AS obshab, qualhab3 AS qualhab, s_hab3 AS s_hab
FROM soif.v1e3habitat vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (hab3, obshab3, qualhab3, s_hab3) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, right(q.donnee, 1) AS num_hab
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3habitat ve ON q.npp = ve.npp
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('HAB1', 'HAB2', 'HAB3', 'OBSHAB1', 'OBSHAB2', 'OBSHAB3', 'QUALHAB1', 'QUALHAB2', 'QUALHAB3', 'S_HAB1', 'S_HAB2', 'S_HAB3')
)
, json_final AS (
    SELECT id_ech, id_point, num_hab, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, num_hab
)
UPDATE inv_prod_new.habitat p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.num_hab = q.num_hab::int2;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Table BOIS_MORT
INSERT INTO inv_prod_new.bois_mort (id_ech, id_point, a, espar, frepli, decomp, dbm_cm)
SELECT v1.id_ech, v1.id_point, a, espar, frepli, decomp, dbm_cm
FROM soif.v1e3boism vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (a, espar, frepli, decomp, dbm_cm) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3boism ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND q.format LIKE 'TV1E3BOISM'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'ESPAR', 'FREPLI', 'DECOMP', 'DBM_CM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.bois_mort p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE
INSERT INTO inv_prod_new.arbre (id_ech, id_point, a, c13_mm, suppl)
SELECT v1.id_ech, v1.id_point, a, c13_mm
, CASE 
    WHEN (c13_inf_mm, c13_sup_mm) IS DISTINCT FROM  (NULL, NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('c13_inf_mm', c13_inf_mm) || jsonb_build_object('c13_sup_mm', c13_sup_mm))
    ELSE NULL
  END AS suppl
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (a, c13_mm, c13_inf_mm, c13_sup_mm) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND q.format = 'TV1E3ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('A', 'C13_MM', 'C13_INF_MM', 'C13_SUP_MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-----------------------------------------------------------------------------------------------------------------
-- Table ARBRE_2014
INSERT INTO inv_prod_new.arbre_2014 (id_ech, id_point, a, datearbre)
SELECT v1.id_ech, v1.id_point, a, datearbre
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (datearbre) IS DISTINCT FROM (NULL);

--------------------------------------------------------------------------------------------------
-- Table SANTE
INSERT INTO inv_prod_new.sante (id_ech, id_point, a, mortb, sfgui, ma, mr)
SELECT v1.id_ech, v1.id_point, a, mortb, sfgui, ma, mr
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (mortb, sfgui, ma, mr) IS DISTINCT FROM (NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('MORTB', 'SFGUI', 'MA', 'MR')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.sante p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1
INSERT INTO inv_prod_new.arbre_m1 (id_ech, id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, suppl)
SELECT v1.id_ech, v1.id_point, a, espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm
, CASE WHEN (arbat) IS DISTINCT FROM (NULL) THEN JSONB_STRIP_NULLS(jsonb_build_object('arbat', arbat)) ELSE NULL END AS suppl
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (espar, ori, veget, acci, lib, dpr_cm, azpr_gd, htot_dm, repere, decoupe, hdec_dm, simplif, cible, datemort, qbp, hbv_dm, hbm_dm, hrb_dm, arbat) 
    IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND q.format = 'TV1E3ARBRE'
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('ESPAR', 'ORI', 'VEGET', 'ACCI', 'LIB', 'DPR_CM', 'AZPR_GD', 'HTOT_DM', 'REPERE', 'DECOUPE', 'HDEC_DM', 'SIMPLIF', 'CIBLE', 'DATEMORT'
        , 'QBP', 'HBV_DM', 'HBM_DM', 'HRB_DM', 'ARBAT')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Table ARBRE_M1_2014
INSERT INTO inv_prod_new.arbre_m1_2014 (id_ech, id_point, a, deggib, ddec_cm, mes_c13, hcd_cm)
SELECT v1.id_ech, v1.id_point, a, deggib, ddec_cm, mes_c13, hcd_cm 
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (deggib, ddec_cm, mes_c13, hcd_cm) IS DISTINCT FROM (NULL, NULL, null, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('DEGGIB', 'DDEC_CM', 'MES_C13', 'HCD_CM')
)
, json_final AS (
    SELECT id_ech, id_point, a, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a
)
UPDATE inv_prod_new.arbre_m1_2014 p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a;

----------------------------------------------------------------------------------------------------------------------------------
-- Table ACCROISSEMENT
INSERT INTO inv_prod_new.accroissement (id_ech, id_point, a, nir, irn_1_10_mm)
SELECT v1.id_ech, v1.id_point, a, 0 AS nir, ir0_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir0_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 5 AS nir, ir5_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir5_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, ncern AS nir, irn_1_10mm
FROM soif.v1e3arbre vp
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (irn_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 1 AS nir, ir1_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir1_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 2 AS nir, ir2_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir2_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 3 AS nir, ir3_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir3_1_10mm) IS DISTINCT FROM (NULL)
UNION
SELECT v1.id_ech, v1.id_point, a, 4 AS nir, ir4_1_10mm
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (ir4_1_10mm) IS DISTINCT FROM (NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, a, CASE WHEN q.donnee IN ('NCERN', 'IRN_1_10MM') THEN ve.ncern::text ELSE substr(q.donnee, 3, 1) END AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR0_1_10MM', 'IR5_1_10MM', 'IRN_1_10MM', 'NCERN')
    UNION 
    SELECT v1.id_ech, v1.id_point, a, substr(q.donnee, 3, 1) AS nir
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre ve ON q.npp = ve.npp
    INNER JOIN soif.v1e3arbre_age va ON ve.npp = va.npp AND ve.id_a = va.id_a  AND q.domaine = va.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('IR1_1_10MM', 'IR2_1_10MM', 'IR3_1_10MM', 'IR4_1_10MM')
)
, json_final AS (
    SELECT id_ech, id_point, a, nir, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, a, nir
)
UPDATE inv_prod_new.accroissement p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.a = q.a
AND p.nir = q.nir::int2;

------------------------------------------------------------------------------------------------------------------------------------
-- Table AGE
INSERT INTO inv_prod_new.age (id_ech, id_point, numa, a, typdom, age13, ncerncar, longcar, sfcoeur)
SELECT v1.id_ech, v1.id_point, vp.id_a, a, typdom, age13, ncerncar, longcar, sfcoeur
FROM soif.v1e3arbre_age vp
INNER JOIN soif.v1e3arbre va ON vp.npp = va.npp AND vp.id_a = va.id_a
INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON vp.npp = v1.nppr
WHERE v1.annee = 2024
AND (typdom, age13, ncerncar, longcar, sfcoeur) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL);

WITH quals AS(
    SELECT v1.id_ech, v1.id_point, id_a AS numa
    , JSONB_STRIP_NULLS(jsonb_build_object('donnee', RTRIM(COALESCE(f."attribute", q.donnee))) ||  jsonb_build_object('qdonnee', RTRIM(q._donnee)) ||  jsonb_build_object('mode', RTRIM(q.mode)) ||  jsonb_build_object('valeur', q.valeur) ||  jsonb_build_object('mesure', q.mesure) ||  jsonb_build_object('note', q.note)) AS qual_data
    FROM soif.qequalite q
    INNER JOIN soif.v1e3arbre_age ve ON q.npp = ve.npp AND q.domaine = ve.domaine
    LEFT JOIN metadata.field f ON q.donnee = f.field
    INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v1 ON q.npp = v1.nppr
    WHERE v1.annee = 2024
    AND RTRIM(COALESCE(f."attribute", q.donnee)) IN ('TYPDOM', 'AGE13', 'NCERNCAR', 'LONGCAR', 'SFCOEUR')
)
, json_final AS (
    SELECT id_ech, id_point, numa, to_jsonb(ARRAY_AGG(qual_data)) AS qual_data
    FROM quals
    GROUP BY id_ech, id_point, numa
)
UPDATE inv_prod_new.age p
SET qual_data = q.qual_data
FROM json_final q
WHERE p.id_ech = q.id_ech
AND p.id_point = q.id_point
AND p.numa = q.numa;


DROP TABLE states;

COMMIT;

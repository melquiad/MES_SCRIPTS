/*****************************************************
 * EXPORT DES DONNÉES POUR placette                  *
 *****************************************************/
SET enable_nestloop = FALSE;

-- données issues du premier passage (suppression de dpyr, anpyr, abrou)
INSERT INTO visu_donnees.placette (campagne, idp, dep, ser, csa, utip, bois, autut, tform, plisi, cslisi, sver, gest, nincid, incid, peupnr, entp
    , dc, dcespar1, tplant, tpespar1, tpespar2, iplant, bplant, videplant, elag, dist, iti, pentexp, portance, asperite, tcat10
    , orniere, cam, andain, bord, integr, pbuis, geom93, visite, passage) 
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.ser_86 AS ser
, r.csa
, r15.utip, r15.bois, r15.autut
, r15.tform
, d1.plisi, d1.cslisi
, d.sver
, d1.gest
, d.nincid, d.incid, d.peupnr, d.suppl['entp']->>0 AS entp, d.dc
, cp.dcespar1
, d.tplant
, pl.tpespar1, pl.tpespar2
, CASE WHEN pl.iplant_dm > 200 THEN NULL ELSE (pl.iplant_dm / 10.0)::NUMERIC(3, 1) END AS iplant
, CASE WHEN pl.bplant_dm > 200 THEN NULL ELSE (pl.bplant_dm / 10.0)::NUMERIC(3, 1) END AS bplant
, pl.videplant AS videplant
, pl.elag
, d1.dist
, d1.iti
, d1.pentexp
, d1.portance
, d1.asperite, d1.tcat10, d1.orniere
, d.suppl['cam']->>0 AS cam
, (d1.andain::INT4)::char(1), d1.bord, d1.integr
, b.pbuis
, m.geom AS geom93
, '1' AS visite
, '1' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN reco_2005 r5 USING (id_ech, id_point)
LEFT JOIN reco_2015 r15 USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN descript_2005 d5 USING (id_ech, id_point)
LEFT JOIN coupes cp USING (id_ech, id_point)
LEFT JOIN plantations pl USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
ORDER BY 1, 2;

/*
-- 6323 points, vérification de cohérence avec :
SELECT COUNT(*)
FROM v_liste_points_lt1 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2024;
*/


-- données issues du deuxième passage (suppression de dpyr, anpyr, abrou)
INSERT INTO visu_donnees.placette (campagne, idp, dep, ser, csa, def5, utip, bois, autut, tform, plisi, cslisi, nlisi5, sver, gest, nincid, incid, peupnr, entp
    , dc, dcespar1, tplant, tpespar1, tpespar2, iplant, bplant, videplant, elag, instp5, dist, iti, pentexp, portance, asperite, tcat10, orniere
    , cam, andain, bord, integr, pbuis, geom93, visite, passage) 
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.ser_86 AS ser
, r.csa
, r2.def5
, r15.utip, r15.bois, r15.autut
, r15.tform
, d1.plisi, d1.cslisi
, d2.nlisi5
, d.sver
, d1.gest
, d.nincid, d.incid, d.peupnr, d.suppl['entp']->>0 AS entp, d.dc
, cp.dcespar1
, d.tplant
, pl.tpespar1, pl.tpespar2
, CASE WHEN pl.iplant_dm > 200 THEN NULL ELSE (pl.iplant_dm / 10.0)::NUMERIC(3, 1) END AS iplant
, CASE WHEN pl.bplant_dm > 200 THEN NULL ELSE (pl.bplant_dm / 10.0)::NUMERIC(3, 1) END AS bplant
, pl.videplant
, pl.elag
, d2.instp5
, d1.dist
, d1.iti
, d1.pentexp
, d1.portance
, d1.asperite, d1.tcat10, d1.orniere
, d.suppl['cam']->>0 AS cam
, (d1.andain::INT4)::char(1), d1.bord, d1.integr
, b.pbuis
, m.geom AS geom93
, CASE WHEN d1.id_point IS NOT NULL THEN '1' ELSE '2' END AS visite
, '2' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN reco_2005 r5 USING (id_ech, id_point)
LEFT JOIN reco_2015 r15 USING (id_ech, id_point)
LEFT JOIN reco_m2 r2 USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN descript_2005 d5 USING (id_ech, id_point)
LEFT JOIN descript_m2 d2 USING (id_ech, id_point)
LEFT JOIN coupes cp USING (id_ech, id_point)
LEFT JOIN plantations pl USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
ORDER BY 1, 2;

ANALYZE visu_donnees.placette;

/*
-- 5741 = 5666 + 75 points, vérification de cohérence avec :
SELECT COUNT(*)
FROM v_liste_points_lt2 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2024;

SELECT COUNT(*)
FROM v_liste_points_lt1_pi2 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2024;
*/

-- on enlève ENTP des points non peupleraie
UPDATE visu_donnees.placette
SET entp = NULL
WHERE csa <> '5'
AND entp IS NOT NULL
AND campagne = 2024;

-- on enlève GEST des points peupleraie
UPDATE visu_donnees.placette
SET gest = NULL
WHERE csa = '5'
AND gest IS NOT NULL
AND campagne = 2024;

/*********************************
 * EXPORT DES DONNÉES POUR arbre *
 *********************************/
-- données issues du protocole première visite
INSERT INTO visu_donnees.arbre (campagne, idp, a, veget, datemort, simplif, acci, espar, ori, lib, cible, mortb, sfgui, sfcoeur, c13, mes_c13, ir5
    , htot, hdec, ddec, decoupe, deggib, age13, v, w, ir1, hrb)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, a.a
, a1.veget
, a1.datemort, a1.simplif, a1.acci, a1.espar
, a1.ori, a1.lib
, a1.cible
, s.mortb, s.sfgui
, g.sfcoeur
, round((a.c13_mm / 1000.0)::NUMERIC, 3) AS c13
, a1_14.mes_c13
, round((r.irn_1_10_mm / 10000.0)::NUMERIC, 4) AS ir5
, round((a1.htot_dm / 10.0)::NUMERIC, 1) AS htot
, round((a1.hdec_dm / 10.0)::NUMERIC, 1) AS hdec
, round((a1_14.ddec_cm / 100.0)::NUMERIC, 2) AS ddec
, a1.decoupe
, a1_14.deggib
, g.age13
, COALESCE(fea.v, pea.v, fem.v, pem.v) AS v
, COALESCE(fea.wac, pea.wac, fem.wac, pem.wac) AS w
, round((r1.irn_1_10_mm / 10000.0)::NUMERIC, 4) AS ir1
, (a1.hrb_dm / 10.0)::numeric (3, 1) AS hrb
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2005 a1_5 USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 a1_14 USING (id_ech, id_point, a)
LEFT JOIN arbre_2014 a14 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
LEFT JOIN age g ON a.id_ech = g.id_ech AND a.id_point = g.id_point AND a.a = g.a AND g.age13 IS NOT NULL
LEFT JOIN accroissement r ON a.id_ech = r.id_ech AND a.id_point = r.id_point AND a.a = r.a AND r.nir = 5
LEFT JOIN accroissement r1 ON a.id_ech = r1.id_ech AND a.id_point = r1.id_point AND a.a = r1.a AND r1.nir = 1
LEFT JOIN inv_exp_nm.g3arbre fea ON p.npp = fea.npp AND a.a = fea.a
LEFT JOIN inv_exp_nm.p3arbre pea ON p.npp = pea.npp AND a.a = pea.a
LEFT JOIN inv_exp_nm.g3morts fem ON p.npp = fem.npp AND a.a = fem.a
LEFT JOIN inv_exp_nm.p3morts pem ON p.npp = pem.npp AND a.a = pem.a
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
ORDER BY 1, 2, 3;

-- données issues du protocole deuxième visite
INSERT INTO visu_donnees.arbre (campagne, idp, a, veget5, c13)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, a.a
, a2.veget5
, round((a.c13_mm / 1000.0)::NUMERIC, 3) AS c13
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN descript_m2 d2 USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
LEFT JOIN arbre_2014 a14 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
ORDER BY 1, 2, 3;

ANALYZE visu_donnees.arbre;


/* Ajout et chargement préalable de INCO_FLOR depuis 2016 (à faire seulement 1 fois en 2023) */
-- ajout de la colonne en base de données brutes
ALTER TABLE donnees.flore
    ADD COLUMN inco_flor CHAR(1);

-- ajout de la colonne dans la table étrangère en base de production
ALTER FOREIGN TABLE visu_donnees.flore
    ADD COLUMN inco_flor CHAR(1);

-- chargement de la donnée sur les campagnes 2016 à 2022
WITH charge AS (
    SELECT c.millesime AS campagne
    , p.idp::INT4 AS idp
    , g.gmode::INT4 AS cd_ref
    , f.inco_flor
    FROM campagne c
    INNER JOIN echantillon e USING (id_campagne)
    INNER JOIN point_ech pe USING (id_ech)
    INNER JOIN point p USING (id_point)
    INNER JOIN flore f USING (id_ech, id_point)
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'CDREF13' AND g.unite = 'CODESP' AND g.mode = f.codesp
    WHERE c.millesime BETWEEN 2016 AND 2022
    AND e.type_ech = 'IFN'
    AND e.type_ue = 'P'
    AND e.phase_stat = 2
    AND p.idp IS NOT NULL
    AND f.inco_flor IS NOT NULL
)
UPDATE visu_donnees.flore f
SET inco_flor = c.inco_flor
FROM charge c
WHERE f.campagne = c.campagne
AND f.idp = c.idp
AND f.cd_ref = c.cd_ref;

/*********************************
 * EXPORT DES DONNÉES POUR flore *
 *********************************/
-- chargement
INSERT INTO visu_donnees.flore (campagne, idp, cd_ref, abond, inco_flor)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, g.gmode::INT4 AS cd_ref
, f.abond
, f.inco_flor
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN flore f USING (id_ech, id_point)
INNER JOIN metaifn.abgroupe g ON g.gunite = 'CDREF13' AND g.unite = 'CODESP' AND g.mode = f.codesp
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
ORDER BY 1, 2, 3;

ANALYZE visu_donnees.flore;

/************************************
 * EXPORT DES DONNÉES POUR ecologie *
 ************************************/
INSERT INTO visu_donnees.ecologie (campagne, idp, dateeco, obsdate, topo, obstopo, pent2, expo, masque, msud, humus, obspedo, roche, typcai, affroc, cailloux
    , cai40, text1, text2, prof1, prof2, obsprof, pcalc, pcalf, pox, ppseudo, pgley, obshydr, tsol, lign1, lign2, herb, obsveget, obschemin, typriv, distriv
    , denivriv, mousse, oln, olv, olt, ofr, oh)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, g.dateeco, g.obsdate, g.topo, g.obstopo, g.pent2, g.expo, g.masque
, g_17.msud
, g.humus, g.obspedo, g.roche
, g_17.typcai
, g.affroc
, g.cailloux, g.cai40, g.text1, g.text2, g.prof1, g.prof2, g.obsprof, g.pcalc, g.pcalf, g.pox, g.ppseudo, g.pgley, g.obshydr, g.tsol
, l.lign1, l.lign2
, g.herb, g.obsveget, g.obschemin
, g_17.typriv
, g.distriv, g.denivriv, g.mousse
, g_17.oln, g_17.olv, g_17.olt, g_17.ofr, g_17.oh
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN ecologie g USING (id_ech, id_point)
LEFT JOIN ecologie_2017 g_17 USING (id_ech, id_point)
LEFT JOIN ligneux l USING (id_ech, id_point)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
ORDER BY 1, 2;

ANALYZE visu_donnees.ecologie;

/***********************************
 * EXPORT DES DONNÉES POUR couvert *
 ***********************************/
INSERT INTO visu_donnees.couvert (campagne, idp, strate, espar_c, tca, tcl, p7ares)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, 'R' AS strate
, s.espar
, s.tcr10 * v.tcar10 AS tca
, (s.tclr10 * v.tcar10 * 100.0 / greatest(100.0, sum(s.tclr10 * 10.0) OVER(PARTITION BY s.id_point)))::int2 AS tcl
, s.p7ares
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN couv_r v USING (id_ech, id_point)
INNER JOIN espar_r s USING (id_ech, id_point)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
ORDER BY 1, 2, 3;

ANALYZE visu_donnees.couvert;

/******************************
 * EXPORT DU BOIS MORT AU SOL *
 ******************************/
INSERT INTO visu_donnees.bois_mort (campagne, idp, a, espar_bm, frepli, decomp, dbm)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, b.a, b.espar, b.frepli, b.decomp, (b.dbm_cm / 100.0)::numeric(3, 2) AS dbm
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN bois_mort b USING (id_ech, id_point)
WHERE c.millesime = 2024
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
AND b.dbm_cm < 250 -- pour éviter de charger les lignes aberrantes
ORDER BY 1, 2, 3;

ANALYZE visu_donnees.bois_mort;


/*
-- contrôle des intervalles de temps sur les unités
CREATE FUNCTION exec(TEXT) RETURNS TEXT AS $$ BEGIN EXECUTE $1; RETURN $1; END $$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS donnees_visu;

CREATE TEMPORARY TABLE donnees_visu (
    "structure" TEXT,
    donnee TEXT,
    annee INT2
);

WITH cols_temp AS (
    SELECT s."structure", c.donnee
    FROM metadonnees.colonne c
    INNER JOIN metadonnees."structure" s USING ("structure")
    WHERE ordre IS NOT NULL
    AND "structure" NOT LIKE 'V\_%'
    ORDER BY 1, 2
)
SELECT exec($$INSERT INTO donnees_visu (structure, donnee, annee) 
SELECT DISTINCT '$$ || "structure" || $$' AS structure, '$$ || donnee || $$' AS donnee
, r.campagne AS annee
FROM donnees.$$ || "structure" || $$ AS r
WHERE $$ || donnee || $$ IS NOT NULL
ORDER BY structure, donnee, annee
$$)
FROM cols_temp;

WITH en_base AS (
    SELECT donnee, min(annee) AS annee_min, max(annee) AS annee_max
    , int4range(min(annee), CASE WHEN max(annee) >= 2024 THEN NULL ELSE max(annee) END, '[]') AS validite_base
    FROM donnees_visu
    GROUP BY donnee
)
, en_meta AS (
    SELECT donnee, min(COALESCE(lower(validite), 2005)) AS annee_min, max(COALESCE(upper(validite) - 1, 2023)) AS annee_max
    FROM metadonnees.donnee_unite
    GROUP BY donnee
)
SELECT b.donnee, b.annee_min, m.annee_min, b.annee_max, m.annee_max
FROM en_base b
INNER JOIN en_meta m USING (donnee)
WHERE (b.annee_min <> m.annee_min
    OR b.annee_max <> m.annee_max)
AND m.annee_min <> 2005
ORDER BY donnee;

SELECT *
FROM metadonnees.donnee_unite
WHERE donnee = 'INCO_FLOR';

SELECT min(campagne)
FROM donnees.flore f
WHERE inco_flor IS NOT NULL;

SELECT *
FROM metadonnees.modalite m
WHERE unite = 'STRATE';

SELECT *
FROM metadonnees.col_contexte cc
WHERE donnee = 'ASPERITE';

DROP TABLE donnees_visu;

-- contrôle des intervalles de temps sur les colonnes
DROP TABLE IF EXISTS cond_ctxt;

CREATE TEMPORARY TABLE cond_ctxt (
    code_contexte TEXT,
    "structure" TEXT,
    donnee TEXT,
    annee INT2
);


WITH ctx AS (
    SELECT code_contexte, conditions
    FROM metadonnees.contexte
)
, col_ctx AS (
    SELECT c.code_contexte, cc."structure", cc.donnee, cc.validite, c.conditions
    FROM ctx c
    INNER JOIN metadonnees.col_contexte cc USING (code_contexte)
)
, cols_base AS (
    SELECT s."structure" AS "structure", c.donnee, c.ordre
    FROM metadonnees."structure" s
    INNER JOIN metadonnees.colonne c ON s."structure" = c."structure"
)
--SELECT *, $$
SELECT EXEC($$INSERT INTO cond_ctxt
SELECT DISTINCT '$$ || cc.code_contexte || $$' AS code_contexte, '$$ || cb."structure" || $$' AS structure, '$$ || cb.donnee || $$' AS donnee
, campagne AS annee
FROM donnees.$$ || lower(cb."structure") || $$ 
$$ || CASE WHEN lower(cb."structure") = 'placette' THEN '' ELSE $$INNER JOIN donnees.placette USING (campagne, idp) $$ END || 
$$WHERE $$ || lower(cb."structure") || $$.$$ || lower(cb.donnee) || $$ IS NOT NULL
AND $$ || cc.conditions || $$
ORDER BY structure, donnee, annee;$$) AS req
--ORDER BY structure, donnee, annee;$$ AS req
FROM cols_base cb
INNER JOIN col_ctx cc USING ("structure", donnee)
ORDER BY "structure", donnee;


WITH en_base AS (
    SELECT code_contexte, "structure", donnee, min(annee) AS annee_min, max(annee) AS annee_max
    FROM cond_ctxt
    GROUP BY code_contexte, "structure", donnee
)
, en_meta AS (
    SELECT code_contexte, "structure", donnee, min(COALESCE(lower(validite), 2005)) AS annee_min, max(COALESCE(upper(validite) - 1, 2023)) AS annee_max
    FROM metadonnees.col_contexte
    GROUP BY code_contexte, "structure", donnee
)
SELECT code_contexte, "structure", donnee, b.annee_min, m.annee_min, b.annee_max, m.annee_max
FROM en_base b
INNER JOIN en_meta m USING (code_contexte, "structure", donnee)
WHERE b.annee_min <> m.annee_min OR b.annee_max <> m.annee_max
ORDER BY "structure", donnee, code_contexte;

SELECT DISTINCT campagne
FROM donnees.arbre
INNER JOIN donnees.placette USING (campagne, idp)
WHERE ir1 IS NOT NULL
AND csa = '5'
ORDER BY 1 DESC;


DROP TABLE cond_ctxt;

DROP FUNCTION exec(TEXT);
*/

-- DOCUMENTATION DES CHANGEMENTS D'UNITÉS

-- humus : on recharge HUMUS22
DELETE FROM visu_metadonnees.modalite
WHERE unite = 'HUMUS22';

INSERT INTO visu_metadonnees.modalite (unite, code, ordre, libelle, definition)
SELECT unite, "mode", classe, libelle, definition
FROM metaifn.abmode
WHERE unite = 'HUMUS22';

-- tsol : on recharge TSOL22
DELETE FROM visu_metadonnees.modalite
WHERE unite = 'TSOL22';

INSERT INTO visu_metadonnees.modalite (unite, code, ordre, libelle, definition)
SELECT unite, "mode", classe, libelle, definition
FROM metaifn.abmode
WHERE unite = 'TSOL22';

-- AJOUT DE INCO_FLOR
INSERT INTO visu_metadonnees.donnee (donnee, libelle, definition)
SELECT donnee, libelle, definition
FROM metaifn.addonnee
WHERE donnee = 'INCO_FLOR';

INSERT INTO visu_metadonnees.unite (unite, utype, libelle, definition)
SELECT unite, 'L' AS utype, libelle, definition
FROM metaifn.abunite
WHERE unite = 'INCO_FLOR';

INSERT INTO visu_metadonnees.modalite (unite, code, ordre, libelle, definition)
SELECT unite, "mode", classe, libelle, definition
FROM metaifn.abmode
WHERE unite = 'INCO_FLOR'
ORDER BY classe;

INSERT INTO visu_metadonnees.donnee_unite (donnee, unite, validite)
VALUES ('INCO_FLOR', 'INCO_FLOR', '[2016,)'::int4range);

INSERT INTO visu_metadonnees.colonne ("structure", donnee, ctype, ordre)
VALUES ('FLORE', 'INCO_FLOR', 'CO', 5);

INSERT INTO visu_metadonnees.col_contexte (code_contexte, "structure", donnee, validite)
VALUES ('PF', 'FLORE', 'INCO_FLOR', '[2016,)'::int4range)
, ('PP', 'FLORE', 'INCO_FLOR', '[2016,)'::int4range);

UPDATE visu_metadonnees.donnee d
SET lib_en = a.libelle
FROM metaifn.ablexique a
WHERE a.unite = 'DONNEE' AND a.langue = 'GB' AND a."mode" = d.donnee
AND d.donnee = 'INCO_FLOR';

UPDATE visu_metadonnees.donnee d
SET libelle = 'Incohérence floristique'
WHERE d.donnee = 'INCO_FLOR';

-- Sur les modalités
UPDATE visu_metadonnees.modalite d
SET lib_en = a.libelle
FROM metaifn.ablexique a
WHERE a.unite = d.unite AND a.langue = 'GB' AND a."mode" = d.code
AND d.unite = 'INCO_FLOR';


-- DONNÉES ARRÊTÉES
-- arrêt de ANPYR, DPYR, ABROU
UPDATE visu_metadonnees.col_contexte
SET validite = int4range(lower(validite), 2023)
WHERE donnee IN ('ANPYR', 'DPYR','ABROU')
AND NOT isempty(validite);

-- données habitats marquées comme arrêtées (même si ça n'est pas vraiment le cas)
UPDATE visu_metadonnees.col_contexte
SET validite = int4range(lower(validite), 2023)
WHERE upper(validite) IS NULL
AND NOT isempty(validite)  
AND "structure" = 'V_HABITAT';

-- CORRECTIONS SUPPLÉMENTAIRES
-- IR1 et IR5 renseignées en peupleraie sur quelques arbres...
UPDATE visu_metadonnees.col_contexte
SET validite = '[2018,)'::int4range
WHERE code_contexte = 'VP'
AND "structure" = 'ARBRE'
AND donnee IN ('IR1', 'IR5');

UPDATE visu_metadonnees.col_contexte
SET validite = 'empty'::int4range
WHERE donnee = 'VIDEPEUPLIER'
AND code_contexte = 'PF';

-- Corrections sur TCAT10
DELETE FROM visu_metadonnees.col_contexte
WHERE "structure" IN ('PLACETTE','V_PLACETTE_GP')
AND code_contexte = 'PF'
AND donnee = 'TCAT10'
AND validite = '[2006,2007)';

UPDATE visu_metadonnees.donnee_unite
SET validite = '[2017,)'
WHERE donnee = 'TCAT10';
    --> Conséquence : mise à 0 NULL de TCAT10 dans la table placette pour la campagne 2006
UPDATE visu_donnees.placette
SET tcat10 = NULL
WHERE campagne = 2006;


-- Mise à jour du libellé d'une modalité sur ABOND
UPDATE visu_metadonnees.modalite
SET libelle = '0 à 5 % (présence faible)'
WHERE unite = 'ABOND'
AND code = '1';

-- Quelques mises à jours de libellés et définitions supplémentaires
UPDATE visu_metadonnees.modalite vm
SET libelle = mm.libelle, definition = mm.definition
FROM metaifn.abmode mm
WHERE mm.unite = vm.unite AND mm."mode" = vm.code
AND mm.unite = 'ABOND';

UPDATE visu_metadonnees.modalite vm
SET libelle = mm.libelle, definition = mm.definition
FROM metaifn.abmode mm
WHERE mm.unite = vm.unite AND mm."mode" = vm.code
AND mm.unite = 'TSOL'
AND vm.code IN ('01', '99');

UPDATE visu_metadonnees.modalite vm
SET definition = mm.definition
FROM metaifn.abmode mm
WHERE mm.unite = vm.unite AND mm."mode" = vm.code
AND mm.unite = 'ESPAR1';

UPDATE visu_metadonnees.modalite vm
SET lib_en = ml.libelle, def_en = ml.definition
FROM metaifn.ablexique ml
WHERE ml.unite = vm.unite AND ml.langue = 'GB' AND ml."mode" = vm.code
AND ml.unite IN ('CAM', 'VEGET56', 'VEGET57');


-- à faire côté base de production
ANALYZE visu_donnees.arbre;
ANALYZE visu_donnees.bois_mort;
ANALYZE visu_donnees.couvert;
ANALYZE visu_donnees.ecologie;
ANALYZE visu_donnees.flore;
ANALYZE visu_donnees.habitat;
ANALYZE visu_donnees.placette;

-- à faire côté données brutes
ANALYZE donnees.arbre;
ANALYZE donnees.bois_mort;
ANALYZE donnees.couvert;
ANALYZE donnees.ecologie;
ANALYZE donnees.flore;
ANALYZE donnees.habitat;
ANALYZE donnees.placette;

/* COMPARAISON DES LIBELLÉS ET DÉFINITION DES UNITÉS ENTRE METAIFN ET MÉTADONNÉES DE VISU
SELECT a.unite, a."mode" AS modalite
, a.libelle AS libelle_metaifn, m.libelle AS libelle_dataifn
, a.definition AS definition_metaifn, m.definition AS definition_dataifn
, l.libelle AS lib_en_metaifn, m.lib_en AS lib_en_dataifn
, l.definition AS def_en_metaifn, m.def_en AS def_en_dataifn
FROM metaifn.abmode a
INNER JOIN visu_metadonnees.modalite m ON a.unite = m.unite AND a."mode" = m.code
LEFT JOIN metaifn.ablexique l ON l.langue = 'GB' AND a.unite = l.unite AND a."mode" = l."mode"
WHERE (a.libelle, a.definition, l.libelle, l.definition) IS DISTINCT FROM (m.libelle, m.definition, m.lib_en, m.def_en)
AND a.unite NOT IN ('HAB', 'CD_HAB', 'CORINE_IFN', 'EUNIS', 'HIC')
ORDER BY a.unite, a."position";
*/

/*
SELECT d.donnee, d.libelle, d.lib_en, du.unite, lower(coalesce(du.validite, int4range(2005, NULL)) * range_merge(range_agg (cc.validite))) AS debut, upper(coalesce(du.validite, int4range(2005, NULL)) * range_merge(range_agg (cc.validite))) - 1 AS fin
FROM visu_metadonnees.donnee d
    INNER JOIN visu_metadonnees.donnee_unite du USING (donnee)
    INNER JOIN visu_metadonnees.colonne c USING (donnee)
    INNER JOIN visu_metadonnees.col_contexte cc USING ("structure", donnee)
GROUP BY donnee, d.libelle, d.lib_en, du.unite, du.validite
HAVING NOT isempty(coalesce(du.validite, int4range(2005, NULL)) * range_merge(range_agg (cc.validite)))
ORDER BY donnee, du.validite;
*/



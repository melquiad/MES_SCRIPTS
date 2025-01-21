/*****************************************************
 * EXPORT DES DONNÉES POUR placette                  *
 *****************************************************/
SET enable_nestloop = FALSE;

-- données issues du premier passage (suppression de dpyr, anpyr, abrou)
INSERT INTO visu_donnees.placette (campagne, idp, dep, ser, csa, def5, uta1, uta2, utip, bois, autut, tm2, tform, plisi, cslisi, elisi, nlisi5, sfo, sver, gest, nincid, incid, peupnr, entp
    , dc, dcespar1, dcespar2, prelev5, tplant, tpespar1, tpespar2, iplant, bplant, videplant, videpeuplier, elag, instp5, dist, acces, iti, pentn, pentexp, portn, portance, asperite, tcat10
    , orniere, cam, andain, bord, integr, pbuis, geom93, visite, passage) 
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.ser_86 AS ser
, r.csa
, NULL AS def5
, r5.uta1, r5.uta2
, r15.utip, r15.bois, r15.autut
, r5.tm2
, r15.tform
, d1.plisi, d1.cslisi
, (d5.suppl['elisi']->>0)::REAL AS elisi
, NULL AS nlisi5
, d5.sfo
, d.sver
, d1.gest
, d.nincid, d.incid, d.peupnr, d.suppl['entp']->>0 AS entp, d.dc
, cp.dcespar1, cp.dcespar2
, NULL AS prelev5
, d.tplant
, pl.tpespar1, pl.tpespar2
, CASE WHEN pl.iplant_dm > 200 THEN NULL ELSE (pl.iplant_dm / 10.0)::NUMERIC(3, 1) END AS iplant
, CASE WHEN pl.bplant_dm > 200 THEN NULL ELSE (pl.bplant_dm / 10.0)::NUMERIC(3, 1) END AS bplant
, pl.videplant AS videplant
, (d1.suppl['videpeuplier']->>0)::int2 AS videpeuplier
, pl.elag
, NULL AS instp5
, d1.dist
, d5.acces
, d1.iti
, d5.pentn
, d1.pentexp
, d5.portn
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
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
ORDER BY 1, 2;

/*
-- 6210 points, vérification de cohérence avec :
SELECT COUNT(*)
FROM v_liste_points_lt1 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2023;
*/


-- données issues du deuxième passage (suppression de dpyr, anpyr, abrou)
INSERT INTO visu_donnees.placette (campagne, idp, dep, ser, csa, def5, uta1, uta2, utip, bois, autut, tm2, tform, plisi, cslisi, elisi, nlisi5, sfo, sver, gest, nincid, incid, peupnr, entp
    , dc, dcespar1, dcespar2, prelev5, tplant, tpespar1, tpespar2, iplant, bplant, videplant, videpeuplier, elag, instp5, dist, acces, iti, pentn, pentexp, portn, portance, asperite, tcat10, orniere, abrou
    , cam, andain, bord, integr, pbuis, dpyr, anpyr, geom93, visite, passage) 
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep, pe.ser_86 AS ser
, r.csa
, r2.def5
, r5.uta1, r5.uta2
, r15.utip, r15.bois, r15.autut
, r5.tm2
, r15.tform
, d1.plisi, d1.cslisi
, (d5.suppl['elisi']->>0)::REAL AS elisi
, d2.nlisi5
, d5.sfo
, d.sver
, d1.gest
, d.nincid, d.incid, d.peupnr, d.suppl['entp']->>0 AS entp, d.dc
, cp.dcespar1, cp.dcespar2
, d2.prelev5
, d.tplant
, pl.tpespar1, pl.tpespar2
, CASE WHEN pl.iplant_dm > 200 THEN NULL ELSE (pl.iplant_dm / 10.0)::NUMERIC(3, 1) END AS iplant
, CASE WHEN pl.bplant_dm > 200 THEN NULL ELSE (pl.bplant_dm / 10.0)::NUMERIC(3, 1) END AS bplant
, pl.videplant
, (d1.suppl['videpeuplier']->>0)::int2 AS videpeuplier
, pl.elag
, d2.instp5
, d1.dist
, d5.acces
, d1.iti
, d5.pentn
, d1.pentexp
, d5.portn
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
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 2
ORDER BY 1, 2;

ANALYZE visu_donnees.placette;

/*
-- 5587 = 5519 + 68 points, vérification de cohérence avec :
SELECT COUNT(*)
FROM v_liste_points_lt2 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2023;

SELECT COUNT(*)
FROM v_liste_points_lt1_pi2 v
INNER JOIN description d USING (id_ech, id_point)
WHERE annee = 2023;
*/

-- on enlève ENTP des points non peupleraie
UPDATE visu_donnees.placette
SET entp = NULL
WHERE csa <> '5'
AND entp IS NOT NULL
AND campagne = 2023;

-- on enlève GEST des points peupleraie
UPDATE visu_donnees.placette
SET gest = NULL
WHERE csa = '5'
AND gest IS NOT NULL
AND campagne = 2023;

/*********************************
 * EXPORT DES DONNÉES POUR arbre *
 *********************************/
-- données issues du protocole première visite
INSERT INTO visu_donnees.arbre (campagne, idp, a, veget, veget5, datemort, simplif, acci, espar, ori, lib, cible, mortb, sfgui, sfcoeur, c13, mes_c13, ir5
    , htot, hdec, ddec, decoupe, deggib, age13, v, w, ir1, hrb)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, a.a
, a1.veget
, NULL AS veget5
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
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
ORDER BY 1, 2, 3;

-- données issues du protocole deuxième visite
INSERT INTO visu_donnees.arbre (campagne, idp, a, veget5, mortb, c13)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, a.a
, a2.veget5
, s.mortb
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
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.ech_parent IS NOT NULL
ORDER BY 1, 2, 3;

ANALYZE visu_donnees.arbre;

/*********************************
 * EXPORT DES DONNÉES POUR flore *
 *********************************/
INSERT INTO visu_donnees.flore (campagne, idp, cd_ref, abond)
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, g.gmode::INT4 AS cd_ref
, MAX(f.abond) AS abond
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN flore f USING (id_ech, id_point)
INNER JOIN metaifn.abgroupe g ON g.gunite = 'CDREF13' AND g.unite = 'CODESP' AND g.mode = f.codesp
WHERE c.millesime = 2023
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND p.idp IS NOT NULL
GROUP BY 1, 2, 3
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
WHERE c.millesime = 2023
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
WHERE c.millesime = 2023
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
WHERE c.millesime = 2023
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
    , int4range(min(annee), CASE WHEN max(annee) >= 2022 THEN NULL ELSE max(annee) END, '[]') AS validite_base
    FROM donnees_visu
    GROUP BY donnee
)
, en_meta AS (
    SELECT donnee, min(COALESCE(lower(validite), 2005)) AS annee_min, max(COALESCE(upper(validite) - 1, 2022)) AS annee_max
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
WHERE donnee = 'STRATE';

SELECT *
FROM metadonnees.modalite m
WHERE unite = 'STRATE';

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
FROM $$ || lower(cb."structure") || $$ 
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
    SELECT code_contexte, "structure", donnee, min(COALESCE(lower(validite), 2005)) AS annee_min, max(COALESCE(upper(validite) - 1, 2022)) AS annee_max
    FROM metadonnees.col_contexte
    GROUP BY code_contexte, "structure", donnee
)
SELECT code_contexte, "structure", donnee, b.annee_min, m.annee_min, b.annee_max, m.annee_max
FROM en_base b
INNER JOIN en_meta m USING (code_contexte, "structure", donnee)
WHERE b.annee_min <> m.annee_min OR b.annee_max <> m.annee_max
ORDER BY "structure", donnee, code_contexte;

SELECT DISTINCT campagne
FROM arbre
INNER JOIN placette USING (campagne, idp)
WHERE ir5 IS NOT NULL
AND csa = '5'
ORDER BY 1 DESC;


DROP TABLE cond_ctxt;

DROP FUNCTION exec(TEXT);
*/

-- DOCUMENTATION DES CHANGEMENTS D'UNITÉS
-- humus
INSERT INTO visu_metadonnees.unite (unite, utype, libelle, definition)
SELECT unite, 'L', libelle, definition
FROM metaifn.abunite
WHERE unite = 'HUMUS22';

INSERT INTO visu_metadonnees.modalite (unite, code, ordre, libelle, definition)
SELECT unite, "mode", classe, libelle, definition
FROM metaifn.abmode
WHERE unite = 'HUMUS22';

UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(lower(validite), 2022)
WHERE donnee = 'HUMUS'
AND unite = 'HUMUS';

INSERT INTO visu_metadonnees.donnee_unite (donnee, unite, validite)
VALUES ('HUMUS', 'HUMUS22', int4range(2022, NULL));

-- tsol
INSERT INTO visu_metadonnees.unite (unite, utype, libelle, definition)
SELECT unite, 'L', libelle, definition
FROM metaifn.abunite
WHERE unite = 'TSOL22';

INSERT INTO visu_metadonnees.modalite (unite, code, ordre, libelle, definition)
SELECT unite, "mode", classe, libelle, definition
FROM metaifn.abmode
WHERE unite = 'TSOL22';

UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(lower(validite), 2022)
WHERE donnee = 'TSOL'
AND unite = 'TSOL';

INSERT INTO visu_metadonnees.donnee_unite (donnee, unite, validite)
VALUES ('TSOL', 'TSOL22', int4range(2022, NULL));


-- DONNÉES ARRÊTÉES

-- arrêt de ANPYR, DPYR, ABROU
UPDATE visu_metadonnees.col_contexte
SET validite = int4range(lower(validite), 2022)
WHERE donnee IN ('ANPYR', 'DPYR','ABROU');





-- CORRECTION DE QUELQUES PÉRIODES DE VALIDITÉ D'UNITÉS
UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(lower(validite), NULL)
WHERE donnee = 'HERB';

UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(2010, NULL)
WHERE donnee = 'MOUSSE';

UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(lower(validite), NULL)
WHERE donnee = 'STRATE';

UPDATE visu_metadonnees.donnee_unite
SET validite = int4range(2006, NULL)
WHERE donnee = 'TCAT10';



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



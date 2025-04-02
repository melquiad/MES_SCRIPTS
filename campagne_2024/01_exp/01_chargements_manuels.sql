-- POINTS PREMIÈRE VISITE
------------------------------
BEGIN;

-- e1noeud
INSERT INTO inv_exp_nm.e1noeud (nppg, usite, site, cyc, inv, absc, ord, tirmax, incref, zp, depp, xlt, ylt, xlp, ylp, regn, geom)
SELECT n.nppg, g.usite, g.site, '5' AS cyc, g.inv, m.absc, m.ord, n.tirmax, n.incref, ne.zp, ne.depn AS depp
, ROUND(ST_X(ST_Transform(n.geom, 27572))::NUMERIC) AS xlt, ROUND(ST_Y(ST_Transform(n.geom, 27572))::NUMERIC) AS ylt
, ROUND(ST_X(ST_Transform(n.geom, 27572))::NUMERIC) AS xlp, ROUND(ST_Y(ST_Transform(n.geom, 27572))::NUMERIC) AS ylp
, ne.regn, ST_SetSRID(n.geom, 2154) AS geom
--, ROUND(ST_X(ST_Transform(n.geom, 932006))::NUMERIC) AS xlt, ROUND(ST_Y(ST_Transform(n.geom, 932006))::NUMERIC) AS ylt
--, ROUND(ST_X(ST_Transform(n.geom, 932006))::NUMERIC) AS xlp, ROUND(ST_Y(ST_Transform(n.geom, 932006))::NUMERIC) AS ylp
--, ne.regn, ST_SetSRID(n.geom, 910001) AS geom
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN noeud_ech ne USING (id_ech)
INNER JOIN noeud n USING (id_noeud)
INNER JOIN grille g USING (id_grille)
INNER JOIN maille m ON n.geom = m.geom
WHERE e.phase_stat = 1
AND e.type_ech = 'IFN'
AND e.ech_parent IS NULL
AND c.millesime = 2024;

-- e1point
WITH val_unite AS (
    SELECT max(id_unite) AS id_unite_deb
    FROM inv_exp_nm.e1point
    WHERE incref = 2024 - 2006
) 
INSERT INTO inv_exp_nm.e1point (npp, nppg, "poi$", xl, yl, auteurpi, datepi, occ, cso, poids, dep, zp, incref, id_unite, idp, geom, cyc, dbpi, pbpi, uspi, ufpi, tfpi, phpi, blpi)
SELECT p.npp, n.nppg, p.code_pt
, ROUND(ST_X(ST_Transform(m.geom, 27572))::NUMERIC) AS xl, ROUND(ST_Y(ST_Transform(m.geom, 27572))::NUMERIC) AS yl
--, ROUND(ST_X(ST_Transform(m.geom, 932006))::NUMERIC) AS xl, ROUND(ST_Y(ST_Transform(m.geom, 932006))::NUMERIC) AS yl
, auteurpi, datepi, occ, cso, poids, dep, pe.zp, vp.annee - 2005 AS incref, id_unite_deb + row_number() OVER(ORDER BY p.npp) AS id_unite, p.idp
, ST_SetSRID(p.geom, 2154) AS geom
--, ST_SetSRID(p.geom, 910001) AS geom
, '5' AS cyc, dbpi, pbpi, uspi, ufpi, tfpi, phpi, blpi
FROM v_liste_points_pi1 vp
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point_pi pp USING (id_ech, id_point)
INNER JOIN noeud n USING (id_noeud)
INNER JOIN maille m USING (id_maille)
CROSS JOIN val_unite
WHERE vp.annee = 2024
ORDER BY npp;

/*
-- Vérification d'absence de doublons d'ID_UNITE dans E1POINT --> ID_UNITE négatif => inventaire à façon
SELECT id_unite, count(id_unite)
FROM inv_exp_nm.e1point
GROUP BY id_unite
HAVING count(id_unite) > 1;
*/

-- e1coord
INSERT INTO inv_exp_nm.e1coord (npp, xl, yl, zp, geom)
SELECT vp.npp, ROUND(ST_X(ST_Transform(p.geom, 27572))::NUMERIC) AS xl, ROUND(ST_Y(ST_Transform(p.geom, 27572))::NUMERIC) AS yl, pe.zp, p.geom
--SELECT vp.npp, ROUND(ST_X(ST_Transform(p.geom, 932006))::NUMERIC) AS xl, ROUND(ST_Y(ST_Transform(p.geom, 932006))::NUMERIC) AS yl, pe.zp, p.geom
FROM v_liste_points_pi1 vp
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
WHERE vp.annee = 2024
ORDER BY npp;

-- e2point
INSERT INTO inv_exp_nm.e2point (npp, incref, dep, cyc, auteurlt, datepoint, csa, formation, poids, obscsa, id_unite, utip, bois, autut, tauf, tform, ser_86, ser_alluv, greco, regn, eflt, qleve, qbois, qreco)
SELECT p.npp, c.millesime - 2005 AS incref, pe.dep, '5' AS cyc, al.matricule, pl.datepoint, r.csa, pl.formation, pe.poids, r.obscsa, p1.id_unite, r1.utip, r1.bois, r1.autut, r1.tauf, r1.tform, pe.ser_86, pe.ser_alluv
, left(pe.ser_86, 1) AS greco, pe.regn, r1.eflt, r1.qleve, r1.qbois, pl.qreco
FROM point_ech pe 
INNER JOIN echantillon e USING (id_ech)
INNER JOIN campagne c USING (id_campagne)
INNER JOIN point p USING (id_point)
INNER JOIN inv_exp_nm.e1point p1 USING (npp)
LEFT JOIN point_lt pl ON pe.id_ech = pl.id_ech AND pe.id_point = pl.id_point
LEFT JOIN agent_lt al ON pe.id_ech = al.id_ech AND pe.id_point = al.id_point AND num_auteurlt = 1
LEFT JOIN reconnaissance r ON pe.id_ech = r.id_ech AND pe.id_point = r.id_point
LEFT JOIN reco_2015 r1 ON pe.id_ech = r1.id_ech AND pe.id_point = r1.id_point
WHERE c.millesime = 2024
AND type_ech = 'IFN'
AND phase_stat = 2
AND ech_parent IS NULL
ORDER BY npp;


--DELETE FROM prod_exp.e2point
--WHERE incref = 16;

/*
ALTER TABLE prod_exp.e2point
ADD COLUMN qleve char(1);

ALTER FOREIGN TABLE prod_exp.e2point
ADD COLUMN qleve char(1);

UPDATE prod_exp.e2point pep
SET qleve = r.qleve
FROM v_liste_points_lt1 vp
INNER JOIN reco_m1 r USING (id_ech, id_point)
WHERE pep.npp = vp.npp
AND r.qleve IS NOT NULL;
*/

INSERT INTO prod_exp.e2point (npp, incref, reco, qleve)
SELECT vp.npp, vp.annee - 2005 AS incref, pl.reco, r.qleve
FROM v_liste_points_lt1 vp
INNER JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN reco_2015 r USING (id_ech, id_point)
WHERE vp.annee = 2024
ORDER BY npp;

COMMIT;

-- g3foret
INSERT INTO inv_exp_nm.g3foret (npp, incref, dep, cyc, plisi, cslisi, dist, dc, tplant, gest, integr, iti, portance, asperite, pentexp, incid
, andain, bord, dcespar1, peupnr, sver, nincid, orniere, caracthab, pbuis, atpyr, ornr, prnr, fouil, predom)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, d1.plisi, d1.cslisi, d1.dist, d.dc, d.tplant, d1.gest, d1.integr, d1.iti, d1.portance, d1.asperite, d1.pentexp, d.incid, d1.andain::INT, d1.bord
, c.dcespar1, d.peupnr, d.sver, d.nincid, d1.orniere, d.caracthab, b.pbuis, b.atpyr, d1.ornr, d1.prnr, d1.fouil, d1.predom
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN coupes c USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY vp.npp;

INSERT INTO prod_exp.g3foret (npp, plas15, plas25, azdcoi_gd, azdlim_gd, azdlim2_gd, azlim1_gd, azlim2_gd, dcoi_cm, dlim_cm, dlim2_cm
, ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e, tcnr, dispnr)
SELECT vp.npp, d1.plas15, d1.plas25, l.azdcoi_gd, l.azdlim_gd, l.azdlim2_gd, l.azlim1_gd, l.azlim2_gd, l.dcoi_cm, l.dlim_cm, l.dlim2_cm
, b.ncbuis10, b.ncbuis_a, b.ncbuis_b, b.ncbuis_c, b.ncbuis_d, b.ncbuis_e
, d1.tcnr, d1.dispnr
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN limites l USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY vp.npp;

-- g3agedom
INSERT INTO inv_exp_nm.g3agedom (npp, incref, dep, cyc, su, numa, a, typdom, age13, cam, ncerncar, longcar, sfcoeur)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, 2 AS su, a.numa, a.a, a.typdom, a.age13, NULL AS cam, a.ncerncar, a.longcar, a.sfcoeur
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN age a USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
UNION
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, 0 AS su, 0 AS numa, NULL AS a, NULL AS typdom, NULL AS age13, d.suppl->>'cam' AS cam, NULL AS ncerncar, NULL AS longcar, NULL AS sfcoeur
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND d.suppl->>'cam' IS NOT NULL
ORDER BY npp, numa;

SET enable_nestloop = FALSE;
-- g3arbre
INSERT INTO inv_exp_nm.g3arbre (npp, incref, dep, cyc, a, ori, veget, acci, lib, qbp, hbv, hbm
, espar, decoupe, simplif, cible, arbat, ncern, deggib, hdec, htot, ir5, irn, c13, mortb, sfgui, ma, mr, hrb_dm, ddec)
WITH accroiss AS (
    SELECT id_ech, id_point, a, max(nir) AS nir
    FROM v_liste_points_lt1
    INNER JOIN accroissement USING (id_ech, id_point)
    WHERE annee = 2024
    GROUP BY id_ech, id_point, a
)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, a.a, a1.ori, a1.veget, a1.acci, a1.lib, a1.qbp, a1.hbv_dm / 10.0, a1.hbm_dm /10.0, a1.espar, a1.decoupe, a1.simplif, a1.cible, (a1.suppl->>'arbat')::INT2 AS arbat, acc.nir AS ncern, a14.deggib, a1.hdec_dm / 10.0 AS hdec, a1.htot_dm / 10.0 AS htot
, CASE WHEN acc.nir = 5 THEN acc.irn_1_10_mm / 10000.0 ELSE NULL END AS ir5, CASE WHEN acc.nir < 5 THEN acc.irn_1_10_mm / 10000.0 ELSE NULL END AS irn, a.c13_mm / 1000.0, s.mortb, s.sfgui, s.ma, s.mr, a1.hrb_dm, a14.ddec_cm / 100.0
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN accroiss ac USING (id_ech, id_point, a)
LEFT JOIN accroissement acc USING (id_ech, id_point, a, nir)
LEFT JOIN arbre_m1_2014 a14 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND a1.veget = '0'
ORDER BY npp, a;

SET enable_nestloop = TRUE;

INSERT INTO prod_exp.g3arbre (npp, a, azpr_gd, dpr_cm, ir1, ir2, ir3, ir4)
SELECT vp.npp
, a.a, a1.azpr_gd, a1.dpr_cm, ac1.irn_1_10_mm / 10000.0 AS ir1, ac2.irn_1_10_mm / 10000.0 AS ir2, ac3.irn_1_10_mm / 10000.0 AS ir3, ac4.irn_1_10_mm / 10000.0 AS ir4
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN accroissement ac1 ON a.id_ech = ac1.id_ech AND a.id_point = ac1.id_point AND a.a = ac1.a AND ac1.nir = 1
LEFT JOIN accroissement ac2 ON a.id_ech = ac2.id_ech AND a.id_point = ac2.id_point AND a.a = ac2.a AND ac2.nir = 2
LEFT JOIN accroissement ac3 ON a.id_ech = ac3.id_ech AND a.id_point = ac3.id_point AND a.a = ac3.a AND ac3.nir = 3
LEFT JOIN accroissement ac4 ON a.id_ech = ac4.id_ech AND a.id_point = ac4.id_point AND a.a = ac4.a AND ac4.nir = 4
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND a1.veget = '0'
ORDER BY npp, a;

INSERT INTO inv_exp_nm.g3arbre_coord (npp, a, azpr, dpr)
SELECT vp.npp
, a.a, a1.azpr_gd * pi() / 200.0, a1.dpr_cm / 100.0
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND a1.veget = '0'
ORDER BY npp, a;

-- g3boism
INSERT INTO inv_exp_nm.g3boism(npp, incref, dep, cyc, a, frepli, decomp, espar, dbm)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, bm.a, bm.frepli, bm.decomp, bm.espar, bm.dbm_cm / 100.0 AS dbm
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN bois_mort bm USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp, a;

-- g3ecologie
INSERT INTO inv_exp_nm.g3ecologie (npp, incref, dep, cyc
	, dateeco, auteuref, expo, pent2, topo, masque, lign1, lign2, herb, humus
	, affroc
	, roche
	, cailloux, cai40
	, text1, text2, prof1, prof2
	, pcalc, pcalf
	, pox, ppseudo, pgley
	, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv
	, htext, msud, typcai, typriv)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
    , e.dateeco, e.auteuref, e.expo, e.pent2, e.topo, e.masque, l.lign1, l.lign2, e.herb, e.humus
    , (CASE WHEN e.affroc = 'X' THEN NULL ELSE e.affroc END)::INT2
    , e.roche
    , (CASE WHEN e.cailloux = 'X' THEN NULL ELSE e.cailloux END)::INT2, (CASE WHEN e.cai40 = 'X' THEN NULL ELSE e.cai40 END)::INT2
    , e.text1, e.text2, e.prof1, e.prof2
    , (CASE WHEN e.pcalc = 'X' THEN NULL ELSE e.pcalc END)::INT2, (CASE WHEN e.pcalf = 'X' THEN NULL ELSE e.pcalf END)::INT2
    , (CASE WHEN e.pox = 'X' THEN NULL ELSE e.pox END)::INT2, (CASE WHEN e.ppseudo = 'X' THEN NULL ELSE e.ppseudo END)::INT2, (CASE WHEN e.pgley = 'X' THEN NULL ELSE e.pgley END)::INT2
    , e.tsol, e.obsdate, e.obshydr, e.obspedo, e.obsprof, e.obstopo, e.obsveget, e.obschemin, e.mousse, e.distriv, e.denivriv
    , e1.htext, e1.msud, e1.typcai, e1.typriv
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN ecologie e USING (id_ech, id_point)
LEFT JOIN ecologie_2017 e1 USING (id_ech, id_point)
LEFT JOIN ligneux l USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

-- g3essence
INSERT INTO inv_exp_nm.g3essence (npp, incref, dep, cyc, su, espar, p1525, cible)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, 2 AS su, e.espar
, CASE WHEN e.p7ares = '1' THEN '0' ELSE '1' END AS p1525
, e.cible
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_r e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

INSERT INTO prod_exp.g3essence (npp, su, espar, tcr10, tclr10)
SELECT vp.npp, 2 AS su, e.espar, e.tcr10, e.tclr10
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_r e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

-- g3flore
INSERT INTO inv_exp_nm.g3flore (npp, incref, dep, cyc, codesp, abond)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.codesp, f.abond
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

INSERT INTO prod_exp.g3flore (npp, codesp, inco_flor)
SELECT vp.npp, f.codesp, f.inco_flor
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

-- g3plant
INSERT INTO inv_exp_nm.g3plant (npp, tpespar1, tpespar2, elag)
SELECT vp.npp, pl.tpespar1, pl.tpespar2, pl.elag
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN plantations pl USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

-- g3morts
INSERT INTO inv_exp_nm.g3morts (npp, incref, dep, cyc
	, a, ori, veget, espar, datemort, arbat, deggib, c13, lib)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, a.a, a1.ori, a1.veget, a1.espar, a1.datemort, (a1.suppl->>'arbat')::INT2 AS arbat, a14.deggib, a.c13_mm / 1000.0 AS c13, a1.lib
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 a14 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND a1.veget != '0'
ORDER BY npp, a;

INSERT INTO prod_exp.g3morts (npp, a, azpr_gd, dpr_cm)
SELECT vp.npp, a.a, a.azpr_gd, a.dpr_cm
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN arbre_m1 a USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
AND a.veget != '0'
ORDER BY npp;

-- g3strate
INSERT INTO inv_exp_nm.g3strate (npp, su, incref, dep, cyc, tca, tcl)
SELECT vp.npp, 2 AS su, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, c.tcar10 * 10.0 AS tca, c.tcar10 * 10.0 AS tcl
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

INSERT INTO prod_exp.g3strate (npp, su, tcar10)
SELECT vp.npp, 2 AS su, c.tcar10
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

-- g3renouv
INSERT INTO prod_exp.g3renouv (npp, nsnr, libnr_sp, pint_sp)
SELECT vp.npp, v.nsnr, v.libnr_sp, v.pint_sp
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN renouv v USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp, nsnr;

-- g3esp_renouv
INSERT INTO prod_exp.g3esp_renouv (npp, nsnr, espar, chnr, nint, nbrou, nfrot, nmixt)
SELECT vp.npp, v.nsnr, v.espar, v.chnr, v.nint, v.nbrou, v.nfrot, v.nmixt
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_renouv v USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp, nsnr, espar, chnr;

-- l1transect
WITH echs AS (
    SELECT c.millesime AS annee, ep.id_ech AS id_ech_point
    , et.id_ech AS id_ech_trans
    FROM echantillon ep
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et ON ep.id_campagne = et.id_campagne AND et.type_ue = 'T' AND et.phase_stat = 1
    WHERE ep.type_ue = 'P'
    AND ep.phase_stat = 1
    AND ep.ech_parent IS NULL
)
INSERT INTO inv_exp_nm.l1transect (npp, tra, incref, dep, cyc
    , aztrans)
SELECT p.npp, 0 AS tra, e.annee - 2005 AS incref, pe.dep, '5' AS cyc, t.aztrans
FROM point p
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echs e ON pe.id_ech = e.id_ech_point
INNER JOIN transect t USING (id_transect)
WHERE e.annee = 2024;

-- l1intersect
WITH echs AS (
    SELECT c.millesime AS annee, ep.id_ech AS id_ech_point
    , et.id_ech AS id_ech_trans
    FROM echantillon ep
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et ON ep.id_campagne = et.id_campagne AND et.type_ue = 'T' AND et.phase_stat = 1
    WHERE ep.type_ue = 'P'
    AND ep.phase_stat = 1
    AND ep.ech_parent IS NULL
)
INSERT INTO inv_exp_nm.l1intersect (npp, sl, incref, dep, cyc
    , disti, xi, yi, repi, flpi)
SELECT p.npp, f.sl_pi AS sl, e.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.disti, f.xi, f.yi, f.repi, f.flpi
FROM point p
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echs e ON pe.id_ech = e.id_ech_point
INNER JOIN fla_pi f ON e.id_ech_trans = f.id_ech AND p.id_transect = f.id_transect
WHERE e.annee = 2024;

-- l2segment
WITH echs AS (
    SELECT c.millesime AS annee, ep.id_ech AS id_ech_point
    , et.id_ech AS id_ech_trans
    FROM echantillon ep
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et ON ep.id_campagne = et.id_campagne AND et.type_ue = 'T' AND et.phase_stat = 2
    WHERE ep.type_ue = 'P'
    AND ep.phase_stat = 2
    AND ep.ech_parent IS NULL
)
INSERT INTO inv_exp_nm.l2segment (npp, sl, incref, dep, cyc
	, optersl, rep, tlhf2, poids, dseg)
SELECT p.npp, f.sl_lt AS sl, e.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.optersl, f.rep, f.tlhf2, te.poids
, f.dseg_dm / 10.0 AS dseg
FROM point p
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echs e ON pe.id_ech = e.id_ech_point
INNER JOIN fla_lt f ON e.id_ech_trans = f.id_ech AND p.id_transect = f.id_transect
INNER JOIN transect_ech te ON f.id_ech = te.id_ech AND f.id_transect = te.id_transect
WHERE e.annee = 2024;

-- l3segment
WITH echs AS (
    SELECT c.millesime AS annee, ep.id_ech AS id_ech_point
    , et.id_ech AS id_ech_trans
    FROM echantillon ep
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et ON ep.id_campagne = et.id_campagne AND et.type_ue = 'T' AND et.phase_stat = 2
    WHERE ep.type_ue = 'P'
    AND ep.phase_stat = 2
    AND ep.ech_parent IS NULL
)
INSERT INTO inv_exp_nm.l3segment (npp, sl, incref, dep, cyc
    , murl, largs, exploit, longdescr, entfl, azhaie)
SELECT p.npp, f.sl_lt AS sl, e.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.murl, f.largs, f.exploit, f.longdescr, f.entfl, f.azhaie_gd * PI() / 200.0 AS azhaie
FROM point p
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echs e ON pe.id_ech = e.id_ech_point
INNER JOIN fla f ON e.id_ech_trans = f.id_ech AND p.id_transect = f.id_transect
WHERE e.annee = 2024;

/*
-- l3arbre
ALTER TABLE inv_exp_nm.l3arbre DROP COLUMN d13;

WITH echs AS (
    SELECT c.millesime AS annee, ep.id_ech AS id_ech_point
    , et.id_ech AS id_ech_trans
    FROM echantillon ep
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN echantillon et ON ep.id_campagne = et.id_campagne AND et.type_ech = 'T' AND et.phase_stat = 2
    WHERE ep.type_ech = 'P'
    AND ep.phase_stat = 2
    AND ep.ech_parent IS NULL
)
INSERT INTO inv_exp_nm.l3arbre (npp, sl, a, incref, dep, cyc
	, rep, espar, decoupe, tetard, azpr, dpr, hdec, htot, c13)
SELECT p.npp, f.sl_lt AS sl, f.a, e.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.rep, f.espar, f.decoupe, f.tetard, f.azpr_gd * PI() / 200.0, f.dpr_cm / 100.0, f.hdec_dm / 10.0, f.htot_dm / 10.0, f.c13_mm / 1000.0
FROM point p
INNER JOIN point_ech pe USING (id_point)
INNER JOIN echs e ON pe.id_ech = e.id_ech_point
INNER JOIN arbre_fla f ON e.id_ech_trans = f.id_ech AND p.id_transect = f.id_transect
WHERE e.annee = 2024;

ALTER FOREIGN TABLE inv_exp_nm.l3arbre ADD COLUMN d13 float8;
*/

-- p3point
INSERT INTO inv_exp_nm.p3point (npp, incref, dep, cyc
    , plisi, cslisi, dist, dc, tplant, entp, integr, iti, portance, asperite, pentexp, incid
    , andain
    , bord, dcespar1, peupnr, nincid, orniere
    , pbuis, atpyr
    , ornr, prnr, fouil, predom)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, d1.plisi, d1.cslisi, d1.dist, d.dc, d.tplant, d.suppl->>'entp' AS entp
, d1.integr, d1.iti, d1.portance, d1.asperite, d1.pentexp, d.incid, d1.andain::INT, d1.bord
, c.dcespar1, d.peupnr, d.nincid, d1.orniere
, b.pbuis, b.atpyr
, d1.ornr, d1.prnr, d1.fouil, d1.predom
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN coupes c USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY vp.npp;

INSERT INTO prod_exp.p3point (npp, plas15, plas25, azdcoi_gd, azdlim_gd, azdlim2_gd, azlim1_gd, azlim2_gd, dcoi_cm, dlim_cm, dlim2_cm
    , ncbuis10, ncbuis_a, ncbuis_b, ncbuis_c, ncbuis_d, ncbuis_e
    , tcnr, dispnr)
SELECT vp.npp, d1.plas15, d1.plas25, l.azdcoi_gd, l.azdlim_gd, l.azdlim2_gd, l.azlim1_gd, l.azlim2_gd, l.dcoi_cm, l.dlim_cm, l.dlim2_cm
, b.ncbuis10, b.ncbuis_a, b.ncbuis_b, b.ncbuis_c, b.ncbuis_d, b.ncbuis_e
, d1.tcnr, d1.dispnr
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN limites l USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY vp.npp;

-- p3agedom
INSERT INTO inv_exp_nm.p3agedom (npp, incref, dep, cyc
	, su, numa, a, typdom, age13, cam)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, 2 AS su, a.numa, a.a, a.typdom, a.age13, NULL AS cam
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN age a USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
UNION
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc, 0 AS su, 0 AS numa, NULL AS a, NULL AS typdom, NULL AS age13, d.suppl->>'cam' AS cam
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
AND d.suppl->>'cam' IS NOT NULL
ORDER BY npp, numa;

-- p3arbre --> transformation de hbv et hbm en hbv_dm et hbm_dm pour que cela fonctionne (hrb_dm n'est pas divisé par 10 ????)
INSERT INTO inv_exp_nm.p3arbre (npp, incref, dep, cyc
	, a, ori, veget, acci, lib, qbp, hbv, hbm, espar, decoupe, simplif, cible, arbat, deggib
	, hdec, htot, c13
	, mortb, sfgui, ma, mr, hrb_dm, ddec)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, a.a, a1.ori, a1.veget, a1.acci, a1.lib, a1.qbp, a1.hbv_dm / 10.0, a1.hbm_dm / 10.0, a1.espar, a1.decoupe, a1.simplif, a1.cible, (a1.suppl->>'arbat')::INT2 AS arbat, a14.deggib, a1.hdec_dm / 10.0 AS hdec, a1.htot_dm / 10.0 AS htot
, a.c13_mm / 1000.0, s.mortb, s.sfgui, s.ma, s.mr, a1.hrb_dm, a14.ddec_cm / 100.0
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 a14 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa = '5'
AND a1.veget = '0'
ORDER BY npp, a;

INSERT INTO prod_exp.p3arbre (npp, a, azpr_gd, dpr_cm)
SELECT vp.npp
, a.a, a1.azpr_gd, a1.dpr_cm
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa = '5'
AND a1.veget = '0'
ORDER BY npp, a;

-- p3boism
INSERT INTO inv_exp_nm.p3boism(npp, incref, dep, cyc, a, frepli, decomp, espar, dbm)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, bm.a, bm.frepli, bm.decomp, bm.espar, bm.dbm_cm / 100.0 AS dbm
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN bois_mort bm USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp, a;

-- p3ecologie
INSERT INTO inv_exp_nm.p3ecologie (npp, incref, dep, cyc
	, dateeco, auteuref, expo, pent2, topo, masque, lign1, lign2, herb, humus
	, affroc
	, roche
	, cailloux, cai40
	, text1, text2, prof1, prof2
	, pcalc, pcalf, pox, ppseudo, pgley
	, tsol, obsdate, obshydr, obspedo, obsprof, obstopo, obsveget, obschemin, mousse, distriv, denivriv
	, htext, msud, typcai, typriv)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
    , e.dateeco, e.auteuref, e.expo, e.pent2, e.topo, e.masque, l.lign1, l.lign2, e.herb, e.humus
    , (CASE WHEN e.affroc = 'X' THEN NULL ELSE e.affroc END)::INT2
    , e.roche
    , (CASE WHEN e.cailloux = 'X' THEN NULL ELSE e.cailloux END)::INT2, (CASE WHEN e.cai40 = 'X' THEN NULL ELSE e.cai40 END)::INT2
    , e.text1, e.text2, e.prof1, e.prof2
    , (CASE WHEN e.pcalc = 'X' THEN NULL ELSE e.pcalc END)::INT2, (CASE WHEN e.pcalf = 'X' THEN NULL ELSE e.pcalf END)::INT2
    , (CASE WHEN e.pox = 'X' THEN NULL ELSE e.pox END)::INT2, (CASE WHEN e.ppseudo = 'X' THEN NULL ELSE e.ppseudo END)::INT2, (CASE WHEN e.pgley = 'X' THEN NULL ELSE e.pgley END)::INT2
    , e.tsol, e.obsdate, e.obshydr, e.obspedo, e.obsprof, e.obstopo, e.obsveget, e.obschemin, e.mousse, e.distriv, e.denivriv
    , e1.htext, e1.msud, e1.typcai, e1.typriv
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN ecologie e USING (id_ech, id_point)
LEFT JOIN ecologie_2017 e1 USING (id_ech, id_point)
LEFT JOIN ligneux l USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

-- p3essence
INSERT INTO inv_exp_nm.p3essence (npp, incref, dep, cyc, su, espar, p1525)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, 2 AS su, e.espar
, CASE WHEN e.p7ares = '1' THEN '0' ELSE '1' END AS p1525
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_r e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

INSERT INTO prod_exp.p3essence (npp, su, espar, tcr10, tclr10)
SELECT vp.npp, 2 AS su, e.espar, e.tcr10, e.tclr10
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_r e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

-- p3flore
INSERT INTO inv_exp_nm.p3flore (npp, incref, dep, cyc, codesp, abond)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, f.codesp, f.abond
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

INSERT INTO prod_exp.p3flore (npp, codesp, inco_flor)
SELECT vp.npp, f.codesp, f.inco_flor
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN flore f USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

-- p3plant
INSERT INTO inv_exp_nm.p3plant (npp, incref, dep, cyc
	, tpespar1, tpespar2)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, pl.tpespar1, pl.tpespar2--, pl.elag
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN plantations pl USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

-- p3morts
INSERT INTO inv_exp_nm.p3morts (npp, incref, dep, cyc
	, a, ori, veget, espar, datemort, arbat, deggib, c13, lib)
SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, a.a, a1.ori, a1.veget, a1.espar, a1.datemort, (a1.suppl->>'arbat')::INT2 AS arbat, a14.deggib, a.c13_mm / 1000.0 AS c13, a1.lib
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 a14 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND r.csa = '5'
AND a1.veget != '0'
ORDER BY npp, a;

INSERT INTO prod_exp.p3morts (npp, a, azpr_gd, dpr_cm)
SELECT vp.npp, a.a, a.azpr_gd, a.dpr_cm
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN arbre_m1 a USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
AND a.veget != '0'
ORDER BY npp;

-- p3strate
INSERT INTO inv_exp_nm.p3strate (npp, su, incref, dep, cyc
, tca, tcl)
SELECT vp.npp, 2 AS su, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
, c.tcar10 * 10.0 AS tca, c.tcar10 * 10.0 AS tcl
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

INSERT INTO prod_exp.p3strate (npp, su, tcar10)
SELECT vp.npp, 2 AS su, c.tcar10
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp;

-- p3renouv
INSERT INTO prod_exp.p3renouv (npp, nsnr, libnr_sp, pint_sp)
SELECT vp.npp, v.nsnr, v.libnr_sp, v.pint_sp
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN renouv v USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp, nsnr;

-- g3esp_renouv
INSERT INTO prod_exp.p3esp_renouv (npp, nsnr, espar, chnr, nint, nbrou, nfrot, nmixt)
SELECT vp.npp, v.nsnr, v.espar, v.chnr, v.nint, v.nbrou, v.nfrot, v.nmixt
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN espar_renouv v USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa = '5'
ORDER BY npp, nsnr, espar, chnr;

COMMIT;
-------------------------------------------------------------------------------------------
-- POINTS DEUXIÈME VISITE
BEGIN;

/*
ALTER TABLE prod_exp.g3foret 
    ADD COLUMN datepoint5 DATE;

ALTER TABLE prod_exp.p3point 
    ADD COLUMN datepoint5 DATE;

UPDATE prod_exp.g3foret pef
SET datepoint5 = p2.datepoint5::DATE
FROM inv_prod.e1point p
INNER JOIN inv_prod.e2point p2 ON p.npp = p2.npp
LEFT JOIN inv_prod.g3foret f ON p.npp = f.npp
WHERE p.npp LIKE '%T'
AND p2.datepoint5 IS NOT NULL 
AND p2.retour5 = '1'
AND pef.npp = p2.npp;

UPDATE prod_exp.p3point pef
SET datepoint5 = p2.datepoint5::DATE
FROM inv_prod.e1point p
INNER JOIN inv_prod.e2point p2 ON p.npp = p2.npp
LEFT JOIN inv_prod.p3point f ON p.npp = f.npp
WHERE p.npp LIKE '%T'
AND p2.datepoint5 IS NOT NULL 
AND p2.retour5 = '1'
AND pef.npp = p2.npp;
*/

UPDATE prod_exp.g3foret pef
SET reco5 = pl.reco, pointok5 = p2.pointok5, csa5 = r.csa, nincid5 = d.nincid, incid5 = d.incid, dc5 = d.dc, def5 = r2.def5, datepoint5 = pl.datepoint
FROM v_liste_points_lt2 vp
INNER JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN point_m2 p2 USING (id_ech, id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
LEFT JOIN reco_m2 r2 USING (id_ech, id_point)
LEFT JOIN description d USING (id_ech, id_point)
WHERE vp.annee = 2024
AND pef.npp = vp.npp;

UPDATE prod_exp.p3point pef
SET reco5 = pl.reco, pointok5 = p2.pointok5, csa5 = r.csa, nincid5 = d.nincid, incid5 = d.incid, dc5 = d.dc, def5 = r2.def5, datepoint5 = pl.datepoint
FROM v_liste_points_lt2 vp
INNER JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
LEFT JOIN point_m2 p2 USING (id_ech, id_point)
LEFT JOIN reco_m2 r2 USING (id_ech, id_point)
LEFT JOIN description d USING (id_ech, id_point)
WHERE vp.annee = 2024
AND pef.npp = vp.npp;

SET enable_nestloop = FALSE;

UPDATE prod_exp.g3arbre pea
SET veget5 = a2.veget5, c135 = ROUND((a.c13_mm / 1000.0)::NUMERIC, 3)
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND pea.npp = vp.npp
AND pea.a = a.a;

UPDATE prod_exp.p3arbre pea
SET veget5 = a2.veget5, c135 = ROUND((a.c13_mm / 1000.0)::NUMERIC, 3)
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND pea.npp = vp.npp
AND pea.a = a.a;

UPDATE prod_exp.g3morts pem
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND pem.npp = vp.npp
AND pem.a = a.a;

UPDATE prod_exp.p3morts pem
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE vp.annee = 2024
AND pem.npp = vp.npp
AND pem.a = a.a;

-- ajout de VEGET5 dans INV_EXP_NM
--ALTER TABLE inv_exp_nm.g3arbre
--    ADD COLUMN veget5 char(1);

--ALTER TABLE inv_exp_nm.p3arbre
--   ADD COLUMN veget5 char(1);

--ALTER TABLE inv_exp_nm.g3morts
--    ADD COLUMN veget5 char(1);

--ALTER TABLE inv_exp_nm.p3morts
--    ADD COLUMN veget5 char(1);

--ALTER FOREIGN TABLE inv_exp_nm.g3arbre
--    ADD COLUMN veget5 char(1);

--ALTER FOREIGN TABLE inv_exp_nm.p3arbre
--    ADD COLUMN veget5 char(1);

--ALTER FOREIGN TABLE inv_exp_nm.g3morts
--    ADD COLUMN veget5 char(1);

--ALTER FOREIGN TABLE inv_exp_nm.p3morts
--    ADD COLUMN veget5 char(1);


SET enable_nestloop = FALSE;

UPDATE inv_exp_nm.g3arbre pea
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE pea.npp = vp.npp
AND pea.a = a.a
AND vp.annee = 2024; 

UPDATE inv_exp_nm.p3arbre pea
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE pea.npp = vp.npp
AND pea.a = a.a
AND vp.annee = 2024; 

UPDATE inv_exp_nm.g3morts pea
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE pea.npp = vp.npp
AND pea.a = a.a
AND vp.annee = 2024; 

UPDATE inv_exp_nm.p3morts pea
SET veget5 = a2.veget5
FROM v_liste_points_lt2 vp
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
WHERE pea.npp = vp.npp
AND pea.a = a.a
AND vp.annee = 2024; 


SET enable_nestloop = FALSE;


-- Correction des VEGET5 impossibles (zombies, disparus sur coupe totale...)
/*
-- CONTRÔLER LES CAS AU PRÉALABLE
WITH arbres AS (
    SELECT incref, npp, a, veget, veget5
    FROM inv_exp_nm.g3arbre
    WHERE incref >= 10
    UNION
    SELECT incref, npp, a, veget, veget5
    FROM inv_exp_nm.p3arbre
    WHERE incref >= 10
    UNION
    SELECT incref, npp, a, veget, veget5
    FROM inv_exp_nm.g3morts
    WHERE incref >= 10
    UNION
    SELECT incref, npp, a, veget, veget5
    FROM inv_exp_nm.p3morts
    WHERE incref >= 10
)
, veg AS (
    SELECT i.incref, m."mode", m.libelle
    FROM metaifn.addonnee d 
    INNER JOIN metaifn.aiunite i ON d.unite = i.unite AND i.site = 'F'
    LEFT JOIN metaifn.abmode m ON i.dcunite = m.unite
    WHERE d.donnee = 'VEGET'
)
, veg5 AS (
    SELECT i.incref, m."mode", m.libelle
    FROM metaifn.addonnee d
    INNER JOIN metaifn.aiunite i ON d.unite = i.unite AND i.site = 'F'
    LEFT JOIN metaifn.abmode m ON i.dcunite = m.unite
    WHERE d.donnee = 'VEGET5'
)
SELECT a.incref + 2005 AS annee_v1, a.veget, v.libelle AS lib_veget
, a.veget5, v5.libelle AS lib_veget5
, count(*) AS nb_arbres
FROM arbres a
LEFT JOIN veg v ON a.incref = v.incref AND a.veget = v."mode"
LEFT JOIN veg5 v5 ON a.incref = v5.incref AND a.veget5 = v5."mode"
WHERE a.incref <= 19
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3;
*/

UPDATE inv_exp_nm.g3morts SET veget5 = 'M' WHERE incref = 13 AND veget IN ('5', 'C') AND veget5 = '0';
UPDATE inv_exp_nm.g3morts SET veget5 = '1' WHERE incref = 13 AND veget = 'A' AND veget5 = '0';
UPDATE inv_exp_nm.g3morts SET veget5 = '2' WHERE incref = 13 AND veget = 'A' AND veget5 = 'M';

-- arbres non retrouvés sur points coupés
/*
SELECT dc5, count(*)
FROM inv_exp_nm.g3arbre
INNER JOIN prod_exp.g3foret USING (npp)
WHERE veget5 = 'N'
GROUP BY 1
ORDER BY 1;
*/
-- voir script /home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/exploitation/Corrections/20210617_correction_INFO_pts_proximite_foret.sql



INSERT INTO prod_exp.g3arbre5 (npp, a, veget, dpr, azpr, c13, htot, espar, decoupe, hdec, agrafc)
SELECT vp2.npp, a.a, a1.veget, ROUND((a1.dpr_cm / 100.0)::NUMERIC, 2) AS dpr, a1.azpr_gd * PI() / 200 AS azpr
, a.c13_mm / 1000.0 AS c13, a1.htot_dm / 10.0 AS htot, a1.espar, a1.decoupe, a1.hdec_dm / 10.0 AS hdec, am1.agrafc
FROM v_liste_points_lt2 vp2
INNER JOIN descript_m2 USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 am1 USING (id_ech, id_point, a)
INNER JOIN v_liste_points_lt1 vp1 ON vp2.npp = vp1.npp AND vp1.annee = vp2.annee - 5
INNER JOIN reconnaissance r ON vp1.id_ech = r.id_ech AND vp1.id_point = r.id_point AND r.csa IN ('1', '3')
WHERE vp2.annee = 2024;

INSERT INTO prod_exp.p3arbre5 (npp, a, veget, dpr, azpr, c13, htot, espar, decoupe, hdec, agrafc)
SELECT vp2.npp, a.a, a1.veget, ROUND((a1.dpr_cm / 100.0)::NUMERIC, 2) AS dpr, a1.azpr_gd * PI() / 200 AS azpr
, a.c13_mm / 1000.0 AS c13, a1.htot_dm / 10.0 AS htot, a1.espar, a1.decoupe, a1.hdec_dm / 10.0 AS hdec, am1.agrafc
FROM v_liste_points_lt2 vp2
INNER JOIN descript_m2 USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 am1 USING (id_ech, id_point, a)
INNER JOIN v_liste_points_lt1 vp1 ON vp2.npp = vp1.npp AND vp1.annee = vp2.annee - 5
INNER JOIN reconnaissance r ON vp1.id_ech = r.id_ech AND vp1.id_point = r.id_point AND r.csa = '5'
WHERE vp2.annee = 2024;

SET enable_nestloop = TRUE;

COMMIT;

/*
-- CHARGEMENT DES ARBRES NOUVELLEMENT RECRUTÉS SUR POINTS REVISITÉS
-- liste des échantillons deuxième visite terrain avec l'échantillon première visite terrain correspondant
CREATE TEMPORARY TABLE echantils AS 
SELECT et2.id_ech AS ech2, et2.nom_ech AS nom2, et1.id_ech AS ech1, et1.nom_ech AS nom1
FROM echantillon et2
INNER JOIN campagne ct2 ON et2.id_campagne = ct2.id_campagne
INNER JOIN echantillon ep2 ON et2.ech_parent_stat = ep2.id_ech
INNER JOIN echantillon et1 ON ep2.ech_parent = et1.ech_parent_stat AND et1.phase_stat = 2
WHERE et2.type_ue = 'P' AND et2.type_ech = 'IFN'
AND et2.ech_parent IS NOT NULL
AND et2.nom_ech LIKE 'FR%'
ORDER BY et2.id_ech;

-- liste des arbres levés en deuxième visite et absents au premier lever (y compris les arbres des points lt1_pi2)
CREATE TEMPORARY TABLE arbres_nouv AS 
SELECT a2.id_ech, a2.id_point, p2.npp, a2.a
FROM arbre a2
INNER JOIN point p2 USING (id_point)
INNER JOIN echantils e2 ON a2.id_ech = e2.ech2
WHERE NOT EXISTS (
    SELECT 1
    FROM arbre a1
    INNER JOIN echantils e1 ON a1.id_ech = e1.ech1
    WHERE a2.id_point = a1.id_point
    AND a2.a = a1.a
				)
AND id_ech = 115
ORDER BY id_ech ASC;

INSERT INTO inv_exp_nm.g3arbre (npp, a, veget, espar, c13, ori, lib, cible, acci, htot, hdec, decoupe, ddec, incref, dep, cyc)

SELECT an.npp, a.id_ech, a.id_point, an.a, am.veget, am.espar, a.c13_mm / 1000.0, am.ori, am.lib, am.cible, am.acci, am.htot_dm / 10.0, am.hdec_dm / 10.0, am.decoupe, am14.ddec_cm / 100.0, f.incref, f.dep, f.cyc
FROM arbres_nouv an
INNER JOIN inv_exp_nm.g3foret f USING (npp)
INNER JOIN arbre a USING (id_ech, id_point, a)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 am14 USING (id_ech, id_point, a)
WHERE id_ech = 115;


INSERT INTO inv_exp_nm.p3arbre (npp, a, veget, espar, c13, ori, lib, cible, acci, htot, hdec, decoupe, ddec, incref, dep, cyc)

SELECT an.npp, an.a, am.veget, am.espar, a.c13_mm / 1000.0, am.ori, am.lib, am.cible, am.acci, am.htot_dm / 10.0, am.hdec_dm / 10.0, am.decoupe, am14.ddec_cm / 100.0, f.incref, f.dep, f.cyc
FROM arbres_nouv an
INNER JOIN inv_exp_nm.p3point f USING (npp)
INNER JOIN arbre a USING (id_ech, id_point, a)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
LEFT JOIN arbre_m1_2014 am14 USING (id_ech, id_point, a)
WHERE id_ech = 115;





(npp, a, ess, lib, htot, gtot, v, incref, dep, cyc, cld, clcir, vr, fr, cldim1, cldim2, cldim3, ec, espar, ori, veget, ad, abg, abv, av, rv, rg, pg, acci, essg16, decoupe, hdec, simplif, cible, clac, clad, orig, pv, vpr_an_act, pvpr, gpr_an_act, pgpr, nt, wac, pgchab_an, vmort, vmort_an, gmort, gmort_an, ntmort, ntmort_an, vchab, vchab_an, gchab, gchab_an, ntchab, ntchab_an, ddec, v5, dv5_an)




DROP TABLE echantils;
DROP TABLE arbres_nouv;
*/

-- À EXÉCUTER EN BASE DE PRODUCTION
ANALYZE inv_exp_nm.e1noeud;
ANALYZE inv_exp_nm.e1point;
ANALYZE inv_exp_nm.e1coord;
ANALYZE inv_exp_nm.e2point;
ANALYZE prod_exp.e2point;
ANALYZE inv_exp_nm.g3foret;
ANALYZE prod_exp.g3foret;
ANALYZE inv_exp_nm.g3agedom;
ANALYZE inv_exp_nm.g3arbre;
ANALYZE prod_exp.g3arbre;
ANALYZE inv_exp_nm.g3arbre_coord;
ANALYZE inv_exp_nm.g3boism;
ANALYZE inv_exp_nm.g3ecologie;
ANALYZE inv_exp_nm.g3essence;
ANALYZE prod_exp.g3essence;
ANALYZE inv_exp_nm.g3flore;
ANALYZE prod_exp.g3flore;
ANALYZE inv_exp_nm.g3plant;
ANALYZE inv_exp_nm.g3morts;
ANALYZE prod_exp.g3morts;
ANALYZE inv_exp_nm.g3strate;
ANALYZE prod_exp.g3strate;
ANALYZE prod_exp.g3renouv;
ANALYZE prod_exp.g3esp_renouv;
ANALYZE inv_exp_nm.g3habitat;
ANALYZE inv_exp_nm.l1intersect;
ANALYZE inv_exp_nm.l1transect;
ANALYZE inv_exp_nm.l2segment;
ANALYZE inv_exp_nm.l3segment;
--ANALYZE inv_exp_nm.l3arbre;
ANALYZE inv_exp_nm.p3point;
ANALYZE prod_exp.p3point;
ANALYZE inv_exp_nm.p3agedom;
ANALYZE inv_exp_nm.p3arbre;
ANALYZE prod_exp.p3arbre;
ANALYZE inv_exp_nm.p3boism;
ANALYZE inv_exp_nm.p3ecologie;
ANALYZE inv_exp_nm.p3essence;
ANALYZE prod_exp.p3essence;
ANALYZE inv_exp_nm.p3flore;
ANALYZE prod_exp.p3flore;
ANALYZE inv_exp_nm.p3plant;
ANALYZE inv_exp_nm.p3morts;
ANALYZE prod_exp.p3morts;
ANALYZE inv_exp_nm.p3strate;
ANALYZE prod_exp.p3strate;
ANALYZE prod_exp.g3arbre5;
ANALYZE prod_exp.p3arbre5;

-- À EXÉCUTER EN BASE D'EXPLOITATION
ANALYZE inv_exp_nm.e1noeud;
ANALYZE inv_exp_nm.e1point;
ANALYZE inv_exp_nm.e1coord;
ANALYZE inv_exp_nm.e2point;
ANALYZE prod_exp.e2point;
ANALYZE inv_exp_nm.g3foret;
ANALYZE prod_exp.g3foret;
ANALYZE inv_exp_nm.g3agedom;
ANALYZE inv_exp_nm.g3arbre;
ANALYZE prod_exp.g3arbre;
ANALYZE inv_exp_nm.g3arbre_coord;
ANALYZE inv_exp_nm.g3boism;
ANALYZE inv_exp_nm.g3ecologie;
ANALYZE inv_exp_nm.g3essence;
ANALYZE prod_exp.g3essence;
ANALYZE inv_exp_nm.g3flore;
ANALYZE prod_exp.g3flore;
ANALYZE inv_exp_nm.g3plant;
ANALYZE inv_exp_nm.g3morts;
ANALYZE prod_exp.g3morts;
ANALYZE inv_exp_nm.g3strate;
ANALYZE prod_exp.g3strate;
ANALYZE prod_exp.g3renouv;
ANALYZE prod_exp.g3esp_renouv;
ANALYZE inv_exp_nm.g3habitat;
ANALYZE inv_exp_nm.l1intersect;
ANALYZE inv_exp_nm.l1transect;
ANALYZE inv_exp_nm.l2segment;
ANALYZE inv_exp_nm.l3segment;
--ANALYZE inv_exp_nm.l3arbre;
ANALYZE inv_exp_nm.p3point;
ANALYZE prod_exp.p3point;
ANALYZE inv_exp_nm.p3agedom;
ANALYZE inv_exp_nm.p3arbre;
ANALYZE prod_exp.p3arbre;
ANALYZE inv_exp_nm.p3boism;
ANALYZE inv_exp_nm.p3ecologie;
ANALYZE inv_exp_nm.p3essence;
ANALYZE prod_exp.p3essence;
ANALYZE inv_exp_nm.p3flore;
ANALYZE prod_exp.p3flore;
ANALYZE inv_exp_nm.p3plant;
ANALYZE inv_exp_nm.p3morts;
ANALYZE prod_exp.p3morts;
ANALYZE inv_exp_nm.p3strate;
ANALYZE prod_exp.p3strate;
ANALYZE prod_exp.g3arbre5;
ANALYZE prod_exp.p3arbre5;

-- À EXÉCUTER EN BASE D'EXPLOITATION
VACUUM ANALYZE inv_exp_nm.e1noeud;
VACUUM ANALYZE inv_exp_nm.e1point;
VACUUM ANALYZE inv_exp_nm.e1coord;
VACUUM ANALYZE inv_exp_nm.e2point;
VACUUM ANALYZE prod_exp.e2point;
VACUUM ANALYZE inv_exp_nm.g3foret;
VACUUM ANALYZE prod_exp.g3foret;
VACUUM ANALYZE inv_exp_nm.g3agedom;
VACUUM ANALYZE inv_exp_nm.g3arbre;
VACUUM ANALYZE prod_exp.g3arbre;
VACUUM ANALYZE inv_exp_nm.g3arbre_coord;
VACUUM ANALYZE inv_exp_nm.g3boism;
VACUUM ANALYZE inv_exp_nm.g3ecologie;
VACUUM ANALYZE inv_exp_nm.g3essence;
VACUUM ANALYZE prod_exp.g3essence;
VACUUM ANALYZE inv_exp_nm.g3flore;
VACUUM ANALYZE prod_exp.g3flore;
VACUUM ANALYZE inv_exp_nm.g3plant;
VACUUM ANALYZE inv_exp_nm.g3morts;
VACUUM ANALYZE prod_exp.g3morts;
VACUUM ANALYZE inv_exp_nm.g3strate;
VACUUM ANALYZE prod_exp.g3strate;
VACUUM ANALYZE prod_exp.g3renouv;
VACUUM ANALYZE prod_exp.g3esp_renouv;
VACUUM ANALYZE inv_exp_nm.g3habitat;
VACUUM ANALYZE inv_exp_nm.l1intersect;
VACUUM ANALYZE inv_exp_nm.l1transect;
VACUUM ANALYZE inv_exp_nm.l2segment;
VACUUM ANALYZE inv_exp_nm.l3segment;
--VACUUM ANALYZE inv_exp_nm.l3arbre;
VACUUM ANALYZE inv_exp_nm.p3point;
VACUUM ANALYZE prod_exp.p3point;
VACUUM ANALYZE inv_exp_nm.p3agedom;
VACUUM ANALYZE inv_exp_nm.p3arbre;
VACUUM ANALYZE prod_exp.p3arbre;
VACUUM ANALYZE inv_exp_nm.p3boism;
VACUUM ANALYZE inv_exp_nm.p3ecologie;
VACUUM ANALYZE inv_exp_nm.p3essence;
VACUUM ANALYZE prod_exp.p3essence;
VACUUM ANALYZE inv_exp_nm.p3flore;
VACUUM ANALYZE prod_exp.p3flore;
VACUUM ANALYZE inv_exp_nm.p3plant;
VACUUM ANALYZE inv_exp_nm.p3morts;
VACUUM ANALYZE prod_exp.p3morts;
VACUUM ANALYZE inv_exp_nm.p3strate;
VACUUM ANALYZE prod_exp.p3strate;
VACUUM ANALYZE prod_exp.g3arbre5;
VACUUM ANALYZE prod_exp.p3arbre5;


/*
-- corrections sur les limites pour calcul du poids des arbres
BEGIN;


COMMIT;
*/
-------------------------------------------------------------------------------
-------------------- CHARGEMENT DES DONNEES HABITAT----------------------------
------------------------ POINTS PREMIERE VISITE -------------------------------
-- g3habitat
.INSERT INTO inv_exp_nm.g3habitat (npp, num_hab, hab, obshab, qualhab, s_hab)
SELECT vp.npp, h.num_hab, h.hab, h.obshab, h.qualhab, h.s_hab
FROM v_liste_points_lt1 vp
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN habitat h USING (id_ech, id_point)
WHERE vp.annee = 2024
AND r.csa IN ('1', '3')
ORDER BY npp;

------------------------ POINTS DEUXIÈME VISITE --------------------------------
-- ajout des habitats sur points retour
INSERT INTO inv_exp_nm.g3habitat (npp, num_hab, hab, obshab, qualhab, s_hab)
SELECT vp2.npp, h.num_hab, h.hab, h.obshab, h.qualhab, h.s_hab--, id_ech, id_point
FROM v_liste_points_lt2 vp2
INNER JOIN descript_m2 USING (id_ech, id_point)
INNER JOIN habitat h USING (id_ech, id_point)
WHERE vp2.annee = 2022
AND NOT EXISTS (
    SELECT 1
    FROM inv_exp_nm.g3habitat eh
    WHERE eh.npp = vp2.npp
    AND eh.num_hab = h.num_hab
);

UPDATE inv_exp_nm.g3foret fi
SET caracthab = d.caracthab
FROM v_liste_points_lt2 vp2
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m2 d2 USING (id_ech, id_point)
WHERE vp2.annee = 2024
AND vp2.npp = fi.npp
AND d.caracthab IS NOT NULL
AND fi.caracthab IS DISTINCT FROM d.caracthab;


-- correction du chargement de quelques données écologiques
UPDATE inv_exp_nm.g3ecologie ie
SET affroc = (CASE WHEN e.affroc = 'X' THEN NULL ELSE e.affroc END)::INT2
, cailloux = (CASE WHEN e.cailloux = 'X' THEN NULL ELSE e.cailloux END)::INT2
, cai40 = (CASE WHEN e.cai40 = 'X' THEN NULL ELSE e.cai40 END)::INT2
, pcalc = (CASE WHEN e.pcalc = 'X' THEN NULL ELSE e.pcalc END)::INT2
, pcalf = (CASE WHEN e.pcalf = 'X' THEN NULL ELSE e.pcalf END)::INT2
, pox = (CASE WHEN e.pox = 'X' THEN NULL ELSE e.pox END)::INT2
, ppseudo = (CASE WHEN e.ppseudo = 'X' THEN NULL ELSE e.ppseudo END)::INT2
, pgley = (CASE WHEN e.pgley = 'X' THEN NULL ELSE e.pgley END)::INT2
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND ie.npp = vp.npp;

UPDATE inv_exp_nm.p3ecologie ie
SET affroc = (CASE WHEN e.affroc = 'X' THEN NULL ELSE e.affroc END)::INT2
, cailloux = (CASE WHEN e.cailloux = 'X' THEN NULL ELSE e.cailloux END)::INT2
, cai40 = (CASE WHEN e.cai40 = 'X' THEN NULL ELSE e.cai40 END)::INT2
, pcalc = (CASE WHEN e.pcalc = 'X' THEN NULL ELSE e.pcalc END)::INT2
, pcalf = (CASE WHEN e.pcalf = 'X' THEN NULL ELSE e.pcalf END)::INT2
, pox = (CASE WHEN e.pox = 'X' THEN NULL ELSE e.pox END)::INT2
, ppseudo = (CASE WHEN e.ppseudo = 'X' THEN NULL ELSE e.ppseudo END)::INT2
, pgley = (CASE WHEN e.pgley = 'X' THEN NULL ELSE e.pgley END)::INT2
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE vp.annee = 2024
AND ie.npp = vp.npp;

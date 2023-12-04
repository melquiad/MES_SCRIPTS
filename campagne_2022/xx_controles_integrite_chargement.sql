/**************************************************************************************************************
 * CONTRÔLE DU CHARGEMENT DE L'ÉCHANTILLON PREMIÈRE VISITE                                                    *
 **************************************************************************************************************/
-- NOMBRE DE POINTS
-- Dans Soif
SELECT count(*) AS nb_points
FROM soif.v1e2point
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022; -- => 7525 points

-- En base de production
SELECT count(*) AS nb_points
FROM v_liste_points_lt1
WHERE annee = 2022; -- => 7525 points


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE RECONNAISSANCE
-- Dans Soif
SELECT count(*) AS nb_lignes, count(auteurlt) AS auteurlt, count(datepoint) AS datepoint, count(reco) AS reco
, count(duracc) AS duracc, count(posipr) AS posipr, count(pclos) AS pclos, count(pdiff) AS pdiff, count(csa) AS csa, count(obscsa) AS obscsa, count(utip) AS utip
, count(bois) AS bois, count(doute_bois) AS doute_bois, count(autut) AS autut, count(tform) AS tform, count(tauf) AS tauf, count(leve) AS leve
, count(qleve) AS qleve, count(eflt) AS eflt, count(rp) AS rp, count(azrp_gd) AS azrp_gd, count(drp_cm) AS drp_cm
, count(qreco) AS qreco, count(qbois) AS qbois, count(pobs) AS pobs, count(vegrp) AS vegrp, count(esprp) AS esprp, count(c13rp_mm) AS c13rp_mm
FROM soif.v1e2point
LEFT JOIN soif.v1e2observ USING (npp)
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022; -- => 7525 points

-- En base de production
SELECT count(*) AS nb_lignes, count(auteurlt) AS auteurlt, count(datepoint) AS datepoint, count(reco) AS reco
, count(duracc) AS duracc, count(posipr) AS posipr, count(pclos) AS pclos, count(pdiff) AS pdiff, count(csa) AS csa, count(obscsa) AS obscsa, count(utip) AS utip
, count(bois) AS bois, count(doute_bois) AS doute_bois, count(autut) AS autut, count(tform) AS tform, count(tauf) AS tauf, count(leve) AS leve
, count(qleve) AS qleve, count(eflt) AS eflt, count(rp) AS rp, count(azrp_gd) AS azrp_gd, count(drp_cm) AS drp_cm
, count(qreco) AS qreco, count(qbois) AS qbois, count(point_lt.suppl->>'pobs') AS pobs, count(vegrp) AS vegrp, count(esprp) AS esprp, count(c13rp_mm) AS c13rp_mm
FROM v_liste_points_lt1
INNER JOIN point_lt USING (id_ech, id_point)
LEFT JOIN reconnaissance USING (id_ech, id_point)
LEFT JOIN point_m1 USING (id_ech, id_point)
LEFT JOIN reco_2015 USING (id_ech, id_point)
LEFT JOIN reco_m1 USING (id_ech, id_point)
WHERE annee = 2022;

-- DÉCOMPTE DES EFFECTIFS DE DATERECO
-- Dans Soif
SELECT COUNT(*)
FROM soif.data_cache d
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022
AND donnee = $$DATERECO$$;

-- En base de production
SELECT COUNT(datereco)
FROM v_liste_points_lt1
INNER JOIN point_lt USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE DESCRIPTION
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr, count(cam) AS cam, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant, count(entp) AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM soif.v1e3point
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr
, count(description.suppl->>'cam') AS cam
, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant
, count(description.suppl->>'entp') AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM v_liste_points_lt1
INNER JOIN description USING (id_ech, id_point)
LEFT JOIN descript_m1 USING (id_ech, id_point)
LEFT JOIN limites USING (id_ech, id_point)
LEFT JOIN buis USING (id_ech, id_point)
LEFT JOIN coupes USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE PLANTATION
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm, count(maille) AS maille, count(videplant) AS videplant
FROM soif.v1e3plant
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022
AND (tpespar1, tpespar2, elag, bplant_dm, iplant_dm, videpeuplier, maille, videplant) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- En base de production
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm
, count(suppl->>'maille') AS maille
, count(videplant) AS videplant
FROM v_liste_points_lt1
INNER JOIN plantations USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE STRATES RECENSABLES
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM soif.v1e3strate
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM v_liste_points_lt1
INNER JOIN couv_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ESSENCES RECENSABLES
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM soif.v1e3essence
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM v_liste_points_lt1
INNER JOIN espar_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ÉCOLOGIE
-- Dans Soif
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo
, COUNT(affroc_2017) AS affroc, COUNT(cailloux_2017) AS cailloux
, COUNT(cai40_2017) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc_2017) AS pcalc, COUNT(pcalf_2017) AS pcalf, COUNT(pox_2017) AS pox
, COUNT(ppseudo_2017) AS ppseudo, COUNT(pgley_2017) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM soif.v1e3ecologie
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo, COUNT(affroc) AS affroc, COUNT(cailloux) AS cailloux
, COUNT(cai40) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc) AS pcalc, COUNT(pcalf) AS pcalf, COUNT(pox) AS pox
, COUNT(ppseudo) AS ppseudo, COUNT(pgley) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM v_liste_points_lt1
INNER JOIN ecologie USING (id_ech, id_point)
LEFT JOIN ecologie_2017 USING (id_ech, id_point)
LEFT JOIN ligneux USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE FLORE
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM soif.v1e3flore
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM v_liste_points_lt1
INNER JOIN flore USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'HABITATS
-- Dans Soif
SELECT count(caracthab) AS caracthab, count(ligneriv) AS ligneriv
, count(hab1) AS hab1, count(obshab1) AS obshab1, count(qualhab1) AS qualhab1, count(s_hab1) AS s_hab1
, count(hab2) AS hab2, count(obshab2) AS obshab2, count(qualhab2) AS qualhab2, count(s_hab2) AS s_hab2
, count(hab3) AS hab3, count(obshab3) AS obshab3, count(qualhab3) AS qualhab3, count(s_hab3) AS s_hab3
FROM soif.v1e3habitat
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(caracthab) AS caracthab
, count(d.suppl->>'ligneriv') AS ligneriv
, count(h1.hab) AS hab1, count(h1.obshab) AS obshab1, count(h1.qualhab) AS qualhab1, count(h1.s_hab) AS s_hab1
, count(h2.hab) AS hab2, count(h2.obshab) AS obshab2, count(h2.qualhab) AS qualhab2, count(h2.s_hab) AS s_hab2
, count(h3.hab) AS hab3, count(h3.obshab) AS obshab3, count(h3.qualhab) AS qualhab3, count(h3.s_hab) AS s_hab3
FROM v_liste_points_lt1 v
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE BOIS MORT AU SOL
-- Dans Soif
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM soif.v1e3boism
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM v_liste_points_lt1
INNER JOIN bois_mort USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ARBRES
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbat) AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM soif.v1e3arbre
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbre_m1.suppl->>'arbat') AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM v_liste_points_lt1
INNER JOIN arbre USING (id_ech, id_point)
LEFT JOIN arbre_2014 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;

-- DÉCOMPTE DES EFFECTIFS DE DATEARBRE
-- Dans Soif
SELECT count(*)
FROM soif.data_cache d
INNER JOIN soif.v1e3arbre a ON d.npp = a.npp AND d.domaine = a.domaine
INNER JOIN soif.point_anref ar ON d.npp = ar.npp
WHERE right(d.npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022
AND donnee = $$DATEARBRE$$
AND format = $$TV1E3ARBRE$$;

-- En base de production
SELECT COUNT(datearbre)
FROM v_liste_points_lt1
INNER JOIN arbre_2014 USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ACCROISSEMENTS
-- Dans Soif
WITH accroi AS (
    SELECT npp, id_a, 0 AS nir, ir0_1_10mm AS ir
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir0_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 5 AS nir, ir5_1_10mm
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir5_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, ncern AS nir, irn_1_10mm
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND irn_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 1 AS nir, ir1_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir1_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 2 AS nir, ir2_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir2_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 3 AS nir, ir3_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir3_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 4 AS nir, ir4_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'T'
    AND numvisi = '1'
    AND anref = 2022
    AND ir4_1_10mm IS NOT NULL
)
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(ir) AS irx_1_10mm
FROM accroi;

-- En base de production
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(irn_1_10_mm) AS irn_1_10_mm    
FROM v_liste_points_lt1
INNER JOIN accroissement USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES MESURES D'ÂGES
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(id_a) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM soif.v1e3arbre_age
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(numa) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM v_liste_points_lt1
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN age USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE RECONNAISSANCES LHF
-- Dans Soif
SELECT count(*) AS nb_lignes, count(sl) AS sl, count(optersl) AS optersl, count(dseg_dm) AS dseg_dm, count(rep) AS rep, count(tlhf2) AS tlhf2
FROM soif.v1l2segment
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(sl_lt) AS sl, count(optersl) AS optersl, count(dseg_dm) AS dseg_dm, count(rep) AS rep, count(tlhf2) AS tlhf2
FROM fla_lt f
INNER JOIN echantillon e ON f.id_ech = e.id_ech AND e.type_ech = 'T' AND e.phase_stat = 2
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2022;


-- DÉCOMPTE DES EFFECTIFS DE DESCRIPTION LHF
-- Dans Soif
SELECT count(*) AS nb_lignes, count(id_sl) AS sl, count(longdescr) AS longdescr, count(azhaie_gd) AS azhaie_gd, count(largs) AS largs, count(murl) AS murl, count(entfl) AS entfl, count(exploit) AS exploit
FROM soif.v1l3segment
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(sl_lt) AS sl, count(longdescr) AS longdescr, count(azhaie_gd) AS azhaie_gd, count(largs) AS largs, count(murl) AS murl, count(entfl) AS entfl, count(exploit) AS exploit
FROM fla f
INNER JOIN echantillon e ON f.id_ech = e.id_ech AND e.type_ech = 'T' AND e.phase_stat = 2
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ARBRES LHF
-- Dans Soif
SELECT count(*) AS nb_lignes, count(id_sl) AS sl, count(a) AS a, count(rep) AS rep, count(espar) AS espar, count(tetard) AS tetard, count(mortb) AS mortb, count(mes_c13) AS mes_c13
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(c13_mm) AS c13_mm
FROM soif.v1l3arbre
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'T'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(sl_lt) AS sl, count(a) AS a, count(rep) AS rep, count(espar) AS espar, count(tetard) AS tetard, count(mortb) AS mortb, count(mes_c13) AS mes_c13
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(c13_mm) AS c13_mm
FROM arbre_fla f
INNER JOIN echantillon e ON f.id_ech = e.id_ech AND e.type_ech = 'T' AND e.phase_stat = 2
INNER JOIN campagne c USING (id_campagne)
WHERE c.millesime = 2022;



/**************************************************************************************************************
 * CONTRÔLE DU CHARGEMENT DE L'ÉCHANTILLON DEUXIÈME VISITE                                                    *
 **************************************************************************************************************/
-- NOMBRE DE POINTS
-- Dans Soif
SELECT count(*) AS nb_points
FROM soif.v2e4point
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022; -- => 5847 points

-- En base de production
SELECT count(*) AS nb_points
FROM v_liste_points_lt2
WHERE annee = 2022; -- => 5847 points

-- DÉCOMPTE DES EFFECTIFS DE DATERECO5
-- Dans Soif
SELECT COUNT(*)
FROM soif.data_cache d
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022
AND donnee = $$DATERECO5$$;

-- En base de production
SELECT COUNT(datereco)
FROM v_liste_points_lt2
INNER JOIN point_lt USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE RECONNAISSANCE V2
-- Dans Soif
SELECT count(*) AS nb_lignes, count(auteurlt5) AS auteurlt5, count(datepoint5) AS datepoint5, count(reco5) AS reco5, count(pointok5) AS pointok5, count(csa5) AS csa5, count(evo_csa5) AS evo_csa5
, count(utip5) AS utip5, count(bois5) AS bois5, count(doute_bois5) AS doute_bois5, count(evo_bois5) AS evo_bois5, count(autut5) AS autut5, count(tform5) AS tform5, count(tauf5) AS tauf5, count(err_p) AS err_p
, count(def5) AS def5, count(evo_utip5) AS evo_utip5, count(eflt5) AS eflt5, count(qreco5) AS qreco5, count(qbois5) AS qbois5, count(pobs5) AS pobs5
FROM soif.v2e4point
LEFT JOIN soif.v2e4observ USING (npp)
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(auteurlt) AS auteurlt5, count(datepoint) AS datepoint5, count(reco) AS reco5, count(pointok5) AS pointok5, count(csa) AS csa5, count(evo_csa) AS evo_csa5
, count(utip) AS utip5, count(bois) AS bois5, count(doute_bois) AS doute_bois5, count(evo_bois) AS evo_bois5, count(autut) AS autut5, count(tform) AS tform5, count(tauf) AS tauf5
, count(reconnaissance.suppl->>'err_p') AS err_p
, count(def5) AS def5, count(evo_utip) AS evo_utip5, count(eflt) AS eflt5, count(qreco) AS qreco5, count(qbois) AS qbois5, count(point_lt.suppl->>'pobs') AS pobs5
FROM v_liste_points_lt2
INNER JOIN point_lt USING (id_ech, id_point)
LEFT JOIN reconnaissance USING (id_ech, id_point)
LEFT JOIN point_m2 USING (id_ech, id_point)
LEFT JOIN reco_2015 USING (id_ech, id_point)
LEFT JOIN reco_m2 USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE DESCRIPTION V2
-- Dans Soif
SELECT count(npp) AS nb_lignes
, count(nincid5) AS nincid5, count(incid5) AS incid5, count(peupnr5) AS peupnr5, count(nlisi5) AS nlisi5, count(dc5) AS dc5, count(instp5) AS instp5, count(tpespar15) AS tpespar15
, count(tpespar25) AS tpespar25, count(bplant5_dm) AS bplant5_dm, count(iplant5_dm) AS iplant5_dm
FROM soif.v2e5point5
LEFT JOIN soif.v2e5ecologie USING (npp)
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes
, count(nincid) AS nincid, count(incid) AS incid5, count(peupnr) AS peupnr5, count(nlisi5) AS nlisi5, count(dc) AS dc5, count(instp5) AS instp5, count(tpespar1) AS tpespar15
, count(tpespar2) AS tpespar25, count(bplant_dm) AS bplant5_dm, count(iplant_dm) AS iplant5_dm
FROM v_liste_points_lt2
INNER JOIN description USING (id_ech, id_point)
INNER JOIN descript_m2 USING (id_ech, id_point)
LEFT JOIN plantations USING (id_ech, id_point)
LEFT JOIN ligneux USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE DESCRIPTION V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr, count(cam) AS cam, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant, count(entp) AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM soif.v2e5point
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr
, count(description.suppl->>'cam') AS cam
, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant
, count(description.suppl->>'entp') AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM v_liste_points_lt2
INNER JOIN description USING (id_ech, id_point)
INNER JOIN descript_m1 USING (id_ech, id_point)
LEFT JOIN limites USING (id_ech, id_point)
LEFT JOIN buis USING (id_ech, id_point)
LEFT JOIN coupes USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE PLANTATION V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm, count(maille) AS maille, count(videplant) AS videplant
FROM soif.v2e5plant
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022
AND (tpespar1, tpespar2, elag, bplant_dm, iplant_dm, maille, videplant) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- En base de production
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm
, count(plantations.suppl->>'maille') AS maille
, count(videplant) AS videplant
FROM v_liste_points_lt2
INNER JOIN descript_m1 USING (id_ech, id_point)
INNER JOIN plantations USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE STRATES RECENSABLES V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM soif.v2e5strate
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM v_liste_points_lt2
INNER JOIN couv_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ESSENCES RECENSABLES V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM soif.v2e5essence
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM v_liste_points_lt2
INNER JOIN espar_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ÉCOLOGIE V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo, COUNT(affroc_2017) AS affroc, COUNT(cailloux_2017) AS cailloux
, COUNT(cai40_2017) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc_2017) AS pcalc, COUNT(pcalf_2017) AS pcalf, COUNT(pox_2017) AS pox
, COUNT(ppseudo_2017) AS ppseudo, COUNT(pgley_2017) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM soif.v2e5ecologie
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo, COUNT(affroc) AS affroc, COUNT(cailloux) AS cailloux
, COUNT(cai40) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc) AS pcalc, COUNT(pcalf) AS pcalf, COUNT(pox) AS pox
, COUNT(ppseudo) AS ppseudo, COUNT(pgley) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM v_liste_points_lt2
INNER JOIN ecologie USING (id_ech, id_point)
LEFT JOIN ecologie_2017 USING (id_ech, id_point)
LEFT JOIN ligneux USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE FLORE V1
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM soif.v2e5flore
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM v_liste_points_lt2
INNER JOIN flore USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'HABITATS V1
-- Dans Soif
SELECT count(caracthab) AS caracthab, count(ligneriv) AS ligneriv
, count(hab1) AS hab1, count(obshab1) AS obshab1, count(qualhab1) AS qualhab1, count(s_hab1) AS s_hab1
, count(hab2) AS hab2, count(obshab2) AS obshab2, count(qualhab2) AS qualhab2, count(s_hab2) AS s_hab2
, count(hab3) AS hab3, count(obshab3) AS obshab3, count(qualhab3) AS qualhab3, count(s_hab3) AS s_hab3
FROM soif.v2e5habitat
INNER JOIN soif.v2e5point USING (npp)
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(caracthab) AS caracthab
, count(d.suppl->>'ligneriv') AS ligneriv
, count(h1.hab) AS hab1, count(h1.obshab) AS obshab1, count(h1.qualhab) AS qualhab1, count(h1.s_hab) AS s_hab1
, count(h2.hab) AS hab2, count(h2.obshab) AS obshab2, count(h2.qualhab) AS qualhab2, count(h2.s_hab) AS s_hab2
, count(h3.hab) AS hab3, count(h3.obshab) AS obshab3, count(h3.qualhab) AS qualhab3, count(h3.s_hab) AS s_hab3
FROM v_liste_points_lt2 v
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE BOIS MORT AU SOL V1
-- Dans Soif
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM soif.v2e5boism
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM v_liste_points_lt2
INNER JOIN bois_mort USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ARBRES V2
-- Dans Soif
SELECT count(*) AS nb_lignes, count(typerr_a) AS typerr_a, count(veget5) AS veget5, count(mes_c135) AS mes_c135, count(c135_mm) AS c135_mm
FROM soif.v2e5arbre5
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(arbre_m2.suppl->>'typerr_a') AS typerr_a, count(veget5) AS veget5, count(mes_c135) AS mes_c135, count(c13_mm) AS c135_mm
FROM v_liste_points_lt2
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN arbre_2014 USING (id_ech, id_point, a)
INNER JOIN arbre_m2 USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;

SET enable_nestloop = TRUE;

-- DÉCOMPTE DES EFFECTIFS DE DATEARBRE5
-- Dans Soif
SELECT COUNT(*)
FROM (
    SELECT d.npp, a.a, cast(d.mode AS DATE) AS datearbre
    FROM soif.data_cache d
    INNER JOIN soif.v2e5arbre a ON d.npp = a.npp AND d.domaine = a.domaine
    INNER JOIN soif.point_anref pa ON d.npp = pa.npp
    WHERE numvisi = '2'
    AND anref = 2022
    AND donnee = $$DATEARBRE$$
    AND format = $$TV2E5ARBRE$$
    UNION
    SELECT d.npp, a.a, cast(d.mode AS DATE) AS datearbre
    FROM soif.data_cache d
    INNER JOIN soif.v2e5arbre_new5 a ON d.npp = a.npp AND d.domaine = a.domaine
    INNER JOIN soif.point_anref pa ON d.npp = pa.npp
    WHERE numvisi = '2'
    AND anref = 2022
    AND donnee = $$DATEARBRE$$
    AND format = $$TV2E5ARBRE_NEW5$$
    UNION
    SELECT d.npp, a.a, cast(d.mode AS DATE) AS datearbre
    FROM soif.data_cache d
    INNER JOIN soif.v2e5arbre5 a ON d.npp = a.npp AND d.domaine = a.domaine
    INNER JOIN soif.point_anref pa ON d.npp = pa.npp
    WHERE numvisi = '2'
    AND anref = 2022
    AND donnee = $$DATEARBRE5$$
    AND format = $$TV2E5ARBRE5$$
) AS t;

-- En base de production
SELECT COUNT(datearbre)
FROM v_liste_points_lt2
INNER JOIN arbre_2014 USING (id_ech, id_point)
WHERE annee = 2022;

-- DÉCOMPTE DES EFFECTIFS D'ARBRES NOUVEAUX V2
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm
FROM soif.v2e5arbre_new5
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm
FROM v_liste_points_lt2
INNER JOIN descript_m2 USING (id_ech, id_point)
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN arbre_2014 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 USING (id_ech, id_point, a)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ARBRES V1 + ARBRES NOUVEAUX V2
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbat) AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM soif.v2e5arbre
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbre_m1.suppl->>'arbat') AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM v_liste_points_lt2
INNER JOIN descript_m1 USING (id_ech, id_point)
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN arbre_2014 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;

SET enable_nestloop = FALSE;


-- DÉCOMPTE DES EFFECTIFS D'ACCROISSEMENTS V1
-- Dans Soif
WITH accroi AS (
    SELECT npp, id_a, 0 AS nir, ir0_1_10mm AS ir
    FROM soif.v2e5arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir0_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 5 AS nir, ir5_1_10mm
    FROM soif.v2e5arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir5_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, ncern AS nir, irn_1_10mm
    FROM soif.v2e5arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND irn_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 1 AS nir, ir1_1_10mm
    FROM soif.v2e5arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir1_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 2 AS nir, ir2_1_10mm
    FROM soif.v2e5arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir2_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 3 AS nir, ir3_1_10mm
    FROM soif.v2e5arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir3_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 4 AS nir, ir4_1_10mm
    FROM soif.v2e5arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE numvisi = '2'
    AND anref = 2022
    AND ir4_1_10mm IS NOT NULL
)
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(ir) AS irn_1_10mm
FROM accroi;

-- En base de production
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(irn_1_10_mm) AS irn_1_10_mm    
FROM v_liste_points_lt2
INNER JOIN accroissement USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES MESURES D'ÂGES V1
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(id_a) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM soif.v2e5arbre_age
INNER JOIN soif.point_anref USING (npp)
WHERE numvisi = '2'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(numa) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM v_liste_points_lt2
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN age USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;



/**************************************************************************************************************
 * CONTRÔLE DU CHARGEMENT DE L'ÉCHANTILLON PREMIÈRE VISITE SUR DEUXIÈME PI                                    *
 **************************************************************************************************************/
-- NOMBRE DE POINTS
-- Dans Soif
SELECT count(*) AS nb_points
FROM soif.v1e2point
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;-- => 116 points

-- En base de production
SELECT count(*) AS nb_points
FROM v_liste_points_lt1_pi2
WHERE annee = 2022; -- => 116 points


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE RECONNAISSANCE
-- Dans Soif
SELECT count(*) AS nb_lignes, count(auteurlt) AS auteurlt, count(datepoint) AS datepoint, count(reco) AS reco
, count(duracc) AS duracc, count(posipr) AS posipr, count(pclos) AS pclos, count(pdiff) AS pdiff, count(csa) AS csa, count(obscsa) AS obscsa, count(utip) AS utip
, count(bois) AS bois, count(doute_bois) AS doute_bois, count(autut) AS autut, count(tform) AS tform, count(tauf) AS tauf, count(leve) AS leve
, count(qleve) AS qleve, count(eflt) AS eflt, count(rp) AS rp, count(azrp_gd) AS azrp_gd, count(drp_cm) AS drp_cm
, count(qreco) AS qreco, count(qbois) AS qbois, count(pobs) AS pobs, count(vegrp) AS vegrp, count(esprp) AS esprp, count(c13rp_mm) AS c13rp_mm
FROM soif.v1e2point
LEFT JOIN soif.v1e2observ USING (npp)
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(auteurlt) AS auteurlt, count(datepoint) AS datepoint, count(reco) AS reco
, count(duracc) AS duracc, count(posipr) AS posipr, count(pclos) AS pclos, count(pdiff) AS pdiff, count(csa) AS csa, count(obscsa) AS obscsa, count(utip) AS utip
, count(bois) AS bois, count(doute_bois) AS doute_bois, count(autut) AS autut, count(tform) AS tform, count(tauf) AS tauf, count(leve) AS leve
, count(qleve) AS qleve, count(eflt) AS eflt, count(rp) AS rp, count(azrp_gd) AS azrp_gd, count(drp_cm) AS drp_cm
, count(qreco) AS qreco, count(qbois) AS qbois, count(point_lt.suppl->>'pobs') AS pobs, count(vegrp) AS vegrp, count(esprp) AS esprp, count(c13rp_mm) AS c13rp_mm
FROM v_liste_points_lt1_pi2
INNER JOIN point_lt USING (id_ech, id_point)
LEFT JOIN reconnaissance USING (id_ech, id_point)
LEFT JOIN point_m1 USING (id_ech, id_point)
LEFT JOIN reco_2015 USING (id_ech, id_point)
LEFT JOIN reco_m1 USING (id_ech, id_point)
WHERE annee = 2022;

-- DÉCOMPTE DES EFFECTIFS DE DATERECO
-- Dans Soif
SELECT COUNT(*)
FROM soif.data_cache d
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022
AND donnee = $$DATERECO$$;

-- En base de production
SELECT COUNT(datereco)
FROM v_liste_points_lt1_pi2
INNER JOIN point_lt USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE DESCRIPTION
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr, count(cam) AS cam, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant, count(entp) AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM soif.v1e3point
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(plas25) AS plas25, count(plas15) AS plas15, count(dlim_cm) AS dlim_cm, count(azdlim_gd) AS azdlim_gd, count(dlim2_cm) AS dlim2_cm
, count(azdlim2_gd ) AS azdlim2_gd, count(dcoi_cm) AS dcoi_cm, count(azdcoi_gd) AS azdcoi_gd, count(azlim1_gd) AS azlim1_gd, count(azlim2_gd) AS azlim2_gd, count(deppr) AS deppr
, count(plisi) AS plisi, count(cslisi) AS cslisi
, count(bord) AS bord, count(integr) AS integr, count(peupnr) AS peupnr
, count(description.suppl->>'cam') AS cam
, count(sver) AS sver, count(gest) AS gest, count(nincid) AS nincid
, count(incid) AS incid, count(dc) AS dc, count(dcespar1) AS dcespar1, count(andain) AS andain, count(abrou) AS abrou, count(tplant) AS tplant
, count(description.suppl->>'entp') AS entp
, count(iti) AS iti, count(dist) AS dist, count(pentexp) AS pentexp, count(portance) AS portance, count(asperite) AS asperite, count(orniere) AS orniere
, count(tcat10) AS tcat10, count(href_dm) AS href_dm, count(pbuis) AS pbuis
, count(dpyr) AS dpyr, count(anpyr) AS anpyr
, count(azdep_gd) AS azdep_gd, count(ddep_cm) AS ddep_cm     
FROM v_liste_points_lt1_pi2
INNER JOIN description USING (id_ech, id_point)
LEFT JOIN descript_m1 USING (id_ech, id_point)
LEFT JOIN limites USING (id_ech, id_point)
LEFT JOIN buis USING (id_ech, id_point)
LEFT JOIN coupes USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS PAR DONNÉES DE PLANTATION
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm, count(maille) AS maille, count(videplant) AS videplant
FROM soif.v1e3plant
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022
AND (tpespar1, tpespar2, elag, bplant_dm, iplant_dm, maille, videplant) IS DISTINCT FROM (NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- En base de production
SELECT count(npp) AS nb_lignes, count(tpespar1) AS tpespar1, count(tpespar2) AS tpespar2, count(elag) AS elag, count(bplant_dm) AS bplant_dm
, count(iplant_dm) AS iplant_dm
, count(suppl->>'maille') AS maille
, count(videplant) AS videplant
FROM v_liste_points_lt1_pi2
INNER JOIN plantations USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE STRATES RECENSABLES
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM soif.v1e3strate
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(tcar10) AS tcar10
FROM v_liste_points_lt1_pi2
INNER JOIN couv_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ESSENCES RECENSABLES
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM soif.v1e3essence
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(espar) AS espar, count(tcr10) AS tcr10, count(tclr10) AS tclr10, count(p7ares) AS p7ares, count(cible) AS cible
FROM v_liste_points_lt1_pi2
INNER JOIN espar_r USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ÉCOLOGIE
-- Dans Soif
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo, COUNT(affroc_2017) AS affroc, COUNT(cailloux_2017) AS cailloux
, COUNT(cai40_2017) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc_2017) AS pcalc, COUNT(pcalf_2017) AS pcalf, COUNT(pox_2017) AS pox
, COUNT(ppseudo_2017) AS ppseudo, COUNT(pgley_2017) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM soif.v1e3ecologie
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, COUNT(auteuref) AS auteuref, COUNT(dateeco) AS dateeco, COUNT(obsdate) AS obsdate, COUNT(obsveget) AS obsveget, COUNT(lign1) AS lign1, COUNT(lign2) AS lign2, COUNT(herb) AS herb
, COUNT(mousse) AS mousse, COUNT(topo) AS topo, COUNT(obstopo) AS obstopo, COUNT(obschemin) AS obschemin, COUNT(distriv) AS distriv
, COUNT(denivriv) AS denivriv, COUNT(pent2) AS pent2, COUNT(expo) AS expo, COUNT(masque) AS masque, COUNT(st_a1) AS st_a1, COUNT(humus) AS humus
, COUNT(roche) AS roche, COUNT(obspedo) AS obspedo, COUNT(az_fo) AS az_fo, COUNT(affroc) AS affroc, COUNT(cailloux) AS cailloux
, COUNT(cai40) AS cai40, COUNT(text1) AS text1, COUNT(text2) AS text2, COUNT(prof2) AS prof2, COUNT(obsprof) AS obsprof, COUNT(prof1) AS prof1, COUNT(pcalc) AS pcalc, COUNT(pcalf) AS pcalf, COUNT(pox) AS pox
, COUNT(ppseudo) AS ppseudo, COUNT(pgley) AS pgley, COUNT(obshydr) AS obshydr, COUNT(tsol) AS tsol, COUNT(msud) AS msud, COUNT(oln) AS oln, COUNT(olv) AS olv, COUNT(olt) AS olt, COUNT(ofr) AS ofr
, COUNT(oh) AS oh, COUNT(typriv) AS typriv, COUNT(typcai) AS typcai, COUNT(di_fo_cm) AS di_fo_cm, COUNT(htext) AS htext
FROM v_liste_points_lt1_pi2
INNER JOIN ecologie USING (id_ech, id_point)
LEFT JOIN ecologie_2017 USING (id_ech, id_point)
LEFT JOIN ligneux USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE FLORE
-- Dans Soif
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM soif.v1e3flore
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(npp) AS nb_lignes, count(codesp) AS codesp, count(abond) AS abond, count(inco_flor) AS inco_flor
FROM v_liste_points_lt1_pi2
INNER JOIN flore USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'HABITATS
-- Dans Soif
SELECT count(caracthab) AS caracthab, count(ligneriv) AS ligneriv
, count(hab1) AS hab1, count(obshab1) AS obshab1, count(qualhab1) AS qualhab1, count(s_hab1) AS s_hab1
, count(hab2) AS hab2, count(obshab2) AS obshab2, count(qualhab2) AS qualhab2, count(s_hab2) AS s_hab2
, count(hab3) AS hab3, count(obshab3) AS obshab3, count(qualhab3) AS qualhab3, count(s_hab3) AS s_hab3
FROM soif.v1e3habitat
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(caracthab) AS caracthab
, count(d.suppl->>'ligneriv') AS ligneriv
, count(h1.hab) AS hab1, count(h1.obshab) AS obshab1, count(h1.qualhab) AS qualhab1, count(h1.s_hab) AS s_hab1
, count(h2.hab) AS hab2, count(h2.obshab) AS obshab2, count(h2.qualhab) AS qualhab2, count(h2.s_hab) AS s_hab2
, count(h3.hab) AS hab3, count(h3.obshab) AS obshab3, count(h3.qualhab) AS qualhab3, count(h3.s_hab) AS s_hab3
FROM v_liste_points_lt1_pi2 v
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS DE BOIS MORT AU SOL
-- Dans Soif
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM soif.v1e3boism
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes, count(a) AS a, count(frepli) AS frepli, count(espar) AS espar, count(dbm_cm) AS dbm_cm, count(decomp) AS decomp
FROM v_liste_points_lt1_pi2
INNER JOIN bois_mort USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES EFFECTIFS D'ARBRES
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbat) AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM soif.v1e3arbre
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(a) AS a, count(veget) AS veget, count(espar) AS espar, count(mes_c13) AS mes_c13, count(azpr_gd) AS azpr_gd, count(dpr_cm) AS dpr_cm, count(simplif) AS simplif
, count(ori) AS ori, count(acci) AS acci, count(cible) AS cible, count(lib) AS lib, count(datemort) AS datemort, count(repere) AS repere, count(arbre_m1.suppl->>'arbat') AS arbat, count(mortb) AS mortb, count(sfgui) AS sfgui, count(deggib) AS deggib
, count(htot_dm) AS htot_dm, count(decoupe) AS decoupe, count(hdec_dm) AS hdec_dm, count(ddec_cm) AS ddec_cm, count(c13_mm) AS c13_mm, count(qbp) AS qbp, count(hbv_dm) AS hbv_dm, count(hbm_dm) AS hbm_dm, count(hrb_dm) AS hrb_dm
, count(ma) AS ma, count(mr) AS mr, count(hcd_cm) AS hcd_cm    
FROM v_liste_points_lt1_pi2
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN arbre_2014 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 USING (id_ech, id_point, a)
INNER JOIN arbre_m1_2014 USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;

-- DÉCOMPTE DES EFFECTIFS DE DATEARBRE
-- Dans Soif
SELECT count(*)
FROM soif.data_cache d
INNER JOIN soif.point_anref USING (npp)
INNER JOIN soif.v1e3arbre a ON d.npp = a.npp AND d.domaine = a.domaine
WHERE right(d.npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022
AND donnee = $$DATEARBRE$$
AND format = $$TV1E3ARBRE$$;

-- En base de production
SELECT COUNT(datearbre)
FROM v_liste_points_lt1_pi2
INNER JOIN arbre_2014 USING (id_ech, id_point)
WHERE annee = 2022;



-- DÉCOMPTE DES EFFECTIFS D'ACCROISSEMENTS
-- Dans Soif
WITH accroi AS (
    SELECT npp, id_a, 0 AS nir, ir0_1_10mm AS ir
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir0_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 5 AS nir, ir5_1_10mm
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir5_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, ncern AS nir, irn_1_10mm
    FROM soif.v1e3arbre 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND irn_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 1 AS nir, ir1_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir1_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 2 AS nir, ir2_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir2_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 3 AS nir, ir3_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir3_1_10mm IS NOT NULL
    UNION ALL 
    SELECT npp, id_a, 4 AS nir, ir4_1_10mm
    FROM soif.v1e3arbre_age 
    INNER JOIN soif.point_anref USING (npp)
    WHERE right(npp, 1) = 'R'
    AND numvisi = '1'
    AND anref = 2022
    AND ir4_1_10mm IS NOT NULL
)
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(ir) AS irx_1_10mm
FROM accroi;

-- En base de production
SELECT count(*) AS nb_lignes
, count(nir) AS nir, count(irn_1_10_mm) AS irn_1_10_mm    
FROM v_liste_points_lt1_pi2
INNER JOIN accroissement USING (id_ech, id_point)
WHERE annee = 2022;


-- DÉCOMPTE DES MESURES D'ÂGES
-- Dans Soif
SELECT count(*) AS nb_lignes
, count(id_a) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM soif.v1e3arbre_age
INNER JOIN soif.point_anref USING (npp)
WHERE right(npp, 1) = 'R'
AND numvisi = '1'
AND anref = 2022;

-- En base de production
SELECT count(*) AS nb_lignes
, count(numa) AS a, count(typdom) AS typdom, count(age13) AS age13, count(sfcoeur) AS sfcoeur, count(ncerncar) AS ncerncar, count(longcar) AS longcar
FROM v_liste_points_lt1_pi2
INNER JOIN arbre USING (id_ech, id_point)
INNER JOIN age USING (id_ech, id_point, a)
LEFT JOIN sante USING (id_ech, id_point, a)
WHERE annee = 2022;






/**************************************************************************************************************
 * CONTRÔLES FONCTIONNELS  -  PREMIÈRE VISITE                                                                 *
 **************************************************************************************************************/

-- CONTROLES DE LA RECONNAISSANCE 
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN reco IN ('0', '2') AND qreco IS NULL THEN '01. QRECO NULL sur RECO = 0 ou 2'
        WHEN reco IN ('0', '2') AND jsonb_path_query_first(pl.qual_data, ('$[*] ? (@.donnee == "QRECO")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Observation sur QRECO absente'
        WHEN reco = '0' AND duracc IS NOT NULL THEN '02a. DURACC renseigné sur RECO = 0'
        WHEN reco IN ('1', '2') AND duracc IS NULL THEN '02b. DURACC non renseigné sur RECO = 1 ou 2'
        WHEN reco IN ('0', '2') AND posipr IS NOT NULL THEN '03a. POSIPR renseigné sur RECO = 0 ou 2'
        WHEN reco = '1' AND posipr IS NULL THEN '03b. POSIPR non renseigné sur RECO = 1'
        WHEN reco = '0' AND pclos IS NOT NULL THEN '04a. PCLOS renseigné sur RECO = 0'
        WHEN reco IN ('1', '2') AND pclos IS NULL THEN '04b. PCLOS non renseigné sur RECO = 1 ou 2'
        WHEN pclos = '1' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "PCLOS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Observation sur PCLOS = 1 absente'
        WHEN reco = '0' AND pdiff IS NOT NULL THEN '05a. PDIFF renseigné sur RECO = 0'
        WHEN reco IN ('1', '2') AND pdiff IS NULL THEN '05b. PDIFF non renseigné sur RECO = 1 ou 2'
        WHEN pdiff = '1' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "PDIFF")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Observation sur PDIFF = 1 absente'
        WHEN reco = '0' AND csa IS NOT NULL THEN '06a. CSA renseigné sur RECO = 0'
        WHEN reco IN ('1', '2') AND csa IS NULL THEN '06b. CSA non renseigné sur RECO = 1 ou 2'
        WHEN csa IN ('1', '3', '5') AND obscsa IS NOT NULL THEN '07a. OBSCSA devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND obscsa IS NULL THEN '07b. OBSCSA NULL sur CSA non boisé'
        WHEN obscsa != '0' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "OBSCSA")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Observation sur OBSCSA absente'
        WHEN reco = '1' AND csa IN ('1', '3', '4L', '5') AND utip IS NULL THEN '08a. UTIP non renseigné sur CSA boisé / lande sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '4L', '5') AND utip IS NULL THEN '08b. UTIP non renseigné sur CSA boisé / lande sur point reconnu à distance'
        WHEN csa IN ('3', '4L') AND utip = 'V' THEN '08c. UTIP verger sur forêt ouverte ou lande'
        WHEN csa IN ('6A', '6H', '7', '8', '9') AND utip IS NOT NULL THEN '08d. UTIP devrait être à NULL'
        WHEN obscsa != 'X' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "UTIP")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99e. Observation sur UTIP absente'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND bois IS NULL THEN '09a. BOIS non renseigné sur CSA boisé sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '5') AND utip = 'X' AND bois IS NULL THEN '09b. BOIS non renseigné sur CSA boisé sur point reconnu à distance'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND bois IS NOT NULL THEN '09C. BOIS devrait être à NULL'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND doute_bois IS NULL THEN '10a. DOUTE_BOIS non renseigné sur CSA boisé sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '5') AND utip = 'X' AND doute_bois IS NULL THEN '10b. DOUTE_BOIS non renseigné sur CSA boisé sur point reconnu à distance'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND doute_bois IS NOT NULL THEN '10c. DOUTE_BOIS devrait être à NULL'
        WHEN doute_bois = '1' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "DOUTE_BOIS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99f. Observation sur DOUTE_BOIS absente'
        WHEN bois = '0' AND qbois IS NULL THEN '11a. QBOIS non renseigné sur BOIS = 0'
        WHEN bois = '1' AND qbois IS NOT NULL THEN '11b. QBOIS devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND qbois IS NOT NULL THEN '11c. QBOIS devrait être à NULL'
        WHEN bois = '0' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "BOIS" || @.donnee == "QBOIS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Observation sur BOIS ou QBOIS absente'
        WHEN bois = '1' AND autut IS NULL THEN '12a. AUTUT non renseigné sur BOIS = 1'
        WHEN bois = '0' AND autut IS NOT NULL THEN '12b. AUTUT devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND autut IS NOT NULL THEN '12c. AUTUT devrait être à NULL'
        WHEN csa IN ('1', '3', '4L', '5') AND tform IS NULL THEN '13a. TFORM non renseigné sur point boisé / lande'
        WHEN csa NOT IN ('1', '3', '4L', '5') AND tform IS NOT NULL THEN '13b. TFORM devrait être à NULL'
        WHEN csa = '4L' AND tform = '1' AND eflt IS NULL THEN '14a. EFLT non renseigné sur petite lande'
        WHEN NOT (csa = '4L' AND tform = '1') AND eflt IS NOT NULL THEN '14b. EFLT devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7') AND tauf IS NULL THEN '15a. TAUF NULL'
        WHEN csa NOT IN ('4L', '6A', '6H', '7') AND tauf IS NOT NULL THEN '15b. TAUF devrait être à NULL'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND bois = '1' AND leve IS NULL THEN '16a. LEVE non renseigné sur point disponible pour la production de bois'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'A' AND tform = '2' AND leve IS NULL THEN '16b. LEVE non renseigné sur forêt agricole'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND bois = '0' AND qbois IN ('11', '12', '13', '99') AND leve IS NULL THEN '16c. LEVE non renseigné sur motifs d''indisponibilité compatibles'
        WHEN leve = '0' AND qleve IS NULL THEN '17a. QLEVE non renseigné sur point non levé'
        WHEN leve = '0' AND jsonb_path_query_first(rm.qual_data, ('$[*] ? (@.donnee == "QLEVE")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99h. Observation sur QLEVE absente'
        WHEN reco = '1' AND rp IS NULL THEN '18. RP non renseigné sur point reconnu'
        WHEN rp IN ('1', '2', '3', '4') AND azrp_gd IS NULL THEN '19. AZRP non renseigné avec un élément repère'
        WHEN rp IN ('1', '2', '3', '4') AND drp_cm IS NULL THEN '20. DRP non renseigné avec un élément repère'
        WHEN rp IN ('1', '2') AND vegrp IS NULL THEN '21a. VEGRP non renseigné avec un arbre repère'
        WHEN rp NOT IN ('1', '2') AND vegrp IS NOT NULL THEN '21b. VEGRP renseigné sur élément repère non arboré'
        WHEN rp IN ('1', '2') AND esprp IS NULL THEN '22a. ESPRP non renseigné avec un arbre repère'
        WHEN rp NOT IN ('1', '2') AND esprp IS NOT NULL THEN '22b. ESPRP renseigné sur élément repère non arboré'
        WHEN rp IN ('1', '2') AND c13rp_mm IS NULL THEN '23a. C13RP non renseigné avec un arbre repère'
        WHEN rp NOT IN ('1', '2') AND esprp IS NOT NULL THEN '23b. C13RP renseigné sur élément repère non arboré'
        WHEN rp = '1' AND c13rp_mm < 235 THEN '23c. C13RP < 235 mm sur arbre recensable'
        WHEN rp = '2' AND c13rp_mm >= 235 THEN '23d. C13RP >= 235 mm sur arbre non recensable'
      END AS erreur
    FROM v_liste_points_lt1 v
    INNER JOIN point_lt pl USING (id_ech, id_point)
    LEFT JOIN point_m1 p1 USING (id_ech, id_point)
    LEFT JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN reco_2015 r1 USING (id_ech, id_point)
    LEFT JOIN reco_m1 rm USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- manques récurrents de commentaires dans des situations obligatoires

/*
SELECT npp, id_ech, id_point, reco, qreco, pclos, pl.suppl AS infos_suppl, pl.qual_data AS qualite1, r.qual_data AS qualite2
FROM v_liste_points_lt1 v
INNER JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN point_m1 p1 USING (id_ech, id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
LEFT JOIN reco_2015 r1 USING (id_ech, id_point)
LEFT JOIN reco_m1 rm USING (id_ech, id_point)
WHERE v.annee = 2022
AND reco IN ('1', '2')
AND pclos IS NULL
ORDER BY npp;
*/

-- POINTS AVEC datepoint HORS LIMITES DE DATES OFFICIELLES
SELECT v.npp, v.id_ech, v.id_point, datepoint
FROM v_liste_points_lt1 v
INNER JOIN point_lt USING (id_ech, id_point)
WHERE (datepoint < '01-10-2021'::DATE
	OR datepoint >= '21-12-2022'::DATE)
AND v.annee = 2022;
-- OK, la campagne s'est finie après basculement pour quelques points

-- CONTROLES DES DONNEES DE DESCRIPTION 
-- points marqués comme levés sans données de peuplement
SELECT v.npp, v.id_ech, v.id_point
FROM v_liste_points_lt1 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_m1 rm USING (id_ech, id_point)
LEFT JOIN description d USING (id_ech, id_point)
WHERE v.annee = 2022
AND csa IN ('1', '3', '5')
AND leve = '1'
AND d.id_ech IS NULL;

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN plas25 IS NULL THEN '01. PLAS25 NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IS NULL THEN '02a. PLAS15 NULL'
        WHEN plas25 NOT IN ('4', '5') AND plas15 IS NOT NULL THEN '02b. PLAS15 devrait être à NULL'
        WHEN plas25 IN ('4', '5') AND deppr IS NULL THEN '03a. DEPPR NULL'
        WHEN plas25 NOT IN ('4', '5') AND deppr IS NOT NULL THEN '03b. DEPPR devrait être à NULL'
        WHEN deppr = '1' AND azdep_gd IS NULL THEN '03c. AZDEP NULL'
        WHEN deppr != '1' AND azdep_gd IS NOT NULL THEN '03d. AZDEP devrait être à NULL'
        WHEN deppr = '1' AND ddep_cm IS NULL THEN '03e. DDEP NULL'
        WHEN deppr != '1' AND ddep_cm IS NOT NULL THEN '03d. DDEP devrait être à NULL'
        WHEN deppr = '1' AND jsonb_path_query_first(dm.qual_data, ('$[*] ? (@.donnee == "DEPPR")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Observation absente sur DEPPR'
        WHEN plas25 IN ('1', '3') AND dlim_cm IS NULL THEN '04a. DLIM_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND dlim_cm IS NULL THEN '04b. DLIM_CM NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim_cm IS NOT NULL THEN '04c. DLIM_CM devrait être à NULL'
        WHEN dlim_cm = 0 THEN '04d. DLIM = 0 interdit'
        WHEN plas25 IN ('1', '3') AND azdlim_gd IS NULL THEN '05a. AZDLIM_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND azdlim_gd IS NULL THEN '05b. AZDLIM_GD NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim_gd IS NOT NULL THEN '05c. AZDLIM_GD devrait être à NULL'
        WHEN plas25 = '3' AND dlim2_cm IS NULL THEN '06a. DLIM2_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND dlim2_cm IS NULL THEN '06b. DLIM2_CM NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim2_cm IS NOT NULL THEN '06c. DLIM2_CM devrait être à NULL'
        WHEN dlim2_cm < dlim_cm THEN '06d. DLIM2 < DLIM'
        WHEN plas25 = '3' AND azdlim2_gd IS NULL THEN '07a. AZDLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND azdlim2_gd IS NULL THEN '07b. AZDLIM2_GD NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim2_gd IS NOT NULL THEN '07c. AZDLIM2_GD devrait être à NULL'
        WHEN plas25 = '2' AND dcoi_cm IS NULL THEN '08a. DCOI_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND dcoi_cm IS NULL THEN '08b. DCOI_CM NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND dcoi_cm IS NOT NULL THEN '08c. DCOI_CM devrait être à NULL'
        WHEN dcoi_cm = 0 THEN '08d. DCOI = 0 interdit'
        WHEN plas25 = '2' AND azdcoi_gd IS NULL THEN '09a. AZDCOI_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azdcoi_gd IS NULL THEN '09b. AZDCOI_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azdcoi_gd IS NOT NULL THEN '09c. AZDCOI_GD devrait être à NULL'
        WHEN plas25 = '2' AND azlim1_gd IS NULL THEN '10a. AZLIM1_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim1_gd IS NULL THEN '10b. AZLIM1_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim1_gd IS NOT NULL THEN '10c. AZLIM1_GD devrait être à NULL'
        WHEN abs(azdcoi_gd - azlim1_gd) IN (0, 200, 400) THEN '10d. AZLIM1 aligné sur AZDCOI'
        WHEN plas25 = '2' AND azlim2_gd IS NULL THEN '11a. AZLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim2_gd IS NULL THEN '11b. AZLIM2_GD NULL'
        WHEN abs(azdcoi_gd - azlim2_gd) IN (0, 200, 400) THEN '10d. AZLIM2 aligné sur AZDCOI'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim2_gd IS NOT NULL THEN '11c. AZLIM2_GD devrait être à NULL'
        WHEN COALESCE(plas25, '0') != '0' AND plisi IS NULL THEN '12a. PLISI NULL'
        WHEN COALESCE(plas25, '0') = '0' AND plisi IS NOT NULL THEN '12b. PLISI devrait être à NULL'
        WHEN plisi IN ('1', '2') AND cslisi IS NULL THEN '13a. CSLISI NULL'
        WHEN plisi = '2' AND cslisi NOT IN ('7', '9', 'T') THEN '13b. Valeur illicite de CSLISI'
        WHEN COALESCE(plisi, '0') = '0' AND cslisi IS NOT NULL THEN '13c. CSLISI devrait être à NULL'
        WHEN bord IS NULL THEN '14. BORD NULL'
        WHEN integr IS NULL THEN '15. INTEGR NULL'
        WHEN tcat10 IS NULL THEN '16. TCAT10 NULL'
        WHEN peupnr IS NULL THEN '17. PEUPNR NULL'
        WHEN peupnr = '1' AND d.suppl->>'cam' IS NULL THEN '18a. CAM NULL'
        WHEN COALESCE(peupnr, '0') != '1' AND d.suppl->>'cam' IS NOT NULL THEN '18b. CAM devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND href_dm IS NULL THEN '19a. HREF NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND href_dm IS NOT NULL THEN '19b. HREF devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND sver IS NULL THEN '19c. SVER NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND sver IS NOT NULL THEN '19d. SVER devrait être à NULL'
        WHEN href_dm < 100 AND sver NOT IN ('2', '3', '4') THEN '18e. SVER incohérent avec HREF < 100'
        WHEN href_dm >= 100 AND sver NOT IN ('4', '5', '6') THEN '18f. SVER incohérent avec HREF >= 100'
        WHEN csa IN ('1', '3') AND gest IS NULL THEN '19. GEST NULL'
        WHEN nincid IS NULL THEN '20. NINCID NULL'
        WHEN nincid != '0' AND incid IS NULL THEN '21a. INCID NULL'
        WHEN COALESCE(nincid, '0') = '0' AND incid IS NOT NULL THEN '21b. INCID devrait être à NULL'
        WHEN dc IS NULL THEN '22. DC NULL'
        WHEN dc IN ('1', '2') AND dcespar1 IS NULL THEN '23a. DCESPAR1 NULL'
        WHEN COALESCE(dc, '0') NOT IN ('1', '2') AND dcespar1 IS NOT NULL THEN '23b. DCESPAR1 devrait être à NULL'
        WHEN andain IS NULL THEN '24. ANDAIN NULL'        
        WHEN abrou IS NULL THEN '25. ABROU NULL'      
        WHEN tplant IS NULL THEN '26a. TPLANT NULL'
        WHEN csa = '5' AND dc != '1' AND tplant = '0' THEN '26b. TPLANT incohérent sur coupe en peupleraie'
        WHEN COALESCE(tplant, '0') != '0' AND tpespar1 IS NULL THEN '27a. TPESPAR1 NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar1 IS NOT NULL THEN '27b. TPESPAR1 devrait être à NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar2 IS NOT NULL THEN '27c. TPESPAR2 devrait être à NULL'
        WHEN COALESCE(tplant, '0') != '0' AND elag IS NULL THEN '28a. ELAG NULL'
        WHEN COALESCE(tplant, '0') = '0' AND elag IS NOT NULL THEN '28b. ELAG devrait être à NULL'
        WHEN tplant = 'P' AND bplant_dm IS NULL THEN '29. BPLANT_DM NULL'
        WHEN tplant = 'P' AND iplant_dm IS NULL THEN '30. IPLANT_DM NULL'
        WHEN csa = '5' AND tplant = 'P' AND p.suppl->>'maille' IS NULL THEN '31. MAILLE NULL'
        WHEN csa = '5' AND tplant = 'P' AND d.suppl->>'entp' IS NULL THEN '32. ENTP NULL'
        WHEN tplant != '0' AND elag IS NULL THEN '33. ELAG NULL'
        WHEN iti IS NULL THEN '34. ITI NULL'      
        WHEN COALESCE(iti, '0') != '0' AND dist IS NULL THEN '35a. DIST NULL'
        WHEN COALESCE(iti, '0') = '0' AND dist IS NOT NULL THEN '35b. DIST devrait être à NULL'
        WHEN pentexp IS NULL THEN '36. PENTEXP NULL'
        WHEN pentexp NOT IN ('4', '5', 'X') AND portance IS NULL THEN '37a. PORTANCE NULL'
        WHEN COALESCE(pentexp, '0') IN ('4', '5', 'X') AND portance IS NOT NULL THEN '37b. PORTANCE devrait être à NULL'
        WHEN asperite NOT IN ('4', '5', 'X') AND asperite IS NULL THEN '38a. ASPERITE NULL'
        WHEN COALESCE(asperite, '0') IN ('4', '5', 'X') AND asperite IS NOT NULL THEN '38b. ASPERITE devrait être à NULL'
        WHEN orniere IS NULL THEN '39. ORNIERE NULL'
        WHEN pbuis IS NULL THEN '40. PBUIS NULL'
        WHEN pbuis != '0' AND dpyr IS NULL THEN '41. DPYR NULL'
        WHEN dpyr = '2' AND anpyr IS NULL THEN '42. ANPYR NULL'
      END AS erreur
    FROM v_liste_points_lt1 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    LEFT JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN limites l USING (id_ech, id_point)
    LEFT JOIN coupes c USING (id_ech, id_point)
    LEFT JOIN plantations p USING (id_ech, id_point)
    LEFT JOIN buis b USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- manque de commentaires obligatoires

/*
*/

-- CONTRÔLE SUPPLÉMENTAIRE SUR PEUPNR ET TAUX DE COUVERT RECENSABLE EN FORÊT
SELECT npp, id_ech, id_point, csa, peupnr, href_dm, dc, peupnr, sver, tcat10
FROM v_liste_points_lt1 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr != '2'
AND tcat10 = 0
ORDER BY npp;
-- 12 points

/*
SELECT npp, id_ech, id_point, peupnr, bord, integr, tcar10, tcat10, dc 
FROM v_liste_points_lt1 v
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr != '2'
AND tcat10 = 0
ORDER BY npp;
*/

-- CONTROLES DES DONNEES ARBRES
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point, a.a
    , csa, espar
    , CASE 
        WHEN veget IN ('5', 'C') AND datemort IS NULL THEN '01a. DATEMORT NULL' 
        WHEN veget NOT IN ('5', 'C') AND datemort IS NOT NULL THEN '01b. DATEMORT devrait être à NULL'
        WHEN veget = '0' AND simplif IS NULL THEN '02a. SIMPLIF NULL'
        WHEN veget != '0' AND simplif IS NOT NULL THEN '02a. SIMPLIF devrait être à NULL'
        WHEN veget = '0' AND repere IS NULL THEN '03a. REPERE NULL'
        WHEN (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NULL THEN '04a. LIB NULL'
        WHEN NOT (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NOT NULL THEN '04b. LIB devrait être à NULL'
        WHEN veget = '0' AND cible IS NULL THEN '05a. CIBLE NULL'
        WHEN veget != '0' AND cible IS NOT NULL THEN '05b. CIBLE devrait être à NULL'
        WHEN veget = '0' AND acci IS NULL THEN '06a. ACCI NULL'
        WHEN veget != '0' AND acci IS NOT NULL THEN '06b. ACCI devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND htot_dm IS NULL THEN '08a. HTOT NULL sur arbre vivant'
        WHEN veget = 'C' AND htot_dm IS NULL THEN '08b. HTOT NULL sur arbre mort sur pied cassé'
        WHEN veget = '0' AND decoupe IS NULL THEN '09a. DECOUPE NULL'
        WHEN veget != '0' AND decoupe IS NOT NULL THEN '09b. DECOUPE devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND hdec_dm IS NULL THEN '10. HDEC NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND ddec_cm IS NULL THEN '11. DDEC NULL'
        WHEN mes_c13 IN ('2', '3', '4') AND hcd_cm IS NULL THEN '12a. HCD NULL'
        WHEN mes_c13 = '2' AND NOT hcd_cm BETWEEN 80 AND 130 THEN '12b. HCD erroné sur moyenne de mesures'
        WHEN mes_c13 IN ('3', '4') AND NOT hcd_cm BETWEEN 50 AND 150 THEN '12c. HCD erroné sur mesure décalée ou autre cas'
        WHEN veget = '0' AND ori IS NULL THEN '13. ORI NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND qbp IS NULL THEN '14a. QBP NULL'
        WHEN hdec_dm < 3 AND qbp = '1' THEN '14b. Valeur erronnée de QBP'
        WHEN veget = '0' AND c13_mm >= 705 AND hrb_dm IS NULL THEN '15. HRB NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND lib != '0'AND lib!='1' AND ACCI='0' AND mortb IS NULL THEN '16. MORTB NULL'
        WHEN veget = '0' AND espar < '50' AND c13_mm >= 705 AND MORTB IN ('1','2','3') AND mr IS NULL THEN '16. MR NULL'
        WHEN veget = '0' AND espar > '50' AND c13_mm >= 705 AND MORTB IN ('1','2','3') AND ma IS NULL THEN '17. MA NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND sfgui IS NULL THEN '18. SFGUI NULL'
        WHEN c13_mm < 1175 AND deggib IS NULL THEN '19. DEGGIB NULL'
      END AS erreur
    FROM v_liste_points_lt1 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre_m1_2014 am4 USING (id_ech, id_point, a)
    LEFT JOIN sante s USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur, npp, a;

WITH no_accroi AS (
    SELECT v.npp, a.a
    FROM v_liste_points_lt1 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND csa IN ('1', '3') AND veget = '0' AND simplif = '0' AND espar NOT IN ('06', '27C', '27N') AND ac.id_ech IS NULL
)
SELECT ncern, count(*)
FROM soif.v1e3arbre a
INNER JOIN no_accroi na USING (npp, a)
GROUP BY 1
ORDER BY 1;
-- Tous à NCERN = 0 donc OK.

-- CONTROLES DES ARBAT/NOMBRE D'ARBRES REPÈRE FORÊT
-- contrôle sur le nombre d'arbres repère
SELECT npp, id_ech, id_point, nb_arbres, nb_reperes, nb_plaque, 'Problème sur le nombre d''arbres repères'
FROM (
	SELECT npp, id_ech, id_point, COUNT(*) AS nb_arbres
	, COUNT(*) FILTER (WHERE repere IN ('1', '2')) AS nb_reperes
	, COUNT(*) FILTER (WHERE repere = '2') AS nb_plaque
	FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND veget = '0'
	GROUP BY npp, id_ech, id_point
	HAVING (COUNT(*) > 3 AND COUNT(*) FILTER (WHERE repere IN ('1', '2')) < 3)
	OR SUM(CASE WHEN repere IN ('1', '2') THEN 1 ELSE 0 END) > 3
	OR SUM(CASE WHEN repere = '2' THEN 1 ELSE 0 END) = 0
) AS t
ORDER BY npp;		-- => pas d'erreur !

-- analyse de ARBAT
SELECT v.npp, v.id_ech, v.id_point, am.a, am.suppl->>'arbat' AS arbat
FROM v_liste_points_lt1 v
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
WHERE v.annee = 2022
AND am.suppl->>'arbat' IS NOT NULL
AND ab.id_ech IS NULL
ORDER BY npp, am.a;        -- => pas d'erreur !

SELECT v.npp, v.id_ech, v.id_point, am.a, am.espar, am.suppl->>'arbat' AS arbat, ab.a AS a2, ab.espar AS espar2
FROM v_liste_points_lt1 v
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
INNER JOIN arbre_m1 ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
WHERE v.annee = 2022
AND am.suppl->>'arbat' IS NOT NULL
AND am.espar != ab.espar
ORDER BY npp, am.a;        -- 1 erreur sur l'espèce

WITH dist_arbat AS (
    SELECT v.npp, v.id_ech, v.id_point
    , am.a, am.espar, a.c13_mm, am.suppl->>'arbat' AS arbat, am.azpr_gd, am.dpr_cm
    , am2.a AS a2, am2.espar AS espar_2, ab.c13_mm AS c13_mm_2, am2.azpr_gd AS azpr_gd2, am2.dpr_cm AS dpr_cm_2
    , ROUND(SQRT(((am2.dpr_cm / 100.0) * cos(pi() * (100.0 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * cos(pi() * (100.0 - am.azpr_gd / 200.0)))^2
     + ((am2.dpr_cm / 100.0) * sin(pi() * (100 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * sin(pi() * (100 - am.azpr_gd / 200.0)))^2)::NUMERIC, 2) AS dist
    FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
    LEFT JOIN arbre_m1 am2 ON ab.id_ech = am2.id_ech AND am.id_point = am2.id_point AND ab.a = am2.a
    WHERE v.annee = 2022
    AND am.suppl->>'arbat' IS NOT NULL
)
SELECT *
FROM dist_arbat
WHERE dist > 2
ORDER BY npp, a;   -- 22 incohérences sur les distances entre arbres attachés


-- CONTROLES DES DONNÉES ÉCOLOGIQUE FORÊT
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN distriv='3' AND denivriv IS NULL THEN '01a. DENIVRIV NULL'
        WHEN distriv NOT IN ('1', '2', '3') AND denivriv IS NOT NULL THEN '01b. DENIVRIV devrait être à NULL'
		WHEN obstopo != '4' AND pent2 IS NULL THEN '02a. PENT2 NULL'
		WHEN obstopo = '4' AND pent2 IS NOT NULL THEN '02b. PENT2 devrait être à NULL'
		WHEN NOT COALESCE(pent2, 0) BETWEEN 0 AND 202 THEN '02c. valeur incorrecte de PENT2'
		WHEN pent2 >= 5 AND obstopo != '4' AND expo IS NULL THEN '03. EXPO NULL'
		WHEN pent2 >= 5 AND masque IS NULL THEN '04a. MASQUE NULL'
		WHEN pent2 < 5 AND masque IS NOT NULL THEN '04b. MASQUE devrait être à NULL'
        WHEN leve = '1' AND msud IS NULL THEN '05a. MSUD NULL'
        WHEN leve != '1' AND msud IS NOT NULL THEN '05b. MSUD devrait être à NULL'
		WHEN COALESCE(obspedo, '0') != '5' AND az_fo IS NULL THEN '06a. AZ_FO NULL'
		WHEN NOT COALESCE(az_fo, 0) BETWEEN 0 AND 400 THEN '06b. valeur incorrecte de AZ_FO'
		WHEN COALESCE(obspedo, '0') != '5' AND di_fo_cm IS NULL THEN '07a. DI_FO NULL'
		WHEN COALESCE(di_fo_cm, 0) > 2500 THEN '07b. valeur incorrecte de DI_FO'
		WHEN obspedo != '5' AND COALESCE(cailloux, 'X') NOT IN ('0', 'X') AND typcai IS NULL THEN '08. TYPCAI NULL'
        WHEN obspedo != '5' AND htext IS NULL THEN '09. HTEXT NULL'
        WHEN obspedo != '5' AND htext = '2' AND text1 IS NULL THEN '10. TEXT1 NULL'
		WHEN obspedo != '5' AND htext = '2' AND prof1 IS NULL THEN '11a. PROF1 NULL'
		WHEN NOT (obspedo != '5' AND htext = '2') AND prof1 IS NOT NULL THEN '11b. PROF1 devrait être à NULL'
		WHEN obspedo != '5' AND htext IN ('1', '2') AND text2 IS NULL THEN '12. TEXT2 NULL'
		WHEN obspedo != '5' AND htext != '0' AND PROF2 IS NULL THEN '13. PROF2 NULL'
		WHEN prof1 >= prof2 THEN '14. PROF1 >= PROF2'
		WHEN obspedo != '5' AND obsprof IS NULL THEN '14a. OBSPROF NULL'
		WHEN prof2 = '9' AND obsprof NOT IN ('0', '4') THEN '14b. Incohérence entre PROF2 = 9 et OBSPROF'
		WHEN prof2 < '9' AND obsprof NOT IN ('1', '2', '3', '4') THEN '14c. Incohérence entre PROF2 < 9 et OBSPROF'
		WHEN obspedo != '5' AND obshydr IS NULL THEN '15. OBSHYDR NULL'
		WHEN obspedo != '5' AND tsol IS NULL THEN '16. TSOL NULL'
      END AS erreur
    FROM v_liste_points_lt1 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN reco_m1 r1 USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN ecologie e USING (id_ech, id_point)
    LEFT JOIN ecologie_2017 e7 USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;


-- CONTROLES DES HABITATS FORÊT - PREMIÈRE VISITE
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN csa IN ('1', '3') AND caracthab IS NULL THEN '01. CARACTHAB NULL'
        WHEN d.suppl->>'ligneriv' IS NOT NULL AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "LIGNERIV")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur LIGNERIV'
        WHEN h1.obshab IN ('1', '3', '6') AND h1.s_hab IS NULL THEN '02. S_HAB1 NULL'
        WHEN h1.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB1")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Commentaire absent sur QUALHAB1'
        WHEN h2.obshab IN ('1', '3', '6') AND h2.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '03. S_HAB2 NULL'
        WHEN h2.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB2")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Commentaire absent sur QUALHAB1'
        WHEN h3.obshab IN ('1', '3', '6') AND h3.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '04. S_HAB3 NULL'
        WHEN h3.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB3")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Commentaire absent sur QUALHAB1'
        WHEN h1.s_hab IS NOT NULL AND (replace(h1.s_hab, 'X', '0'))::int2 + coalesce((replace(h2.s_hab, 'X', '0'))::int2, 0) + coalesce((replace(h3.s_hab, 'X', '0'))::int2, 0) != 10 THEN '05. Problème de somme de surfaces d''habitats'
      END AS erreur
    FROM v_liste_points_lt1 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
    LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
    LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- commentaires absents sur LIGNERIV et les QUALHAB1



-- REQUÊTES COMPLÉMENTAIRES
-- requête vérifiant la bonne numérotation des arbres sur les points
WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2022
)
, t1 AS (
     SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, rang_a - rang_az AS gap,
     DENSE_RANK() OVER(PARTITION BY npp ORDER BY npp,
     ABS(rang_a - rang_az) DESC, rang_a - rang_az DESC) AS rang_ecart
     FROM t0
     WHERE rang_a <> rang_az
)
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, gap
FROM t1
WHERE rang_ecart = 1
ORDER BY npp, a;
-- 6 arbres présentent des problèmes de numérotation

/*
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm
FROM v_liste_points_lt1 v
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
WHERE id_ech = 52
AND id_point = 1065642
--AND a > 25
ORDER BY a;
*/




/**************************************************************************************************************
 * CONTRÔLES FONCTIONNELS  -  DEUXIÈME VISITE                                                                 *
 **************************************************************************************************************/


-- CONTROLES DE LA RECONNAISSANCE 
WITH t AS (
	SELECT v.npp, v.id_ech, v.id_point
	, CASE
		WHEN reco IN ('0', '2') AND qreco IS NULL THEN '01a. QRECO5 NULL'
		WHEN reco = '1' AND qreco IS NOT NULL THEN '01b. QRECO5 renseigné sur RECO = 1'
		WHEN reco IN ('0', '2') AND jsonb_path_query_first(p.qual_data, ('$[*] ? (@.donnee == "RECO5" || @.donnee == "QRECO5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur RECO5 = 0 ou 2'
		WHEN reco = '1' AND pointok5 IS NULL THEN '02a. POINTOK5 NULL'
		WHEN pointok5 IN ('0', '1') AND jsonb_path_query_first(p.qual_data, ('$[*] ? (@.donnee == "POINTOK5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Commentaire absent sur POINTOK5 = 0 ou 1'
		WHEN pointok5 = '0' AND r.csa IS NOT NULL THEN '03a. CSA5 renseigné sur POINTOK5 = 0'
		WHEN pointok5 != '0' AND r.csa IS NULL THEN '03b. CSA5 non renseigné sur POINTOK5 != 0'
		WHEN LEFT(r.csa, 1) != LEFT(rm5.csa, 1) AND NOT ((LEFT(rm5.csa, 1) = '4' AND LEFT(r.csa, 1) = '4') OR (LEFT(rm5.csa, 1) = '2' AND LEFT(r.csa, 1) = '1')) AND evo_csa IS NULL THEN '04a. EVO_CSA5 non renseigné sur CSA5 != CSA'
		WHEN LEFT(r.csa, 1) = LEFT(rm5.csa, 1) AND r1.tform = r1m5.tform AND evo_csa IS NOT NULL THEN '04b. EVO_CSA5 renseigné sur CSA5 = CSA'
		WHEN pointok5 != '0' AND rm5.csa IN ('1', '2', '3', '5') AND def5 IS NULL THEN '05a. DEF5 NULL'
		WHEN pointok5 != '0' AND rm5.csa IN ('1', '2', '3', '5') AND r.csa IN ('1', '3', '5') AND def5 NOT IN ('0', '1', '2') THEN '05b. Incohérence entre CSA boisé, CSA5 boisé et DEF5'
		WHEN pointok5 != '0' AND rm5.csa IN ('1', '2', '3', '5') AND r.csa NOT IN ('1', '3', '5') AND evo_csa = '1' AND def5 NOT IN ('3', '4', '5') THEN '05c. Incohérence entre CSA boisé, CSA5 non boisé et DEF5'
		WHEN r.csa IN ('1', '2', '3', '5', '4L') AND r1.utip IS NULL THEN '06a. UTIP5 non renseigné sur CSA5 boisé / lande'
		WHEN r.csa = '4L' AND r1.utip = 'V' THEN '06b. UTIP5 verger sur lande'
		WHEN COALESCE(r.csa, '6') IN ('6', '7', '8', '9') AND r1.utip IS NOT NULL THEN '06c. UTIP5 devrait être à NULL'
		WHEN r1.utip != r1m5.utip AND evo_utip IS NULL THEN '07. EVO_UTIP5 NULL'
		WHEN r.csa IN ('1', '2', '3', '5') AND r1.utip = 'X' AND r1.bois IS NULL THEN '08a. BOIS5 NULL'
		WHEN r.csa IN ('1', '2', '3', '5') AND r1.utip != 'X' AND r1.bois IS NOT NULL THEN '08b. BOIS5 devrait être à NULL'
		WHEN r.csa IN ('4L', '6', '7', '8', '9') AND r1.bois IS NOT NULL THEN '08c. BOIS5 devrait être à NULL'
		WHEN r.csa IN ('1', '2', '3', '5') AND r1.utip = 'X' AND r1.doute_bois IS NULL THEN '09a. DOUTE_BOIS5 NULL'
		WHEN r.csa IN ('1', '2', '3', '5') AND r1.utip != 'X' AND r1.doute_bois IS NOT NULL THEN '09b. DOUTE_BOIS5 devrait être à NULL'
		WHEN r.csa IN ('4L', '6', '7', '8', '9') AND r1.doute_bois IS NOT NULL THEN '09c. DOUTE_BOIS5 devrait être à NULL'
        WHEN r1.doute_bois = '1' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "BOIS5" || @.donnee == "DOUTE_BOIS5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Observation sur DOUTE_BOIS absente'
        WHEN r1.bois = '0' AND r1.qbois IS NULL THEN '10a. QBOIS5 non renseigné sur BOIS5 = 0'
        WHEN r1.bois = '1' AND r1.qbois IS NOT NULL THEN '10b. QBOIS5 devrait être à NULL'
        WHEN r.csa IN ('4L', '6A', '6H', '7', '8', '9') AND r1.qbois IS NOT NULL THEN '10c. QBOIS5 devrait être à NULL'
        WHEN r1.bois = '0' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "BOIS5" || @.donnee == "QBOIS5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Observation sur BOIS5 ou QBOIS5 absente'
        WHEN r1.bois != r1m5.bois AND r2.evo_bois IS NULL THEN '11a. EVO_BOIS5 NULL'
        WHEN r1.bois = r1m5.bois AND r2.evo_bois IS NOT NULL THEN '11a. EVO_BOIS5 devrait être NULL'
        WHEN r1.bois = '1' AND r1.autut IS NULL THEN '12a. AUTUT5 non renseigné sur BOIS5 = 1'
        WHEN r1.bois = '0' AND r1.autut IS NOT NULL THEN '12b. AUTUT5 devrait être à NULL'
        WHEN r.csa IN ('4L', '6A', '6H', '7', '8', '9') AND r1.autut IS NOT NULL THEN '12c. AUTUT5 devrait être à NULL'
        WHEN r.csa IN ('1', '3', '4L', '5') AND r1.tform IS NULL THEN '13a. TFORM5 non renseigné sur point boisé / lande'
        WHEN r.csa NOT IN ('1', '3', '4L', '5') AND r1.tform IS NOT NULL THEN '13b. TFORM5 devrait être à NULL'
        WHEN r.csa = '4L' AND r1.tform = '1' AND r1.eflt IS NULL THEN '14a. EFLT5 non renseigné sur petite lande'
        WHEN NOT (r.csa = '4L' AND r1.tform = '1') AND r1.eflt IS NOT NULL THEN '14b. EFLT5 devrait être à NULL'
        WHEN r.csa IN ('4L', '6A', '6H', '7') AND r1.tauf IS NULL THEN '15a. TAUF5 NULL'
        WHEN r.csa NOT IN ('4L', '6A', '6H', '7') AND r1.tauf IS NOT NULL THEN '15b. TAUF5 devrait être à NULL'
	  END AS erreur
	FROM v_liste_points_lt2 v
    INNER JOIN point_lt p USING (id_ech, id_point)
    LEFT JOIN point_m2 pm USING (id_ech, id_point)
    LEFT JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN reco_m2 r2 USING (id_ech, id_point)
    LEFT JOIN reconnaissance rm5 ON r.id_ech > rm5.id_ech AND r.id_point = rm5.id_point
    LEFT JOIN reco_2015 r1 ON r.id_ech = r1.id_ech AND r.id_point = r1.id_point
    LEFT JOIN reco_2015 r1m5 ON rm5.id_ech = r1m5.id_ech AND rm5.id_point = r1m5.id_point
    WHERE v.annee = 2022
) 
SELECT * FROM t
WHERE t.erreur IS NOT NULL
ORDER BY erreur, npp;
-- commentaires/observations absents

/*
SELECT v.npp, v.id_ech, v.id_point--, rm5.csa AS csa, r.csa AS csa5, evo_csa, p.qual_data, r1.tauf, r1m5.tauf, p.reco, pm.pointok5
FROM v_liste_points_lt2 v
INNER JOIN point_lt p USING (id_ech, id_point)
LEFT JOIN point_m2 pm USING (id_ech, id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
LEFT JOIN reco_m2 r2 USING (id_ech, id_point)
LEFT JOIN reconnaissance rm5 ON r.id_ech > rm5.id_ech AND r.id_point = rm5.id_point
LEFT JOIN reco_2015 r1 ON r.id_ech = r1.id_ech AND r.id_point = r1.id_point
LEFT JOIN reco_2015 r1m5 ON rm5.id_ech = r1m5.id_ech AND rm5.id_point = r1m5.id_point
WHERE v.annee = 2022
AND v.npp IN ('16-40-126-1-277T', '16-54-226-1-027T')
ORDER BY npp;
*/

-- CONTROLES DE LA DESCRIPTION FORÊT - DEUXIÈME VISITE
SELECT *
FROM (
    SELECT v.npp, v.id_ech, v.id_point
	, CASE
		WHEN nincid = '5' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "NINCID5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur NINCID5 = 5'
		WHEN nincid != '0' AND incid IS NULL THEN '01a. INCID5 NULL'
		WHEN nincid = '0' AND incid IS NOT NULL THEN '01b. INCID5 devrait être NULL'
		WHEN instp5 = 'P' AND bplant_dm IS NULL THEN '02. BPLANT5 absent sur INSTP5 = P'
		WHEN instp5 = 'P' AND iplant_dm IS NULL THEN '03. IPLANT5 absent sur INSTP5 = P'
		WHEN instp5 IN ('P', 'S') AND tpespar1 IS NULL THEN '04a. TPESPAR15 absent sur INSTP5 = P ou S'
		WHEN instp5 NOT IN ('P', 'S') AND tpespar1 IS NOT NULL THEN '04b. TPESPAR15 devrait être à NULL'
		WHEN instp5 NOT IN ('P', 'S') AND tpespar2 IS NOT NULL THEN '05c. TPESPAR25 devrait être à NULL'
	  END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN description d USING (id_ech, id_point)
    LEFT JOIN descript_m2 dm2 USING (id_ech, id_point)
    LEFT JOIN plantations pl USING (id_ech, id_point)
    WHERE v.annee = 2022
) t
WHERE t.erreur IS NOT NULL
ORDER BY erreur, npp;
-- 1 point avec BPLANTS absent sur INSTP5=P; commentaires absents


/*
SELECT v.npp, v.id_ech, v.id_point, d.dc, d2.instp5, p.tpespar1, d.peupnr
FROM v_liste_points_lt2 v
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m2 d2 USING (id_ech, id_point)
LEFT JOIN plantations p USING (id_ech, id_point)
WHERE v.npp IN ('17-63-221-1-171T')
ORDER BY npp;
*/

-- CONTROLES DES ARBRES VIFS REMESURÉS - DEUXIÈME VISITE

SELECT *
FROM (
	SELECT v.npp, v.id_ech, v.id_point, a.a
	, CASE
		WHEN am2.suppl->>'typerr_a' != '0' AND jsonb_path_query_first(am2.qual_data, ('$[*] ? (@.donnee == "TYPERR_A")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur TYPERR_A'
		WHEN am2.veget5 = 'N' AND jsonb_path_query_first(am2.qual_data, ('$[*] ? (@.donnee == "VEGET5")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Commentaire absent sur VEGET5 = N'
		WHEN am1.veget = 'A' AND am2.veget5 NOT IN ('1', '2', '6', '7', 'N') THEN '01a. Incohérence sur VEGET5 pour VEGET = A'
		WHEN am1.veget IN ('5', 'C') AND am2.veget5 NOT IN ('M', '2', '6', '7', 'N', 'T') THEN '01b. Incohérence sur VEGET5 pour VEGET = 5 ou C'
		WHEN am1.veget = '0' AND am2.veget5 IN ('0', 'M', '1', '2') AND a.c13_mm IS NULL THEN '02a. C135_MM NULL'
		WHEN NOT (am1.veget = '0' AND am2.veget5 IN ('0', 'M', '1', '2')) AND a.c13_mm IS NOT NULL THEN '02b. C135_MM devrait être à NULL'
		WHEN am1.veget = '0' AND am2.veget5 IN ('0', 'M', '1', '2') AND am2.mes_c135 IS NULL THEN '03a. MES_C135 NULL'
		WHEN NOT (am1.veget = '0' AND am2.veget5 IN ('0', 'M', '1', '2')) AND am2.mes_c135 IS NOT NULL THEN '03b. MES_C135 devrait être à NULL'
--		WHEN am2.veget5 = '0' AND a.c13_mm >= 705 AND am1.lib != '0' AND s.mortb IS NULL THEN '04a. MORTB5 NULL'
--		WHEN NOT (am2.veget5 = '0' AND a.c13_mm >= 705 AND am1.lib != '0') AND s.mortb IS NOT NULL THEN '04b. MORTB5 devrait être à NULL'
	  END AS erreur
	, a.qual_data
	FROM v_liste_points_lt2 v
	INNER JOIN arbre a USING (id_ech, id_point)
	INNER JOIN arbre_m2 am2 USING (id_ech, id_point, a)
	LEFT JOIN sante s USING (id_ech, id_point, a)
	INNER JOIN arbre_m1 am1 ON am2.id_ech > am1.id_ech AND am2.id_point = am1.id_point AND am2.a = am1.a
	WHERE v.annee = 2022
) t
WHERE t.erreur IS NOT NULL
ORDER BY erreur, npp, a; -- 1 incohérence sur 17-29-025-1-125T entre VEGET et VEGET5

/*
SELECT v.npp, v.id_ech, v.id_point, a.a, am1.veget, am2.veget5, am2.suppl->>'typerr_a', am2.qual_data
FROM v_liste_points_lt2 v
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 am2 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 am1 ON am2.id_ech > am1.id_ech AND am2.id_point = am1.id_point AND am2.a = am1.a
WHERE (npp, a.a) IN (('17-29-025-1-125T', 9 ))
ORDER BY npp, a;
*/


-- CONTROLES DES DONNEES NOUVEAUX ARBRES RECENSABLES FORÊT - DEUXIÈME VISITE
SET enable_nestloop = FALSE;

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point, a.a
    , espar, veget
    , CASE 
        WHEN veget = '0' AND lib IS NULL THEN '01a. LIB NULL'
        WHEN veget != '0' AND lib IS NOT NULL THEN '01b. LIB devrait être à NULL'
        WHEN veget = '0' AND cible IS NULL THEN '02a. CIBLE NULL'
        WHEN veget != '0' AND cible IS NOT NULL THEN '02b. CIBLE devrait être à NULL'
        WHEN veget = '0' AND acci IS NULL THEN '03a. ACCI NULL'
        WHEN veget != '0' AND acci IS NOT NULL THEN '03b. ACCI devrait être à NULL'
        WHEN veget IN ('0', 'C') AND htot_dm IS NULL THEN '04. HTOT NULL sur arbre vivant ou mort sur pied cassé'
        WHEN veget = '0' AND decoupe IS NULL THEN '05a. DECOUPE NULL'
        WHEN veget != '0' AND decoupe IS NOT NULL THEN '05b. DECOUPE devrait être à NULL'
        WHEN veget = '0' AND decoupe IN ('1', '2') AND hdec_dm IS NULL THEN '06. HDEC NULL'
        WHEN veget = '0' AND decoupe IN ('1', '2') AND ddec_cm IS NULL THEN '07. DDEC NULL'
      END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN descript_m2 dm USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre_m1_2014 am4 USING (id_ech, id_point, a)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur, npp, a;

SET enable_nestloop = TRUE;
-- OK


-- VÉRIFICATIONS DE PREMIERS LEVÉS SUR DEUXIÈME VISITE

-- CONTROLES DES DONNEES DE DESCRIPTION 
-- points marqués comme levés sans données de peuplement forêt
SELECT v.npp, v.id_ech, v.id_point
FROM v_liste_points_lt2 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_m1 rm USING (id_ech, id_point)
LEFT JOIN description d USING (id_ech, id_point)
WHERE v.annee = 2022
AND csa IN ('1', '3', '5')
AND leve = '1'
AND d.id_ech IS NULL;

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN plas25 IS NULL THEN '01. PLAS25 NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IS NULL THEN '02a. PLAS15 NULL'
        WHEN plas25 NOT IN ('4', '5') AND plas15 IS NOT NULL THEN '02b. PLAS15 devrait être à NULL'
        WHEN plas25 IN ('4', '5') AND deppr IS NULL THEN '03a. DEPPR NULL'
        WHEN plas25 NOT IN ('4', '5') AND deppr IS NOT NULL THEN '03b. DEPPR devrait être à NULL'
        WHEN deppr = '1' AND azdep_gd IS NULL THEN '03c. AZDEP NULL'
        WHEN deppr != '1' AND azdep_gd IS NOT NULL THEN '03d. AZDEP devrait être à NULL'
        WHEN deppr = '1' AND ddep_cm IS NULL THEN '03e. DDEP NULL'
        WHEN deppr != '1' AND ddep_cm IS NOT NULL THEN '03d. DDEP devrait être à NULL'
        WHEN deppr = '1' AND jsonb_path_query_first(dm.qual_data, ('$[*] ? (@.donnee == "DEPPR")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Observation absente sur DEPPR'
        WHEN plas25 IN ('1', '3') AND dlim_cm IS NULL THEN '04a. DLIM_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND dlim_cm IS NULL THEN '04b. DLIM_CM NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim_cm IS NOT NULL THEN '04c. DLIM_CM devrait être à NULL'
        WHEN dlim_cm = 0 THEN '04d. DLIM = 0 interdit'
        WHEN plas25 IN ('1', '3') AND azdlim_gd IS NULL THEN '05a. AZDLIM_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND azdlim_gd IS NULL THEN '05b. AZDLIM_GD NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim_gd IS NOT NULL THEN '05c. AZDLIM_GD devrait être à NULL'
        WHEN plas25 = '3' AND dlim2_cm IS NULL THEN '06a. DLIM2_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND dlim2_cm IS NULL THEN '06b. DLIM2_CM NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim2_cm IS NOT NULL THEN '06c. DLIM2_CM devrait être à NULL'
        WHEN dlim2_cm < dlim_cm THEN '06d. DLIM2 < DLIM'
        WHEN plas25 = '3' AND azdlim2_gd IS NULL THEN '07a. AZDLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND azdlim2_gd IS NULL THEN '07b. AZDLIM2_GD NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim2_gd IS NOT NULL THEN '07c. AZDLIM2_GD devrait être à NULL'
        WHEN plas25 = '2' AND dcoi_cm IS NULL THEN '08a. DCOI_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND dcoi_cm IS NULL THEN '08b. DCOI_CM NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND dcoi_cm IS NOT NULL THEN '08c. DCOI_CM devrait être à NULL'
        WHEN dcoi_cm = 0 THEN '08d. DCOI = 0 interdit'
        WHEN plas25 = '2' AND azdcoi_gd IS NULL THEN '09a. AZDCOI_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azdcoi_gd IS NULL THEN '09b. AZDCOI_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azdcoi_gd IS NOT NULL THEN '09c. AZDCOI_GD devrait être à NULL'
        WHEN plas25 = '2' AND azlim1_gd IS NULL THEN '10a. AZLIM1_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim1_gd IS NULL THEN '10b. AZLIM1_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim1_gd IS NOT NULL THEN '10c. AZLIM1_GD devrait être à NULL'
        WHEN abs(azdcoi_gd - azlim1_gd) IN (0, 200, 400) THEN '10d. AZLIM1 aligné sur AZDCOI'
        WHEN plas25 = '2' AND azlim2_gd IS NULL THEN '11a. AZLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim2_gd IS NULL THEN '11b. AZLIM2_GD NULL'
        WHEN abs(azdcoi_gd - azlim2_gd) IN (0, 200, 400) THEN '10d. AZLIM2 aligné sur AZDCOI'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim2_gd IS NOT NULL THEN '11c. AZLIM2_GD devrait être à NULL'
        WHEN COALESCE(plas25, '0') != '0' AND plisi IS NULL THEN '12a. PLISI NULL'
        WHEN COALESCE(plas25, '0') = '0' AND plisi IS NOT NULL THEN '12b. PLISI devrait être à NULL'
        WHEN plisi IN ('1', '2') AND cslisi IS NULL THEN '13a. CSLISI NULL'
        WHEN plisi = '2' AND cslisi NOT IN ('7', '9', 'T') THEN '13b. Valeur illicite de CSLISI'
        WHEN COALESCE(plisi, '0') = '0' AND cslisi IS NOT NULL THEN '13c. CSLISI devrait être à NULL'
        WHEN bord IS NULL THEN '14. BORD NULL'
        WHEN integr IS NULL THEN '15. INTEGR NULL'
        WHEN tcat10 IS NULL THEN '16. TCAT10 NULL'
        WHEN peupnr IS NULL THEN '17. PEUPNR NULL'
        WHEN peupnr = '1' AND d.suppl->>'cam' IS NULL THEN '18a. CAM NULL'
        WHEN COALESCE(peupnr, '0') != '1' AND d.suppl->>'cam' IS NOT NULL THEN '18b. CAM devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND href_dm IS NULL THEN '19a. HREF NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND href_dm IS NOT NULL THEN '19b. HREF devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND sver IS NULL THEN '19c. SVER NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND sver IS NOT NULL THEN '19d. SVER devrait être à NULL'
        WHEN href_dm < 100 AND sver NOT IN ('2', '3', '4') THEN '18e. SVER incohérent avec HREF < 100'
        WHEN href_dm >= 100 AND sver NOT IN ('4', '5', '6') THEN '18f. SVER incohérent avec HREF >= 100'
        WHEN csa IN ('1', '3') AND gest IS NULL THEN '19. GEST NULL'
        WHEN nincid IS NULL THEN '20. NINCID NULL'
        WHEN nincid != '0' AND incid IS NULL THEN '21a. INCID NULL'
        WHEN COALESCE(nincid, '0') = '0' AND incid IS NOT NULL THEN '21b. INCID devrait être à NULL'
        WHEN dc IS NULL THEN '22. DC NULL'
        WHEN dc IN ('1', '2') AND dcespar1 IS NULL THEN '23a. DCESPAR1 NULL'
        WHEN COALESCE(dc, '0') NOT IN ('1', '2') AND dcespar1 IS NOT NULL THEN '23b. DCESPAR1 devrait être à NULL'
        WHEN andain IS NULL THEN '24. ANDAIN NULL'        
        WHEN abrou IS NULL THEN '25. ABROU NULL'      
        WHEN tplant IS NULL THEN '26a. TPLANT NULL'
        WHEN csa = '5' AND dc != '1' AND tplant = '0' THEN '26b. TPLANT incohérent sur coupe en peupleraie'
        WHEN COALESCE(tplant, '0') != '0' AND tpespar1 IS NULL THEN '27a. TPESPAR1 NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar1 IS NOT NULL THEN '27b. TPESPAR1 devrait être à NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar2 IS NOT NULL THEN '27c. TPESPAR2 devrait être à NULL'
        WHEN COALESCE(tplant, '0') != '0' AND elag IS NULL THEN '28a. ELAG NULL'
        WHEN COALESCE(tplant, '0') = '0' AND elag IS NOT NULL THEN '28b. ELAG devrait être à NULL'
        WHEN tplant = 'P' AND bplant_dm IS NULL THEN '29. BPLANT_DM NULL'
        WHEN tplant = 'P' AND iplant_dm IS NULL THEN '30. IPLANT_DM NULL'
        WHEN csa = '5' AND tplant = 'P' AND p.suppl->>'maille' IS NULL THEN '31. MAILLE NULL'
        WHEN csa = '5' AND tplant = 'P' AND d.suppl->>'entp' IS NULL THEN '32. ENTP NULL'
        WHEN tplant != '0' AND elag IS NULL THEN '33. ELAG NULL'
        WHEN iti IS NULL THEN '34. ITI NULL'      
        WHEN COALESCE(iti, '0') != '0' AND dist IS NULL THEN '35a. DIST NULL'
        WHEN COALESCE(iti, '0') = '0' AND dist IS NOT NULL THEN '35b. DIST devrait être à NULL'
        WHEN pentexp IS NULL THEN '36. PENTEXP NULL'
        WHEN pentexp NOT IN ('4', '5', 'X') AND portance IS NULL THEN '37a. PORTANCE NULL'
        WHEN COALESCE(pentexp, '0') IN ('4', '5', 'X') AND portance IS NOT NULL THEN '37b. PORTANCE devrait être à NULL'
        WHEN asperite NOT IN ('4', '5', 'X') AND asperite IS NULL THEN '38a. ASPERITE NULL'
        WHEN COALESCE(asperite, '0') IN ('4', '5', 'X') AND asperite IS NOT NULL THEN '38b. ASPERITE devrait être à NULL'
        WHEN orniere IS NULL THEN '39. ORNIERE NULL'
        WHEN pbuis IS NULL THEN '40. PBUIS NULL'
        WHEN pbuis != '0' AND dpyr IS NULL THEN '41. DPYR NULL'
        WHEN dpyr = '2' AND anpyr IS NULL THEN '42. ANPYR NULL'
      END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN limites l USING (id_ech, id_point)
    LEFT JOIN coupes c USING (id_ech, id_point)
    LEFT JOIN plantations p USING (id_ech, id_point)
    LEFT JOIN buis b USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- OK

-- CONTRÔLE SUPPLÉMENTAIRE SUR PEUPNR ET TAUX DE COUVERT RECENSABLE EN FORÊT
SELECT npp, id_ech, id_point, csa, peupnr, href_dm, sver, tcat10
FROM v_liste_points_lt2 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr != '2'
AND dc != '1'
AND tcat10 = 0
ORDER BY npp; -- OK



SELECT npp, id_ech, id_point, peupnr, bord, integr, tcar10, tcat10 
FROM v_liste_points_lt2 v
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr ='0'
AND tcar10 = 0
ORDER BY npp; -- 1 incohérence sur 17-11-224-1-266T


-- CONTROLES DES DONNEES ARBRES VIFS FORÊT

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point, a.a
    , csa, espar
    , CASE 
        WHEN veget IN ('5', 'C') AND datemort IS NULL THEN '01a. DATEMORT NULL' 
        WHEN veget NOT IN ('5', 'C') AND datemort IS NOT NULL THEN '01b. DATEMORT devrait être à NULL'
        WHEN veget = '0' AND simplif IS NULL THEN '02a. SIMPLIF NULL'
        WHEN veget != '0' AND simplif IS NOT NULL THEN '02a. SIMPLIF devrait être à NULL'
        WHEN veget = '0' AND repere IS NULL THEN '03a. REPERE NULL'
        WHEN (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NULL THEN '04a. LIB NULL'
        WHEN NOT (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NOT NULL THEN '04b. LIB devrait être à NULL'
        WHEN veget = '0' AND cible IS NULL THEN '05a. CIBLE NULL'
        WHEN veget != '0' AND cible IS NOT NULL THEN '05b. CIBLE devrait être à NULL'
        WHEN veget = '0' AND acci IS NULL THEN '06a. ACCI NULL'
        WHEN veget != '0' AND acci IS NOT NULL THEN '06b. ACCI devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND htot_dm IS NULL THEN '08a. HTOT NULL sur arbre vivant'
        WHEN veget = 'C' AND htot_dm IS NULL THEN '08b. HTOT NULL sur arbre mort sur pied cassé'
        WHEN veget = '0' AND decoupe IS NULL THEN '09a. DECOUPE NULL'
        WHEN veget != '0' AND decoupe IS NOT NULL THEN '09b. DECOUPE devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND hdec_dm IS NULL THEN '10. HDEC NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND ddec_cm IS NULL THEN '11. DDEC NULL'
        WHEN mes_c13 IN ('2', '3', '4') AND hcd_cm IS NULL THEN '12a. HCD NULL'
        WHEN mes_c13 = '2' AND NOT hcd_cm BETWEEN 80 AND 130 THEN '12b. HCD erroné sur moyenne de mesures'
        WHEN mes_c13 IN ('3', '4') AND NOT hcd_cm BETWEEN 50 AND 150 THEN '12c. HCD erroné sur mesure décalée ou autre cas'
        WHEN veget = '0' AND ori IS NULL THEN '13. ORI NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND qbp IS NULL THEN '14a. QBP NULL'
        WHEN hdec_dm < 3 AND qbp = '1' THEN '14b. Valeur erronnée de QBP'
        WHEN veget = '0' AND c13_mm >= 705 AND hrb_dm IS NULL THEN '15. HRB NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND lib NOT IN ('0','1') AND ACCI = '0'AND mortb IS NULL THEN '16. MORTB NULL'
        WHEN veget = '0' AND espar < '50' AND c13_mm >= 705 AND mortb IN ('0','1','2','3') AND mr IS NULL THEN '16. MR NULL'
        WHEN veget = '0' AND espar > '50' AND c13_mm >= 705 AND lib != '0' AND ma IS NULL THEN '17. MA NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND sfgui IS NULL THEN '18. SFGUI NULL'
        WHEN c13_mm < 1175 AND deggib IS NULL THEN '19. DEGGIB NULL'
      END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN descript_m1 d USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre_m1_2014 am4 USING (id_ech, id_point, a)
    LEFT JOIN sante s USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur, npp, a; -- OK

WITH no_accroi AS (
    SELECT v.npp, a.a
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN descript_m1 d USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND csa IN ('1', '3') AND veget = '0' AND simplif = '0' AND espar NOT IN ('06', '27C', '27N') AND ac.id_ech IS NULL
)
SELECT ncern, count(*)
FROM soif.v1e3arbre a
INNER JOIN no_accroi na USING (npp, a)
GROUP BY 1
ORDER BY 1; -- OK

-- CONTROLES DES ARBAT/NOMBRE D'ARBRES REPÈRE FORÊT
-- contrôle sur le nombre d'arbres repère
SELECT npp, id_ech, id_point, nb_arbres, nb_reperes, nb_plaque, 'Problème sur le nombre d''arbres repères'
FROM (
    SELECT npp, id_ech, id_point, COUNT(*) AS nb_arbres
    , COUNT(*) FILTER (WHERE repere IN ('1', '2')) AS nb_reperes
    , COUNT(*) FILTER (WHERE repere = '2') AS nb_plaque
    FROM v_liste_points_lt2 v
    INNER JOIN descript_m1 d USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND veget = '0'
    GROUP BY npp, id_ech, id_point
    HAVING (COUNT(*) > 3 AND COUNT(*) FILTER (WHERE repere IN ('1', '2')) < 3)
    OR SUM(CASE WHEN repere IN ('1', '2') THEN 1 ELSE 0 END) > 3
    OR SUM(CASE WHEN repere = '2' THEN 1 ELSE 0 END) = 0
) AS t
ORDER BY npp;       -- => pas d'erreur !

-- analyse de ARBAT
SELECT v.npp, v.id_ech, v.id_point, am.a, am.suppl->>'arbat' AS arbat
FROM v_liste_points_lt2 v
INNER JOIN descript_m1 d USING (id_ech, id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
WHERE v.annee = 2022
AND am.suppl->>'arbat' IS NOT NULL
AND ab.id_ech IS NULL
ORDER BY npp, am.a;        -- => pas d'erreur !


WITH dist_arbat AS (
    SELECT v.npp, v.id_ech, v.id_point
    , am.a, am.espar, a.c13_mm, am.suppl->>'arbat' AS arbat, am.azpr_gd, am.dpr_cm
    , am2.a AS a2, am2.espar AS espar_2, ab.c13_mm AS c13_mm_2, am2.azpr_gd AS azpr_gd2, am2.dpr_cm AS dpr_cm_2
    , ROUND(SQRT(((am2.dpr_cm / 100.0) * cos(pi() * (100.0 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * cos(pi() * (100.0 - am.azpr_gd / 200.0)))^2
     + ((am2.dpr_cm / 100.0) * sin(pi() * (100 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * sin(pi() * (100 - am.azpr_gd / 200.0)))^2)::NUMERIC, 2) AS dist
    FROM v_liste_points_lt2 v
    INNER JOIN descript_m1 d USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
    LEFT JOIN arbre_m1 am2 ON ab.id_ech = am2.id_ech AND am.id_point = am2.id_point AND ab.a = am2.a
    WHERE v.annee = 2022
    AND am.suppl->>'arbat' IS NOT NULL
)
SELECT *
FROM dist_arbat
WHERE dist > 2
ORDER BY npp, a; -- OK


-- CONTROLES DES DONNÉES ÉCOLOGIQUE FORÊT
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN distriv ='3' AND denivriv IS NULL THEN '01a. DENIVRIV NULL'
        WHEN distriv NOT IN ('1', '2', '3') AND denivriv IS NOT NULL THEN '01b. DENIVRIV devrait être à NULL'
        WHEN obstopo != '4' AND pent2 IS NULL THEN '02a. PENT2 NULL'
        WHEN obstopo = '4' AND pent2 IS NOT NULL THEN '02b. PENT2 devrait être à NULL'
        WHEN NOT COALESCE(pent2, 0) BETWEEN 0 AND 202 THEN '02c. valeur incorrecte de PENT2'
        WHEN pent2 >= 5 AND obstopo != '4' AND expo IS NULL THEN '03. EXPO NULL'
        WHEN pent2 >= 5 AND masque IS NULL THEN '04a. MASQUE NULL'
        WHEN pent2 < 5 AND masque IS NOT NULL THEN '04b. MASQUE devrait être à NULL'
        WHEN leve = '1' AND msud IS NULL THEN '05a. MSUD NULL'
        WHEN leve != '1' AND msud IS NOT NULL THEN '05b. MSUD devrait être à NULL'
        WHEN COALESCE(obspedo, '0') != '5' AND az_fo IS NULL THEN '06a. AZ_FO NULL'
        WHEN NOT COALESCE(az_fo, 0) BETWEEN 0 AND 400 THEN '06b. valeur incorrecte de AZ_FO'
        WHEN COALESCE(obspedo, '0') != '5' AND di_fo_cm IS NULL THEN '07a. DI_FO NULL'
        WHEN COALESCE(di_fo_cm, 0) > 2500 THEN '07b. valeur incorrecte de DI_FO'
        WHEN obspedo != '5' AND COALESCE(cailloux, 'X') NOT IN ('0', 'X') AND typcai IS NULL THEN '08. TYPCAI NULL'
        WHEN obspedo != '5' AND htext IS NULL THEN '09. HTEXT NULL'
        WHEN obspedo != '5' AND htext = '2' AND text1 IS NULL THEN '10. TEXT1 NULL'
        WHEN obspedo != '5' AND htext = '2' AND prof1 IS NULL THEN '11a. PROF1 NULL'
        WHEN NOT (obspedo != '5' AND htext = '2') AND prof1 IS NOT NULL THEN '11b. PROF1 devrait être à NULL'
        WHEN obspedo != '5' AND htext IN ('1', '2') AND text2 IS NULL THEN '12. TEXT2 NULL'
        WHEN obspedo != '5' AND htext != '0' AND PROF2 IS NULL THEN '13. PROF2 NULL'
        WHEN prof1 >= prof2 THEN '14. PROF1 >= PROF2'
        WHEN obspedo != '5' AND obsprof IS NULL THEN '14a. OBSPROF NULL'
        WHEN prof2 = '9' AND obsprof NOT IN ('0', '4') THEN '14b. Incohérence entre PROF2 = 9 et OBSPROF'
        WHEN prof2 < '9' AND obsprof NOT IN ('1', '2', '3', '4') THEN '14c. Incohérence entre PROF2 < 9 et OBSPROF'
        WHEN obspedo != '5' AND obshydr IS NULL THEN '15. OBSHYDR NULL'
        WHEN obspedo != '5' AND tsol IS NULL THEN '16. TSOL NULL'
      END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN reco_m1 r1 USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN descript_m1 d1 USING (id_ech, id_point)
    INNER JOIN ecologie e USING (id_ech, id_point)
    LEFT JOIN ecologie_2017 e7 USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur; -- OK


-- CONTROLES DES HABITATS FORÊT - PREMIÈRE VISITE
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN csa IN ('1', '3') AND leve = '1' AND caracthab IS NULL THEN '01. CARACTHAB NULL'
        WHEN d.suppl->>'ligneriv' IS NOT NULL AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "LIGNERIV")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur LIGNERIV'
        WHEN h1.obshab IN ('1', '3', '6') AND h1.s_hab IS NULL THEN '02. S_HAB1 NULL'
        WHEN h1.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB1")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Commentaire absent sur QUALHAB1'
        WHEN h2.obshab IN ('1', '3', '6') AND h2.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '03. S_HAB2 NULL'
        WHEN h2.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB2")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Commentaire absent sur QUALHAB1'
        WHEN h3.obshab IN ('1', '3', '6') AND h3.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '04. S_HAB3 NULL'
        WHEN h3.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB3")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Commentaire absent sur QUALHAB1'
        WHEN h1.s_hab IS NOT NULL AND (replace(h1.s_hab, 'X', '0'))::int2 + coalesce((replace(h2.s_hab, 'X', '0'))::int2, 0) + coalesce((replace(h3.s_hab, 'X', '0'))::int2, 0) != 10 THEN '05. Problème de somme de surfaces d''habitats'
      END AS erreur
    FROM v_liste_points_lt2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN reco_m1 r1 USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
    LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
    LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- OK



-- REQUÊTES COMPLÉMENTAIRES
-- requête vérifiant la bonne numérotation des arbres sur les points
WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt2 v
    INNER JOIN descript_m1 d USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2022
)
, t1 AS (
     SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, rang_a - rang_az AS gap,
     DENSE_RANK() OVER(PARTITION BY npp ORDER BY npp,
     ABS(rang_a - rang_az) DESC, rang_a - rang_az DESC) AS rang_ecart
     FROM t0
     WHERE rang_a <> rang_az
)
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, gap
FROM t1
WHERE rang_ecart = 1
ORDER BY npp, a;
-- OK



/**************************************************************************************************************
 * CONTRÔLES FONCTIONNELS  -  PREMIÈRE VISITE / DEUXIÈME PI                                                   *
 **************************************************************************************************************/

-- CONTROLES DE LA RECONNAISSANCE 
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN reco IN ('0', '2') AND qreco IS NULL THEN '01. QRECO NULL sur RECO = 0 ou 2'
        WHEN reco IN ('0', '2') AND jsonb_path_query_first(pl.qual_data, ('$[*] ? (@.donnee == "QRECO")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Observation sur QRECO absente'
        WHEN reco = '0' AND duracc IS NOT NULL THEN '02a. DURACC renseigné sur RECO = 0'
        WHEN reco = '1' AND duracc IS NULL THEN '02b. DURACC non renseigné sur RECO = 1'
        WHEN reco IN ('0', '2') AND posipr IS NOT NULL THEN '03a. POSIPR renseigné sur RECO = 0 ou 2'
        WHEN reco = '1' AND posipr IS NULL THEN '03b. POSIPR non renseigné sur RECO = 1'
        WHEN reco = '0' AND pclos IS NOT NULL THEN '04a. PCLOS renseigné sur RECO = 0'
        WHEN reco IN ('1','2') AND pclos IS NULL THEN '04b. PCLOS non renseigné sur RECO = 1'
        WHEN pclos = '1' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "PCLOS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Observation sur PCLOS = 1 absente'
        WHEN reco = '0' AND pdiff IS NOT NULL THEN '05a. PDIFF renseigné sur RECO = 0 ou 2'
        WHEN reco IN ('1','2') AND pdiff IS NULL THEN '05b. PDIFF non renseigné sur RECO = 1'
        WHEN pdiff = '1' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "PDIFF")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Observation sur PDIFF = 1 absente'
        WHEN reco = '0' AND csa IS NOT NULL THEN '06a. CSA renseigné sur RECO = 0'
        WHEN reco IN ('1', '2') AND csa IS NULL THEN '06b. CSA non renseigné sur RECO = 1 ou 2'
        WHEN csa IN ('1', '3', '5') AND obscsa IS NOT NULL THEN '07a. OBSCSA devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND obscsa IS NULL THEN '07b. OBSCSA NULL sur CSA non boisé'
        WHEN obscsa != '0' AND jsonb_path_query_first(p1.qual_data, ('$[*] ? (@.donnee == "OBSCSA")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Observation sur OBSCSA absente'
        WHEN reco = '1' AND csa IN ('1', '3', '4L', '5') AND utip IS NULL THEN '08a. UTIP non renseigné sur CSA boisé / lande sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '4L', '5') AND utip IS NULL THEN '08b. UTIP non renseigné sur CSA boisé / lande sur point reconnu à distance'
        WHEN csa IN ('3', '4L') AND utip = 'V' THEN '08c. UTIP verger sur forêt ouverte ou lande'
        WHEN csa IN ('6A', '6H', '7', '8', '9') AND utip IS NOT NULL THEN '08d. UTIP devrait être à NULL'
        WHEN obscsa != 'X' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "UTIP")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99e. Observation sur UTIP absente'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND bois IS NULL THEN '09a. BOIS non renseigné sur CSA boisé sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '5') AND utip = 'X' AND bois IS NULL THEN '09b. BOIS non renseigné sur CSA boisé sur point reconnu à distance'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND bois IS NOT NULL THEN '09C. BOIS devrait être à NULL'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND doute_bois IS NULL THEN '10a. DOUTE_BOIS non renseigné sur CSA boisé sur point reconnu'
        WHEN reco = '2' AND qreco IN ('22', '23', '99') AND csa IN ('1', '3', '5') AND utip = 'X' AND doute_bois IS NULL THEN '10b. DOUTE_BOIS non renseigné sur CSA boisé sur point reconnu à distance'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND doute_bois IS NOT NULL THEN '10c. DOUTE_BOIS devrait être à NULL'
        WHEN doute_bois = '1' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "DOUTE_BOIS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99f. Observation sur DOUTE_BOIS absente'
        WHEN bois = '0' AND qbois IS NULL THEN '11a. QBOIS non renseigné sur BOIS = 0'
        WHEN bois = '1' AND qbois IS NOT NULL THEN '11b. QBOIS devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND qbois IS NOT NULL THEN '11c. QBOIS devrait être à NULL'
        WHEN bois = '0' AND jsonb_path_query_first(r1.qual_data, ('$[*] ? (@.donnee == "BOIS" || @.donnee == "QBOIS")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Observation sur BOIS ou QBOIS absente'
        WHEN bois = '1' AND autut IS NULL THEN '12a. AUTUT non renseigné sur BOIS = 1'
        WHEN bois = '0' AND autut IS NOT NULL THEN '12b. AUTUT devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7', '8', '9') AND autut IS NOT NULL THEN '12c. AUTUT devrait être à NULL'
        WHEN csa IN ('1', '3', '4L', '5') AND tform IS NULL THEN '13a. TFORM non renseigné sur point boisé / lande'
        WHEN csa NOT IN ('1', '3', '4L', '5') AND tform IS NOT NULL THEN '13b. TFORM devrait être à NULL'
        WHEN csa = '4L' AND tform = '1' AND eflt IS NULL THEN '14a. EFLT non renseigné sur petite lande'
        WHEN NOT (csa = '4L' AND tform = '1') AND eflt IS NOT NULL THEN '14b. EFLT devrait être à NULL'
        WHEN csa IN ('4L', '6A', '6H', '7') AND tauf IS NULL THEN '15a. TAUF NULL'
        WHEN csa NOT IN ('4L', '6A', '6H', '7') AND tauf IS NOT NULL THEN '15b. TAUF devrait être à NULL'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND bois = '1' AND leve IS NULL THEN '16a. LEVE non renseigné sur point disponible pour la production de bois'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'A' AND tform = '2' AND leve IS NULL THEN '16b. LEVE non renseigné sur forêt agricole'
        WHEN reco = '1' AND csa IN ('1', '3', '5') AND utip = 'X' AND bois = '0' AND qbois IN ('11', '12', '13', '99') AND leve IS NULL THEN '16c. LEVE non renseigné sur motifs d''indisponibilité compatibles'
        WHEN leve = '0' AND qleve IS NULL THEN '17a. QLEVE non renseigné sur point non levé'
        WHEN leve = '0' AND jsonb_path_query_first(rm.qual_data, ('$[*] ? (@.donnee == "QLEVE")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99h. Observation sur QLEVE absente'
        WHEN reco = '1' AND rp IS NULL THEN '18. RP non renseigné sur point reconnu'
        WHEN rp IN ('1', '2', '3', '4') AND azrp_gd IS NULL THEN '19. AZRP non renseigné avec un élément repère'
        WHEN rp IN ('1', '2', '3', '4') AND drp_cm IS NULL THEN '20. DRP non renseigné avec un élément repère'
      END AS erreur
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN point_lt pl USING (id_ech, id_point)
    LEFT JOIN point_m1 p1 USING (id_ech, id_point)
    LEFT JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN reco_2015 r1 USING (id_ech, id_point)
    LEFT JOIN reco_m1 rm USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- manques récurrents de commentaires dans des situations obligatoires


-- POINTS AVEC datepoint HORS LIMITES DE DATES OFFICIELLES
SELECT v.npp, v.id_ech, v.id_point, datepoint
FROM v_liste_points_lt1_pi2 v
INNER JOIN point_lt USING (id_ech, id_point)
WHERE (datepoint < '16-10-2021'::DATE
    OR datepoint >= '01-12-2022'::DATE)
AND v.annee = 2022;
-- 1 point 17-51-183-1-052T hors date

-- CONTROLES DES DONNEES DE DESCRIPTION 
-- points marqués comme levés sans données de peuplement forêt
SELECT v.npp, v.id_ech, v.id_point
FROM v_liste_points_lt1_pi2 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_m1 rm USING (id_ech, id_point)
LEFT JOIN description d USING (id_ech, id_point)
WHERE v.annee = 2022
AND csa IN ('1', '3', '5')
AND leve = '1'
AND d.id_ech IS NULL; -- OK

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN plas25 IS NULL THEN '01. PLAS25 NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IS NULL THEN '02a. PLAS15 NULL'
        WHEN plas25 NOT IN ('4', '5') AND plas15 IS NOT NULL THEN '02b. PLAS15 devrait être à NULL'
        WHEN plas25 IN ('4', '5') AND deppr IS NULL THEN '03a. DEPPR NULL'
        WHEN plas25 NOT IN ('4', '5') AND deppr IS NOT NULL THEN '03b. DEPPR devrait être à NULL'
        WHEN deppr = '1' AND azdep_gd IS NULL THEN '03c. AZDEP NULL'
        WHEN deppr != '1' AND azdep_gd IS NOT NULL THEN '03d. AZDEP devrait être à NULL'
        WHEN deppr = '1' AND ddep_cm IS NULL THEN '03e. DDEP NULL'
        WHEN deppr != '1' AND ddep_cm IS NOT NULL THEN '03d. DDEP devrait être à NULL'
        WHEN deppr = '1' AND jsonb_path_query_first(dm.qual_data, ('$[*] ? (@.donnee == "DEPPR")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Observation absente sur DEPPR'
        WHEN plas25 IN ('1', '3') AND dlim_cm IS NULL THEN '04a. DLIM_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND dlim_cm IS NULL THEN '04b. DLIM_CM NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim_cm IS NOT NULL THEN '04c. DLIM_CM devrait être à NULL'
        WHEN dlim_cm = 0 THEN '04d. DLIM = 0 interdit'
        WHEN plas25 IN ('1', '3') AND azdlim_gd IS NULL THEN '05a. AZDLIM_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3') AND azdlim_gd IS NULL THEN '05b. AZDLIM_GD NULL'
        WHEN NOT (plas25 IN ('1', '3') OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim_gd IS NOT NULL THEN '05c. AZDLIM_GD devrait être à NULL'
        WHEN plas25 = '3' AND dlim2_cm IS NULL THEN '06a. DLIM2_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND dlim2_cm IS NULL THEN '06b. DLIM2_CM NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND dlim2_cm IS NOT NULL THEN '06c. DLIM2_CM devrait être à NULL'
        WHEN dlim2_cm < dlim_cm THEN '06d. DLIM2 < DLIM'
        WHEN plas25 = '3' AND azdlim2_gd IS NULL THEN '07a. AZDLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '3' AND azdlim2_gd IS NULL THEN '07b. AZDLIM2_GD NULL'
        WHEN NOT (plas25 = '3' OR (plas25 IN ('4', '5') AND plas15 IN ('0', '1', '3'))) AND azdlim2_gd IS NOT NULL THEN '07c. AZDLIM2_GD devrait être à NULL'
        WHEN plas25 = '2' AND dcoi_cm IS NULL THEN '08a. DCOI_CM NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND dcoi_cm IS NULL THEN '08b. DCOI_CM NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND dcoi_cm IS NOT NULL THEN '08c. DCOI_CM devrait être à NULL'
        WHEN dcoi_cm = 0 THEN '08d. DCOI = 0 interdit'
        WHEN plas25 = '2' AND azdcoi_gd IS NULL THEN '09a. AZDCOI_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azdcoi_gd IS NULL THEN '09b. AZDCOI_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azdcoi_gd IS NOT NULL THEN '09c. AZDCOI_GD devrait être à NULL'
        WHEN plas25 = '2' AND azlim1_gd IS NULL THEN '10a. AZLIM1_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim1_gd IS NULL THEN '10b. AZLIM1_GD NULL'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim1_gd IS NOT NULL THEN '10c. AZLIM1_GD devrait être à NULL'
        WHEN abs(azdcoi_gd - azlim1_gd) IN (0, 200, 400) THEN '10d. AZLIM1 aligné sur AZDCOI'
        WHEN plas25 = '2' AND azlim2_gd IS NULL THEN '11a. AZLIM2_GD NULL'
        WHEN plas25 IN ('4', '5') AND plas15 = '2' AND azlim2_gd IS NULL THEN '11b. AZLIM2_GD NULL'
        WHEN abs(azdcoi_gd - azlim2_gd) IN (0, 200, 400) THEN '10d. AZLIM2 aligné sur AZDCOI'
        WHEN NOT (plas25 = '2' OR (plas25 IN ('4', '5') AND plas15 = '2')) AND azlim2_gd IS NOT NULL THEN '11c. AZLIM2_GD devrait être à NULL'
        WHEN COALESCE(plas25, '0') != '0' AND plisi IS NULL THEN '12a. PLISI NULL'
        WHEN COALESCE(plas25, '0') = '0' AND plisi IS NOT NULL THEN '12b. PLISI devrait être à NULL'
        WHEN plisi IN ('1', '2') AND cslisi IS NULL THEN '13a. CSLISI NULL'
        WHEN plisi = '2' AND cslisi NOT IN ('7', '9', 'T') THEN '13b. Valeur illicite de CSLISI'
        WHEN COALESCE(plisi, '0') = '0' AND cslisi IS NOT NULL THEN '13c. CSLISI devrait être à NULL'
        WHEN bord IS NULL THEN '14. BORD NULL'
        WHEN integr IS NULL THEN '15. INTEGR NULL'
        WHEN tcat10 IS NULL THEN '16. TCAT10 NULL'
        WHEN peupnr IS NULL THEN '17. PEUPNR NULL'
        WHEN peupnr = '1' AND d.suppl->>'cam' IS NULL THEN '18a. CAM NULL'
        WHEN COALESCE(peupnr, '0') != '1' AND d.suppl->>'cam' IS NOT NULL THEN '18b. CAM devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND href_dm IS NULL THEN '19a. HREF NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND href_dm IS NOT NULL THEN '19b. HREF devrait être à NULL'
        WHEN csa = '1' AND peupnr != '2' AND sver IS NULL THEN '19c. SVER NULL'
        WHEN NOT (csa = '1' AND peupnr != '2') AND sver IS NOT NULL THEN '19d. SVER devrait être à NULL'
        WHEN href_dm < 100 AND sver NOT IN ('2', '3', '4') THEN '18e. SVER incohérent avec HREF < 100'
        WHEN href_dm >= 100 AND sver NOT IN ('4', '5', '6') THEN '18f. SVER incohérent avec HREF >= 100'
        WHEN csa IN ('1', '3') AND gest IS NULL THEN '19. GEST NULL'
        WHEN nincid IS NULL THEN '20. NINCID NULL'
        WHEN nincid != '0' AND incid IS NULL THEN '21a. INCID NULL'
        WHEN COALESCE(nincid, '0') = '0' AND incid IS NOT NULL THEN '21b. INCID devrait être à NULL'
        WHEN dc IS NULL THEN '22. DC NULL'
        WHEN dc IN ('1', '2') AND dcespar1 IS NULL THEN '23a. DCESPAR1 NULL'
        WHEN COALESCE(dc, '0') NOT IN ('1', '2') AND dcespar1 IS NOT NULL THEN '23b. DCESPAR1 devrait être à NULL'
        WHEN andain IS NULL THEN '24. ANDAIN NULL'        
        WHEN abrou IS NULL THEN '25. ABROU NULL'      
        WHEN tplant IS NULL THEN '26a. TPLANT NULL'
        WHEN csa = '5' AND dc != '1' AND tplant = '0' THEN '26b. TPLANT incohérent sur coupe en peupleraie'
        WHEN COALESCE(tplant, '0') != '0' AND tpespar1 IS NULL THEN '27a. TPESPAR1 NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar1 IS NOT NULL THEN '27b. TPESPAR1 devrait être à NULL'
        WHEN COALESCE(tplant, '0') = '0' AND tpespar2 IS NOT NULL THEN '27c. TPESPAR2 devrait être à NULL'
        WHEN COALESCE(tplant, '0') != '0' AND elag IS NULL THEN '28a. ELAG NULL'
        WHEN COALESCE(tplant, '0') = '0' AND elag IS NOT NULL THEN '28b. ELAG devrait être à NULL'
        WHEN tplant = 'P' AND bplant_dm IS NULL THEN '29. BPLANT_DM NULL'
        WHEN tplant = 'P' AND iplant_dm IS NULL THEN '30. IPLANT_DM NULL'
        WHEN csa = '5' AND tplant = 'P' AND p.suppl->>'maille' IS NULL THEN '31. MAILLE NULL'
        WHEN csa = '5' AND tplant = 'P' AND d.suppl->>'entp' IS NULL THEN '32. ENTP NULL'
        WHEN tplant != '0' AND elag IS NULL THEN '33. ELAG NULL'
        WHEN iti IS NULL THEN '34. ITI NULL'      
        WHEN COALESCE(iti, '0') != '0' AND dist IS NULL THEN '35a. DIST NULL'
        WHEN COALESCE(iti, '0') = '0' AND dist IS NOT NULL THEN '35b. DIST devrait être à NULL'
        WHEN pentexp IS NULL THEN '36. PENTEXP NULL'
        WHEN pentexp NOT IN ('4', '5', 'X') AND portance IS NULL THEN '37a. PORTANCE NULL'
        WHEN COALESCE(pentexp, '0') IN ('4', '5', 'X') AND portance IS NOT NULL THEN '37b. PORTANCE devrait être à NULL'
        WHEN asperite NOT IN ('4', '5', 'X') AND asperite IS NULL THEN '38a. ASPERITE NULL'
        WHEN COALESCE(asperite, '0') IN ('4', '5', 'X') AND asperite IS NOT NULL THEN '38b. ASPERITE devrait être à NULL'
        WHEN orniere IS NULL THEN '39. ORNIERE NULL'
        WHEN pbuis IS NULL THEN '40. PBUIS NULL'
        WHEN pbuis != '0' AND dpyr IS NULL THEN '41. DPYR NULL'
        WHEN dpyr = '2' AND anpyr IS NULL THEN '42. ANPYR NULL'
      END AS erreur
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    LEFT JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN limites l USING (id_ech, id_point)
    LEFT JOIN coupes c USING (id_ech, id_point)
    LEFT JOIN plantations p USING (id_ech, id_point)
    LEFT JOIN buis b USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur; -- OK


-- CONTRÔLE SUPPLÉMENTAIRE SUR PEUPNR ET TAUX DE COUVERT RECENSABLE EN FORÊT
SELECT npp, id_ech, id_point, csa, peupnr, href_dm, sver, tcat10
FROM v_liste_points_lt1_pi2 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr != '2'
AND dc != '1'
AND tcat10 = 0
ORDER BY npp; --OK


SELECT npp, id_ech, id_point, peupnr, bord, integr, tcar10, tcat10 
FROM v_liste_points_lt1_pi2 v
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
INNER JOIN couv_r c USING (id_ech, id_point)
WHERE v.annee = 2022
AND peupnr = '0'
AND tcar10 = 0
ORDER BY npp; -- OK


-- CONTROLES DES DONNEES ARBRES VIFS FORÊT

SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point, a.a
    , csa, espar
    , CASE 
        WHEN veget IN ('5', 'C') AND datemort IS NULL THEN '01a. DATEMORT NULL' 
        WHEN veget NOT IN ('5', 'C') AND datemort IS NOT NULL THEN '01b. DATEMORT devrait être à NULL'
        WHEN veget = '0' AND simplif IS NULL THEN '02a. SIMPLIF NULL'
        WHEN veget != '0' AND simplif IS NOT NULL THEN '02a. SIMPLIF devrait être à NULL'
        WHEN veget = '0' AND repere IS NULL THEN '03a. REPERE NULL'
        WHEN (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NULL THEN '04a. LIB NULL'
        WHEN NOT (veget = '0' OR (veget IN ('5', 'C') AND datemort = '1')) AND lib IS NOT NULL THEN '04b. LIB devrait être à NULL'
        WHEN veget = '0' AND cible IS NULL THEN '05a. CIBLE NULL'
        WHEN veget != '0' AND cible IS NOT NULL THEN '05b. CIBLE devrait être à NULL'
        WHEN veget = '0' AND acci IS NULL THEN '06a. ACCI NULL'
        WHEN veget != '0' AND acci IS NOT NULL THEN '06b. ACCI devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND htot_dm IS NULL THEN '08a. HTOT NULL sur arbre vivant'
        WHEN veget = 'C' AND htot_dm IS NULL THEN '08b. HTOT NULL sur arbre mort sur pied cassé'
        WHEN veget = '0' AND decoupe IS NULL THEN '09a. DECOUPE NULL'
        WHEN veget != '0' AND decoupe IS NOT NULL THEN '09b. DECOUPE devrait être à NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND hdec_dm IS NULL THEN '10. HDEC NULL'
        WHEN veget = '0' AND simplif = '0' AND decoupe IN ('1', '2') AND ddec_cm IS NULL THEN '11. DDEC NULL'
        WHEN mes_c13 IN ('2', '3', '4') AND hcd_cm IS NULL THEN '12a. HCD NULL'
        WHEN mes_c13 = '2' AND NOT hcd_cm BETWEEN 80 AND 130 THEN '12b. HCD erroné sur moyenne de mesures'
        WHEN mes_c13 IN ('3', '4') AND NOT hcd_cm BETWEEN 50 AND 150 THEN '12c. HCD erroné sur mesure décalée ou autre cas'
        WHEN veget = '0' AND ori IS NULL THEN '13. ORI NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND qbp IS NULL THEN '14a. QBP NULL'
        WHEN hdec_dm < 3 AND qbp = '1' THEN '14b. Valeur erronnée de QBP'
        WHEN veget = '0' AND c13_mm >= 705 AND hrb_dm IS NULL THEN '15. HRB NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND lib NOT IN ('0','1') AND ACCI = '0'AND mortb IS NULL THEN '16. MORTB NULL'
        WHEN veget = '0' AND espar < '50' AND c13_mm >= 705 AND mortb IN ('0','1','2','3') AND mr IS NULL THEN '16. MR NULL'
        WHEN veget = '0' AND espar > '50' AND c13_mm >= 705 AND lib != '0' AND ma IS NULL THEN '17. MA NULL'
        WHEN veget = '0' AND c13_mm >= 705 AND sfgui IS NULL THEN '18. SFGUI NULL'
        WHEN c13_mm < 1175 AND deggib IS NULL THEN '19. DEGGIB NULL'
      END AS erreur
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre_m1_2014 am4 USING (id_ech, id_point, a)
    LEFT JOIN sante s USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur, npp, a; -- OK

WITH no_accroi AS (
    SELECT v.npp, a.a
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN accroissement ac USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND csa IN ('1', '3') AND veget = '0' AND simplif = '0' AND espar NOT IN ('06', '27C', '27N') AND ac.id_ech IS NULL
)
SELECT ncern, count(*)
FROM soif.v1e3arbre a
INNER JOIN no_accroi na USING (npp, a)
GROUP BY 1
ORDER BY 1; -- OK


-- CONTROLES DES ARBAT/NOMBRE D'ARBRES REPÈRE FORÊT
-- contrôle sur le nombre d'arbres repère
SELECT npp, id_ech, id_point, nb_arbres, nb_reperes, nb_plaque, 'Problème sur le nombre d''arbres repères'
FROM (
    SELECT npp, id_ech, id_point, COUNT(*) AS nb_arbres
    , COUNT(*) FILTER (WHERE repere IN ('1', '2')) AS nb_reperes
    , COUNT(*) FILTER (WHERE repere = '2') AS nb_plaque
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE v.annee = 2022
    AND veget = '0'
    GROUP BY npp, id_ech, id_point
    HAVING (COUNT(*) > 3 AND COUNT(*) FILTER (WHERE repere IN ('1', '2')) < 3)
    OR SUM(CASE WHEN repere IN ('1', '2') THEN 1 ELSE 0 END) > 3
    OR SUM(CASE WHEN repere = '2' THEN 1 ELSE 0 END) = 0
) AS t
ORDER BY npp;       -- 1 erreur 

-- analyse de ARBAT
SELECT v.npp, v.id_ech, v.id_point, am.a, am.suppl->>'arbat' AS arbat
FROM v_liste_points_lt1_pi2 v
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
WHERE v.annee = 2022
AND am.suppl->>'arbat' IS NOT NULL
AND ab.id_ech IS NULL
ORDER BY npp, am.a;        -- => pas d'erreur !


WITH dist_arbat AS (
    SELECT v.npp, v.id_ech, v.id_point
    , am.a, am.espar, a.c13_mm, am.suppl->>'arbat' AS arbat, am.azpr_gd, am.dpr_cm
    , am2.a AS a2, am2.espar AS espar_2, ab.c13_mm AS c13_mm_2, am2.azpr_gd AS azpr_gd2, am2.dpr_cm AS dpr_cm_2
    , ROUND(SQRT(((am2.dpr_cm / 100.0) * cos(pi() * (100.0 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * cos(pi() * (100.0 - am.azpr_gd / 200.0)))^2
     + ((am2.dpr_cm / 100.0) * sin(pi() * (100 - am2.azpr_gd / 200.0)) - (am.dpr_cm / 100.0) * sin(pi() * (100 - am.azpr_gd / 200.0)))^2)::NUMERIC, 2) AS dist
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    LEFT JOIN arbre ab ON am.id_ech = ab.id_ech AND am.id_point = ab.id_point AND (am.suppl->>'arbat')::INT2 = ab.a
    LEFT JOIN arbre_m1 am2 ON ab.id_ech = am2.id_ech AND am.id_point = am2.id_point AND ab.a = am2.a
    WHERE v.annee = 2022
    AND am.suppl->>'arbat' IS NOT NULL
)
SELECT *
FROM dist_arbat
WHERE dist > 2
ORDER BY npp, a;


-- CONTROLES DES DONNÉES ÉCOLOGIQUE FORÊT
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN distriv ='3' AND denivriv IS NULL THEN '01a. DENIVRIV NULL'
        WHEN distriv != '3' AND denivriv IS NOT NULL THEN '01b. DENIVRIV devrait être à NULL'
        WHEN obstopo != '4' AND pent2 IS NULL THEN '02a. PENT2 NULL'
        WHEN obstopo = '4' AND pent2 IS NOT NULL THEN '02b. PENT2 devrait être à NULL'
        WHEN NOT COALESCE(pent2, 0) BETWEEN 0 AND 202 THEN '02c. valeur incorrecte de PENT2'
        WHEN pent2 >= 5 AND obstopo != '4' AND expo IS NULL THEN '03. EXPO NULL'
        WHEN pent2 >= 5 AND masque IS NULL THEN '04a. MASQUE NULL'
        WHEN pent2 < 5 AND masque IS NOT NULL THEN '04b. MASQUE devrait être à NULL'
        WHEN leve = '1' AND msud IS NULL THEN '05a. MSUD NULL'
        WHEN leve != '1' AND msud IS NOT NULL THEN '05b. MSUD devrait être à NULL'
        WHEN COALESCE(obspedo, '0') != '5' AND az_fo IS NULL THEN '06a. AZ_FO NULL'
        WHEN NOT COALESCE(az_fo, 0) BETWEEN 0 AND 400 THEN '06b. valeur incorrecte de AZ_FO'
        WHEN COALESCE(obspedo, '0') != '5' AND di_fo_cm IS NULL THEN '07a. DI_FO NULL'
        WHEN COALESCE(di_fo_cm, 0) > 2500 THEN '07b. valeur incorrecte de DI_FO'
        WHEN obspedo != '5' AND COALESCE(cailloux, 'X') NOT IN ('0', 'X') AND typcai IS NULL THEN '08. TYPCAI NULL'
        WHEN obspedo != '5' AND htext IS NULL THEN '09. HTEXT NULL'
        WHEN obspedo != '5' AND htext = '2' AND text1 IS NULL THEN '10. TEXT1 NULL'
        WHEN obspedo != '5' AND htext = '2' AND prof1 IS NULL THEN '11a. PROF1 NULL'
        WHEN NOT (obspedo != '5' AND htext = '2') AND prof1 IS NOT NULL THEN '11b. PROF1 devrait être à NULL'
        WHEN obspedo != '5' AND htext IN ('1', '2') AND text2 IS NULL THEN '12. TEXT2 NULL'
        WHEN obspedo != '5' AND htext != '0' AND PROF2 IS NULL THEN '13. PROF2 NULL'
        WHEN prof1 >= prof2 THEN '14. PROF1 >= PROF2'
        WHEN obspedo != '5' AND obsprof IS NULL THEN '14a. OBSPROF NULL'
        WHEN prof2 = '9' AND obsprof NOT IN ('0', '4') THEN '14b. Incohérence entre PROF2 = 9 et OBSPROF'
        WHEN prof2 < '9' AND obsprof NOT IN ('1', '2', '3', '4') THEN '14c. Incohérence entre PROF2 < 9 et OBSPROF'
        WHEN obspedo != '5' AND obshydr IS NULL THEN '15. OBSHYDR NULL'
        WHEN obspedo != '5' AND tsol IS NULL THEN '16. TSOL NULL'
      END AS erreur
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN reco_m1 r1 USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN ecologie e USING (id_ech, id_point)
    LEFT JOIN ecologie_2017 e7 USING (id_ech, id_point)
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur; -- OK


-- CONTROLES DES HABITATS FORÊT - PREMIÈRE VISITE
SELECT * FROM (
    SELECT v.npp, v.id_ech, v.id_point
    , CASE 
        WHEN csa IN ('1', '3') AND caracthab IS NULL THEN '01. CARACTHAB NULL'
        WHEN d.suppl->>'ligneriv' IS NOT NULL AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "LIGNERIV")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99a. Commentaire absent sur LIGNERIV'
        WHEN h1.obshab IN ('1', '3', '6') AND h1.s_hab IS NULL THEN '02. S_HAB1 NULL'
        WHEN h1.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB1")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99b. Commentaire absent sur QUALHAB1'
        WHEN h2.obshab IN ('1', '3', '6') AND h2.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '03. S_HAB2 NULL'
        WHEN h2.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB2")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99c. Commentaire absent sur QUALHAB1'
        WHEN h3.obshab IN ('1', '3', '6') AND h3.s_hab IS NULL AND h1.s_hab IS NOT NULL THEN '04. S_HAB3 NULL'
        WHEN h3.qualhab = 'X' AND jsonb_path_query_first(d.qual_data, ('$[*] ? (@.donnee == "QUALHAB3")."qdonnee"')::jsonpath)->>0 IS NULL THEN '99d. Commentaire absent sur QUALHAB1'
        WHEN h1.s_hab IS NOT NULL AND (replace(h1.s_hab, 'X', '0'))::int2 + coalesce((replace(h2.s_hab, 'X', '0'))::int2, 0) + coalesce((replace(h3.s_hab, 'X', '0'))::int2, 0) != 10 THEN '05. Problème de somme de surfaces d''habitats'
      END AS erreur
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    INNER JOIN description d USING (id_ech, id_point)
    INNER JOIN descript_m1 dm USING (id_ech, id_point)
    LEFT JOIN habitat h1 ON v.id_ech = h1.id_ech AND v.id_point = h1.id_point AND h1.num_hab = 1
    LEFT JOIN habitat h2 ON v.id_ech = h2.id_ech AND v.id_point = h2.id_point AND h2.num_hab = 2
    LEFT JOIN habitat h3 ON v.id_ech = h3.id_ech AND v.id_point = h3.id_point AND h3.num_hab = 3
    WHERE v.annee = 2022
) AS t
WHERE erreur IS NOT NULL
ORDER BY erreur;
-- commentaires absents sur QUALHAB1



-- REQUÊTES COMPLÉMENTAIRES
-- requête vérifiant la bonne numérotation des arbres sur les points
WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2022
)
, t1 AS (
     SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, rang_a - rang_az AS gap,
     DENSE_RANK() OVER(PARTITION BY npp ORDER BY npp,
     ABS(rang_a - rang_az) DESC, rang_a - rang_az DESC) AS rang_ecart
     FROM t0
     WHERE rang_a <> rang_az
)
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, gap
FROM t1
WHERE rang_ecart = 1
ORDER BY npp, a; -- OK


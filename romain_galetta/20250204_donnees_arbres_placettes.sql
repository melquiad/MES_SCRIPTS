SET enable_nestloop = FALSE;

---------------------------------------
-- Données placettes de 1ère visite
---------------------------------------
SELECT p.idp, plt.datepoint, r.csa, pe.ser_86, r2.tform, gf.comp_r
, d.tplant, pl.tpespar1, pl.tpespar2, d.href_dm AS hauteur_de_ref_en_dm, d.sver, dm.tcat10
, e.pent2, e.topo, e.expo, e.masque, e2.msud, e.humus, e.tsol
--, CASE WHEN r.csa = '5' THEN pe2.rayo ELSE ge.rayo END AS rayo
--, CASE WHEN r.csa = '5' THEN pe2.hydr ELSE ge.hydr END AS hydr
--, CASE WHEN r.csa = '5' THEN pe2.troph ELSE ge.troph END AS troph
, COALESCE (ge.rayo, pe2.rayo) AS rayo
, COALESCE (ge.hydr, pe2.hydr) AS hydr
, COALESCE (ge.troph, pe2.troph) AS troph
--, ge.rayo, pe2.rayo AS rayo_peupleraie, ge.hydr, pe2.hydr AS hydr_peupleraie, ge.troph, pe2.troph AS troph_peupleraie
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 v1
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point_lt plt USING (id_ech, id_point)
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
LEFT JOIN plantations pl USING (id_ech, id_point)
LEFT JOIN ecologie e USING (id_ech, id_point)
LEFT JOIN ecologie_2017 e2 USING (id_ech, id_point)
LEFT JOIN inv_exp_nm.g3ecologie ge ON v1.npp = ge.npp
LEFT JOIN inv_exp_nm.p3ecologie pe2 ON v1.npp = pe2.npp
LEFT JOIN inv_exp_nm.g3foret gf ON v1.npp = gf.npp
WHERE annee = 2023 AND csa IN ('1','3','5')
UNION
SELECT p.idp, plt.datepoint, r.csa, pe.ser_86, r2.tform, gf.comp_r
, d.tplant, pl.tpespar1, pl.tpespar2, d.href_dm AS hauteur_de_ref_en_dm, d.sver, dm.tcat10
, e.pent2, e.topo, e.expo, e.masque, e2.msud, e.humus, e.tsol
--, CASE WHEN r.csa = '5' THEN pe2.rayo ELSE ge.rayo END AS rayo
--, CASE WHEN r.csa = '5' THEN pe2.hydr ELSE ge.hydr END AS hydr
--, CASE WHEN r.csa = '5' THEN pe2.troph ELSE ge.troph END AS troph
, COALESCE (ge.rayo, pe2.rayo) AS rayo
, COALESCE (ge.hydr, pe2.hydr) AS hydr
, COALESCE (ge.troph, pe2.troph) AS troph
--, ge.rayo, pe2.rayo, ge.hydr, pe2.hydr, ge.troph, pe2.troph
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point_lt plt USING (id_ech, id_point)
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN descript_m1 dm USING (id_ech, id_point)
LEFT JOIN plantations pl USING (id_ech, id_point)
LEFT JOIN ecologie e USING (id_ech, id_point)
LEFT JOIN ecologie_2017 e2 USING (id_ech, id_point)
LEFT JOIN inv_exp_nm.g3ecologie ge ON vp1.npp = ge.npp
LEFT JOIN inv_exp_nm.p3ecologie pe2 ON vp1.npp = pe2.npp
LEFT JOIN inv_exp_nm.g3foret gf ON vp1.npp = gf.npp
WHERE annee = 2023 AND csa IN ('1','3','5')
ORDER BY datepoint;


-------------------------------------
-- Données arbres de 1ère visite
-------------------------------------
SELECT p.idp, v1.annee, a.a , a.c13_mm / 10::numeric AS c13_en_cm
, a2.libelle, a1.espar, a1.veget, a1.dpr_cm, a1.azpr_gd, a1.lib, a1.htot_dm AS hauteur_totale_en_dm
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 v1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN metaifn.abmode a2 ON a1.espar = a2."mode" AND a2.unite = 'ESPAR1'
WHERE annee = 2023
UNION 
SELECT p.idp, vp1.annee, a.a , a.c13_mm / 10::numeric AS c13_en_cm  -- les arbres recrutés sur pi2 lt1 sont pris en compte car dans arbre_m1
, a2.libelle, a1.espar, a1.veget, a1.dpr_cm, a1.azpr_gd, a1.lib, a1.htot_dm AS hauteur_totale_en_dm
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN metaifn.abmode a2 ON a1.espar = a2."mode" AND a2.unite = 'ESPAR1'
WHERE annee = 2023
ORDER BY annee, idp, a;


-------------------------------------
-- Données de couverture arbres
-------------------------------------
SELECT v1.annee, p.idp, r.csa, ge.espar, ge.tca, ge.tcl
FROM v_liste_points_lt1 v1
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN inv_exp_nm.g3essence ge ON v1.npp = ge.npp
WHERE annee = 2023 AND csa IN ('1','3','5')
UNION
SELECT v1.annee, p.idp, r.csa, pe.espar, pe.tca, pe.tcl
FROM v_liste_points_lt1 v1
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN inv_exp_nm.p3essence pe ON v1.npp = pe.npp
WHERE annee = 2023 AND csa IN ('1','3','5')
ORDER BY idp;

-- pas de points PI2LT1 dans g3essence et p3essence => aucun résultat
/*
SELECT vp1.annee, vp1.npp, vp1.id_point, p.idp, r.csa, ge.espar, ge.tca, ge.tcl
FROM v_liste_points_lt1_pi2 vp1
INNER  JOIN point p  USING (id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN inv_exp_nm.g3essence ge ON vp1.npp = ge.npp
WHERE annee BETWEEN 2020 AND 2022 AND csa IN ('1','3','5')
UNION
SELECT vp1.annee, vp1.npp, vp1.id_point, p.idp, r.csa, pe.espar, pe.tca, pe.tcl
FROM v_liste_points_lt1_pi2 vp1
INNER  JOIN point p  USING (id_point)
LEFT JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN inv_exp_nm.p3essence pe ON vp1.npp = pe.npp
WHERE annee BETWEEN 2020 AND 2022 AND csa IN ('1','3','5')
ORDER BY npp;
*/ 
-------------------------------------------------------------------------------------------------------------------


/* Test présence points pi2lt1 dans g3essence et p3essence => aucun résultat

SELECT vp1.annee, vp1.npp, vp1.id_point
--FROM v_liste_points_lt1_pi2 vp1
FROM v_liste_points_lt1 vp1
INNER JOIN inv_exp_nm.g3essence ge ON vp1.npp = ge.npp
WHERE incref BETWEEN 15 AND 17;

SELECT vp1.annee, vp1.npp, vp1.id_point
--FROM v_liste_points_lt1_pi2 vp1
FROM v_liste_points_lt1 vp1
INNER JOIN inv_exp_nm.p3essence pe ON vp1.npp = pe.npp
WHERE incref BETWEEN 15 AND 17;
*/

---------------------------------------
-- Données placettes de 2ème visite
---------------------------------------
SELECT p.idp, plt.datepoint, r.csa, pe.ser_86, r2.tform, gf.comp_r
, d.tplant, pl.tpespar1, pl.tpespar2, d.href_dm AS hauteur_de_ref_en_dm, d.sver--, dm.tcat10
, e.pent2, e.topo, e.expo, e.masque, e2.msud, e.humus, e.tsol
--, CASE WHEN r.csa = '5' THEN pe2.rayo ELSE ge.rayo END AS rayo
--, CASE WHEN r.csa = '5' THEN pe2.hydr ELSE ge.hydr END AS hydr
--, CASE WHEN r.csa = '5' THEN pe2.troph ELSE ge.troph END AS troph
, COALESCE (ge.rayo, pe2.rayo) AS rayo
, COALESCE (ge.hydr, pe2.hydr) AS hydr
, COALESCE (ge.troph, pe2.troph) AS troph
--, ge.rayo, pe2.rayo AS rayo_peupleraie, ge.hydr, pe2.hydr AS hydr_peupleraie, ge.troph, pe2.troph AS troph_peupleraie
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 v1
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point_lt plt USING (id_ech, id_point)
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_2015 r2 USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
--INNER JOIN descript_m1 dm USING (id_ech, id_point)
LEFT JOIN plantations pl USING (id_ech, id_point)
LEFT JOIN ecologie e USING (id_ech, id_point)
LEFT JOIN ecologie_2017 e2 USING (id_ech, id_point)
LEFT JOIN inv_exp_nm.g3ecologie ge ON v1.npp = ge.npp
LEFT JOIN inv_exp_nm.p3ecologie pe2 ON v1.npp = pe2.npp
LEFT JOIN inv_exp_nm.g3foret gf ON v1.npp = gf.npp
WHERE annee BETWEEN 2020 AND 2023 AND csa IN ('1','3','5')
ORDER BY datepoint;


-------------------------------------
-- Données arbres de 2ème visite
-------------------------------------
SELECT p.idp, v1.annee, a.a , a.c13_mm / 10::numeric AS c13_en_cm, a1.veget5
--, a2.libelle, a1.espar, a1.veget, a1.dpr_cm, a1.azpr_gd, a1.lib, a1.htot_dm AS hauteur_totale_en_dm
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 v1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a1 USING (id_ech, id_point, a)
--INNER JOIN metaifn.abmode a2 ON a1.espar = a2."mode" AND a2.unite = 'ESPAR1'
WHERE annee BETWEEN 2020 AND 2023
ORDER BY annee, idp, a;

-------------------------------------------------------------------------------------------
-- Données arbres de 2ème visite nouvellement recensables ( les arbres 1ère visite
-- nouvellement recensables sont déjà inclus dans la requête arbres 1ère visite au-dessus)
-------------------------------------------------------------------------------------------
SELECT p.idp, v1.annee, a.a , a.c13_mm / 10::numeric AS c13_en_cm--, a1.veget5
, a2.libelle , a1.espar, a1.veget, a1.dpr_cm, a1.azpr_gd, a1.lib, a1.htot_dm AS hauteur_totale_en_dm
, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt2 v1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN metaifn.abmode a2 ON a1.espar = a2."mode" AND a2.unite = 'ESPAR1'
WHERE annee BETWEEN 2020 AND 2023
ORDER BY annee, idp, a;


-------------------------------------
-- Données de couverture arbres
-------------------------------------
SELECT v1.annee, p.idp, r.csa, ge.espar, ge.tca, ge.tcl
FROM v_liste_points_lt2 v1
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_m2 rm USING (id_ech, id_point)
INNER JOIN inv_exp_nm.g3essence ge ON v1.npp = ge.npp
WHERE annee BETWEEN 2020 AND 2023 AND csa IN ('1','3','5')
UNION
SELECT v1.annee, p.idp, r.csa, pe.espar, pe.tca, pe.tcl
FROM v_liste_points_lt2 v1
INNER JOIN point p  USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN reco_m2 rm USING (id_ech, id_point)
INNER JOIN inv_exp_nm.p3essence pe ON v1.npp = pe.npp
WHERE annee BETWEEN 2020 AND 2023 AND csa IN ('1','3','5')
ORDER BY idp;


-----------------------------------------------------------------------------
--------------- METADONNEES -------------------------------------------------
-----------------------------------------------------------------------------

WITH u AS
	(
	SELECT d.donnee, COALESCE(i.dcunite, d.unite) AS unite
	, COALESCE(min(i.incref + 2005), 2020) AS debut, COALESCE(max(i.incref + 2005), 2022) AS fin
	FROM metaifn.addonnee d
	LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' AND i.incref BETWEEN 15 AND 17
	WHERE d.donnee ~~* 'tca'
	GROUP BY 1, 2
	)
SELECT u.donnee, u.unite, ab."mode", ab.libelle, ab.definition
FROM u
INNER JOIN metaifn.abmode ab ON u.unite = ab.unite;


-- ma requête basique pour les données dont les unités n'ont pas varié dans le temps  ---
SELECT ad.codage, ad.libelle, ad.donnee, ab.unite, ab."mode", ab.libelle, ab.definition
FROM metaifn.addonnee ad
INNER JOIN metaifn.abmode ab ON ad.unite = ab.unite
WHERE ad.donnee = 'COMP_R';


---------------------------------------------------------------------------------------------------
---- Cédric -----
-- unités au fil des incref --
SELECT d.donnee, d.unite, i.incref, i.dcunite, d.libelle
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' -- AND i.incref BETWEEN 15 AND 17
WHERE d.donnee ~~* 'veget'
ORDER BY incref;

-- année début et fin des unités
SELECT d.donnee, COALESCE(i.dcunite, d.unite) AS unite
, COALESCE(min(i.incref + 2005), 2020) AS debut, COALESCE(max(i.incref + 2005), 2022) AS fin
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' --AND i.incref BETWEEN 15 AND 17
WHERE d.donnee ~~* 'veget'
GROUP BY 1, 2
ORDER BY 3, 4;





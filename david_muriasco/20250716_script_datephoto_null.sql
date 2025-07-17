

SELECT pp.id_point, v.npp
FROM inv_prod_new.point_pi pp
INNER JOIN v_liste_points_lt1_pi2 v USING (id_point)
WHERE v.id_ech = 145 AND pp.id_ech = 142
AND pp.datephoto = NULL;

SELECT *
FROM public.date_photo_point d
where datephoto IS NULL; 

SELECT id_ech, id_point
FROM point_pi p
WHERE datephoto IS NULL
AND id_ech IN (141,142);

-------------------------------------------


CREATE TABLE public.pts_39 AS
(
WITH pts_v1 AS
(
SELECT vp.npp, pe.dep, vp.annee, 'T' AS inv, 1::int2 AS numvisi, round(st_x (st_transform (p.geom, 27572))::numeric) AS xl, round(st_y (st_transform (p.geom, 27572))::numeric) AS yl, pe.zp AS z, st_x (st_transform (p.geom, 4326)) AS xgps, st_y (st_transform (p.geom, 4326)) AS ygps,
pe.ser_86 AS ser, pe.regn, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init AS echelon, m2.libelle AS libelledir, t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, t.decli, 'OUI' AS lhf,
pe.rbi, pl.secteur_cn, '' AS pdiff, '' AS pclos, pp.datephoto
FROM v_liste_points_lt1 vp
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN echantillon ech USING (id_ech)
LEFT JOIN point_pi pp ON ech.ech_parent_stat = pp.id_ech AND pe.id_point = pp.id_point
INNER JOIN transect t USING (id_transect)
LEFT JOIN metaifn.abmode m ON m.mode = pe.regn AND m.unite = 'RF'
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init AND m2.unite = 'EX'
LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86 AND m3.unite = 'SER_86'
WHERE vp.annee = 2026
UNION
SELECT vp.nppr AS npp, pe.dep, vp.annee, 'R' AS inv, 1::int2 AS numvisi, round(st_x (st_transform (p.geom, 27572))::numeric) AS xl, round(st_y (st_transform (p.geom, 27572))::numeric) AS yl, pe.zp AS z, st_x (st_transform (p.geom, 4326)) AS xgps, st_y (st_transform (p.geom, 4326)) AS ygps,
pe.ser_86 AS ser, pe.regn, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init, m2.libelle AS libelledir, t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, decli_pt AS decli, 'NON' AS lhf,
pe.rbi, pl.secteur_cn, '' AS pdiff, '' AS pclos, max(pp.datephoto) AS datephoto
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN echantillon ech ON pl.id_ech = ech.id_ech AND ech.passage > 1
LEFT JOIN point_pi pp ON pe.id_point = pp.id_point-- AND ech.ech_parent_stat = pp.id_ech
INNER JOIN transect t USING (id_transect)
LEFT JOIN metaifn.abmode m ON m.mode = pe.regn AND m.unite = 'RF'
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init AND m2.unite = 'EX'
LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86 AND m3.unite = 'SER_86'
WHERE vp.annee = 2026
GROUP BY nppr, dep, annee, inv, numvisi, xl, yl, z, xgps, ygps, ser, regn, libellereg, libelleser, pl.echelon_init, libelledir, aztrans, aztransgr
, pl.decli_pt, lhf, rbi, secteur_cn, pdiff, pclos
)
SELECT npp, dep, annee AS campagne, inv, numvisi, xl, yl, z, xgps, ygps,
ser, regn AS reg, libellereg, libelleser, echelon, libelledir, aztrans, aztransgr, decli, row_number() OVER (ORDER BY secteur_cn, npp) AS page, lhf, rbi, secteur_cn, pdiff, pclos, datephoto
FROM pts_v1
WHERE datephoto IS NULL
ORDER BY dep, npp);

---------------------------------------------------------------------------
SELECT p.npp, pp.id_point, max(pp.datephoto) AS datephoto
FROM public.pts_39 p
INNER JOIN point_pi pp ON p.id_point = pp.id_point
GROUP BY p.npp, pp.id_point
ORDER BY p.npp;

------------------------------------------------------------------
SELECT DISTINCT ON (nppr) annee, npp, nppr, nph, vlp.id_ech, vlp.id_point, datepi, occ, cso, dbpi, pbpi, uspi, ufpi, tfpi, phpi, blpi, dupi, evof, datephoto
FROM v_liste_points_lt1_pi2 vlp
INNER JOIN point_pi pp ON vlp.id_point = pp.id_point
INNER JOIN echantillon e ON pp.id_ech = e.id_ech AND e.passage > 1
WHERE annee = 2026
ORDER BY nppr, pp.id_ech DESC;







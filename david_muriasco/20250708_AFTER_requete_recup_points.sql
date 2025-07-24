

Requête permettant de récupère les points premiere  visite :

WITH pts_v1 AS (
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
LEFT JOIN metaifn.abmode m ON m.mode = pe.regn
AND m.unite = 'RF'
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
AND m2.unite = 'EX'
LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86
AND m3.unite = 'SER_86'
WHERE vp.annee = 2026 AND pl.reco IS NULL --> pour exclure les points reco = '3'
UNION
SELECT vp.nppr AS npp, pe.dep, vp.annee, 'R' AS inv, 1::int2 AS numvisi, round(st_x (st_transform (p.geom, 27572))::numeric) AS xl, round(st_y (st_transform (p.geom, 27572))::numeric) AS yl, pe.zp AS z, st_x (st_transform (p.geom, 4326)) AS xgps, st_y (st_transform (p.geom, 4326)) AS ygps,
pe.ser_86 AS ser, pe.regn, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init, m2.libelle AS libelledir, t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, decli_pt AS decli, 'NON' AS lhf,
pe.rbi, pl.secteur_cn, '' AS pdiff, '' AS pclos, pp.datephoto
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN echantillon ech USING (id_ech)
LEFT JOIN point_pi pp ON ech.ech_parent_stat = pp.id_ech AND pe.id_point = pp.id_point
INNER JOIN transect t USING (id_transect)
LEFT JOIN metaifn.abmode m ON m.mode = pe.regn
AND m.unite = 'RF'
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
AND m2.unite = 'EX'
LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86
AND m3.unite = 'SER_86'
WHERE vp.annee = 2026
)
SELECT npp, dep, annee AS campagne, inv, numvisi, xl, yl, z, xgps, ygps,
ser, regn AS reg, libellereg, libelleser, echelon, libelledir, aztrans, aztransgr, decli, row_number() OVER (ORDER BY dep, npp) AS page, lhf, rbi, secteur_cn, pdiff, pclos, datephoto
FROM pts_v1
ORDER BY dep, npp;

```

Requête permettant de récupère les points deuxième visite :

SELECT vp.npp, pe.dep, vp.annee as campagne, 'T' AS inv, 2::INT2 AS numvisi
, round(st_x(st_transform(p.geom, 27572))::NUMERIC) AS xl, round(st_y(st_transform(p.geom, 27572))::NUMERIC) AS yl, pe.zp AS z
, st_x(st_transform(p.geom, 4326)) AS xgps, st_y(st_transform(p.geom, 4326)) AS ygps
, pe.ser_86 AS ser, pe.regn as reg, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init AS echelon, m2.libelle AS libelledir
, t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, t.decli, row_number() OVER (ORDER BY pe.dep, vp.npp) AS page
, 'NON' AS lhf, pe.rbi, pl.secteur_cn
, pm1.pdiff
, pm1.pclos
FROM v_liste_points_lt2 vp
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN transect t USING (id_transect)
INNER JOIN point_m1 pm1 ON vp.id_point = pm1.id_point AND pm1.id_ech < pe.id_ech
LEFT JOIN metaifn.abmode m ON m.mode = pe.regn
AND m.unite = 'RF'
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
AND m2.unite = 'EX'
LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86
AND m3.unite = 'SER_86'
WHERE vp.annee = 2026 --AND pl.reco IS NULL --> pour exclure les points reco = '3'
ORDER BY dep, npp;



Requète permettant de récupère les points Ecologie :

SELECT lp1.npp, lp1.nph, lp1.annee AS campagne,
ROUND(ST_X(ST_Transform(p.geom, 27572))::NUMERIC) AS xl,
ROUND(ST_Y(ST_Transform(p.geom, 27572))::NUMERIC) AS yl,
pe.regn, pe.dep, pl.secteur_cn, left(pe.ser_86, 1) AS greco, h.indrivmnt,
proba_hetre*10 probhet3, angle_gams gamsc, 'aller' AS lot,
rmoy PLUIE, round(tmoy, 1) AS temp,
pmin, pmax, tMIN, tMAX,
tmax_ete, ind_mart IA_DM, ind_emb QP_E,
m2.libelle AS libelledir
FROM v_liste_points_lt1 lp1
LEFT JOIN point p USING (id_point)
LEFT JOIN point_ech pe USING (id_ech, id_point)
LEFT JOIN hydro h USING (id_ech, id_point)
LEFT JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init AND m2.unite = 'EX'
LEFT JOIN aurelhy.aurelhy_pt ap ON round(st_x(st_transform(p.geom, 27572))::numeric, -3) = ap.xl2 AND round(st_y(st_transform(p.geom, 27572))::numeric, -3) = ap.yl2
LEFT JOIN aurelhy.aurelhy_an aa ON ap.id_pt= aa.id_pt AND annee_deb = 1971
WHERE lp1.annee = 2026
UNION
SELECT lp2.npp, lp2.nph, lp2.annee AS campagne,
ROUND(ST_X(ST_Transform(p.geom, 27572))::NUMERIC) AS xl,
ROUND(ST_Y(ST_Transform(p.geom, 27572))::NUMERIC) AS yl,
pe.regn, pe.dep, pl.secteur_cn, left(pe.ser_86, 1) AS greco, h.indrivmnt,
proba_hetre*10 probhet3, angle_gams gamsc, 'aller' AS lot,
rmoy PLUIE, round(tmoy, 1) AS temp,
pmin, pmax, tMIN, tMAX,
tmax_ete, ind_mart IA_DM, ind_emb QP_E,
m2.libelle AS libelledir
FROM v_liste_points_lt1_pi2 lp2
LEFT JOIN point p USING (id_point)
LEFT JOIN point_ech pe USING (id_ech, id_point)
LEFT JOIN hydro h USING (id_ech, id_point)
LEFT JOIN point_lt pl USING (id_ech, id_point)
LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init AND m2.unite = 'EX'
LEFT JOIN aurelhy.aurelhy_pt ap ON round(st_x(st_transform(p.geom, 27572))::numeric, -3) = ap.xl2 AND round(st_y(st_transform(p.geom, 27572))::numeric, -3) = ap.yl2
LEFT JOIN aurelhy.aurelhy_an aa ON ap.id_pt= aa.id_pt AND annee_deb = 1971
WHERE lp2.annee = 2026
ORDER BY dep, npp;


---------------------------------------------------------------------------------------------

WITH BD AS
	(
	SELECT lp1.npp, lp1.nph, lp1.annee AS campagne, geom
	, round(ST_X (ST_Transform (p.geom, 27572))::numeric) AS xl, round(ST_Y (ST_Transform (p.geom, 27572))::numeric) AS yl, pe.regn, pe.dep, pl.secteur_cn
	, LEFT (pe.ser_86, 1) AS greco
	, h.indrivmnt, proba_hetre * 10 probhet3, angle_gams gamsc, 'aller' AS lot
	, m2.libelle AS libelledir
	FROM v_liste_points_lt1 lp1
	INNER JOIN point p USING (id_point)
	INNER JOIN point_ech pe USING (id_ech, id_point)
	INNER JOIN hydro h USING (id_ech, id_point)
	INNER JOIN point_lt pl USING (id_ech, id_point)
	INNER JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
	    AND m2.unite = 'EX'
	WHERE lp1.annee = 2026
	   AND reco IS NULL
	UNION 
	               SELECT lp1.nppr AS npp, lp1.nph, lp1.annee AS campagne, geom
	, round(ST_X (ST_Transform (p.geom, 27572))::numeric) AS xl, round(ST_Y (ST_Transform (p.geom, 27572))::numeric) AS yl, pe.regn, pe.dep, pl.secteur_cn
	, LEFT (pe.ser_86, 1) AS greco
	, h.indrivmnt, proba_hetre * 10 probhet3, angle_gams gamsc, 'aller' AS lot, m2.libelle AS libelledir
	FROM v_liste_points_lt1_pi2 lp1
	INNER JOIN point p USING (id_point)
	INNER JOIN point_ech pe USING (id_ech, id_point)
	INNER JOIN hydro h USING (id_ech, id_point)
	INNER JOIN point_lt pl USING (id_ech, id_point)
	INNER JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
	    AND m2.unite = 'EX'
	WHERE lp1.annee = 2026
	--AND reco IS NULL
    )
SELECT BD.*, rmoy PLUIE, round(tmoy, 1) AS temp, pmin, pmax, tMIN, tMAX, tmax_ete, ind_mart IA_DM, ind_emb QP_E
FROM BD
INNER JOIN LATERAL (
    SELECT id_pt
    FROM aurelhy.v_aurelhy_pt a
    ORDER BY BD.geom <-> a.geom
    LIMIT 1) ap ON TRUE
INNER JOIN aurelhy.aurelhy_an aa ON ap.id_pt = aa.id_pt and annee_deb = 1971
ORDER BY dep, npp;











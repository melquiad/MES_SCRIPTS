SET enable_nestloop = FALSE;

WITH bd AS (
			SELECT v.npp, v.id_point
			FROM inv_prod_new.v_liste_points_lt1 v
			WHERE v.annee = 2025
			UNION
			SELECT v1.nppr AS npp, id_point
			FROM inv_prod_new.v_liste_points_lt1_pi2 v1
			WHERE annee = 2025                                                                                       
           )
SELECT bd.npp, bd.id_point, MOIS, TMOY, RMOY AS PLUIE
FROM bd
LEFT JOIN inv_prod_new.point p USING (ID_POINT)
JOIN LATERAL (
				SELECT id_pt
--				FROM aurelhy.v_aurelhy_pt a
				FROM carto_exo.aurelhy_pt a
				ORDER BY p.geom <-> ST_Transform(a.geom, 2154)
				LIMIT 1
			) ap ON TRUE
--LEFT JOIN aurelhy.aurelhy_mois aa ON aa.id_pt = ap.id_pt AND aa.annee_deb = '1971'
LEFT JOIN carto_exo.aurelhy_mois aa ON aa.id_pt = ap.id_pt AND aa.annee_deb = '1971'
ORDER BY bd.npp, mois;


------------------------------------------------------------------------------
WITH bd AS (
    SELECT v.npp, v.id_point
    , round(st_x(st_transform(p.geom, 27572))::numeric, -3) AS xl2
    , round(st_y(st_transform(p.geom, 27572))::numeric, -3) AS yl2
    FROM v_liste_points_lt1 v
    INNER JOIN point p USING (id_point)
    WHERE v.annee = 2025
    UNION
    SELECT v.nppr AS npp, v.id_point
    , round(st_x(st_transform(p.geom, 27572))::numeric, -3) AS xl2
    , round(st_y(st_transform(p.geom, 27572))::numeric, -3) AS yl2
    FROM v_liste_points_lt1_pi2 v
    INNER JOIN point p USING (id_point)
    WHERE v.annee = 2025
)
SELECT bd.npp, bd.id_point, mois, tmoy, rmoy AS pluie
FROM bd
INNER JOIN aurelhy.aurelhy_pt ap ON bd.xl2 = ap.xl2 AND bd.yl2 = ap.yl2
LEFT JOIN aurelhy.aurelhy_mois aa ON aa.id_pt = ap.id_pt
    AND aa.annee_deb = 1971
ORDER BY bd.npp, mois;

--------------------------------------------------------------------------
--- version optimisée par Cédric
WITH bd AS (
    SELECT npp, id_point
    FROM v_liste_points_lt1
    WHERE annee = 2026
    UNION
    SELECT nppr AS npp, id_point
    FROM v_liste_points_lt1_pi2
    WHERE annee = 2026
)
SELECT bd.npp, id_point, mois, tmoy, rmoy AS pluie, reco
FROM bd
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_point)
JOIN LATERAL (
    SELECT id_pt
    FROM aurelhy.v_aurelhy_pt a
    ORDER BY p.geom <-> a.geom
    LIMIT 1) ap ON TRUE
LEFT JOIN aurelhy.aurelhy_mois aa ON aa.id_pt = ap.id_pt
    AND aa.annee_deb = 1971
WHERE reco IS NULL
ORDER BY bd.npp, mois;


SELECT lp1.npp, lp1.nph, lp1.annee AS campagne
, round(ST_X (ST_Transform (p.geom, 27572))::numeric) AS xl, round(ST_Y (ST_Transform (p.geom, 27572))::numeric) AS yl, pe.regn, pe.dep, pl.secteur_cn
, LEFT (pe.ser_86, 1) AS greco
, h.indrivmnt, proba_hetre * 10 probhet3, angle_gams gamsc, 'aller' AS lot
, rmoy PLUIE, round(tmoy, 1) AS temp, pmin, pmax, tMIN, tMAX
, tmax_ete, ind_mart IA_DM, ind_emb QP_E, m2.libelle AS libelledir
FROM v_liste_points_lt1 lp1
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN hydro h USING (id_ech, id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
    AND m2.unite = 'EX'
INNER JOIN LATERAL (
    SELECT id_pt
    FROM aurelhy.v_aurelhy_pt a
    ORDER BY p.geom <-> a.geom
    LIMIT 1) ap ON TRUE
INNER JOIN aurelhy.aurelhy_an aa ON ap.id_pt = aa.id_pt
    AND annee_deb = 1971
WHERE lp1.annee = 2026
    AND reco IS NULL
ORDER BY dep, npp;










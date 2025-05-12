
REFRESH MATERIALIZED VIEW aurelhy.v_aurelhy_pt;

SET enable_nestloop = FALSE;

SELECT lp1.npp, lp1.nph
               	, lp1.annee AS campagne
                , ROUND(ST_X(ST_Transform(p.geom, 27572))::NUMERIC) AS xl
                , ROUND(ST_Y(ST_Transform(p.geom, 27572))::NUMERIC) AS yl
                , pe.regn, pe.dep, pl.secteur_cn, left(pe.ser_86, 1) AS greco, h.indrivmnt
                , proba_hetre*10 probhet3, angle_gams gamsc, 'aller' AS lot
                , rmoy PLUIE, round(tmoy, 1) AS temp
                , pmin, pmax, tMIN, tMAX
                , tmax_ete, ind_mart IA_DM, ind_emb QP_E
                , m2.libelle AS libelledir
                FROM v_liste_points_lt1 lp1
                LEFT JOIN point p USING (id_point)
                LEFT JOIN point_ech pe USING (id_ech, id_point)
                LEFT JOIN hydro h USING (id_ech, id_point)
                LEFT JOIN point_lt pl USING (id_ech, id_point)
                LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init AND m2.unite = 'EX'
                JOIN LATERAL (
                             SELECT id_pt
                             FROM aurelhy.v_aurelhy_pt a
                             ORDER BY p.geom <-> ST_Transform(p.geom, 2154)
                             LIMIT 1
                             ) ap ON TRUE
                LEFT JOIN aurelhy.aurelhy_an aa ON ap.id_pt= aa.id_pt AND annee_deb = 1971
                WHERE lp1.annee = '2025'
                ORDER BY dep, npp;
				

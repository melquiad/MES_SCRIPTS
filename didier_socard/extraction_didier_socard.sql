WITH pts_v1 AS (
                SELECT vp.npp, pe.dep, vp.annee, 'T' AS inv, 1::INT2 AS numvisi
                , round(st_x(st_transform(p.geom, 932006))::NUMERIC) AS xl,  round(st_y(st_transform(p.geom, 932006))::NUMERIC) AS yl, pe.zp AS z
                , st_x(st_transform(p.geom, 921048)) AS xgps, st_y(st_transform(p.geom, 921048)) AS ygps
                , pe.ser_86 AS ser, pe.regn, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init AS echelon, m2.libelle AS libelledir
                , t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, t.decli
                , 'OUI'     AS lhf, pe.rbi, pe.secteur_cn, '' as pdiff
                FROM v_liste_points_lt1 vp
                INNER JOIN point_ech pe USING (id_ech, id_point)
                INNER JOIN point p USING (id_point)
                INNER JOIN point_lt pl USING (id_ech, id_point)
                INNER JOIN transect t USING (id_transect)
                LEFT JOIN metaifn.abmode m ON m.mode = pe.regn
               AND m.unite = 'RF'
                LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
                AND m2.unite = 'EX'
                LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86
                AND m3.unite = 'SER_86'
                WHERE vp.annee = 2023
                UNION                
                SELECT vp.nppr AS npp, pe.dep, vp.annee, 'R' AS inv, 1::INT2 AS numvisi
                , round(st_x(st_transform(p.geom, 932006))::NUMERIC) AS xl,  round(st_y(st_transform(p.geom, 932006))::NUMERIC) AS yl, pe.zp AS z
                , st_x(st_transform(p.geom, 921048)) AS xgps, st_y(st_transform(p.geom, 921048)) AS ygps
                , pe.ser_86 AS ser, pe.regn, m.libelle AS libellereg, m3.libelle AS libelleser, pl.echelon_init, m2.libelle AS libelledir
                , t.aztrans, round((t.aztrans * 200 / pi())::numeric, 2) AS aztransgr, decli_pt as decli
                , 'NON' AS lhf, pe.rbi, pe.secteur_cn, '' AS pdiff
                FROM v_liste_points_lt1_pi2 vp
                INNER JOIN point_ech pe USING (id_ech, id_point)
                INNER JOIN point p USING (id_point)
                INNER JOIN point_lt pl USING (id_ech, id_point)
                INNER JOIN transect t USING (id_transect)
                LEFT JOIN metaifn.abmode m ON m.mode = pe.regn
                AND m.unite = 'RF'
                LEFT JOIN metaifn.abmode m2 ON m2.mode = pl.echelon_init
                AND m2.unite = 'EX'
                LEFT JOIN metaifn.abmode m3 ON m3.mode = pe.ser_86
                AND m3.unite = 'SER_86'
                WHERE vp.annee = 2023
                )
                SELECT npp, dep, annee as campagne, inv, numvisi, xl, yl, z, xgps, ygps, ser, regn as reg, libellereg, libelleser, echelon, libelledir, aztrans, aztransgr, decli
                , row_number() OVER (ORDER BY dep, npp) AS page, lhf, rbi, secteur_cn, pdiff
                FROM pts_v1
                ORDER BY dep, npp;

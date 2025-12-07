LOAD postgres;
ATTACH 'host=localhost port=5433 user=LHaugomat dbname=inventaire' AS pg (TYPE postgres);


WITH decompte AS (
    SELECT *
    FROM postgres_query('pg', $$
    SELECT 
        CASE 
            WHEN formation & 14 > 0 THEN '1_foret'
            WHEN formation & 16 > 0 THEN '2_lande'
            WHEN formation & 32 > 0 THEN '4_peupl'
            WHEN formation & 960 > 0 THEN '3_LHF'
        ELSE NULL
        END AS formation
    , CASE 
        WHEN d.ex = '01' THEN 'DIRSO'
        WHEN d.ex = '02' THEN 'DIRNO'
        WHEN d.ex = '03' THEN 'Nogent'
        WHEN d.ex = '04' THEN 'DIRCE'
        WHEN d.ex = '05' THEN 'DIRSE'
        WHEN d.ex = '06' THEN 'DIRNE'
        ELSE NULL 
      END AS dir_init
    , count(*) AS nb_pts_terrain
    FROM public.points_tir_final p
    INNER JOIN point p1 USING (id_point)
    LEFT JOIN sig_inventaire.dir_2024 d ON ST_Intersects(d.geom, p1.geom)
    GROUP BY GROUPING SETS ((formation, dir_init), (formation), (dir_init), ())
    $$)
)
PIVOT (SELECT COALESCE(formation, 'Total') AS formation, COALESCE(dir_init, 'TOTAL') AS dir_init, nb_pts_terrain FROM decompte)
ON (formation)
USING sum(nb_pts_terrain)
GROUP BY dir_init
ORDER BY dir_init;

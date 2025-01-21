
-- exemple de requête utilisant la fonction "<->" k nearest neighbours

INSERT INTO inv_exp_nm.point_aurelhy (npp, id_pt)
SELECT c.npp, p.id_pt
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point e USING (npp)
JOIN LATERAL (
    SELECT id_pt
    FROM carto_exo.aurelhy_pt a
    ORDER BY c.geom <-> a.geom --> fonction KNN
    LIMIT 1 --> pour ne prendre que le plus proche
) p ON TRUE
WHERE e.incref IN (15,16,17);
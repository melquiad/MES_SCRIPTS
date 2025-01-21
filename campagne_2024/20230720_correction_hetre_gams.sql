UPDATE point_ech
SET (angle_gams, proba_hetre) = (0, 0)
WHERE id_ech IN ('114', '115');

------------------------ en base locale -----------------------------------------------
SELECT ST_SRID(rast) As srid
FROM sig_inventaire.angle_gams
WHERE rid = 1;

SELECT ST_SRID(rast) As srid
FROM sig_inventaire.prob_hetre
WHERE rid = 1;

SELECT UpdateRasterSRID('sig_inventaire', 'angle_gams', 'rast', 27572);

SELECT UpdateRasterSRID('sig_inventaire', 'prob_hetre', 'rast', 27572);
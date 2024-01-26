
-- en base de production
SELECT DISTINCT p.npp, p.id_point, af.id_ech, te.id_transect, t.xl_centre, t.yl_centre
FROM arbre_fla af
INNER JOIN point p USING (id_transect)
--INNER JOIN fla_lt fl USING (id_ech, id_transect)
INNER JOIN transect_ech te USING (id_ech, id_transect)
INNER JOIN transect t USING (id_transect)
ORDER BY 1;

-- en base d'exploitation
SELECT DISTINCT la.npp, lt.npp, round(st_x(ec.geom)) AS X_l93, round(st_y(ec.geom)) AS y_l93
FROM inv_exp_nm.l3arbre la
INNER JOIN inv_exp_nm.l1transect lt USING (npp)
INNER JOIN inv_exp_nm.e1coord ec USING (npp)
ORDER BY 1;


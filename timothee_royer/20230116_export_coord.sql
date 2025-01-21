-- DONNÉES DES POINTS PREMIÈRE VISITE (LT1)
SET enable_nestloop = FALSE;

SELECT p.idp, p.npp, vp1.annee, 'LT1' AS visite, round(st_x(p.geom)::NUMERIC, 0) AS xl93, round(st_y(p.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
FROM v_liste_points_lt1 vp1
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp1.annee = 2021
UNION 
SELECT p.idp, p.npp, vp1.annee, 'LT1' AS visite, round(st_x(p.geom)::NUMERIC, 0) AS xl93, round(st_y(p.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp1.annee = 2021
ORDER BY idp;
-----------------------------------------------------------------------------------------------------------------------------------
-- DONNÉES DES POINTS DEUXIEME VISITE (LT2) (on ne prend que les points avec une description)
SELECT p.idp, p.npp, vp2.annee, 'LT2' AS visite, round(st_x(p.geom)::NUMERIC, 0) AS xl93, round(st_y(p.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
FROM v_liste_points_lt2 vp2
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp2.annee = 2021
ORDER BY idp;
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- DONNÉES DES ARBRES SUR POINTS PREMIÈRE VISITE (LT1)
SET enable_nestloop = FALSE;

SELECT p.idp, p.npp, vp1.annee, 'LT1' AS visite,
a.a, a1.veget, a1.espar, a.c13_mm / 10::numeric AS c13, a1.htot_dm, a1.dpr_cm, a1.azpr_gd
FROM v_liste_points_lt1 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp1.annee = 2021
UNION 
SELECT p.idp, p.npp, vp1.annee, 'LT1' AS visite,
a.a, a1.veget, a1.espar, a.c13_mm / 10::numeric AS c13, a1.htot_dm, a1.dpr_cm, a1.azpr_gd
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp1.annee = 2021
ORDER BY idp, a;


-- DONNÉES DES ARBRES SUR POINTS DEUXIÈME VISITE (LT2)
SELECT p.idp, p.npp, vp2.annee, 'LT2' AS visite,
a.a, a2.veget5, a1.espar, a.c13_mm / 10::numeric AS c13, a1.htot_dm, a1.dpr_cm, a1.azpr_gd
FROM v_liste_points_lt2 vp2
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
INNER JOIN arbre_m1 a1 ON a2.id_point = a1.id_point AND a2.a = a1.a
INNER JOIN public."Valides_221215" v ON st_intersects(p.geom,v.geom)
WHERE vp2.annee = 2021
AND a.c13_mm IS NOT NULL 
ORDER BY idp, a;




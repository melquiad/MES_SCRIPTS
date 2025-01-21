-- DONNÉES DES POINTS PREMIÈRE VISITE (LT1)
SET enable_nestloop = FALSE;

SELECT p.idp, vp1.annee, 'LT1' AS visite, round(st_x(m.geom)::NUMERIC, 0) AS xl93, round(st_y(m.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
, b.pbuis, b.dpyr, b.anpyr
FROM v_liste_points_lt1 vp1
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN buis b USING (id_ech, id_point)
WHERE vp1.annee =  2023
UNION 
SELECT p.idp, vp1.annee, 'LT1' AS visite, round(st_x(m.geom)::NUMERIC, 0) AS xl93, round(st_y(m.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
, b.pbuis, b.dpyr, b.anpyr
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN buis b USING (id_ech, id_point)
WHERE vp1.annee =  2023
ORDER BY idp;


-- DONNÉES DES POINTS DEUXIEME VISITE (LT2) (on ne prend que les points avec une description)
SELECT p.idp, vp2.annee, 'LT2' AS visite, round(st_x(m.geom)::NUMERIC, 0) AS xl93, round(st_y(m.geom)::NUMERIC, 0) AS yl93
, pl.datepoint, r.csa
, b.pbuis, b.dpyr, b.anpyr
FROM v_liste_points_lt2 vp2
INNER JOIN point p USING (id_point)
INNER JOIN maille m USING (id_maille)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN buis b USING (id_ech, id_point) -----> normalement pas de données buis en 2ème visite -----------------
WHERE vp2.annee =  2023
ORDER BY idp;

-----------------------------------------------------------------------------------------------------------------
-- DONNÉES DES ARBRES SUR POINTS PREMIÈRE VISITE (LT1)
SELECT p.idp, vp1.annee, 'LT1' AS visite
, a.a, a1.veget, a1.espar, a.c13_mm / 10::numeric AS c13, a1.datemort, a1.ori, a1.lib, a1.acci
, s.mortb, s.sfgui, s.sfgeliv, s.sfdorge, s.ma, s.mr, g.sfcoeur
FROM v_liste_points_lt1 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
LEFT JOIN age g USING (id_ech, id_point, a)
WHERE vp1.annee =  2023
UNION 
SELECT p.idp, vp1.annee, 'LT1' AS visite
, a.a, a1.veget, a1.espar, a.c13_mm / 10::numeric AS c13, a1.datemort, a1.ori, a1.lib, a1.acci
, s.mortb, s.sfgui, s.sfgeliv, s.sfdorge, s.ma, s.mr, g.sfcoeur
FROM v_liste_points_lt1_pi2 vp1
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN arbre_m1 a1 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
LEFT JOIN age g USING (id_ech, id_point, a)
WHERE vp1.annee =  2023
ORDER BY idp, a;


-- DONNÉES DES ARBRES SUR POINTS DEUXIÈME VISITE (LT2)
SELECT p.idp, vp2.annee, 'LT2' AS visite
, a.a, a2.veget5, a1.espar, a.c13_mm / 10::numeric AS c13, NULL::char(1) AS datemort, NULL::char(1) AS ori, NULL::char(1) AS lib
, NULL::char(1) AS acci, s.mortb AS mortb5, NULL::char(1) AS sfcoeur, s.ma, s.mr
FROM v_liste_points_lt2 vp2
INNER JOIN point p USING (id_point)
INNER JOIN arbre a USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
INNER JOIN arbre_m2 a2 USING (id_ech, id_point, a)
LEFT JOIN sante s USING (id_ech, id_point, a)
INNER JOIN arbre_m1 a1 ON a2.id_point = a1.id_point AND a2.a = a1.a
WHERE vp2.annee =  2023
AND a.c13_mm IS NOT NULL 
ORDER BY idp, a;



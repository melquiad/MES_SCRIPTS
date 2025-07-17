
SELECT v.id_ech, v.id_point, v.npp, v.nph, d.ex AS dir, 'nouveau' AS type_point, sc.nom_sect
FROM point p
INNER JOIN sig_inventaire.dir d ON st_intersects(p.geom,d.geom)
INNER JOIN sig_inventaire.secteurs_cn sc ON st_intersects(p.geom,sc.geom)
INNER JOIN v_liste_points_lt1 v USING (id_point)
WHERE v.annee = 2026
UNION ALL
SELECT v.id_ech, v.id_point, v.npp, v.nph, d.ex AS dir, 'visite 2' AS type_point, sc.nom_sect
FROM point p
INNER JOIN sig_inventaire.dir d ON st_intersects(p.geom,d.geom)
INNER JOIN sig_inventaire.secteurs_cn sc ON st_intersects(p.geom,sc.geom)
INNER JOIN v_liste_points_lt2 v USING (id_point)
WHERE v.annee = 2026
UNION ALL
SELECT v.id_ech, v.id_point, v.npp, v.nph, d.ex AS dir, 'nouveau' AS type_point, sc.nom_sect
FROM point p
INNER JOIN sig_inventaire.dir d ON st_intersects(p.geom,d.geom)
INNER JOIN sig_inventaire.secteurs_cn sc ON st_intersects(p.geom,sc.geom)
INNER JOIN v_liste_points_lt1_pi2 v USING (id_point)
WHERE v.annee = 2026
ORDER BY type_point, id_point;
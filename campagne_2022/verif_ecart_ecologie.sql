SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.affroc = 'X'; --> 4155 = 140 + 4015

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.cailloux = 'X'; --> 1671 = 1560 + 111

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.cai40 = 'X'; --> 1807 = 1694 + 113

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.pcalc = 'X'; --> 4788 = 4703 + 85

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.pcalf = 'X'; --> 5188 = 5093 + 95

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.pox = 'X'; --> 4288 = 4256 + 32

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.ppseudo = 'X'; --> 4839 = 4775 + 64

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2022
AND e.pgley = 'X'; --> 6030 = 5906 + 124









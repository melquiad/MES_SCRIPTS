SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.affroc = 'X'; --> 4153 = 4030 + 123

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.cailloux = 'X'; --> 1630 = 1537 + 93

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.cai40 = 'X'; --> 1753 = 1657 + 96

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.pcalc = 'X'; --> 4839 = 4761 + 78

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.pcalf = 'X'; --> 5222 = 5137 + 85

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.pox = 'X'; --> 4371 = 4343 + 28

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.ppseudo = 'X'; --> 4891 = 4834 + 57

SELECT count(*)
FROM v_liste_points_lt1 v
INNER JOIN ecologie e USING (id_ech, id_point)
WHERE annee = 2023
AND e.pgley = 'X'; --> 6093 = 5976 + 117









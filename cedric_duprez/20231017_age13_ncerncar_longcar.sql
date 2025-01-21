-- en base d'exploitation
SELECT f.incref + 2005 AS annee, count(d.age13) AS age13, count(d.ncerncar) AS ncerncar , count(d.longcar) AS longcar
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.g3agedom d USING (npp,a)
INNER JOIN inv_exp_nm.g3foret f ON a.npp = f.npp
WHERE f.incref < 18 AND d.age13 != ROUND((ncerncar * a.c13 * 100 / (2 * PI() * longcar / 10))::NUMERIC, 0)
GROUP BY annee
ORDER BY annee;

SELECT f.incref + 2005 AS annee, count(d.age13) AS age13, count(d.ncerncar) AS ncerncar , count(d.longcar) AS longcar
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.g3agedom d USING (npp,a)
INNER JOIN inv_exp_nm.g3foret f ON a.npp = f.npp
WHERE f.incref < 18 AND d.ncerncar IS NOT NULL --AND d.longcar IS NOT NULL
GROUP BY annee
ORDER BY annee;



-- en base de production
SELECT c.millesime AS annee, count(a.age13), count(a.ncerncar), count(a.longcar)
FROM arbre_m1 am
INNER JOIN arbre ar USING (id_ech, id_point, a)
INNER JOIN "age" a USING (id_ech, id_point, a)
INNER JOIN echantillon e ON a.id_ech = e.id_ech
INNER JOIN campagne c ON e.id_campagne = c.id_campagne
WHERE c.millesime < 2023 AND a.age13 != ROUND((ncerncar * (ar.c13_mm/10) / (2 * PI() * longcar / 10))::NUMERIC, 0)
GROUP BY annee
ORDER BY annee;

SELECT c.millesime AS annee, count(a.age13), count(a.ncerncar), count(a.longcar)
FROM arbre_m1 am
INNER JOIN arbre ar USING (id_ech, id_point, a)
INNER JOIN "age" a USING (id_ech, id_point, a)
INNER JOIN echantillon e ON a.id_ech = e.id_ech
INNER JOIN campagne c ON e.id_campagne = c.id_campagne
WHERE c.millesime < 2023 AND a.ncerncar IS NOT NULL
GROUP BY annee
ORDER BY annee;

SELECT v.annee, count(a.age13), count(a.ncerncar), count(a.longcar)
FROM v_liste_points_lt1 v
INNER JOIN arbre_m1 am USING (id_ech, id_point)
INNER JOIN arbre ar USING (id_ech, id_point, a)
INNER JOIN "age" a USING (id_ech, id_point, a)
WHERE v.annee  < 2023 AND a.age13 != ROUND((ncerncar * (ar.c13_mm/10) / (2 * PI() * longcar / 10))::NUMERIC, 0)
GROUP BY annee
ORDER BY annee;






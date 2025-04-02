
-- liste les modalités par unité
WITH u AS
	(
	SELECT d.donnee, COALESCE(i.dcunite, d.unite) AS unite
	, COALESCE(min(i.incref + 2005), 2020) AS debut, COALESCE(max(i.incref + 2005), 2025) AS fin
	FROM metaifn.addonnee d
	LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' AND i.incref BETWEEN 0 AND 20
	WHERE d.donnee ~~* 'QBOIS'
	GROUP BY 1, 2
	)
SELECT u.donnee, u.unite, ab."mode", ab.libelle, ab.definition
FROM u
INNER JOIN metaifn.abmode ab ON u.unite = ab.unite;


-- renseigne les unités au cours du temps
SELECT d.donnee, d.unite, i.incref, i.dcunite, d.libelle
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P'  AND i.incref BETWEEN 0 AND 20
WHERE d.donnee ~~* 'QBOIS'
ORDER BY incref;


-- date de début et de fin de l'utilisation des unités
SELECT d.donnee, COALESCE(i.dcunite, d.unite) AS unite
, COALESCE(min(i.incref + 2005), 2020) AS debut, COALESCE(max(i.incref + 2005), 2025) AS fin
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' AND i.incref BETWEEN 0 AND 20
WHERE d.donnee ~~* 'QBOIS'
GROUP BY 1, 2
ORDER BY 3, 4;


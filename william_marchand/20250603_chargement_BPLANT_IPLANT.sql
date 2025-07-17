
SELECT DISTINCT p.incref --, p.bplant, p.iplant
FROM inv_exp_nm.p3point p
WHERE (bplant, iplant)  IS DISTINCT FROM (NULL, NULL)
ORDER BY incref;

SELECT DISTINCT p.incref --, p.bplant, p.iplant
FROM inv_exp_nm.p3point p
--WHERE bplant IS NOT NULL
WHERE iplant IS NOT NULL
ORDER BY incref;

SELECT DISTINCT p.incref --, gp.bplant, gp.iplant
FROM inv_exp_nm.g3plant gp
INNER JOIN inv_exp_nm.p3point p USING (npp)
WHERE (gp.bplant, gp.iplant)  IS DISTINCT FROM (NULL, NULL)
ORDER BY incref;

SELECT DISTINCT p.incref --, gp.bplant, gp.iplant
FROM inv_exp_nm.p3plant gp
INNER JOIN inv_exp_nm.p3point p USING (npp)
WHERE gp.bplant IS NOT NULL
--WHERE gp.iplant IS NOT NULL
ORDER BY incref;
------------------------------------------------------------------------------
 -- en base de production depuis 2017

SELECT c.millesime, pl.id_point, p2.iplant_dm, p2.bplant_dm
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN plantations p2 USING (id_ech, id_point)
WHERE c.millesime >= 2005
AND (p2.bplant_dm, p2.iplant_dm) IS DISTINCT FROM (NULL, NULL)
ORDER BY c.millesime DESC;

---------------------------------------------------------------------------
-- Chargement en base d'exploitation
WITH p AS 
		(
		SELECT vp.npp, vp.annee - 2005 AS incref, pe.dep, '5' AS cyc
		, pl.bplant_dm/10 AS bplant, pl.iplant_dm/10 AS iplant 
		FROM v_liste_points_lt1 vp
		INNER JOIN reconnaissance r USING (id_ech, id_point)
		INNER JOIN point_ech pe USING (id_ech, id_point)
		INNER JOIN plantations pl USING (id_ech, id_point)
		WHERE r.csa = '5'
		--AND vp.annee = 2024
		ORDER BY npp
		)
UPDATE inv_exp_nm.p3plant pp
SET bplant = p.bplant, iplant = p.iplant
FROM p
WHERE pp.npp = p.npp;


WITH f AS
		(
		SELECT vp.npp, pl.bplant_dm/10 AS bplant, pl.iplant_dm/10 AS iplant 
		FROM v_liste_points_lt1 vp
		INNER JOIN reconnaissance r USING (id_ech, id_point)
		INNER JOIN plantations pl USING (id_ech, id_point)
		WHERE r.csa IN ('1', '3')
		--AND vp.annee = 2024
		ORDER BY npp
		)
UPDATE inv_exp_nm.g3plant gp
SET bplant = f.bplant, iplant = f.iplant
FROM f
WHERE gp.npp = f.npp;





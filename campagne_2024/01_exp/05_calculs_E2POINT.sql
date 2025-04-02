BEGIN;

-- POINTS OCCULTES
UPDATE inv_exp_nm.e2point p2
SET info = '0', leve = '0'
, auteurlt = p1.auteurpi
, datepoint = p1.datepi
, csp2 = '0'
FROM inv_exp_nm.e1point p1
WHERE p2.npp = p1.npp
AND p1.occ = '0'
AND p2.incref = 19;

-- POINTS IMPOSSIBLES A LEVER
-- on met à jour les points impossible à reconnaître (RECO = 0)
UPDATE inv_exp_nm.e2point p2
SET info = '1', leve = '0'
FROM prod_exp.e2point pe
WHERE p2.npp = pe.npp
AND pe.reco = '0'
AND p2.incref = 19;

-- on met à jour les points reconnus à distance (RECO = 2)
UPDATE inv_exp_nm.e2point p2
SET info = '2', leve = '0'
FROM prod_exp.e2point pe
WHERE p2.npp = pe.npp
AND pe.reco = '2'
AND p2.incref = 19;

-- Recopie des données phase 1 des RECO = 0 en phase 2
UPDATE inv_exp_nm.e2point p2
SET csa = p1.cso
, tform = p1.tfpi
, auteurlt = p1.auteurpi
, datepoint = p1.datepi
FROM inv_exp_nm.e1point p1
WHERE p1.npp = p2.npp
AND p2.info = '1'
AND p2.incref = 19;

-- POINTS RECLASSES LANDES AU-DESSUS DE 1700
/*
SELECT p2.npp, n.zp, p2.info, p2.leve, pe.reco
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.e1point p1 ON p2.npp = p1.npp
INNER JOIN inv_exp_nm.e1noeud n ON p1.nppg = n.nppg
INNER JOIN prod_exp.e2point pe ON p2.npp = pe.npp
WHERE p1.incref = 19
AND p2.csa = '4L'
AND n.zp >= 1900
ORDER BY pe.reco;
*/
-- 8 points levés sur la campagne 2024


UPDATE inv_exp_nm.e2point
SET info = '3', leve = '0'
WHERE npp IN (
	SELECT p2.npp
	FROM inv_exp_nm.e2point p2
	INNER JOIN inv_exp_nm.e1point p1 ON p2.npp = p1.npp
	INNER JOIN inv_exp_nm.e1noeud n ON p1.nppg = n.nppg
	WHERE p1.incref = 19
	AND p2.csa = '4L'
	AND n.zp >= 1900
);

-- POINTS LEVES NORMALEMENT
UPDATE inv_exp_nm.e2point p2
SET info = '3', leve = CASE WHEN COALESCE(g3.npp, p3.npp) IS NULL THEN '0' ELSE '1' END
FROM prod_exp.e2point p
INNER JOIN inv_exp_nm.e1point p1 ON p.npp = p1.npp
LEFT JOIN inv_exp_nm.g3foret g3 ON p1.npp = g3.npp
LEFT JOIN inv_exp_nm.p3point p3 ON p1.npp = p3.npp
WHERE p2.npp = p.npp
AND p.reco = '1'
AND p2.info IS NULL
AND p2.incref = 19;

-- POINTS NON INVENTORIES
UPDATE inv_exp_nm.e2point p2
SET info = '4', leve = '0'
, csa = p1.cso
, auteurlt = p1.auteurpi
, datepoint = p1.datepi
FROM inv_exp_nm.e1point p1
WHERE p2.npp = p1.npp
AND p2.info IS NULL
AND p2.incref = 19;

-- calcul de CSP2 --> pour revenir en arrière si problème
/*
UPDATE inv_exp_nm.e2point
SET csp2 = NULL
WHERE incref = 19;
*/

UPDATE inv_exp_nm.e2point
SET csp2 = 
CASE 
	WHEN info = '0' THEN '0'
    WHEN csa IN ('1', '3') AND tform = '1' THEN '2'
	WHEN csa = '5' AND tform = '1' THEN '2'
	WHEN csa = '8' THEN '7'
	WHEN csa = '4L' THEN '4'
    WHEN csa IN ('6A', '6H') THEN '6'
	ELSE csa 
END
WHERE incref = 19
AND csp2 IS NULL;

/*
SELECT incref + 2005 AS campagne, csp2, SUM(poids)::INT
FROM inv_exp_nm.e2point
GROUP BY incref, csp2
ORDER BY incref DESC
\crosstabview csp2 campagne;
*/

-- CORNES DE BOIS

UPDATE inv_exp_nm.e2point p2
SET corne = '1'
FROM prod_exp.e2point pp
WHERE p2.npp = pp.npp
and pp.qleve='C'
AND p2.incref = 19;

UPDATE inv_exp_nm.e2point
SET corne = '0'
WHERE corne IS NULL
AND incref = 19;


-- calcul de US_NM pour les points issus de la PI
UPDATE inv_exp_nm.e2point p2
SET us_nm = 
CASE
	WHEN p1.cso IN ('1', '3') AND p1.tfpi = '1' AND p1.uspi = 'X' THEN 'A'                      -- bosquets impossibles à visiter
	WHEN p1.cso IN ('1', '3') AND p1.tfpi = '1' AND p1.uspi IN ('U', 'I', 'T') THEN 'A'         -- oui, je sais, c'est bizarre, mais on a toujours classé les bosquets urbains dans "autres bosquets"...
	WHEN p1.cso IN ('1', '3') AND p1.tfpi = '1' AND p1.uspi IN ('A', 'V') THEN '6'              -- bosquets agricoles et vergers
	WHEN p1.cso IN ('1', '3') AND p1.uspi IN ('X', 'I', 'T') THEN '2'                           -- utilisation "autre", "infrastructures" et "réseaux" dans autre forêt
	WHEN p1.cso IN ('1', '3') THEN '6'
	WHEN p1.cso = '4L' THEN '4'
	WHEN p1.cso = '5' AND p1.tfpi = '1' THEN 'A'
	WHEN p1.cso = '5' AND p1.tfpi = '2' THEN '2'
	WHEN LEFT(p1.cso, 1) = '6' THEN '6'
--	WHEN p1.cso = '7' AND p1.ufpi = '1' THEN '1'		                                        -- ROUTES FORESTIÈRES ISSUES DE LA PI
	WHEN p1.cso = '7' THEN '7'       				                                            -- AUTRES ROUTES
	WHEN p1.cso = '8' THEN '7'
	WHEN p1.cso = '9' THEN '8'
END
FROM inv_exp_nm.e1point p1
WHERE p2.npp = p1.npp
AND p2.info IN ('1', '4')
AND p2.incref = 19;

-- calcul de US_NM sur les points reconnus sur le terrain
UPDATE inv_exp_nm.e2point
SET us_nm =
CASE 
	WHEN csa IN ('1', '3') AND tform = '1' THEN 
	CASE
		WHEN corne = '1' THEN '3'
		WHEN utip != 'X' THEN '6'
        WHEN info = '2' THEN 'A'      -- points reconnus à vue => autre bosquet
		WHEN bois = '0' THEN 'A'
		WHEN bois = '1' THEN '3'
	END
	WHEN csa IN ('1', '3') AND tform = '2' THEN
	CASE
		WHEN corne = '1' THEN '1'
		WHEN utip != 'X' THEN '6'
        WHEN info = '2' THEN '2'      -- points reconnus à vue => autre forêt
		WHEN bois = '0' THEN '2'
		WHEN bois = '1' THEN '1'
	END
	WHEN csa = '4L' THEN '4'
	WHEN csa = '5' THEN 
	CASE
		WHEN corne = '1' THEN '5'
		WHEN utip != 'X' THEN '6'
        WHEN tform = '1' AND info = '2' THEN 'A'      -- points reconnus à vue => autre bosquet
		WHEN tform = '1' AND bois = '0' THEN 'A'
		WHEN tform = '1' AND bois = '1' THEN '3'
        WHEN info = '2' THEN '2'      -- points reconnus à vue => autre forêt
		WHEN bois = '0' THEN '2'
		WHEN bois = '1' THEN '5'
	END
	WHEN LEFT(csa, 1) = '6' THEN '6'
	WHEN csa = '7' THEN '7'
	WHEN csa = '8' THEN '7'
	WHEN csa = '9' THEN '8'
END
WHERE incref = 19
AND info IN ('2', '3');

-- US_NM = 0 sur les points restants (occultés)
UPDATE inv_exp_nm.e2point
SET us_nm = '0'
WHERE incref = 19
AND csp2 = '0';

-- calcul de la donnée utilisateur d'analyse : U_US_2015
UPDATE inv_exp_nm.u_e2point u
SET u_us_2015 = 
CASE
    WHEN p1.cso IN ('1', '3') AND p1.tfpi = '1' AND p1.uspi = 'X' THEN '4' 		-- points tirés mais reconnaissance impossible
    WHEN p1.cso IN ('1', '3') AND p1.tfpi = '1' AND p1.uspi != 'X' THEN '5'
    WHEN p1.cso IN ('1', '3') AND p1.uspi = 'X' THEN '4' -- points tirés mais reconnaissance impossible
	WHEN p1.cso IN ('1', '3') THEN '5'
    WHEN p1.cso = '5' AND p1.tfpi = '1' THEN '5'
    WHEN p1.cso = '5' AND p1.tfpi = '2' THEN '5'
	WHEN p1.cso = '5' AND p1.uspi = 'X' THEN '5' 		-- points tirés mais reconnaissance impossible
	WHEN p1.cso = '7' AND p1.ufpi = '1' THEN '3'			-- routes forestières issues de la pi
END
FROM inv_exp_nm.e1point p1
INNER JOIN inv_exp_nm.e2point p2 ON p1.npp = p2.npp
WHERE u.npp = p1.npp
AND p2.info IN ('1', '4')
AND p2.incref = 19;

UPDATE inv_exp_nm.u_e2point u
SET u_us_2015 =
CASE 
	WHEN csa IN ('1', '3') AND tform = '1' THEN 
	CASE
		WHEN utip != 'X' THEN '5'
		WHEN info = '2' THEN '4'
		WHEN bois = '0' THEN '4'
		WHEN bois = '1' AND leve = '0' THEN '2'
		WHEN bois = '1' AND leve = '1' THEN '1'
	END
	WHEN csa IN ('1', '3') AND tform = '2' THEN
	CASE
		WHEN utip != 'X' THEN '5'
        WHEN info = '2' THEN '4'
		WHEN bois = '0' THEN '4'
		WHEN bois = '1' AND leve = '0' THEN '2'
		WHEN bois = '1' AND leve = '1' THEN '1'
	END
	WHEN csa = '5' THEN 
	CASE
		WHEN utip != 'X' THEN '5'
		WHEN tform = '1' AND bois = '0' THEN '4'
        WHEN info = '2' THEN '4'
		WHEN tform = '1' AND bois = '1' AND leve = '0' THEN '2'
		WHEN tform = '1' AND bois = '1' AND leve = '1' THEN '1'
		WHEN bois = '0' THEN '4'
		WHEN bois = '1' AND leve = '0' THEN '4'
		WHEN bois = '1' AND leve = '1' THEN '1'
	END
	WHEN csa = '7' THEN
	CASE
		WHEN tauf = '1' THEN '3'
	END
END
FROM inv_exp_nm.e2point p2
WHERE u.npp = p2.npp
AND p2.incref = 19
AND info IN ('2', '3');

/* MULTIPLES CONTRÔLES
SELECT p2.incref, p2.us_nm, SUM(p2.poids) AS surf_ha
FROM inv_exp_nm.e2point p2
GROUP BY incref, us_nm
ORDER BY us_nm, incref DESC;

SELECT p2.us_nm, p2.incref, SUM(ue.poids) AS surf_ha
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
GROUP BY p2.incref, us_nm
ORDER BY us_nm, incref DESC;

SELECT p2.incref + 2005 as campagne, COALESCE(p2.us_nm, 'X') AS us_nm, ROUND(SUM(ue.poids)::NUMERIC, 1) AS surf_ha
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
WHERE p2.incref >= 10
GROUP BY p2.incref, us_nm
ORDER BY p2.incref DESC, us_nm
\crosstabview us_nm campagne;

SELECT csp2, csa, tform, tfpi, uspi, us_nm, info, COUNT(*)
FROM inv_exp_nm.e2point
INNER JOIN inv_exp_nm.e1point USING (incref, npp)
WHERE incref = 19
AND us_nm IN ('3', 'A')
GROUP BY csp2, csa, tform, tfpi, uspi, us_nm, info
ORDER BY csp2, csa, tform, tfpi, uspi, us_nm, info;

SELECT us_nm, u_us_2015,  ROUND(sum(poids)::NUMERIC, 1) AS surf_ha
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.u_e2point u2 USING (npp)
WHERE p2.incref = 19
GROUP BY us_nm, u_us_2015
ORDER BY us_nm, u_us_2015;

SELECT npp, info, csa, tform, csp2, utip, indisp, bois, us_nm, u_us_2015
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.u_e2point u2 USING (npp)
WHERE p2.incref = 19
AND us_nm = 'A'
AND u_us_2015 = '4'
ORDER BY npp;

SELECT p2.incref, us_nm, u_us_2015, sum(ue.poids) AS eff_pond
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.u_e2point u2 USING (npp)
INNER JOIN inv_exp_nm.unite_ech ue ON p2.id_unite = ue.id_unite
INNER JOIN inv_exp_nm.echantillon e ON ue.id_ech = e.id_ech AND e.usite = 'P' AND e.format = 'TE2POINT'
WHERE p2.incref >= 10
GROUP BY p2.incref, us_nm, u_us_2015
ORDER BY us_nm, u_us_2015, p2.incref;

SELECT p2.incref, indisp, sum(poids) AS surf_ha --> INDISP n'est plus prise sur le terrain
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.u_e2point u2 USING (npp)
WHERE p2.incref >= 10
AND us_nm = '2'
GROUP BY p2.incref, indisp
ORDER BY indisp, p2.incref;

SELECT p2.incref
, SUM(p2.poids) FILTER(WHERE csa = '1') AS surf_1
, SUM(p2.poids) FILTER(WHERE csa = '3') AS surf_3
, SUM(p2.poids) FILTER(WHERE uto = '6' OR uspi = 'V') AS surf_vergers
, SUM(p2.poids) AS surf_boise
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.e1point p1 USING (npp)
WHERE csa IN ('1', '3') AND COALESCE (tform, '2') = '2'
GROUP BY p2.incref
ORDER BY incref;

SELECT incref, us_nm, sum(poids) AS surf_ha
FROM inv_exp_nm.e2point p2
WHERE p2.corne = '1'
GROUP BY incref, us_nm
ORDER BY incref, us_nm;
*/

-- mise à jour du département du point de phase 2 par le département du point de phase 1 (région parisienne)
UPDATE inv_exp_nm.e2point p2
SET dep = p1.dep
FROM inv_exp_nm.e1point p1
WHERE p2.npp = p1.npp
AND p2.dep != p1.dep
AND p2.incref = 19;

-- regroupements des départements en RA, RAD2, RAD3 et RAD13
UPDATE inv_exp_nm.e2point p
SET ra = b.gmode
FROM metaifn.abgroupe b
WHERE p.dep = b.mode
AND b.unite = 'DP'
AND b.gunite = 'RA'
AND p.incref = 19;

UPDATE inv_exp_nm.e2point p
SET rad2 = b.gmode
FROM metaifn.abgroupe b
WHERE p.ra = b.mode
AND b.unite = 'RA'
AND b.gunite = 'RAD2'
AND p.incref = 19;

UPDATE inv_exp_nm.e2point p
SET rad3 = b.gmode
FROM metaifn.abgroupe b
WHERE p.ra = b.mode
AND b.unite = 'RA'
AND b.gunite = 'RAD3'
AND p.incref = 19;

UPDATE inv_exp_nm.e2point p
SET rad13 = b.gmode
FROM metaifn.abgroupe b
WHERE p.ra = b.mode
AND b.unite = 'RA'
AND b.gunite = 'RAD13'
AND p.incref = 19;

-- regroupements dans E2POINT
-- CLZ et CLALTI (classes d'altitude du point)
UPDATE inv_exp_nm.e2point
SET clz = CASE 	WHEN c.zp < 200 THEN '1'
				WHEN c.zp < 400 THEN '2'
				WHEN c.zp < 600 THEN '3'
				WHEN c.zp < 1000 THEN '4'
				WHEN c.zp < 1400 THEN '5'
				ELSE '6'
		  END
, clalti = LEAST(FLOOR(c.zp::NUMERIC / 50::NUMERIC) * 50, 2000)
FROM inv_exp_nm.e1coord c
WHERE c.npp = e2point.npp
AND e2point.incref = 19;

-- AQUIT
UPDATE inv_exp_nm.e2point
SET aquit = 
CASE 
	WHEN regn IN ('330', '334', '401', '404') THEN '1' 
	ELSE '0' 
END
WHERE incref = 19;

UPDATE inv_exp_nm.e2point
SET ser_alluv = 'HS'
WHERE incref = 19
AND ser_alluv IS NULL;

--/*
SELECT incref, count(*), count(ser_alluv), count(ser_alluv) FILTER(WHERE ser_alluv != 'HS')
FROM inv_exp_nm.e2point 
GROUP BY incref
ORDER BY incref DESC;
*/

-- calcul de RAK
UPDATE inv_exp_nm.e2point p2 
SET rak = g.gmode
FROM metaifn.abgroupe g
WHERE g.gunite = 'RAK' AND g.unite = 'DPD4' AND g.mode = p2.dep
AND p2.incref = 19;

COMMIT;

VACUUM ANALYZE inv_exp_nm.e2point;

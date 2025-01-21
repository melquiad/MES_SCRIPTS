BEGIN
	
-- en forêt -----------------------
ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_ntpr float8;

ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_ntpr_an float8;
   
ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_gpr float8;

ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_gpr_an float8;
 
ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_vpr float8;

ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_vpr_an float8;

-- en peupleraie ------------------
ALTER TABLE inv_exp_nm.u_p3morts
	ADD COLUMN u_ntpr float8;

ALTER TABLE inv_exp_nm.u_p3morts
    ADD COLUMN u_ntpr_an float8;
   
ALTER TABLE inv_exp_nm.u_p3morts
    ADD COLUMN u_gpr float8;

ALTER TABLE inv_exp_nm.u_p3morts
    ADD COLUMN u_gpr_an float8;
 
ALTER TABLE inv_exp_nm.u_p3morts
    ADD COLUMN u_vpr float8;

ALTER TABLE inv_exp_nm.u_p3morts
    ADD COLUMN u_vpr_an float8;
   
/************************************************************************************************************
*				CALCUL DU PRÉLÈVEMENT EN BOIS MORTS	EN FORET			*
************************************************************************************************************/
SET enable_nestloop = FALSE;

-- CALCULS DES DONNÉES AU NIVEAU ARBRES MORTS
UPDATE inv_exp_nm.u_g3morts u3
SET u_vpr = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN g3m.v
	ELSE 0
END
, u_vpr_an = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN g3m.v / 5
	ELSE 0 
END
FROM inv_exp_nm.g3morts g3m
INNER JOIN inv_exp_nm.e2point e2p ON g3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = g3m.npp AND u3.a = g3m.a
AND e2p.incref BETWEEN 6 AND 12; ---> ce qui correspond à toutes les campagnes depuis 2016

/*
SELECT p2.incref, SUM(p2.poids * ua.u_vpr_an * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3morts ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT m.libelle AS ra, (2005 + p2.incref)::SMALLINT as campagne, ROUND(SUM(p2.poids * ua.u_vpr_an * a.w)::NUMERIC, 0) AS vpr
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3morts ua ON a.npp = ua.npp AND a.a = ua.a
INNER JOIN metaifn.abmode m ON m.unite = 'RA' and p2.ra = m.mode
GROUP BY p2.incref, m.libelle
HAVING SUM(p2.poids * ua.u_vpr_an * a.w) IS NOT NULL
ORDER BY m.libelle, p2.incref DESC
\crosstabview ra campagne;
*/


/************************************************************************************************************
*					CALCUL DU PRÉLÈVEMENT EN BOIS MORTS EN PEUPLERAIE 							*
************************************************************************************************************/
UPDATE inv_exp_nm.u_p3morts u3
SET u_vpr = 
CASE
	WHEN p3m.veget5 IN ('6', '7') THEN p3m.v
	ELSE 0
END
, u_vpr_an = 
CASE
	WHEN p3m.veget5 IN ('6', '7') THEN p3m.v / 5
	ELSE 0 
END
FROM inv_exp_nm.p3morts p3m
INNER JOIN inv_exp_nm.e2point e2p ON p3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = p3m.npp AND u3.a = p3m.a
AND e2p.incref BETWEEN 6 AND 12; ---> ce qui correspond à toutes les campagnes depuis 2016

/*
SELECT p2.incref, SUM(p2.poids * ua.u_vpr_an * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_p3morts ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;
*/


/************************************************************************************************************
*							CALCUL DU PRÉLÈVEMENT DE BOIS MORTS EN SURFACE TERRIÈRE EN FORÊT 								*
************************************************************************************************************/

UPDATE inv_exp_nm.u_g3morts u3
SET u_gpr = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN g3m.gtot -- arbres coupés
	ELSE 0
END
, u_gpr_an = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN g3m.gtot / 5 -- arbres coupés
	ELSE 0
END
FROM inv_exp_nm.g3morts g3m
INNER JOIN inv_exp_nm.e2point e2p ON g3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = g3m.npp AND u3.a = g3m.a
AND e2p.incref >= 6;


/************************************************************************************************************
*						CALCUL DU PRÉLÈVEMENT DE BOIS MORTS EN SURFACE TERRIERE EN PEUPLERAIE 							*
************************************************************************************************************/
UPDATE inv_exp_nm.u_p3morts u3
SET u_gpr = 
CASE
    WHEN p3m.veget5 IN ('6', '7') THEN p3m.gtot
    ELSE 0
END
, u_gpr_an = 
CASE
    WHEN p3m.veget5 IN ('6', '7') THEN p3m.gtot / 5
    ELSE 0
END
FROM inv_exp_nm.p3morts p3m
INNER JOIN inv_exp_nm.e2point e2p ON p3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = p3m.npp AND u3.a = p3m.a
AND e2p.incref = 6;


/************************************************************************************************************
*			CALCUL DU PRÉLÈVEMENT EN NOMBRE DE TIGES DE BOIS MORTS EN FORÊT (PAS D'ACTUALISATION NÉCESSAIRE)				*
************************************************************************************************************/
UPDATE inv_exp_nm.u_g3morts u3
SET u_ntpr = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN 1
    ELSE 0
END
, u_ntpr_an = 
CASE
	WHEN g3m.veget5 IN ('6', '7') THEN 0.2
	ELSE 0 
END
FROM inv_exp_nm.g3morts g3m
INNER JOIN inv_exp_nm.e2point e2p ON g3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = g3m.npp AND u3.a = g3m.a
AND e2p.incref = 6;

/*
SELECT p2.incref, SUM(p2.poids * ua.u_ntpr_an * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3morts a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3morts ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;
*/


/************************************************************************************************************
*			CALCUL DU PRÉLÈVEMENT EN NOMBRE DE TIGES DE BOIS MORTS EN PEUPLERAIE (PAS D'ACTUALISATION NÉCESSAIRE)			*
************************************************************************************************************/
UPDATE inv_exp_nm.u_p3morts u3
SET u_ntpr = 
CASE
    WHEN p3m.veget5 IN ('6', '7') THEN 1
    ELSE 0
END
, u_ntpr_an = 
CASE
    WHEN p3m.veget5 IN ('6', '7') THEN 0.2
    ELSE 0 
END
FROM inv_exp_nm.p3morts p3m
INNER JOIN inv_exp_nm.e2point e2p ON p3m.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE u3.npp = p3m.npp AND u3.a = p3m.a
AND e2p.incref = 6;



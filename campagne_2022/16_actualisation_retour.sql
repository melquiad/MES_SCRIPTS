BEGIN;

-- volume prélevé actualisé en forêt
UPDATE inv_exp_nm.g3arbre g3a
SET vpr_an_act = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN (g3a.v + 2.5 * u3.u_abv_an) / 5
	ELSE 0 
END
, pvpr = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN u3.u_abv_an / 2
	ELSE 0 
END
FROM inv_exp_nm.u_g3arbre u3
INNER JOIN inv_exp_nm.e2point e2p ON u3.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE g3a.npp = u3.npp AND g3a.a = u3.a
AND g3a.incref = 12;

/*
SELECT count(*) FROM inv_exp_nm.g3arbre WHERE incref = 9 AND vpr_an_act IS NULL; 

SELECT p.incref, sum(p.poids * a.w * a.vpr_an_act) as vpr_an_act, sum(p.poids * a.w * ua.u_vpr_an) as u_vpr_an
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

-- volume prélevé actualisé en peupleraie
UPDATE inv_exp_nm.p3arbre p3a
SET vpr_an_act = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN (p3a.v + 2.5 * u3.u_abv_an) / 5
	ELSE 0 
END
, pvpr = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN u3.u_abv_an / 2
	ELSE 0 
END
FROM inv_exp_nm.u_p3arbre u3
INNER JOIN inv_exp_nm.e2point e2p ON u3.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE p3a.npp = u3.npp AND p3a.a = u3.a
AND p3a.incref = 12;

/*
SELECT count(*) FROM inv_exp_nm.p3arbre WHERE incref = 12 AND vpr_an_act IS NULL; 

SELECT p.incref, sum(p.poids * a.w * a.vpr_an_act), sum(p.poids * a.w * ua.u_vpr_an)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

-- surface terrière prélevée actualisée en forêt
UPDATE inv_exp_nm.g3arbre g3a
SET gpr_an_act = 
CASE 
	WHEN u3.u_gpr > 0 THEN (g3a.gtot + 2.5 *g3a.abg) / 5
	ELSE 0 
END
, pgpr = 
CASE 
	WHEN u3.u_gpr > 0 THEN g3a.abg / 2
	ELSE 0 
END
FROM inv_exp_nm.u_g3arbre u3
INNER JOIN inv_exp_nm.e2point e2p ON u3.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE g3a.npp = u3.npp AND g3a.a = u3.a
AND g3a.incref = 12;

/************************************************************************************************************
*					CALCUL DU PRÉLÈVEMENT EN VOLUME TOTAL EN FORÊT (AVEC ACTUALISATION)						*
************************************************************************************************************/
UPDATE inv_exp_nm.u_g3arbre u3
SET u_v0pr_an = 
CASE
	WHEN g3a.veget5 IN ('6', '7') THEN (u3.u_v0 - g3a.vr) / 5
	ELSE 0
END
FROM inv_exp_nm.g3arbre g3a 
WHERE u3.npp = g3a.npp AND u3.a = g3a.a
AND g3a.incref = 12;

-- prélèvement actualisé
UPDATE inv_exp_nm.u_g3arbre u3
SET u_v0pr_an_ac = 
CASE 
	WHEN u3.u_v0pr_an > 0 AND g3a.v > 0 THEN ((u3.u_v0 - g3a.vr) + 2.5 * u3.u_abv_an * (u3.u_v0 - g3a.vr) / g3a.v) / 5
	WHEN u_v0pr_an > 0 AND g3a.v = 0 THEN u3.u_v0pr_an
	ELSE 0 
END
, u_pv0pr = 
CASE 
	WHEN u_v0pr_an > 0 AND g3a.v > 0 THEN u3.u_abv_an * (u3.u_v0 - g3a.vr) / (2 * g3a.v)
	ELSE 0 
END
FROM inv_exp_nm.g3arbre g3a
INNER JOIN inv_exp_nm.e2point e2p ON g3a.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
INNER JOIN prod_exp.g3foret f ON e2p.npp = f.npp
WHERE u3.npp = g3a.npp AND u3.a = g3a.a
AND e2p.incref = 12;

/*
SELECT p.incref, sum(p.poids * a.w * ua.u_v0pr_an), sum(p.poids * a.w * ua.u_v0pr_an_ac)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

/************************************************************************************************************
*				CALCUL DU PRÉLÈVEMENT EN VOLUME TOTAL EN PEUPLERAIE (AVEC ACTUALISATION)					*
************************************************************************************************************/
UPDATE inv_exp_nm.u_p3arbre u3
SET u_v0pr_an = 
CASE
    WHEN p3a.veget5 IN ('6', '7') THEN (u3.u_v0 - p3a.vr) / 5
    ELSE 0
END
FROM inv_exp_nm.p3arbre p3a
WHERE u3.npp = p3a.npp AND u3.a = p3a.a
AND p3a.incref = 12;

-- actualisation
UPDATE inv_exp_nm.u_p3arbre u3
SET u_v0pr_an_ac = 
CASE 
	WHEN u_v0pr_an > 0 THEN 
		(u_v0 + 2.5 * u_abv_an * u_v0 / v) / 5
	ELSE 0 
END
, u_pv0pr = 
CASE 
	WHEN u_v0pr_an > 0 THEN 
		u_abv_an * u_v0 / (2 * v)
	ELSE 0 
END
FROM inv_exp_nm.p3arbre p3a
WHERE u3.npp = p3a.npp AND u3.a = p3a.a
AND p3a.incref = 12;

/*
SELECT p.incref, sum(p.poids * a.w * ua.u_v0pr_an), sum(p.poids * a.w * ua.u_v0pr_an_ac)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

COMMIT;

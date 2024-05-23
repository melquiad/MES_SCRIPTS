-- Coefficient moyen par SER
SELECT (SUM(U_GINI * POIDS) / SUM(POIDS)) AS GINI_MOY, ser_86
FROM inv_exp_nm.u_g3foret ug3f
INNER JOIN inv_exp_nm.e2point e2p on e2p.npp = ug3f.npp
WHERE U_GINI IS NOT NULL
GROUP BY ser_86;

-- Coefficient moyen par campagne d'inventaire
SELECT (SUM(U_GINI * POIDS) / SUM(POIDS)) AS GINI_MOY, (e2p.incref + 2005) AS CAMPAGNE
FROM inv_exp_nm.u_g3foret ug3f
INNER JOIN inv_exp_nm.e2point e2p on e2p.npp = ug3f.npp
WHERE U_GINI IS NOT NULL
GROUP BY CAMPAGNE;

-- Coefficient moyen par type de composition
SELECT (SUM(U_GINI * POIDS) / SUM(POIDS)) AS GINI_MOY, TYPECOMP
FROM inv_exp_nm.u_g3foret ug3f
INNER JOIN inv_exp_nm.g3foret g3f on g3f.npp = ug3f.npp
INNER JOIN inv_exp_nm.e2point e2p on e2p.npp = ug3f.npp
WHERE U_GINI IS NOT NULL
GROUP BY TYPECOMP;
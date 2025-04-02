BEGIN;

-- calcul de CSP1
UPDATE inv_exp_nm.e1point
SET csp1 = 
CASE	WHEN occ = '0' THEN '0'
		WHEN cso IN ('1', '3') AND tfpi = '1' THEN '2'
		WHEN cso = '5' AND tfpi = '1' THEN '2'
		WHEN cso = '8' THEN '7'
		WHEN cso = '4L' THEN '4'
		WHEN cso IN ('6A', '6H') THEN '6'
		ELSE cso END
WHERE incref = 19;

/*
SELECT csp1, cso, COUNT(*)
FROM inv_exp_nm.e1point
WHERE incref = 19
GROUP BY csp1, cso
ORDER BY csp1, cso;

--> à jouer sous psql avec le \crosstabview
SELECT incref + 2005 AS campagne, csp1, SUM(poids)
FROM inv_exp_nm.e1point
WHERE incref >=10
GROUP BY incref, csp1
ORDER BY incref DESC
\crosstabview csp1 campagne;
*/

-- regroupement des départements de la région parisienne
UPDATE inv_exp_nm.e1point
SET dep = '75'
WHERE incref = 19
AND dep IN ('78', '91', '92', '93', '94', '95');

COMMIT;

VACUUM ANALYZE inv_exp_nm.e1point;

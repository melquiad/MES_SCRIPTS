
SELECT e.auteurlt, g.mortb, count(g.mortb)
FROM inv_exp_nm.e2point e
INNER JOIN inv_exp_nm.g3arbre g USING (npp)
WHERE e.incref = 19
AND g.espar = '51' --> pin maritime
GROUP BY e.auteurlt, g.mortb;
--AND e.auteurlt = 257;

UPDATE inv_exp_nm.g3arbre g
SET mortb = '0'
INNER JOIN inv_exp_nm.e2point e ON g.npp = e.npp
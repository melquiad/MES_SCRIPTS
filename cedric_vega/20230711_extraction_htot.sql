SELECT g.npp, g.htot, g3.htot_dm, g3.htot5_dm 
FROM inv_exp_nm.g3arbre g
INNER JOIN inv_prod.g3arbre g3 USING (npp)
INNER JOIN inv_exp_nm.e2point ep USING (npp)
WHERE g.incref BETWEEN 10 AND 17 AND leve = '1'
UNION
(SELECT p.npp, p.htot
FROM inv_exp_nm.p3arbre p
--INNER JOIN inv_exp_nm.e2point ep USING (npp)
WHERE p.incref BETWEEN 10 AND 17)
UNION
(SELECT l.npp, l.htot
FROM inv_exp_nm.l3arbre l
--INNER JOIN inv_exp_nm.e2point ep USING (npp)
WHERE l.incref BETWEEN 10 AND 17);


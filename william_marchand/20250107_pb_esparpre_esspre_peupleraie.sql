
SELECT p.npp, p.incref, p.esparpre, p.esspre, p.recens, p.espar_r1, p.ess_r1 
FROM inv_exp_nm.p3point p
WHERE p.incref = 12
ORDER BY recens;
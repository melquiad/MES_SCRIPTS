

UPDATE inv_exp_nm.u_g3arbre ua
SET u_veget5 = pa.veget5
FROM inv_exp_nm.g3arbre pa
WHERE ua.npp = pa.npp
AND ua.a = pa.a
AND ua.incref BETWEEN 7 AND 12;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_veget5 = pa.veget5
FROM inv_exp_nm.p3arbre pa
WHERE ua.npp = pa.npp
AND ua.a = pa.a
AND ua.incref BETWEEN 7 AND 12;

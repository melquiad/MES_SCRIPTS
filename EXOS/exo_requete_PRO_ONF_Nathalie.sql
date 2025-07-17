SELECT DISTINCT ON (e1.idp) idp ,e1.npp, e1.pro_nm, m.libelle,  g.gunite, g.gmode AS pf_maaf, m1.libelle AS lib_pf_maaf
FROM inv_exp_nm.e1point e1
LEFT JOIN metaifn.abmode m ON e1.pro_nm = m."mode" AND m.unite = 'PRO_2015'
LEFT JOIN metaifn.abgroupe g ON g."mode" = e1.pro_nm AND g.gunite = 'PF_MAAF'
LEFT JOIN metaifn.abmode m1 ON g.gunite = m1.unite AND g.gmode = m1."mode"
WHERE incref = 19
ORDER BY idp, npp;


SELECT count(npp)
FROM inv_exp_nm.e1point
WHERE incref = 10;



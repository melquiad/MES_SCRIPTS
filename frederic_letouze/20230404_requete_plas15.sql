(SELECT gf.npp ,gf.plas15
FROM prod_exp.g3foret gf
WHERE plas15 = '0' OR plas15 IS NULL)
UNION
(SELECT pp.npp ,pp.plas15
FROM prod_exp.p3point pp
WHERE plas15 = '0' OR plas15 IS NULL);

---------------------------------------------------------------------------------------
SELECT ga.npp, ga.a, ga.pds, ga.cld, ga.clad
FROM inv_exp_nm.g3arbre ga
INNER JOIN inv_prod_new.point p ON ga.npp = p.npp 
INNER JOIN inv_prod_new.descript_m1 dm ON p.id_point = dm.id_point
WHERE dm.plas25 = '1'
AND incref BETWEEN 4 AND 18
UNION 
SELECT pa.npp, pa.a, pa.pds, pa.cld, pa.clad
FROM inv_exp_nm.p3arbre pa
INNER JOIN inv_prod_new.point p ON pa.npp = p.npp 
INNER JOIN inv_prod_new.descript_m1 dm ON p.id_point = dm.id_point
WHERE dm.plas25 = '1'
AND incref BETWEEN 4 AND 18
UNION
SELECT ga.npp, ga.a, ga.pds, ga.cld, ga.clad
FROM inv_exp_nm.g3morts  ga
INNER JOIN inv_prod_new.point p ON ga.npp = p.npp 
INNER JOIN inv_prod_new.descript_m1 dm ON p.id_point = dm.id_point
WHERE dm.plas25 = '1'
AND incref BETWEEN 4 AND 18
UNION
SELECT pa.npp, pa.a, pa.pds, pa.cld, pa.clad
FROM inv_exp_nm.p3morts pa
INNER JOIN inv_prod_new.point p ON pa.npp = p.npp 
INNER JOIN inv_prod_new.descript_m1 dm ON p.id_point = dm.id_point
WHERE dm.plas25 = '1'
AND incref BETWEEN 4 AND 18
ORDER BY npp;







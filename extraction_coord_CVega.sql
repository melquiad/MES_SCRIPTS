(SELECT ga.incref, ga.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.g3arbre ga ON ec.npp = ga.npp  
WHERE ga.incref BETWEEN 11 and 15
ORDER BY ga.incref)
UNION
(SELECT pa.incref, pa.dep, ec.npp, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.p3arbre pa ON ec.npp = pa.npp
WHERE pa.incref BETWEEN 11 and 15
ORDER BY pa.incref);

-------------------------- version optimisée ----------------------------------------------------------

SELECT p.incref, p.npp, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.e1point p ON ec.npp = p.npp 
WHERE p.incref BETWEEN 11 AND 15
AND EXISTS (
    SELECT 1
    FROM inv_exp_nm.g3arbre a
    WHERE p.npp = a.npp
)
ORDER BY incref, npp;

--Tu fais la même chose avec les peupleraies, et ça donne quelque chose comme ça :

SELECT p.incref, p.npp, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM inv_exp_nm.e1coord ec
INNER JOIN inv_exp_nm.e1point p ON ec.npp = p.npp
WHERE p.incref BETWEEN 11 AND 15
AND (
 EXISTS (
    SELECT 1
    FROM inv_exp_nm.g3arbre a
    WHERE p.npp = a.npp
)
OR
 EXISTS (
    SELECT 1
    FROM inv_exp_nm.p3arbre a
    WHERE p.npp = a.npp
 )
)
ORDER BY incref, npp;



SELECT DISTINCT e2.npp, gf.codesp, m.libelle, gf.tcar, ge.espar, am.libelle, g.tcar, ge.tca
FROM inv_exp_nm.e2point e2
INNER JOIN inv_exp_nm.g3foret g USING (npp)
INNER JOIN inv_exp_nm.g3flore gf USING (npp)
INNER JOIN metaifn.abmode m ON gf.codesp = m."mode" AND m.unite = 'CODESP'
INNER  JOIN inv_exp_nm.g3essence ge USING (npp)
INNER JOIN metaifn.abmode am ON ge.espar = am."mode" AND am.unite = 'ESPAR1'
WHERE e2.incref = 18
ORDER BY npp;

/*
SELECT DISTINCT tcar
FROM inv_exp_nm.g3flore
WHERE  incref = 18;

SELECT tcar, count(tcar)
FROM inv_exp_nm.g3flore
WHERE incref = 18
GROUP BY tcar
ORDER BY tcar;

SELECT abondc, count(abondc)
FROM inv_exp_nm.g3flore
WHERE incref = 18
GROUP BY abondc
ORDER BY abondc;

SELECT abondc, count(abondc)
FROM inv_exp_nm.p3flore
WHERE incref = 18
GROUP BY abondc
ORDER BY abondc;
*/

-- on recalcule ABONDC, et d'abord on remet à zéro ABONDNR et ABONDC pour incref 18 puis on rejoue le script 11_calculs_flore
UPDATE inv_exp_nm.g3flore gf
SET abondc = NULL
WHERE incref = 18;

UPDATE inv_exp_nm.g3flore gf
SET abondnr = NULL
WHERE incref = 18;

/* -- inutile
UPDATE inv_exp_nm.p3flore gf
SET abondc = NULL
WHERE incref = 18;

UPDATE inv_exp_nm.p3flore gf
SET abondnr = NULL
WHERE incref = 18;
*/


















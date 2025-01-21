BEGIN;

-- indicateur de visite de transect
UPDATE inv_exp_nm.l1transect l
SET vis_sl = '1'
FROM inv_exp_nm.e2point p2
WHERE l.npp = p2.npp
AND l.incref = 17
AND p2.info IN ('2', '3');

UPDATE inv_exp_nm.l1transect
SET vis_sl = '0'
WHERE vis_sl IS NULL
AND incref = 17;

COMMIT;

VACUUM ANALYZE inv_exp_nm.l1transect;

-- on supprime de L3SEGMENT les lignes où OPTERSL = 1
BEGIN;

DELETE FROM inv_exp_nm.l3segment l3
USING inv_exp_nm.l2segment l2
WHERE l3.npp = l2.npp AND l3.sl = l2.sl
AND l2.optersl = '1'
AND l2.incref = 17;

-- indicateur de levé d'un segment de LHF
UPDATE inv_exp_nm.l2segment
SET leve_sl = '0'
WHERE incref = 17;

UPDATE inv_exp_nm.l2segment
SET leve_sl = '1'
WHERE incref = 17
AND (npp, sl) IN (
    SELECT npp, sl
    FROM inv_exp_nm.l3segment
    WHERE incref = 17
);

COMMIT;

VACUUM ANALYZE inv_exp_nm.l2segment;
VACUUM ANALYZE inv_exp_nm.l3segment;


-- calcul de la surface terrière
BEGIN;

UPDATE inv_exp_nm.l3arbre
SET gtot = c13 * c13 / (4 * PI())
WHERE incref = 17;

COMMIT;

VACUUM ANALYZE inv_exp_nm.l3arbre;

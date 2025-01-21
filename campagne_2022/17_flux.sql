-- calcul du volume 5 ans après avec tarif de cubage à une entrée (qu'on recalcule en première visite à cause du peuplier cultivé)
DROP TABLE IF EXISTS arbres;

CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13, a3.c135
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS v13
, NULL::FLOAT8 AS v135
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.g3arbre g3a USING (npp)
INNER JOIN prod_exp.g3arbre a3 USING (npp, a)
INNER JOIN inv_exp_nm.e1coord e1c USING (npp)
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
WHERE g3a.incref = 12
UNION 
SELECT p3a.npp, p3a.a
, p3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, p3a.ess, p3a.c13, a3.c135
, SUM(p3a.gtot * p3a.w / p3a.pds) OVER (PARTITION BY p3a.npp) AS g
, NULL::FLOAT8 AS v13
, NULL::FLOAT8 AS v135
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.p3arbre p3a USING (npp)
INNER JOIN prod_exp.p3arbre a3 USING (npp, a)
INNER JOIN inv_exp_nm.e1coord e1c USING (npp)
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
WHERE p3a.incref = 12
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
CREATE INDEX arbres_incref_idx ON arbres USING btree (incref);
ANALYZE arbres;

CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2022
    GROUP BY id_type_tarif, id_tarif
)
SELECT et.id_type_tarif, et.id_tarif, et.ess
, x.alt2, x.pf_maaf, x.greco, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (alt2 TEXT, pf_maaf TEXT, greco TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.formule_tarif ~* 'ln\(C13\)'
AND et.periode @> 2022
ORDER BY ess, id_tarif;

UPDATE arbres ab
SET v13 = t.v13, v135 = t.v135
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13)
                + COALESCE(coef3, 0) * (LN(c13))^2
                + COALESCE(coef4, 0) * (LN(c13))^3
                + COALESCE(coef5, 0) * (LN(c13))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13)
                + COALESCE(coef3, 0) * (LN(c13))^2
                + COALESCE(coef4, 0) * (LN(c13))^3
                + COALESCE(coef5, 0) * (LN(c13))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v13
    , CASE 
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c135)
                + COALESCE(coef3, 0) * (LN(c135))^2
                + COALESCE(coef4, 0) * (LN(c135))^3
                + COALESCE(coef5, 0) * (LN(c135))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c135)
                + COALESCE(coef3, 0) * (LN(c135))^2
                + COALESCE(coef4, 0) * (LN(c135))^3
                + COALESCE(coef5, 0) * (LN(c135))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v135
    FROM arbres a
    INNER JOIN coefs_ess c ON a.ess = c.ess 
    INNER JOIN prod_exp.type_tarif tt USING (id_type_tarif)
    WHERE 
        CASE
            WHEN c.fact IS NULL THEN TRUE
            WHEN c.fact = 'greco' THEN a.greco = c.greco
            WHEN c.fact = 'alt2,pf_maaf' THEN a.alt2 = c.alt2 AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'greco,pf_maaf' THEN a.greco = c.greco AND a.pf_maaf = c.pf_maaf
            WHEN c.fact = 'alt2,greco,pf_maaf' THEN a.alt2 = c.alt2 AND a.greco = c.greco AND a.pf_maaf = c.pf_maaf
        END
) t
WHERE ab.npp = t.npp AND ab.a = t.a;

/*
SELECT npp, a, ess, v13, u_v13
FROM arbres a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
WHERE abs(a.v13 - ua.u_v13) > 0.00001
AND a.incref = 12
ORDER BY 1;

SELECT COUNT(*)
FROM arbres
LEFT JOIN inv_exp_nm.g3arbre g USING (npp, a)
LEFT JOIN inv_exp_nm.p3arbre p USING (npp, a)
WHERE v135 IS NULL
AND COALESCE(g.veget5, p.veget5) = '0';
*/

UPDATE inv_exp_nm.g3arbre m
SET vmort = a.v135, gmort = p.c135 * p.c135 / (4 * PI()), ntmort = 1
FROM arbres a
INNER JOIN prod_exp.g3arbre p ON a.npp = p.npp AND a.a = p.a
WHERE m.npp = a.npp
AND m.a = a.a
AND p.veget5 = 'M';

UPDATE inv_exp_nm.p3arbre m
SET vmort = a.v135, gmort = p.c135 * p.c135 / (4 * PI()), ntmort = 1
FROM arbres a
INNER JOIN prod_exp.p3arbre p ON a.npp = p.npp AND a.a = p.a
WHERE m.npp = a.npp
AND m.a = a.a
AND p.veget5 = 'M'

UPDATE inv_exp_nm.g3arbre
SET ntmort = 1, gmort = gtot, vmort = v
WHERE veget5 = 'T'
AND incref = 12;

UPDATE inv_exp_nm.p3arbre
SET ntmort = 1, gmort = gtot, vmort = v
WHERE veget5 = 'T'
AND incref = 12;

UPDATE inv_exp_nm.g3arbre m
SET vchab = a.v135, gchab = p.c135 * p.c135 / (4 * PI()), ntchab = 1
FROM arbres a
INNER JOIN prod_exp.g3arbre p ON a.npp = p.npp AND a.a = p.a
WHERE m.npp = a.npp
AND m.a = a.a
AND p.veget5 IN ('A', '1', '2');

UPDATE inv_exp_nm.p3arbre m
SET vchab = a.v135, gchab = p.c135 * p.c135 / (4 * PI()), ntchab = 1
FROM arbres a
INNER JOIN prod_exp.p3arbre p ON a.npp = p.npp AND a.a = p.a
WHERE m.npp = a.npp
AND m.a = a.a
AND p.veget5 IN ('A', '1', '2');

DROP TABLE arbres;

/*
SELECT a.incref + 2005 AS annee, sum(a.w * p.poids * a.v) AS vmort_v1, sum(a.w * p.poids * a.nt) AS ntmort_v1
FROM inv_exp_nm.g3morts a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.incref = 16
AND a.veget != 'A'
AND a.datemort = '1'
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref + 2010 AS annee, sum(a.w * p.poids * a.vmort) AS vmort_v2, sum(a.w * p.poids * a.ntmort) AS ntmort_v2
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.incref = 12
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref + 2005 AS annee, sum(a.w * p.poids * a.v) AS vchab_v1, sum(a.w * p.poids * a.nt) AS ntchab_v1
FROM inv_exp_nm.g3morts a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.incref = 16
AND a.veget IN ('1', '2')
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref + 2010 AS annee, sum(a.w * p.poids * a.vchab) AS vchab_v2, sum(a.w * p.poids * a.ntchab) AS ntchab_v2, count(*)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.incref >= 5
AND a.veget5 IN ('A', '1', '2')
GROUP BY a.incref
ORDER BY a.incref DESC;
*/

-- calcul des volumes précédents annualisés
UPDATE inv_exp_nm.g3arbre a
SET vmort_an = COALESCE(vmort / ((datepoint5::date - datepoint::date) / 365.25), 0)
, gmort_an = COALESCE(gmort / ((datepoint5::date - datepoint::date) / 365.25), 0)
, ntmort_an = ntmort / ((datepoint5::date - datepoint::date) / 365.25)
FROM inv_exp_nm.e2point p2
INNER JOIN prod_exp.g3foret f ON p2.npp = f.npp
WHERE a.npp = p2.npp
AND a.vmort > 0
AND a.incref = 12;

UPDATE inv_exp_nm.p3arbre a
SET vmort_an = COALESCE(vmort / ((datepoint5::date - datepoint::date) / 365.25), 0)
, gmort_an = COALESCE(gmort / ((datepoint5::date - datepoint::date) / 365.25), 0)
, ntmort_an = ntmort / ((datepoint5::date - datepoint::date) / 365.25)
FROM inv_exp_nm.e2point p2
INNER JOIN prod_exp.p3point f ON p2.npp = f.npp
WHERE a.npp = p2.npp
AND a.vmort > 0
AND a.incref = 12;

UPDATE inv_exp_nm.g3arbre a
SET vchab_an = vchab / ((datepoint5::date - datepoint::date) / 365.25)
, gchab_an = gchab / ((datepoint5::date - datepoint::date) / 365.25)
, ntchab_an = ntchab / ((datepoint5::date - datepoint::date) / 365.25)
FROM inv_exp_nm.e2point p2
INNER JOIN prod_exp.g3foret f ON p2.npp = f.npp
WHERE a.npp = p2.npp
AND a.vchab > 0
AND a.incref = 12;

UPDATE inv_exp_nm.p3arbre a
SET vchab_an = vchab / ((datepoint5::date - datepoint::date) / 365.25)
, gchab_an = gchab / ((datepoint5::date - datepoint::date) / 365.25)
, ntchab_an = ntchab / ((datepoint5::date - datepoint::date) / 365.25)
FROM inv_exp_nm.e2point p2
INNER JOIN prod_exp.p3point f ON p2.npp = f.npp
WHERE a.npp = p2.npp
AND a.vchab > 0
AND a.incref = 12;

UPDATE metaifn.afchamp
SET calcout = 12, validout = 12
WHERE famille ~~* 'inv_exp_nm'
AND donnee IN ('VMORT', 'GMORT', 'NTMORT', 'VCHAB', 'GCHAB', 'NTCHAB', 'VMORT_AN', 'GMORT_AN', 'NTMORT_AN', 'VCHAB_AN', 'GCHAB_AN', 'NTCHAB_AN');

-- Ajout de la production annualisée de chablis en surface terrière
UPDATE inv_exp_nm.g3arbre m
SET pgchab_an = ((p.c135^2 - m.c13^2) / (4 * PI())) * 1.0  / ((datepoint5::date - datepoint::date) / 365.25)
FROM prod_exp.g3arbre p
INNER JOIN prod_exp.g3foret f USING (npp)
INNER JOIN inv_exp_nm.e2point p2 USING (npp)
WHERE m.npp = p.npp
AND m.a = p.a
AND p.veget5 IN ('A', '1', '2')
AND m.incref = 12;

UPDATE inv_exp_nm.p3arbre m
SET pgchab_an = ((p.c135^2 - m.c13^2) / (4 * PI())) * 1.0  / ((datepoint5::date - datepoint::date) / 365.25)
FROM prod_exp.p3arbre p
INNER JOIN prod_exp.p3point f USING (npp)
INNER JOIN inv_exp_nm.e2point p2 USING (npp)
WHERE m.npp = p.npp
AND m.a = p.a
AND p.veget5 IN ('A', '1', '2')
AND m.incref = 12;

UPDATE inv_exp_nm.g3arbre
SET pgchab_an = 0
WHERE pgchab_an IS NULL
AND incref = 12;

UPDATE inv_exp_nm.p3arbre
SET pgchab_an = 0
WHERE pgchab_an IS NULL
AND incref = 12;


/*
SELECT a.incref + 2010 AS annee, sum(a.w * p.poids * a.pgchab_an) AS pgchab_an
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE a.incref >= 5
AND a.veget5 IN ('A', '1', '2')
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT veget5, count(*)
FROM inv_exp_nm.g3arbre ga
WHERE incref = 12
GROUP BY 1
ORDER BY 1;

SELECT vmort
FROM inv_exp_nm.g3arbre ga
WHERE incref = 12
AND veget5 = 'T';

SELECT incref, count(*)
FROM inv_exp_nm.g3arbre ga
WHERE veget5 IN ('T')
AND vmort IS NULL
GROUP BY 1
ORDER BY 1 DESC;
*/


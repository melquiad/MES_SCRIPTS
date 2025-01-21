BEGIN;

/***********************************************************************
 * CALCULS EN FORET
 ***********************************************************************/
-- calcul des volumes par tarif à 1 entrée en log de C13

DROP TABLE IF EXISTS arbres;

CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, g3a.incref
, gp.gmode AS pf_maaf
, CASE WHEN e1c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, e2p.greco
, g3a.ess, g3a.c13, g3a.c13_5
, SUM(g3a.gtot * g3a.w / g3a.pds) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest, NULL::FLOAT8 AS vest_5
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.NPP = g3f.NPP
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.NPP = g3a.NPP
INNER JOIN inv_exp_nm.e1coord e1c ON g3a.NPP = e1c.NPP
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = e2p.pro_nm
WHERE g3a.incref = 16
ORDER BY g3a.npp, g3a.a;

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
    AND et.periode @> 2021              -- CAMPAGNE
    GROUP BY id_type_tarif, id_tarif
)
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.alt2, x.pf_maaf, x.greco, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (alt2 TEXT, pf_maaf TEXT, greco TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.formule_tarif ~* 'ln\(C13\)'
AND et.periode @> 2021               -- CAMPAGNE
ORDER BY ess, id_tarif;

UPDATE arbres ab
SET vest_5 = t.v13_5
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN c13_5 < 10^(-2) THEN 0
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v13_5
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

UPDATE arbres
SET vest_5 = 0
WHERE vest_5 < 10^(-6);

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13_5 = a.vest_5
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a;

DROP TABLE coefs_ess;
DROP TABLE arbres;


/*
SELECT count(*), count(u_v13_5)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_v13_5 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;
*/

-- calcul de la nouvelle production PV2
UPDATE inv_exp_nm.u_g3arbre u
SET u_pv2 = 0.2 *
CASE	WHEN a.c13_5 < 0.235 THEN a.v
		ELSE a.v * (1 - u.u_v13_5 / u.u_v13)
END
, u_abv2 = 0.2 * a.v * (1 - u.u_v13_5 / u.u_v13)
FROM inv_exp_nm.g3arbre a
WHERE u.npp = a.npp AND u.a = a.a
AND a.incref = 16;

/*
SELECT count(*), count(u_pv2)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_pv2 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;
*/

-- CALCUL DE L'EFFET TECHNIQUE (à demander à F. Morneau, bien contrôler le format du fichier avant import)
CREATE UNLOGGED TABLE public.tau_k (
	essence TEXT,
	ess CHAR(2),
	pro_2015 CHAR(1),
	cld TEXT,
	tau_k FLOAT8,
	seuil INT2
)
WITHOUT oids;

-------------------------------------- J'en suis là -------------------------------


\COPY tau_k FROM '/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref16/donnees/CoefsEffetTechnique2021.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

/*
UPDATE tau_k
SET ess = LPAD(ess, 2, '0')
, cld = LPAD(cld, 2, '0');
*/

INSERT INTO prod_exp.tau_pv (ess, pro_nm, cld, tau, incref, seuil)
SELECT ess, pro_2015, cld, tau_k, 16 AS incref, seuil / 100.0
FROM tau_k;

DROP TABLE public.tau_k;

CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.ess, a.cld, 
g.gmode AS pro_2015, 
a.v, u.u_pv2, COALESCE(t.tau, 1)::FLOAT AS tau, t.ess AS tess, t.pro_nm AS tpro, t.cld AS tcld
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre u USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = p.pro_nm
INNER JOIN metaifn.abmode m ON m.unite = 'DIMG1' AND a.cld = m.mode
LEFT JOIN prod_exp.tau_pv t ON a.incref = t.incref AND a.ess = t.ess AND g.gmode = t.pro_nm 
	AND m.libelle = t.cld
--	AND a.cld = t.cld
WHERE a.incref = 16;

ALTER TABLE arbres ADD CONSTRAINT pkarbres PRIMARY KEY (npp, a);

UPDATE inv_exp_nm.u_g3arbre u
SET u_et_an = 0.2 * 
CASE
    WHEN a3.c13_5 < 0.235 THEN 0
    ELSE (1 - a.tau) * (a3.v * u.u_v13_5 / u.u_v13)
END
, u_abv_an = GREATEST(0.2 * a3.v * (1 - a.tau * u.u_v13_5 / u.u_v13), 0)
FROM arbres a
INNER JOIN inv_exp_nm.g3arbre a3 ON a.npp = a3.npp AND a.a = a3.a
WHERE u.npp = a.npp AND u.a = a.a
AND a3.incref = 16;

/*
SELECT count(*), count(u_et_an)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_et_an * a.w), SUM(p2.poids * a.w * ua.u_v13_5 / ua.u_v13)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p2.incref, g.gmode as pro, SUM(p2.poids * ua.u_et_an * a.w), SUM(p2.poids * a.w * ua.u_v13_5 / ua.u_v13)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
INNER JOIN metaifn.abgroupe g ON g.gunite = 'PF_MAAF' AND g.unite = 'PRO_2015' AND g.mode = p2.pro_nm
GROUP BY p2.incref, pro
ORDER BY pro, p2.incref DESC;

SELECT p2.incref, g.gmode as pro, SUM(p2.poids * ua.u_vpr_an * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
INNER JOIN metaifn.abgroupe g ON g.gunite = 'PF_MAAF' AND g.unite = 'PRO_2015' AND g.mode = p2.pro_nm
GROUP BY p2.incref, pro
ORDER BY pro, p2.incref DESC;
**/

UPDATE inv_exp_nm.g3arbre a3
SET pv = GREATEST(0.2 * 
CASE
    WHEN a3.c13_5 < 0.235 THEN a3.v
    ELSE a3.v * (1 - a.tau * u.u_v13_5 / u.u_v13)
END
, 0)
FROM arbres a
INNER JOIN inv_exp_nm.u_g3arbre u ON a.npp = u.npp AND a.a = u.a
WHERE a3.npp = a.npp AND a3.a = a.a
AND a3.incref = 16;

UPDATE inv_exp_nm.g3arbre
SET pv = 0
WHERE pv > 0 and pv < 0.000000001
AND incref = 16;

/*
SELECT count(*), count(pv)
FROM inv_exp_nm.g3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * a.pv * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
GROUP BY p2.incref
ORDER BY p2.incref DESC;
*/

-- calcul de la production en volume total aérien
UPDATE inv_exp_nm.u_g3arbre u
SET u_pv0 = 0.2 *
CASE
    WHEN a3.c13_5 < 0.235 THEN u.u_v0
    ELSE u.u_v0 * (1 - u.u_v13_5 / u.u_v13)
END
FROM inv_exp_nm.g3arbre a3
WHERE u.npp = a3.npp AND u.a = a3.a
AND a3.incref = 16;

UPDATE inv_exp_nm.u_g3arbre
SET u_pv0 = 0
WHERE u_pv0 > 0 and u_pv0 < 0.000000001
AND incref = 16;

DROP TABLE arbres;

/*
SELECT count(*), count(u_pv0)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_pv0 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.g3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_g3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p.incref, SUM(p.poids * a.w * u.u_pv2) AS pv_brut
, SUM(p.poids * a.w * u.u_et_an) AS effet_tech
, SUM(p.poids * a.w * a.pv) AS pv
, SUM(p.poids * a.w * u.u_pv0) AS pv0
FROM inv_exp_nm.e2point p
INNER JOIN inv_exp_nm.g3arbre a USING(npp)
INNER JOIN inv_exp_nm.u_g3arbre u USING(npp, a)
GROUP BY p.incref
ORDER BY p.incref DESC;

SELECT p.incref, SUM(p.poids * a.w * u.u_pv2) AS pv_brut
, SUM(p.poids * a.w * u.u_et_an) AS effet_tech
, SUM(p.poids * a.w * a.pv) AS pv
, SUM(p.poids * a.w * u.u_pv0) AS pv0
FROM inv_exp_nm.e2point p
INNER JOIN inv_exp_nm.g3arbre a USING(npp)
INNER JOIN inv_exp_nm.u_g3arbre u USING(npp, a)
WHERE a.ess = '06'
GROUP BY p.incref
ORDER BY p.incref DESC;
*/

/***********************************************************************
 * CALCULS EN PEUPLERAIES
 ***********************************************************************/
-- recalcul de l'âge des points
CREATE TEMPORARY TABLE age_peup AS
SELECT e1p.incref, p3p.npp
, CASE
    WHEN COUNT(p3a.npp) = 0 AND p3b.cam IS NULL THEN 0
    WHEN COUNT(p3a.npp) = 0 AND m.etendue = 5 THEN m.classe + (m.etendue - 1) / 2
    WHEN COUNT(p3a.npp) = 0 AND m.etendue > 5 THEN m.classe + (m.etendue + 1) / 2
    ELSE AVG(p3a.age13)
  END AS age_1
, CASE
    WHEN COUNT(p3a.npp) = 0 AND p3b.cam IS NULL THEN 'AA'
    WHEN COUNT(p3a.npp) = 0 AND p3b.cam IS NOT NULL THEN 'CAM'
    ELSE 'MS'
  END AS qage
FROM inv_exp_nm.p3point p3p
INNER JOIN inv_exp_nm.e1point e1p ON p3p.npp = e1p.npp
LEFT JOIN inv_exp_nm.p3agedom p3a ON p3p.npp = p3a.npp AND p3a.age13 IS NOT NULL
LEFT JOIN inv_exp_nm.p3agedom p3b ON p3p.npp = p3b.npp AND p3b.cam IS NOT NULL
LEFT JOIN metaifn.abmode m ON m.unite = 'CAM' AND m.mode = p3b.cam
WHERE e1p.incref = 16
GROUP BY p3p.npp, p3b.cam, m.classe, m.etendue, p3a.espar, e1p.incref
ORDER BY COUNT(p3a.npp), p3p.npp;

CREATE TEMPORARY TABLE peupliers AS
SELECT p3a.incref, p3a.npp, p3a.a, p3a.c13, p3g.age13 AS age, NULL::CHAR(1) AS recrut
FROM inv_exp_nm.p3arbre p3a
LEFT JOIN inv_exp_nm.p3agedom p3g ON p3a.npp = p3g.npp AND p3a.a = p3g.a
WHERE p3a.ess = '19'
AND p3a.incref = 16
ORDER BY incref, npp, a;

-- calcul du volume des peupliers par tarif d'âge
UPDATE inv_exp_nm.u_p3arbre u3
SET u_v13 = 
CASE
    WHEN ess <> '19' THEN 0
    WHEN COALESCE(p.age, a.age_1) = 0 THEN 0
    WHEN COALESCE(p.age, a.age_1) <= 17 THEN exp(-10.1756 + 0.8252^2 / 2 + 5.0121 * LN(COALESCE(p.age, a.age_1)) - 0.5275 * (LN(COALESCE(p.age, a.age_1)))^2)
    ELSE exp(-10.1756 + 0.8252^2 / 2 + 5.0121 * LN(17) - 0.5275 * (LN(17))^2) * COALESCE(p.age, a.age_1) / 17
END
, u_v13_5 = 
    CASE
        WHEN ess <> '19' THEN 0
        WHEN COALESCE(p.age, a.age_1) <= 5 THEN 0
        WHEN COALESCE(p.age, a.age_1) <= 22 THEN exp(-10.1756 + 0.8252^2 / 2 + 5.0121 * ln(COALESCE(p.age, a.age_1) - 5) - 0.5275 * (ln(COALESCE(p.age, a.age_1) - 5))^2)
        ELSE exp(-10.1756 + 0.8252^2 / 2 + 5.0121 * LN(17) - 0.5275 * (LN(17))^2) * (COALESCE(p.age, a.age_1) - 5) / 17
	END
FROM peupliers p
INNER JOIN age_peup a ON p.npp = a.npp
INNER JOIN inv_exp_nm.p3arbre p3a ON p.npp = p3a.npp AND p.a = p3a.a
WHERE u3.npp = p.npp AND u3.a = p.a;

-- calcul de la recensabilité des peupliers cultivés
UPDATE peupliers p
SET recrut =
CASE
    WHEN COALESCE(p.age, a.age_1, 0) = 0 AND p.c13 - 0.3 < 0.235 THEN '1'
    WHEN COALESCE(p.age, a.age_1, 0) <= 5 THEN '1'
    WHEN p.incref > 0 AND p.c13 * (1 - 5 / COALESCE(p.age, a.age_1)) < 0.235 THEN '1'
    ELSE '0'
END
FROM age_peup a
WHERE p.npp = a.npp;

UPDATE inv_exp_nm.u_p3arbre u3
SET u_rt5 = p.recrut
FROM peupliers p
WHERE u3.npp = p.npp AND u3.a = p.a;

-- calcul de la nouvelle production sur les peupliers (pas d'effet technique, tout est coupé en même temps par définition)
UPDATE inv_exp_nm.u_p3arbre u3
SET u_pv2 = 0.2 *
CASE
    WHEN p.recrut = '1' THEN v
    WHEN u3.u_v13 = 0 THEN 0
    ELSE p3.v * (1 - u3.u_v13_5 / u3.u_v13)
END
, u_abv2 = 
CASE
    WHEN u3.u_v13 = 0 THEN 0
    ELSE 0.2 * p3.v * (1 - u3.u_v13_5 / u3.u_v13)
END
, u_et_an = 0
, u_abv_an = 
CASE
    WHEN u3.u_v13 = 0 THEN 0
    ELSE GREATEST(0.2 * p3.v * (1 - u3.u_v13_5 / u3.u_v13), 0)
END
FROM peupliers p
INNER JOIN inv_exp_nm.p3arbre p3 ON p3.npp = p.npp AND p3.a = p.a
WHERE u3.npp = p.npp AND u3.a = p.a;

UPDATE inv_exp_nm.p3arbre a3
SET pv = GREATEST(0.2 * 
CASE
    WHEN p.recrut = '1' THEN a3.v
    WHEN u3.u_v13 = 0 THEN 0
    ELSE p3.v * (1 - u3.u_v13_5 / u3.u_v13)
END, 0)
FROM peupliers p
INNER JOIN inv_exp_nm.u_p3arbre u3 ON u3.npp = p.npp AND u3.a = p.a
INNER JOIN inv_exp_nm.p3arbre p3 ON p3.npp = p.npp AND p3.a = p.a
WHERE a3.npp = p.npp AND a3.a = p.a;

-- calcul de la production aérienne totale
UPDATE inv_exp_nm.u_p3arbre p3
SET u_pv0 = 0.2 *
CASE
    WHEN p.recrut = '1' THEN u_v0
    WHEN p3.u_v13 = 0 THEN 0
    ELSE p3.u_v0 * (1 - p3.u_v13_5 / p3.u_v13)
END
FROM peupliers p
WHERE p3.npp = p.npp AND p3.a = p.a;

DROP TABLE age_peup;
DROP TABLE peupliers;


-- CALCUL DE L'IR5 POUR LES ARBRES NON PEUPLIER EN PEUPLERAIE (SI ESS=27, ALORS IR5=0)
-- on récupère les arbres de forêt non peupliers sur des points forêt où il y a des peupliers
CREATE TEMPORARY TABLE arbresf AS
SELECT a.incref, a.npp, a.a, a.ess, p2.rad2, a.c13, a.ir5, c.xl, c.yl
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.e2point p2 ON a.npp = p2.npp
INNER JOIN inv_exp_nm.e1coord c ON p2.npp = c.npp
WHERE a.ess NOT IN ('19', '27')
AND EXISTS (
	SELECT 1
	FROM inv_exp_nm.g3arbre a2
	WHERE a.npp = a2.npp
	AND a2.ess = '19'
)
ORDER BY a.incref, a.npp, a.a;

-- on récupère les arbres de peupleraie non peupliers
CREATE TEMPORARY TABLE arbresp AS
WITH arbs_peup AS (
    SELECT npp, SUM(gtot * w / pds) as g
    FROM inv_exp_nm.p3arbre
    WHERE incref = 16
    GROUP BY npp
)
SELECT a.incref, a.npp, a.a, a.ess, a.c13
, c.xl, c.yl
, CASE WHEN c.zp <= 600 THEN '0' ELSE '1' END AS alt2
, gp.gmode AS pf_maaf
, p2.greco
, ap.g
, SUM(a.gtot * a.w / a.pds) OVER (PARTITION BY a.npp) AS old_g
, NULL::REAL AS ir5, NULL::FLOAT8 AS c13_5, NULL::FLOAT8 AS v13, NULL::FLOAT8 AS v13_5
FROM inv_exp_nm.p3arbre a
INNER JOIN arbs_peup ap ON a.npp = ap.npp
INNER JOIN inv_exp_nm.p3point p3 ON a.npp = p3.npp
INNER JOIN inv_exp_nm.e2point p2 ON a.npp = p2.npp
INNER JOIN inv_exp_nm.e1coord c ON p2.npp = c.npp
LEFT JOIN metaifn.abgroupe gp ON gp.unite = 'PRO_2015' AND gp.gunite = 'PF_MAAF' AND gp.mode = p2.pro_nm
WHERE v IS NOT NULL
AND a.ess <> '19'
AND a.incref = 16
ORDER BY a.npp, a.a;


-- pour chaque arbre de peupleraie, on va chercher l'IR5 de l'arbre forêt le plus proche selon les critères décroissants suivants :
--     * même campagne
--     * même essence (à défaut même regroupement feuillu/résineux)
--     * le plus proche en C13 (écart en valeur absolue)
--     * si il y en a plusieurs, le plus proche en distance kilométrique
--     * s'il reste plusieurs arbres possibles, alors le premier en numérotation d'arbres sur la placette (donnée A)
UPDATE arbresp a
SET ir5 = CASE WHEN a.ess = '27' THEN 0 ELSE t.ir5 END
FROM (
	SELECT p.incref, p.npp, p.a, p.ess, ROUND((p.c13 * 100)::NUMERIC, 0) AS c13cm
	, ABS(ROUND((p.c13 * 100)::NUMERIC, 0) - ROUND((f.c13 * 100)::NUMERIC, 0)) AS dist_c13
	, f.ir5
	, SQRT((p.xl - f.xl)^2 + (p.yl - f.yl)^2) AS dist_pts
	, RANK() OVER(PARTITION BY p.incref, p.npp, p.a ORDER BY ABS(ROUND((p.c13 * 100)::NUMERIC, 0) - ROUND((f.c13 * 100)::NUMERIC, 0)), SQRT((p.xl - f.xl)^2 + (p.yl - f.yl)^2), f.a) AS rang
	FROM arbresp p
	LEFT JOIN arbresf f ON p.incref = f.incref AND p.ess = f.ess
	WHERE f.npp IS NOT NULL
	UNION
	SELECT p.incref, p.npp, p.a, p.ess, ROUND((p.c13 * 100)::NUMERIC, 0) AS c13cm
	, ABS(ROUND((p.c13 * 100)::NUMERIC, 0) - ROUND((f2.c13 * 100)::NUMERIC, 0)) AS dist_c13
	, f2.ir5
	, SQRT((p.xl - f2.xl)^2 + (p.yl - f2.yl)^2) AS dist_pts
	, RANK() OVER(PARTITION BY p.incref, p.npp, p.a ORDER BY ABS(ROUND((p.c13 * 100)::NUMERIC, 0) - ROUND((f2.c13 * 100)::NUMERIC, 0)), SQRT((p.xl - f2.xl)^2 + (p.yl - f2.yl)^2), f2.a) AS rang
	FROM arbresp p
	LEFT JOIN arbresf f ON p.incref = f.incref AND p.ess = f.ess
	LEFT JOIN arbresf f2 ON p.incref = f2.incref AND (CASE WHEN p.ess < '50' THEN 'F' ELSE 'R' END) = (CASE WHEN f2.ess < '50' THEN 'F' ELSE 'R' END)
	WHERE f.npp IS NULL
) t
WHERE a.npp = t.npp AND a.a = t.a
AND t.rang = 1;

DROP TABLE arbresf;

-- CALCUL DU C13_5 POUR LES ARBRES NON PEUPLIER EN PEUPLERAIE
UPDATE arbresp p
SET c13_5 = GREATEST(c13 - (2 * PI() * ir5) / (1 - 2 * PI() * c.coeftarif), 0)
FROM prod_exp.c4ctarif c 
INNER JOIN prod_exp.c4tarifs t ON c.ntarif = t.ntarif AND t.typtarif = 'E1' AND format = 'DTOTAL' AND domaine = 0
WHERE p.ess = c.ess
AND c.nctarif = 1;

UPDATE inv_exp_nm.u_p3arbre a
SET u_rt5 = 
CASE
	WHEN p.c13_5 < 0.235 THEN '1'
	ELSE '0'
END
FROM arbresp p
WHERE a.npp = p.npp AND a.a = p.a;

/*
SELECT p.incref, u.u_rt5
, SUM(p.poids * a.w * a.v) AS v, count(*) as nb
FROM inv_exp_nm.e2point p
INNER JOIN inv_exp_nm.p3arbre a USING(npp)
INNER JOIN inv_exp_nm.u_p3arbre u USING(npp, a)
GROUP BY p.incref, u.u_rt5
ORDER BY u.u_rt5, incref;
*/

-- CALCUL DE V13_5 POUR LES ARBRES NON PEUPLIER EN PEUPLERAIE
-- récupération des tarifs à 1 entrée en log
CREATE TEMPORARY TABLE coefs_ess AS 
WITH f AS (
    SELECT tt.id_type_tarif, et.id_tarif, string_agg(DISTINCT x, ',' ORDER BY x) AS fact
    FROM prod_exp.type_tarif tt
    INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif)
    CROSS JOIN LATERAL jsonb_object_keys(et.facteurs) x
    WHERE lib_type_tarif ~* 'ln\(C13\)'
    AND et.periode @> 2021             -- CAMPAGNE
    GROUP BY id_type_tarif, id_tarif
)
SELECT et.id_type_tarif, et.id_tarif, et.ess, x.alt2, x.pf_maaf, x.greco, c.coef1, c.coef2, c.coef3, c.coef4, c.coef5, c.coef6, c.coef7
, f.fact
FROM prod_exp.type_tarif tt
INNER JOIN prod_exp.tarifs t USING (id_type_tarif)
INNER JOIN prod_exp.ess_tarif et USING (id_type_tarif, id_tarif)
LEFT JOIN f USING (id_type_tarif, id_tarif)
LEFT JOIN LATERAL jsonb_to_record(et.facteurs) AS x (alt2 TEXT, pf_maaf TEXT, greco TEXT) ON TRUE
CROSS JOIN LATERAL jsonb_to_record(t.coefficients) AS c(coef1 REAL, coef2 REAL, coef3 REAL, coef4 REAL, coef5 REAL, coef6 REAL, coef7 REAL)
WHERE tt.formule_tarif ~* 'ln\(C13\)'
AND et.periode @> 2021                  -- CAMPAGNE
ORDER BY ess, id_tarif;

-- mise à jour des volumes dans la table des arbres
UPDATE arbresp ab
SET v13_5 = t.v13_5
FROM (
    SELECT npp, a, a.ess
    , CASE 
        WHEN c13_5 < 10^(-2) THEN 0
        WHEN tt.lib_type_tarif ~~* '%v1'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * LN(g)
                + coef7^2 / 2
            )
        WHEN tt.lib_type_tarif ~~* '%v2'
            THEN EXP(
                coef1
                + COALESCE(coef2, 0) * LN(c13_5)
                + COALESCE(coef3, 0) * (LN(c13_5))^2
                + COALESCE(coef4, 0) * (LN(c13_5))^3
                + COALESCE(coef5, 0) * (LN(c13_5))^4
                + COALESCE(coef6, 0) * g
                + coef7^2 / 2
            )
      END AS v13_5
    FROM arbresp a
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

UPDATE inv_exp_nm.u_p3arbre a
SET u_v13_5 = v.v13_5
FROM arbresp v
WHERE a.npp = v.npp AND a.a = v.a;

DROP TABLE coefs_ess;

/*
SELECT count(*), count(u_v13), count(u_v13_5), count(u_rt5)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_v13 * a.w), SUM(p2.poids * ua.u_v13_5 * a.w), SUM(u_rt5::INT2)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_p3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref desc;
*/

-- calcul de la nouvelle production PV2
UPDATE inv_exp_nm.u_p3arbre u
SET u_pv2 = 0.2 *
	CASE	WHEN p.c13_5 < 0.235 THEN v
			ELSE a.v * (1 - u.u_v13_5 / u.u_v13)
	END
, u_abv2 = 0.2 * a.v * (1 - u.u_v13_5 / u.u_v13)
FROM arbresp p
INNER JOIN inv_exp_nm.p3arbre a ON a.npp = p.npp AND a.a = p.a
WHERE u.npp = p.npp AND u.a = p.a;

-- actualisation de la production avec effet technique
CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.ess, a.cld, 
g.gmode AS pro_2015, 
a.v, u.u_pv2, COALESCE(t.tau, 1)::FLOAT AS tau, t.ess AS tess, t.pro_nm AS tpro, t.cld AS tcld
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre u USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
INNER JOIN metaifn.abgroupe g ON g.unite = 'PRO_2015' AND g.gunite = 'PF_MAAF' AND g.mode = p.pro_nm
INNER JOIN metaifn.abmode m ON m.unite = 'DIMG1' AND a.cld = m.mode
LEFT JOIN prod_exp.tau_pv t ON a.incref = t.incref AND a.ess = t.ess AND g.gmode = t.pro_nm 
	AND m.libelle = t.cld
WHERE a.espar != '19'
AND a.incref = 16;

ALTER TABLE arbres ADD CONSTRAINT pkarbres PRIMARY KEY (npp, a);

UPDATE inv_exp_nm.u_p3arbre u3
SET u_et_an = 0.2 * 
CASE	WHEN ap.c13_5 < 0.235 THEN 0
		ELSE (1 - a.tau) * (a3.v * u3.u_v13_5 / u3.u_v13)
END
, u_abv_an = GREATEST(0.2 * a3.v * (1 - a.tau * u3.u_v13_5 / u3.u_v13), 0)
FROM arbres a
INNER JOIN arbresp ap ON a.npp = ap.npp AND a.a = ap.a
INNER JOIN inv_exp_nm.p3arbre a3 ON a3.npp = a.npp AND a3.a = a.a
WHERE u3.npp = a.npp AND u3.a = a.a;

UPDATE inv_exp_nm.p3arbre a3
SET pv = GREATEST(0.2 * 
CASE
    WHEN ap.c13_5 < 0.235 THEN a3.v
    ELSE a3.v * (1 - a.tau * u3.u_v13_5 / u3.u_v13)
END
, 0)
FROM arbres a
INNER JOIN arbresp ap ON a.npp = ap.npp AND a.a = ap.a
INNER JOIN inv_exp_nm.u_p3arbre u3 ON u3.npp = a.npp AND u3.a = a.a
WHERE a3.npp = a.npp AND a3.a = a.a;

-- calcul de la production aérienne totale
UPDATE inv_exp_nm.u_p3arbre a
SET u_pv0 = 0.2 *
CASE
    WHEN p.c13_5 < 0.235 THEN a.u_v0
    ELSE a.u_v0 * (1 - a.u_v13_5 / a.u_v13)
END
FROM arbresp p
WHERE a.npp = p.npp AND a.a = p.a;

DROP TABLE arbres;
DROP TABLE arbresp;

-- on met à 0 les noyers
UPDATE inv_exp_nm.u_p3arbre ua
SET u_pv2 = 0, u_abv2 = 0, u_et_an = 0, u_pv0 = 0, u_v13_5 = u_v13, u_abv_an = 0
FROM inv_exp_nm.p3arbre a
WHERE ua.npp = a.npp
AND ua.a = a.a
AND a.ess = '27'
AND a.incref = 16;

UPDATE inv_exp_nm.p3arbre
SET pv = 0
WHERE ess = '27'
AND incref = 16;


/*
SELECT count(*), count(u_v0)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 16;

SELECT p2.incref, SUM(p2.poids * ua.u_pv0 * a.w)
FROM inv_exp_nm.e2point p2
INNER JOIN inv_exp_nm.p3arbre a ON p2.npp = a.npp
INNER JOIN inv_exp_nm.u_p3arbre ua ON a.npp = ua.npp AND a.a = ua.a
GROUP BY p2.incref
ORDER BY p2.incref DESC;

SELECT p.incref, SUM(p.poids * a.w * u.u_pv2) AS pv_brut
, SUM(p.poids * a.w * u.u_et_an) AS effet_tech
, SUM(p.poids * a.w * a.pv) AS pv
, SUM(p.poids * a.w * u.u_pv0) AS pv0
FROM inv_exp_nm.e2point p
INNER JOIN inv_exp_nm.p3arbre a USING(npp)
INNER JOIN inv_exp_nm.u_p3arbre u USING(npp, a)
GROUP BY p.incref
ORDER BY p.incref DESC;
*/

COMMIT;

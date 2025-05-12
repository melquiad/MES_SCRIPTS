

-- calcul exceptionnel de U_V0 pour la campagne 2024 
CREATE TABLE public.coefs (
	ess CHAR(2),
	essence VARCHAR(100),
	ntarif CHAR(3),
	a FLOAT,
	b FLOAT,
	g FLOAT,
	d FLOAT,
	CONSTRAINT coefs_pkey PRIMARY KEY (ess)
)
WITH (
  OIDS=FALSE
);

\COPY public.coefs FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-exploitation/inv_exp_nm/Incref19/donnees/coefs_tarifVallet.csv' WITH DELIMITER ';' NULL AS '' --> même fichier tous les ans


UPDATE inv_exp_nm.u_g3arbre ua
SET u_v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM public.coefs c
INNER JOIN inv_exp_nm.g3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 19
AND a.htot IS NOT NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = (a.c13 * 100)^2 * a.htot / (40000 * PI()) * (c.a + c.b * a.c13 * 100 + c.g * sqrt(a.c13 * 100) / a.htot) * (1 + c.d / (a.c13 * 100)^2)
FROM public.coefs c
INNER JOIN inv_exp_nm.p3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 19
AND a.ess <> '19'
AND a.htot IS NOT NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = (a.v + a.vr) * 1.25
FROM public.coefs c
INNER JOIN inv_exp_nm.p3arbre a ON c.ess = a.ess
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.incref = 19
AND a.ess = '19'
AND a.htot IS NOT NULL;

-- imputation de V0
CREATE TEMPORARY TABLE arbres AS
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, a2.u_v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 19
UNION ALL
SELECT a.npp, a.a, a.incref, a.espar, a.ess
, a.simplif, ROUND(a.c13::NUMERIC, 3) AS c13, a.htot
, CASE
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.395 THEN 'TPB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 0.705 THEN 'PB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.175 THEN 'MB'
        WHEN ROUND(a.c13::NUMERIC, 3) < 1.645 THEN 'GB'
        ELSE 'TGB'
  END AS dimess
, a2.u_v0 AS v0, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS v0imp
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 19
ORDER BY npp, a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, v0, v0 / v13 AS coef, v13, 'A'::BPCHAR AS ref
FROM arbres a
WHERE simplif = '0'
ORDER BY npp, a;

ALTER TABLE refs
ADD CONSTRAINT refs_pkey PRIMARY KEY (npp, a);

ANALYZE refs;

CREATE TEMPORARY TABLE corresp AS
SELECT *
FROM (
	WITH t0 AS (
		SELECT a.npp, a.a, a.espar, a.dimess, r.c13
      , r.coef, r.v0, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, v0, v13, ref
	FROM t0
	WHERE rang = 1
) AS t
ORDER BY npp, a;

ALTER TABLE corresp
ADD CONSTRAINT corresp_pkey PRIMARY KEY (npp, a);

ANALYZE corresp;

UPDATE corresp c
SET ref = r.ref
FROM refs r
WHERE c.npp = r.npp
AND c.a = r.a;

UPDATE arbres a
SET v0imp = c.v0 * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v0 = a.v0imp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_v0 IS NULL;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_v0 = a.v0imp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_v0 IS NULL;

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;
DROP TABLE coefs;


/*
SELECT COUNT(*), count(u_v0)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 19;

SELECT COUNT(*), count(u_v0)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 19;
*/


/*
SELECT a.incref, sum(a.w * p.poids * ua.u_v0)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids * ua.u_v0)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/


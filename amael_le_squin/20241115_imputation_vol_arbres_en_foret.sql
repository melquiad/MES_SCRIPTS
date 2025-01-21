

-- IMPUTATION DU VOLUME EN FORÊT
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
, a2.u_vest AS vest, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS vimp
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 13 AND a.npp = '18-25-273-1-092T'
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, vest, vest / v13 AS coef, v13, 'A'::BPCHAR AS ref
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
      , r.coef, r.vest, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, vest, v13, ref
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
SET vimp = c.vest * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

/*
SELECT count(*)
FROM arbres
WHERE vimp IS NULL; --> 0

SELECT * FROM arbres WHERE vimp IS NULL order by npp, a, ess, dimess; --> aucune sélection
*/

UPDATE inv_exp_nm.u_g3arbre ua
SET u_vest = a.vimp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_vest IS NULL;

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;

/*
SELECT COUNT(*), count(u_vest)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 18;

SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/

-- IMPUTATION DU VOLUME EN PEUPLERAIE

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
, a2.u_vest AS vest, a2.u_v13 AS v13
, 'S'::BPCHAR AS ref
, NULL::FLOAT AS vimp
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
WHERE a.incref = 18
ORDER BY a.npp, a.a;

ALTER TABLE arbres
ADD CONSTRAINT arbres_pkey PRIMARY KEY (npp, a);

ANALYZE arbres;

CREATE TEMPORARY TABLE refs AS
SELECT a.npp, a.a, a.espar
, dimess, c13, vest, vest / v13 AS coef, v13, 'A'::BPCHAR AS ref
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
      , r.coef, r.vest, r.v13
      , RANK() OVER(PARTITION BY a.npp, a.a ORDER BY ABS(a.c13 - r.c13)
      , ABS(a.a - r.a), r.a) AS rang, 'S'::BPCHAR AS ref
		FROM arbres a
		INNER JOIN refs r ON a.npp = r.npp AND a.espar = r.espar AND a.dimess = r.dimess
	)
	SELECT npp, a, espar, dimess, c13, coef, vest, v13, ref
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
SET vimp = c.vest * (a.v13 / c.v13)
, ref = c.ref
FROM corresp c
WHERE a.npp = c.npp AND a.a = c.a;

UPDATE inv_exp_nm.u_p3arbre ua
SET u_vest = a.vimp
FROM arbres a
WHERE ua.npp = a.npp AND ua.a = a.a
AND ua.u_vest IS NULL;

/*
SELECT * FROM arbres WHERE vimp IS NULL order by npp, a, ess, dimess;
*/

DROP TABLE arbres;
DROP TABLE refs;
DROP TABLE corresp;

/*
SELECT COUNT(*), count(u_vest)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 18;

SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.g3arbre a
INNER JOIN inv_exp_nm.u_g3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;

SELECT a.incref, sum(a.w * p.poids * ua.u_vest)
FROM inv_exp_nm.p3arbre a
INNER JOIN inv_exp_nm.u_p3arbre ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY a.incref
ORDER BY a.incref DESC;
*/


/************************************************************
*				CALCUL DES AGES (FORET)						*
*************************************************************/
-- création de la table recevant les âges
CREATE TEMPORARY TABLE ages (
	incref SMALLINT, 
	npp CHAR(16),
	age_1 FLOAT, 
	espar_age_1 CHAR(4), 
	age_2 FLOAT, 
	espar_age_2 CHAR(4), 
	qage CHAR(3),
--	age13_c FLOAT, --> donnée intermédiaire
--	age13_i FLOAT, --> donnée intermédiaire
	CONSTRAINT ages_pkey PRIMARY KEY (npp)
)
WITH (
	OIDS = FALSE
);


-- points momentanément déboisés (PEUPNR = 2) => âge = 0
INSERT INTO ages (npp, age_1, qage, incref)
SELECT npp, 0, 'MD', incref
FROM inv_exp_nm.g3foret g3f
WHERE incref = 18
AND peupnr = '2';

-- points non recensables (PEUPNR = 1) => avec CAM
INSERT INTO ages (npp, age_1, espar_age_1, qage, incref)
SELECT g3f.npp, 
	CASE WHEN g3d.cam IS NOT NULL AND m1.etendue = 5 THEN m1.classe + (m1.etendue - 1) / 2
		 WHEN g3d.cam IS NOT NULL AND m1.etendue > 5 THEN m1.classe + (m1.etendue + 1) / 2 
	END AS age
, COALESCE(g3f.tpespar1, g3f.esparpre), 'CAM', g3f.incref
FROM inv_exp_nm.g3foret g3f
INNER JOIN inv_exp_nm.g3agedom g3d ON g3f.npp = g3d.npp AND g3d.cam IS NOT NULL
INNER JOIN metaifn.abmode m1 ON m1.unite = 'CAM2' AND g3d.cam = m1.mode
WHERE g3f.incref = 18
AND g3f.peupnr = '1';

-- points non recensables (PEUPNR = 1) sans CAM => absence d'âge (âge = 0)
INSERT INTO ages (npp, age_1, qage, incref)
SELECT g3f.npp, 0, 'AA', g3f.incref
FROM inv_exp_nm.g3foret g3f
LEFT JOIN ages a ON g3f.npp = a.npp
WHERE g3f.incref = 18
AND g3f.peupnr = '1'
AND a.npp IS NULL;

-- points recensables (PEUPNR = 0) sans mesure d'âge => absence d'âge (âge = 0)
INSERT INTO ages (npp, age_1, qage, incref)
SELECT DISTINCT g3f.npp, 0, 'AA', g3f.incref
FROM inv_exp_nm.g3foret g3f
LEFT JOIN inv_exp_nm.g3agedom g3d ON g3f.npp = g3d.npp AND (g3d.age13 IS NOT NULL OR g3d.ncerncar IS NOT NULL OR g3d.cam IS NOT NULL)
WHERE g3f.incref = 18
AND g3f.peupnr = '0'
AND g3d.npp IS NULL;

TABLE ages;


-- points recensables (PEUPNR = 0)
-- on crée la table temporaire de tous les arbres avec leurs données d'âge
CREATE TEMPORARY TABLE calcul_age (
	npp CHAR(16), 
	numa SMALLINT, 
	a SMALLINT, 
	espar CHAR(4), 
	age SMALLINT,
	age13_c SMALLINT, --> donnée intermédiaire
	age13_i SMALLINT, --> donnée intermédiaire
	longcar SMALLINT, 
	ncerncar SMALLINT,
--	auteurlt CHAR(5), 
	typdom CHAR(1), 
	c13 REAL,
	cld CHAR(2)
	greco CHAR(1)
	incref SMALLINT,
	CONSTRAINT calcul_age_pkey PRIMARY KEY (npp, a)
)
WITH (
	OIDS = FALSE
);


---> 0. On crée AGE13_C comme la copie de AGE13  
INSERT INTO calcul_age
SELECT g3f.npp, g3d.numa, g3a.a, g3a.espar, g3d.age13 AS age13, g3d.age13 AS age13_c, 0 AS age13_i, g3d.longcar, g3d.ncerncar, g3d.typdom, g3a.c13, g3f.incref
FROM inv_exp_nm.g3foret g3f
INNER JOIN inv_exp_nm.e2point e2p ON g3f.npp = e2p.npp
INNER JOIN inv_exp_nm.g3agedom g3d ON g3f.npp = g3d.npp AND (g3d.age13 IS NOT NULL OR (g3d.ncerncar IS NOT NULL AND g3d.longcar IS NOT NULL))
INNER JOIN inv_exp_nm.g3arbre g3a ON g3d.npp = g3a.npp AND g3d.a = g3a.a
WHERE g3f.incref = 18
AND g3f.peupnr = '0'
ORDER BY g3f.npp, g3a.a;

TABLE calcul_age;
--DROP TABLE calcul_age;

---> 1. Si le couple (NCERNCAR ; LONCAR) est mesuré, on recalcule AGE13_C d'après (NCERNCAR ; LONCAR)  ---> 1 OK
-- reconstitution des âges partiels manquants
UPDATE calcul_age
SET age13_c = CASE WHEN c13 * 100 / (2 * PI() * longcar / 10) > 1 THEN ROUND((ncerncar * c13 * 100 / (2 * PI() * longcar / 10))::NUMERIC, 0)
		ELSE ncerncar END
WHERE age IS NULL;

---> 2. Si le couple (NCERNCAR ; LONCAR) est aberrant, on supprime AGE13_C  
-- suppression de l'âge calculé des arbres dont le rapport LONGCAR / R13 < 33% ou > 160% (12 arbres) ---> 2 OK
UPDATE calcul_age
SET age13_c = NULL
WHERE CAST(longcar AS REAL) * 2 * PI() * 100 / (c13 * 1000) NOT BETWEEN 33 AND 160;

-- suppression de l'âge calcul des arbres dont le rapport LONGCAR / NCERNCAR > 8 (10 arbres)
UPDATE calcul_age
SET age13_c = NULL
WHERE CAST(longcar AS REAL) / CAST(ncerncar AS REAL) > 8;


-- récupération des points recensables qui n'ont plus d'âge (1) => tarif d'âge
CREATE TEMP table vide_age AS
SELECT * FROM calcul_age WHERE npp IN (
	SELECT npp
	FROM calcul_age
	GROUP BY npp
	HAVING SUM(CASE WHEN age IS NULL THEN 0 ELSE 1 END) = 0
	ORDER BY npp
) ORDER BY npp;

TABLE vide_age;

UPDATE vide_age
SET age13_c = age_new
FROM (
	SELECT c.npp, c.a, AVG(T.AGE13) AS age_new 
	FROM vide_age C
	INNER JOIN (
		SELECT a.espar, COALESCE(a.c13, a2.c13) AS c13, a.age13
		FROM inv_exp_nm.g3agedom a
		LEFT JOIN inv_exp_nm.g3arbre a2 ON a.npp = a2.npp AND a.a = a2.a
		WHERE a.age13 IS NOT NULL
	) AS T ON c.espar = t.espar
				AND CAST(5 * ROUND(((100 * t.c13::REAL / PI()) / 5::REAL)::NUMERIC, 0) AS INT) = CAST(5 * ROUND(((100 * c.c13::REAL / PI()) / 5::REAL)::NUMERIC, 0) AS INT)
	GROUP BY c.npp, c.a
) t
WHERE t.npp = vide_age.npp AND t.a = vide_age.a;

UPDATE calcul_age
SET age13_c = v.age13_c
FROM vide_age v
WHERE calcul_age.npp = v.npp AND calcul_age.a = v.a;

TABLE calcul_age;

-- suppression des âges reconstitués mais erronés
DELETE FROM calcul_age
WHERE age13_c IS NULL;

---> 3. On calcule AGE_1 comme la moyenne des AGE13_C (+facteur correctif de l'âge à la base) de l'espèce dominante principale  
-- on calcul les âges pour TYPDOM 0 ou, TYPDOM 1 mais sans TYPDOM 0
INSERT INTO ages (npp, age_1, espar_age_1, qage, incref)
SELECT npp, AVG(age13_c), espar, 'MS', incref
FROM calcul_age
WHERE typdom = '0'
GROUP BY npp, espar, incref;

---> 4. Si aucun arbre de l'espèce dominante principale n'a de AGE13_C, on calcule AGE_1 comme le AGE13_C (+facteur correctif de l'âge à la base) de l'espèce dominante secondaire
INSERT INTO ages (npp, age_1, espar_age_1, qage, incref)
SELECT c1.npp, AVG(c1.age13_c), c1.espar, 'MS', c1.incref
FROM calcul_age c1
LEFT JOIN calcul_age c2 ON c1.npp = c2.npp AND c2.typdom = '0'
WHERE c1.typdom = '1'
AND c2.npp IS NULL
GROUP BY c1.npp, c1.espar, c1.incref;

-- on s'intéresse ensuite aux quelques points avec une espèce secondaire (TYPDOM = 1)
UPDATE ages
SET espar_age_2 = t.espar, age_2 = t.age
FROM (
	SELECT c1.npp, AVG(c1.age13_c) AS age, c1.espar, c2.typdom, c1.typdom
	FROM calcul_age c1
	INNER JOIN calcul_age c2 ON c1.npp = c2.npp AND c2.typdom = '0'
	WHERE c1.typdom = '1'
	GROUP BY c1.npp, c1.espar, c2.typdom, c1.typdom
) AS t
WHERE t.npp = ages.npp;

---> 5. Si aucun arbre n'a de AGE13_C, on impute aux arbres de l'espèce dominante principale un âge (AGE13_I) comme la moyenne des AGE13_C des arbres de...  
--  * même ESPAR  
--  * même GRECO  
--  * même CLD  
--  * 5 campagnes précédentes  
-- ... et AGE_1 est la moyenne de ces âges imputés AGE13_I (+facteur correctif de l'âge à la base)

UPDATE calcul_age
SET age13_i = avg(age13_c)
FROM calcul_age c1
INNER JOIN calcul_age c2 ON c1.npp = c2.npp 
WHERE calcul_age.npp = v.npp AND calcul_age.a = v.a;


UPDATE ages
SET espar_age_1 = t.espar, age_1 = t.age
FROM (
	SELECT c1.npp, AVG(c1.age13_c) AS age, c1.espar
	FROM calcul_age c1
	INNER JOIN calcul_age c2 ON c1.npp = c2.npp AND c1.espar = c2.espar
	WHERE c1.typdom = '0'
	GROUP BY c1.npp, c1.espar
WHERE c1.typdom = '0'
)


-- on corrige l'âge des arbres mesurés pour les ramener à des âges à la base
CREATE TEMPORARY TABLE ecart (espar CHAR(4), diff_m SMALLINT);

INSERT INTO ecart (espar, diff_m) 
VALUES ('02', 7), ('03', 8), ('05', 7), ('06', 6), ('09', 9)
, ('10', 3), ('11', 7), ('12V', 4), ('17C', 5), ('51', 4)
, ('52', 7), ('54', 8), ('61', 9), ('62', 8), ('64', 4)
, ('AF', 5), ('AR', 6);

UPDATE ages
SET age_1 = age_1 + e.diff_m
FROM ecart e 
WHERE e.espar = 
CASE 
	WHEN ages.espar_age_1 IN ('02', '03', '05', '06', '09', '10', '11', '12V', '17V', '51', '52', '54', '61', '62', '64') THEN AGES.ESPAR_AGE_1
	WHEN ages.espar_age_1 < '5' THEN 'AF'
	ELSE 'AR'
END
AND ages.qage = 'MS';

UPDATE ages
SET age_2 = age_2 + e.diff_m
FROM ecart e 
WHERE e.espar = 
CASE 
	WHEN ages.espar_age_2 IN ('02', '03', '05', '06', '09', '10', '11', '12V', '17V', '51', '52', '54', '61', '62', '64') THEN AGES.ESPAR_AGE_2
	WHEN ages.espar_age_2 < '5' THEN 'AF'
	ELSE 'AR'
END
AND ages.age_2 IS NOT NULL;
--TABLE ages;

ALTER TABLE ages ADD COLUMN cac CHAR(2);

UPDATE ages a
SET cac =
CASE
	WHEN a.qage IN ('AA', 'MD') THEN RTRIM(a.qage)
	WHEN a.age_1 < 5 THEN '01'
	WHEN a.age_1 < 10 THEN '02'
	WHEN a.age_1 < 16 THEN '03'
	WHEN a.age_1 < 20 THEN '04'
	WHEN a.age_1 < 25 THEN '05'
	WHEN a.age_1 < 30 THEN '06'
	WHEN a.age_1 < 35 THEN '07'
	WHEN a.age_1 < 40 THEN '08'
	WHEN a.age_1 < 50 THEN '09'
	WHEN a.age_1 < 60 THEN '10'
	WHEN a.age_1 < 70 THEN '11'
	WHEN a.age_1 < 80 THEN '12'
	WHEN a.age_1 < 100 THEN '13'
	WHEN a.age_1 < 120 THEN '14'
	WHEN a.age_1 < 140 THEN '15'
	WHEN a.age_1 < 160 THEN '16'
	WHEN a.age_1 < 180 THEN '17'
	WHEN a.age_1 < 200 THEN '18'
	WHEN a.age_1 < 240 THEN '19'
	ELSE '20'
END;

/*
SELECT f.incref, f.npp, f.peupnr
FROM inv_exp_nm.g3foret f
LEFT JOIN ages a ON f.npp = a.npp
WHERE a.npp IS NULL
AND f.incref = 17;
-- il y a un point pour lequel le tarif d'âge n'a pas été possible => sans âge

INSERT INTO ages (npp, age_1, qage, incref) --> correction pour le point détecté ci-dessus
SELECT g3f.npp, 0, 'AA', g3f.incref
FROM inv_exp_nm.g3foret g3f
WHERE g3f.npp = '22-64-130-1-290T';
*/

-- Mise à jour des données d'âge dans G3FORET
UPDATE inv_exp_nm.g3foret f
SET cac = a.cac
, ess_age_1 = RTRIM(g.gmode)
, qage = RTRIM(a.qage)
, age_1 = a.age_1
FROM ages a
LEFT JOIN metaifn.aiunite ai ON ai.unite = 'ESPAR' AND ai.incref = a.incref AND ai.usite = 'P'
LEFT JOIN metaifn.abgroupe g ON g.gunite = 'ESS' AND g.mode = a.espar_age_1 AND g.unite = ai.dcunite
WHERE f.npp = a.npp;

/*
UPDATE inv_exp_nm.g3foret f
SET cac = '01'
WHERE f.npp = '22-64-130-1-290T'; --> mise à jour de cac (en fonction de âge_1) pour le point concerné 
*/

DROP TABLE vide_age;
DROP TABLE calcul_age;
DROP TABLE ages;
DROP TABLE ecart;


/************************************************************
*				CALCUL DES AGES (PEUPLERAIE)				*
*************************************************************/
-- création de la table recevant les âges
CREATE TEMPORARY TABLE ages (
    incref SMALLINT, 
    npp CHAR(16), 
    age_1 FLOAT, 
    espar_age_1 CHAR(4), 
    qage CHAR(3),
    cac CHAR(2),
    CONSTRAINT ages_pkey PRIMARY KEY (npp)
)
WITH (
    OIDS = FALSE
);

-- points momentanément déboisés (PEUPNR = 2) => âge = 0
INSERT INTO ages (npp, age_1, qage, incref)
SELECT npp, 0, 'MD', incref
FROM inv_exp_nm.p3point
WHERE peupnr = '2'
AND incref = 17;

-- points non recensables (PEUPNR = 1) => CAM
INSERT INTO ages (npp, age_1, espar_age_1, qage, incref)
SELECT p3p.npp, 
    CASE WHEN g3d.cam IS NOT NULL AND m1.etendue = 5 THEN m1.classe + (m1.etendue - 1) / 2
         WHEN g3d.cam IS NOT NULL AND m1.etendue > 5 THEN m1.classe + (m1.etendue + 1) / 2 
    END AS age
, '19' AS espar_age_1, 'CAM', p3p.incref
FROM inv_exp_nm.p3point p3p
INNER JOIN inv_exp_nm.p3agedom g3d ON p3p.npp = g3d.npp AND g3d.cam IS NOT NULL
INNER JOIN metaifn.abmode m1 ON m1.unite = 'CAM2' AND g3d.cam = m1.mode
WHERE p3p.peupnr = '1'
AND p3p.incref = 17;

-- points non recensables (PEUPNR = 1) sans CAM => absence d'âge (âge = 0)
INSERT INTO ages (npp, age_1, qage, incref)
SELECT p3p.npp, 0, 'AA', p3p.incref
FROM inv_exp_nm.p3point p3p
LEFT JOIN ages a ON p3p.npp = a.npp
WHERE p3p.peupnr = '1'
AND a.npp IS NULL
AND p3p.incref = 17;

-- points recensables (PEUPNR = 0)
-- on crée la table temporaire de tous les arbres avec leurs données d'âge
CREATE TEMPORARY TABLE calcul_age (
    npp CHAR(16), 
    numa SMALLINT, 
    a SMALLINT, 
    espar CHAR(4), 
    age SMALLINT, 
    typdom CHAR(1), 
    c13 REAL,
    incref SMALLINT,
    CONSTRAINT calcul_age_pkey PRIMARY KEY (npp, a)
)
WITH (
    OIDS = FALSE
);

INSERT INTO calcul_age
SELECT p3p.npp, g3d.numa, g3a.a, g3a.espar, g3d.age13, g3d.typdom, g3a.c13, p3p.incref
FROM inv_exp_nm.p3point p3p
INNER JOIN inv_exp_nm.e2point e2p ON p3p.npp = e2p.npp
INNER JOIN inv_exp_nm.p3agedom g3d ON p3p.npp = g3d.npp AND g3d.age13 IS NOT NULL
INNER JOIN inv_exp_nm.p3arbre g3a ON g3d.npp = g3a.npp AND g3d.a = g3a.a
WHERE p3p.peupnr = '0'
AND p3p.incref = 17
ORDER BY p3p.npp, g3a.a;

-- on calcul les âges pour TYPDOM 0
INSERT INTO ages (npp, age_1, espar_age_1, qage, incref)
SELECT npp, AVG(age), espar, 'MS', incref
FROM calcul_age
WHERE typdom = '0'
GROUP BY npp, espar, incref;

-- on corrige l'âge des arbres mesurés pour les ramener à des âges à la base (+5 ans pour le peuplier cultivé)
UPDATE ages
SET age_1 = age_1 + 5
WHERE qage = 'MS';

UPDATE ages a
SET cac =
CASE
    WHEN a.qage IN ('AA', 'MD') THEN RTRIM(a.qage)
    WHEN a.age_1 < 5 THEN '01'
    WHEN a.age_1 < 10 THEN '02'
    WHEN a.age_1 < 16 THEN '03'
    WHEN a.age_1 < 20 THEN '04'
    WHEN a.age_1 < 25 THEN '05'
    WHEN a.age_1 < 30 THEN '06'
    WHEN a.age_1 < 35 THEN '07'
    WHEN a.age_1 < 40 THEN '08'
    WHEN a.age_1 < 50 THEN '09'
    WHEN a.age_1 < 60 THEN '10'
    WHEN a.age_1 < 70 THEN '11'
    WHEN a.age_1 < 80 THEN '12'
    WHEN a.age_1 < 100 THEN '13'
    WHEN a.age_1 < 120 THEN '14'
    WHEN a.age_1 < 140 THEN '15'
    WHEN a.age_1 < 160 THEN '16'
    WHEN a.age_1 < 180 THEN '17'
    WHEN a.age_1 < 200 THEN '18'
    WHEN a.age_1 < 240 THEN '19'
    ELSE '20'
END;

-- Mise à jour des données d'âge dans P3POINT
UPDATE inv_exp_nm.p3point f
SET cac = a.cac
, ess_age_1 = RTRIM(g.gmode)
, qage = RTRIM(a.qage)
, age_1 = a.age_1
FROM ages a
LEFT JOIN metaifn.aiunite ai ON ai.unite = 'ESPAR' AND ai.incref = a.incref AND ai.usite = 'P'
LEFT JOIN metaifn.abgroupe g ON g.gunite = 'ESS' AND g.mode = a.espar_age_1 AND g.unite = ai.dcunite
WHERE f.npp = a.npp;

DROP TABLE calcul_age;
DROP TABLE ages;


-- calcul de DCA
UPDATE inv_exp_nm.g3foret f
SET dca = g.gmode
FROM metaifn.aiunite i
LEFT JOIN metaifn.abgroupe g ON i.dcunite = g.unite AND g.gunite = 'DCA'
WHERE f.incref = i.incref AND i.inv = 'T' AND i.unite = 'DC' AND f.dc = g.mode
AND f.incref = 17;

UPDATE inv_exp_nm.g3foret
SET dca = '0'
WHERE dca IS NULL
AND incref = 17;

UPDATE inv_exp_nm.p3point f
SET dca = g.gmode
FROM metaifn.aiunite i
LEFT JOIN metaifn.abgroupe g ON i.dcunite = g.unite AND g.gunite = 'DCA'
WHERE f.incref = i.incref AND i.inv = 'T' AND i.unite = 'DC' AND f.dc = g.mode
AND f.incref = 17;

UPDATE inv_exp_nm.p3point
SET dca = '0'
WHERE dca IS NULL
AND incref = 17;

-- SVER dans les peupleraies
UPDATE inv_exp_nm.p3point
SET sver = '6'
WHERE incref = 17
AND peupnr != '2';

UPDATE inv_exp_nm.p3point
SET sver = '0'
WHERE incref = 17
AND peupnr = '2';

-- calcul de CAMNR
UPDATE inv_exp_nm.g3foret f
SET camnr = a.cam
FROM inv_exp_nm.g3agedom a
WHERE f.npp = a.npp
AND a.cam IS NOT NULL
AND f.incref = 17;

UPDATE inv_exp_nm.p3point p
SET camnr = a.cam
FROM inv_exp_nm.p3agedom a
WHERE p.npp = a.npp
AND a.cam IS NOT NULL
AND p.incref = 17;

COMMIT;

VACUUM ANALYZE inv_exp_nm.g3foret;
VACUUM ANALYZE inv_exp_nm.p3point;
-- INCREFS 2 ET 3
-- export des infos de la base de production
-- psql -h prod.ifn.fr -U cduprez -d production
\copy (SELECT a.npp, a.a, a.ir1, a.ir2, a.ir3, a.ir4 FROM inv_prod.g3arbre a INNER JOIN inv_prod.e1point p USING (npp) WHERE p.incref = 2 UNION SELECT a.npp, a.a, a.ir1, a.ir2, a.ir3, a.ir4 FROM inv_prod.g3agedom a INNER JOIN inv_prod.e1point p USING (npp) WHERE p.incref = 3 AND COALESCE(a.ir1, a.ir2, a.ir3, a.ir4) IS NOT NULL) TO 'C:/Documents and Settings/cduprez/Mes documents/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir.txt' with delimiter ';' null as 'NULL'

-- import des infos en base d'exploitation
-- psql -h preexploitation.ifn.fr -U cduprez -d preexploitation
BEGIN;

CREATE TEMPORARY TABLE irs (
	npp CHAR(16),
	a SMALLINT,
	ir1 REAL,
	ir2 REAL,
	ir3 REAL,
	ir4 REAL,
	CONSTRAINT pkirs PRIMARY KEY (npp, a)
) WITHOUT OIDS;

\COPY irs FROM 'C:/Documents and Settings/cduprez/Mes documents/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir.txt' with delimiter ';' null as 'NULL'

ALTER TABLE inv_exp_nm.u_g3arbre
ADD COLUMN u_ai1 REAL,
ADD COLUMN u_ai2 REAL,
ADD COLUMN u_ai3 REAL,
ADD COLUMN u_ai4 REAL;

UPDATE inv_exp_nm.g3arbre
SET u_ai1 = ir1, u_ai2 = ir2, u_ai3 = ir3, u_ai4 = ir4
FROM irs
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.aquit = '1'
AND inv_exp_nm.g3arbre.npp = irs.npp
AND inv_exp_nm.g3arbre.a = irs.a;

DROP TABLE irs;

-- documentation MetaIFN des données
INSERT INTO metaifn.addonnee (donnee, unite, proprietaire, etendue, type, operation, codage, calcul, libelle, definition)
VALUES ('U_AI1', 'm', 'COLIN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 1 AN', 'ACCROISSEMENT RADIAL SUR 1 AN')
, ('U_AI2', 'm', 'COLIN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 2 ANS', 'ACCROISSEMENT RADIAL SUR 2 ANS')
, ('U_AI3', 'm', 'COLIN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 3 ANS', 'ACCROISSEMENT RADIAL SUR 3 ANS')
, ('U_AI4', 'm', 'COLIN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 4 ANS', 'ACCROISSEMENT RADIAL SUR 4 ANS');

INSERT INTO metaifn.afchamp (format, donnee, type, famille, position, classe, etendue, domdatein, domdateout, dtype)
VALUES ('TG3ARBRE', 'U_AI1', 'COLONNE', 'INV_EXP_NM', 200, 2000, 4, metaifn.aifduscii('P', 'F', '5', 2, 'T'), metaifn.aifduscii('P', 'F', '5', 3, 'T'), 'real')
, ('TG3ARBRE', 'U_AI2', 'COLONNE', 'INV_EXP_NM', 201, 2004, 4, metaifn.aifduscii('P', 'F', '5', 2, 'T'), metaifn.aifduscii('P', 'F', '5', 3, 'T'), 'real')
, ('TG3ARBRE', 'U_AI3', 'COLONNE', 'INV_EXP_NM', 202, 2008, 4, metaifn.aifduscii('P', 'F', '5', 2, 'T'), metaifn.aifduscii('P', 'F', '5', 3, 'T'), 'real')
, ('TG3ARBRE', 'U_AI4', 'COLONNE', 'INV_EXP_NM', 203, 2012, 4, metaifn.aifduscii('P', 'F', '5', 2, 'T'), metaifn.aifduscii('P', 'F', '5', 3, 'T'), 'real');

COMMIT;


-- INCREF 4
-- export des infos de la base de production
-- psql -h prod.ifn.fr -U cduprez -d production
\copy (SELECT a.npp, a.a, a.ir1, a.ir2, a.ir3, a.ir4 FROM inv_prod.g3agedom a INNER JOIN inv_prod.e1point p USING (npp) WHERE p.incref = 4 AND COALESCE(a.ir1, a.ir2, a.ir3, a.ir4) IS NOT NULL) TO 'C:/Documents and Settings/cduprez/Mes documents/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir4.txt' with delimiter ';' null as 'NULL'

-- import des infos en base d'exploitation
-- psql -h preexploitation.ifn.fr -U cduprez -d preexploitation
BEGIN;

CREATE TEMPORARY TABLE irs (
	npp CHAR(16),
	a SMALLINT,
	ir1 REAL,
	ir2 REAL,
	ir3 REAL,
	ir4 REAL,
	CONSTRAINT pkirs PRIMARY KEY (npp, a)
) WITHOUT OIDS;

\COPY irs FROM 'C:/Documents and Settings/cduprez/Mes documents/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir4.txt' with delimiter ';' null as 'NULL'

UPDATE inv_exp_nm.g3arbre
SET u_ai1 = ir1, u_ai2 = ir2, u_ai3 = ir3, u_ai4 = ir4
FROM irs
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.aquit = '1'
AND inv_exp_nm.g3arbre.npp = irs.npp
AND inv_exp_nm.g3arbre.a = irs.a;

DROP TABLE irs;

-- documentation MetaIFN des données
UPDATE metaifn.afchamp
SET domdateout = metaifn.aifduscii('P', 'F', '5', 4, 'T')
WHERE famille = 'INV_EXP_NM'
AND format = 'TG3ARBRE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');

COMMIT;

-- INCREFS 5 à 7
-- export des infos de la base de production
-- psql -h prod.ign.fr -U **CDuprez -d production
\copy (SELECT a.npp, a.a, a.ir1, a.ir2, a.ir3, a.ir4 FROM inv_prod.g3agedom a INNER JOIN inv_prod.e1point p USING (npp) WHERE p.incref IN (5, 6, 7) AND COALESCE(a.ir1, a.ir2, a.ir3, a.ir4) IS NOT NULL) TO 'D:/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir5_7.txt' with delimiter ';' null as 'NULL'

-- import des infos en base d'exploitation
-- psql -h exploitation.ign.fr -U **CDuprez -d exploitation
BEGIN;

CREATE TEMPORARY TABLE irs (
	npp CHAR(16),
	a SMALLINT,
	ir1 REAL,
	ir2 REAL,
	ir3 REAL,
	ir4 REAL,
	CONSTRAINT pkirs PRIMARY KEY (npp, a)
) WITHOUT OIDS;

\COPY irs FROM 'D:/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir.txt' with delimiter ';' null as 'NULL'
\COPY irs FROM 'D:/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir4.txt' with delimiter ';' null as 'NULL'
\COPY irs FROM 'D:/Inventaire/Eclipse/workspace36/SQL/inv_exp_nm/Utilisateurs/COLIN/ir5_7.txt' with delimiter ';' null as 'NULL'

UPDATE inv_exp_nm.u_g3arbre
SET u_ai1 = ir1, u_ai2 = ir2, u_ai3 = ir3, u_ai4 = ir4
FROM irs
WHERE inv_exp_nm.u_g3arbre.npp = irs.npp
AND inv_exp_nm.u_g3arbre.a = irs.a;

DROP TABLE irs;

-- documentation MetaIFN des données
UPDATE metaifn.afchamp
SET calcout = 7, validout = 7
WHERE famille = 'INV_EXP_NM'
AND format = 'U_G3ARBRE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');

COMMIT;

-- INCREFs 8 à 10 (via tables étrangères depuis la base de production)
BEGIN;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1, u_ai2 = a.ir2, u_ai3 = a.ir3, u_ai4 = a.ir4
FROM inv_prod.g3agedom a
WHERE a.npp = ua.npp
AND a.a = ua.a
AND ua.incref >= 8;

-- documentation MetaIFN des données
UPDATE metaifn.afchamp
SET calcout = 10, validout = 10
WHERE famille = 'INV_EXP_NM'
AND format = 'U_G3ARBRE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');

/*
SELECT incref, count(*) AS total, count(u_ai1) AS ir1, count(u_ai2) AS ir2, count(u_ai3) AS ir3, count(u_ai4) AS ir4
FROM inv_exp_nm.u_g3arbre
GROUP BY incref
ORDER BY incref;
*/

COMMIT;


-- après archivage, demande de remettre toutes les données en place !
-- faire et défaire, c'est toujours travailler !
BEGIN;

ALTER TABLE inv_exp_nm.u_g3arbre
    ADD COLUMN u_ai1 REAL,
    ADD COLUMN u_ai2 REAL,
    ADD COLUMN u_ai3 REAL,
    ADD COLUMN u_ai4 REAL;

COMMIT;

-- chargement depuis la base de production, après avoir rechargé les tables étrangères.
BEGIN;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1, u_ai2 = a.ir2, u_ai3 = a.ir3, u_ai4 = a.ir4
FROM inv_prod.g3agedom a
WHERE a.npp = ua.npp
AND a.a = ua.a;

-- attention, à partir de l'incref 11, il faut prendre les données irx_1_10mm !
UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1_1_10mm, u_ai2 = a.ir2_1_10mm, u_ai3 = a.ir3_1_10mm, u_ai4 = a.ir4_1_10mm
FROM inv_prod.g3agedom a
WHERE a.npp = ua.npp
AND a.a = ua.a
AND ua.incref >= 11;

/*
SELECT incref, COUNT(u_ai1)
FROM inv_exp_nm.u_g3arbre
GROUP BY incref
ORDER BY incref desc;
*/

COMMIT;

-- documentation MetaIFN des données (en base d'exploitation)
BEGIN;

SELECT * FROM metaifn.ajoutchamp('U_AI1', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_AI2', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_AI3', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_AI4', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 12, validin = 0, validout = 12
WHERE famille = 'INV_EXP_NM'
AND donnee ~~* 'U_AI_';

COMMIT;

-- remise des IR de 2007 qui avaient disparu, à partir de la nouvelle base de production
CREATE TEMPORARY TABLE accroiss AS 
SELECT p.npp, a1.a
, ac1.irn_1_10_mm / 10000.0 AS ir1
, ac2.irn_1_10_mm / 10000.0 AS ir2
, ac3.irn_1_10_mm / 10000.0 AS ir3
, ac4.irn_1_10_mm / 10000.0 AS ir4
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN arbre_m1 a1 USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN reconnaissance r USING (id_ech, id_point)
LEFT JOIN accroissement ac1 ON a1.id_ech = ac1.id_ech AND a1.id_point = ac1.id_point AND a1.a = ac1.a AND ac1.nir = 1
LEFT JOIN accroissement ac2 ON a1.id_ech = ac2.id_ech AND a1.id_point = ac2.id_point AND a1.a = ac2.a AND ac2.nir = 2
LEFT JOIN accroissement ac3 ON a1.id_ech = ac3.id_ech AND a1.id_point = ac3.id_point AND a1.a = ac3.a AND ac3.nir = 3
LEFT JOIN accroissement ac4 ON a1.id_ech = ac4.id_ech AND a1.id_point = ac4.id_point AND a1.a = ac4.a AND ac4.nir = 4
WHERE r.csa != '5'
AND c.millesime = 2021
AND COALESCE(ac1.a, ac2.a, ac3.a, ac4.a) IS NOT NULL;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1
, u_ai2 = a.ir2
, u_ai3 = a.ir3
, u_ai4 = a.ir4
FROM accroiss a
WHERE ua.npp = a.npp
AND ua.a = a.a;

DROP TABLE accroiss;

-- mise à jour sur campagnes 2018 et 2019
WITH accroiss AS (
    SELECT p.npp, a1.a
    , ac1.irn_1_10_mm / 10000.0 AS ir1
    , ac2.irn_1_10_mm / 10000.0 AS ir2
    , ac3.irn_1_10_mm / 10000.0 AS ir3
    , ac4.irn_1_10_mm / 10000.0 AS ir4
    FROM campagne c
    INNER JOIN echantillon e USING (id_campagne)
    INNER JOIN arbre_m1 a1 USING (id_ech)
    INNER JOIN point p USING (id_point)
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN accroissement ac1 ON a1.id_ech = ac1.id_ech AND a1.id_point = ac1.id_point AND a1.a = ac1.a AND ac1.nir = 1
    LEFT JOIN accroissement ac2 ON a1.id_ech = ac2.id_ech AND a1.id_point = ac2.id_point AND a1.a = ac2.a AND ac2.nir = 2
    LEFT JOIN accroissement ac3 ON a1.id_ech = ac3.id_ech AND a1.id_point = ac3.id_point AND a1.a = ac3.a AND ac3.nir = 3
    LEFT JOIN accroissement ac4 ON a1.id_ech = ac4.id_ech AND a1.id_point = ac4.id_point AND a1.a = ac4.a AND ac4.nir = 4
    WHERE r.csa != '5'
    AND c.millesime IN (2018, 2019)
    AND COALESCE(ac1.a, ac2.a, ac3.a, ac4.a) IS NOT NULL
)
UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1
, u_ai2 = a.ir2
, u_ai3 = a.ir3
, u_ai4 = a.ir4
FROM accroiss a
WHERE ua.npp = a.npp
AND ua.a = a.a;

-- correction des IR de 2016 et 2017 (passage au 1/10è de mm non répercuté)
UPDATE inv_exp_nm.u_g3arbre
SET u_ai1 = u_ai1 / 10000.0
, u_ai2 = u_ai2 / 10000.0
, u_ai3 = u_ai3 / 10000.0
, u_ai4 = u_ai4 / 10000.0
WHERE incref IN (11, 12);

SELECT incref, COUNT(u_ai1)
FROM inv_exp_nm.u_g3arbre
GROUP BY incref
ORDER BY incref;


-- mise à jour sur campagne 2021

	-- dans inv-dev on exporte cette selection dans un fichier accroiss.csv
DROP TABLE public.accroiss;

SELECT p.npp, a1.a, ac1.irn_1_10_mm / 10000.0 AS ir1, ac2.irn_1_10_mm / 10000.0 AS ir2
    , ac3.irn_1_10_mm / 10000.0 AS ir3
    , ac4.irn_1_10_mm / 10000.0 AS ir4
    FROM campagne c
    INNER JOIN echantillon e USING (id_campagne)
    INNER JOIN arbre_m1 a1 USING (id_ech)
    INNER JOIN point p USING (id_point)
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN accroissement ac1 ON a1.id_ech = ac1.id_ech AND a1.id_point = ac1.id_point AND a1.a = ac1.a AND ac1.nir = 1
    LEFT JOIN accroissement ac2 ON a1.id_ech = ac2.id_ech AND a1.id_point = ac2.id_point AND a1.a = ac2.a AND ac2.nir = 2
    LEFT JOIN accroissement ac3 ON a1.id_ech = ac3.id_ech AND a1.id_point = ac3.id_point AND a1.a = ac3.a AND ac3.nir = 3
    LEFT JOIN accroissement ac4 ON a1.id_ech = ac4.id_ech AND a1.id_point = ac4.id_point AND a1.a = ac4.a AND ac4.nir = 4
    WHERE r.csa != '5'
    AND c.millesime = 2021 
    AND COALESCE(ac1.a, ac2.a, ac3.a, ac4.a) IS NOT NULL;

	-- dans test-inv-exp : on crée une table temporaire accroiss puis on y copie le fichier accroiss.csv
CREATE TEMPORARY TABLE public.accroiss
(
	npp CHAR(16),
	a SMALLINT,
	ir1 REAL,
	ir2 REAL,
	ir3 REAL,
	ir4 REAL,
	CONSTRAINT pkaccroiss PRIMARY KEY (npp, a)
) WITHOUT OIDS;

	--depuis un psql local
\COPY public.accroiss FROM '/home/lhaugomat/Documents/EXPORTS_DIVERS/accroiss.csv' WITH CSV HEADER DELIMITER ';' NULL AS 'NULL'

   
UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1
, u_ai2 = a.ir2
, u_ai3 = a.ir3
, u_ai4 = a.ir4
FROM accroiss a
WHERE ua.npp = a.npp
AND ua.a = a.a;


-- mise à jour sur campagne 2023

	-- dans inv-dev on exporte cette selection dans un fichier accroiss.csv
DROP TABLE public.accroiss;

\COPY (SELECT p.npp, a1.a, ac1.irn_1_10_mm / 10000.0 AS ir1, ac2.irn_1_10_mm / 10000.0 AS ir2
    , ac3.irn_1_10_mm / 10000.0 AS ir3
    , ac4.irn_1_10_mm / 10000.0 AS ir4
    FROM campagne c
    INNER JOIN echantillon e USING (id_campagne)
    INNER JOIN arbre_m1 a1 USING (id_ech)
    INNER JOIN point p USING (id_point)
    INNER JOIN reconnaissance r USING (id_ech, id_point)
    LEFT JOIN accroissement ac1 ON a1.id_ech = ac1.id_ech AND a1.id_point = ac1.id_point AND a1.a = ac1.a AND ac1.nir = 1
    LEFT JOIN accroissement ac2 ON a1.id_ech = ac2.id_ech AND a1.id_point = ac2.id_point AND a1.a = ac2.a AND ac2.nir = 2
    LEFT JOIN accroissement ac3 ON a1.id_ech = ac3.id_ech AND a1.id_point = ac3.id_point AND a1.a = ac3.a AND ac3.nir = 3
    LEFT JOIN accroissement ac4 ON a1.id_ech = ac4.id_ech AND a1.id_point = ac4.id_point AND a1.a = ac4.a AND ac4.nir = 4
    WHERE r.csa != '5'
    AND c.millesime = 2023
    AND COALESCE(ac1.a, ac2.a, ac3.a, ac4.a) IS NOT NULL) TO '/home/lhaugomat/Documents/EXPORTS/accroiss_2023.csv' WITH CSV HEADER DELIMITER ';' NULL AS '';

	-- dans test-inv-exp : on crée une table temporaire accroiss puis on y copie le fichier accroiss.csv
CREATE UNLOGGED TABLE public.accroiss
(
	npp CHAR(16),
	a SMALLINT,
	ir1 REAL,
	ir2 REAL,
	ir3 REAL,
	ir4 REAL,
	CONSTRAINT pkaccroiss PRIMARY KEY (npp, a)
) WITHOUT OIDS;

	--depuis un psql local
\COPY public.accroiss FROM '/home/lhaugomat/Documents/EXPORTS/accroiss_2023.csv' WITH CSV HEADER DELIMITER ';' NULL AS 'NULL';

   
UPDATE inv_exp_nm.u_g3arbre ua
SET u_ai1 = a.ir1
, u_ai2 = a.ir2
, u_ai3 = a.ir3
, u_ai4 = a.ir4
FROM accroiss a
WHERE ua.npp = a.npp
AND ua.a = a.a;

-- désarchivage
UPDATE metaifn.afchamp
SET format = 'U_G3ARBRE', famille = 'INV_EXP_NM' 
WHERE famille = 'ARCHIVE'
AND format = 'ARCHIVE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');


-- documentation MetaIFN des données
UPDATE metaifn.afchamp
SET calcout = 18, validout = 18
WHERE famille = 'INV_EXP_NM'
AND format = 'U_G3ARBRE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');



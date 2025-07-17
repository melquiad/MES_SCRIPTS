

------------ Finalement on fait une recopie brutale des U_AIx dans les AIx pour les incref <= 18 --------

UPDATE inv_exp_nm.g3arbre ua
SET ai1 = a.u_ai1
, ai2 = a.u_ai2
, ai3 = a.u_ai3
, ai4 = a.u_ai4
FROM inv_exp_nm.u_g3arbre a
WHERE ua.npp = a.npp
AND ua.a = a.a
AND ua.incref <= 18;

-- documentation metaifn
UPDATE metaifn.afchamp
SET calcin = 2, calcout = 19, validin = 4, validout = 18, defin = 2, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND format = 'TG3ARBRE'
AND donnee IN ('AI1', 'AI2', 'AI3', 'AI4');

---------------------------------------
-- création des colonnes dans g3arbre
ALTER TABLE inv_exp_nm.g3arbre
ADD COLUMN ai1 REAL,
ADD COLUMN ai2 REAL,
ADD COLUMN ai3 REAL,
ADD COLUMN ai4 REAL;

-- documentation MetaIFN des données
INSERT INTO metaifn.addonnee (donnee, unite, proprietaire, etendue, type, operation, codage, calcul, libelle, definition)
VALUES ('AI1', 'm', 'IFN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 1 AN', 'ACCROISSEMENT RADIAL SUR 1 AN')
, ('AI2', 'm', 'IFN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 2 ANS', 'ACCROISSEMENT RADIAL SUR 2 ANS')
, ('AI3', 'm', 'IFN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 3 ANS', 'ACCROISSEMENT RADIAL SUR 3 ANS')
, ('AI4', 'm', 'IFN', 0, 'real', 'CC', 1::BIT, 1::BIT, 'ACCROISSEMENT RADIAL SUR 4 ANS', 'ACCROISSEMENT RADIAL SUR 4 ANS');

SELECT * FROM metaifn.ajoutchamp('AI1', 'G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('AI2', 'G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('AI3', 'G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('AI4', 'G3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'float4', 4);


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
    AND c.millesime BETWEEN 2009 AND 2024
    AND COALESCE(ac1.a, ac2.a, ac3.a, ac4.a) IS NOT NULL) TO '/home/lhaugomat/Documents/ECHANGES/EXPORTS_DIVERS/accroiss.csv' WITH CSV HEADER DELIMITER ';' NULL AS '';

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
\COPY public.accroiss FROM '/home/lhaugomat/Documents/ECHANGES/EXPORTS_DIVERS/accroiss.csv' WITH CSV HEADER DELIMITER ';' NULL AS 'NULL';

   
UPDATE inv_exp_nm.g3arbre ua
SET ai1 = a.ir1
, ai2 = a.ir2
, ai3 = a.ir3
, ai4 = a.ir4
FROM public.accroiss a
WHERE ua.npp = a.npp
AND ua.a = a.a;

/*-- désarchivage
UPDATE metaifn.afchamp
SET format = 'TG3ARBRE', famille = 'INV_EXP_NM' 
WHERE famille = 'ARCHIVE'
AND format = 'ARCHIVE'
AND donnee IN ('AI1', 'AI2', 'AI3', 'AI4');
*/

-- documentation MetaIFN des données pour 2024

UPDATE metaifn.afchamp
SET calcin = 2, calcout = 19, validin = 4, validout = 18, defin = 2, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND format = 'TG3ARBRE'
AND donnee IN ('AI1', 'AI2', 'AI3', 'AI4');

UPDATE metaifn.addonnee
SET libelle = 'Accroissement radial sur 1 an'
, definition = 'Accroissement radial sur 1 an'
WHERE donnee = 'AI1';

UPDATE metaifn.addonnee
SET libelle = 'Accroissement radial sur 2 ans'
, definition = 'Accroissement radial sur 2 ans'
WHERE donnee = 'AI2';

UPDATE metaifn.addonnee
SET libelle = 'Accroissement radial sur 3 ans'
, definition = 'Accroissement radial sur 3 ans'
WHERE donnee = 'AI3';

UPDATE metaifn.addonnee
SET libelle = 'Accroissement radial sur 4 ans'
, definition = 'Accroissement radial sur 4 ans'
WHERE donnee = 'AI4';






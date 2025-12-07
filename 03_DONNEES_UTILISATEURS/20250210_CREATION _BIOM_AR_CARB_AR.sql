/*
UPDATE metaifn.addonnee
SET unite = 'UTMS' WHERE donnee = 'BIOM_AR' AND unite = 'MMS';

UPDATE metaifn.addonnee
SET unite = 'UTC' WHERE donnee = 'CARB_AR' AND unite = 'MMS';
*/

-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_BIOM_AR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_BIOM_AR';

DELETE FROM metaifn.afchamp WHERE donnee = 'U_CARB_AR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_CARB_AR';
--------------------------------------------------------------------------------------------

-- On crée les champs dans g3arbre et p3arbre pour BIOM_AR
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN biom_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN biom_ar float(8);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN biom_ar float(8);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN biom_ar float(8);

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('UTMS', 'IFN', 'CONTINU', 'Tonne de matière sèche', 'Tonne de matière sèche');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('BIOM_AR', NULL, 'UTMS', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Biomasse aerienne et racinaire', 'Biomasse aerienne et racinaire');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('BIOM_AR'::varchar, 'G3ARBRE'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 0, 18, 'float8'::varchar, 1::int4);
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
---------------------------------------------------------------------------------------------------

-- On crée les champs dans g3arbre et p3arbre pour CARB_AR
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN carb_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN carb_ar float(8);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN carb_ar float(8);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN carb_ar float(8);

--- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'CARB_AR'), ('IFN', 'BIOM_AR');

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('UTC', 'IFN', 'CONTINU', 'Tonne de carbone', 'Tonne de carbone');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('CARB_AR', NULL, 'UTC', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Stock de carbone aerien et racinaire', 'Stock de carbone aerien et racinaire');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('CARB_AR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('CARB_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
-----------------------------------------------------------------------------------------------------

-- Copie de la donnée à partir de U_BIOM_AR et U_CARB_AR pour les incref < 18

UPDATE inv_exp_nm.g3arbre g
SET biom_ar = ug.u_biom_ar
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET biom_ar = up.u_biom_ar
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;

UPDATE inv_exp_nm.g3arbre g
SET carb_ar = ug.u_carb_ar
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET carb_ar = up.u_carb_ar
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;

/*-- Contrôles
SELECT incref, count(biom_ar)
FROM inv_exp_nm.g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(biom_ar)
FROM inv_exp_nm.p3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(carb_ar)
FROM inv_exp_nm.g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(carb_ar)
FROM inv_exp_nm.p3arbre
GROUP BY incref
ORDER BY incref DESC;
*/

-- mise à jour de BIOM_AR et CARB_AR pour les incref 18 et 19
BEGIN



CREATE TABLE public.facteurs (
    ess CHAR(2),
    essence VARCHAR(100),
    densite REAL,
    thf REAL,
    gp1 VARCHAR(20),
    gp VARCHAR(20),
    thh REAL,
    fexp REAL,
    CONSTRAINT facteurs_pkey PRIMARY KEY (ess)
)
WITH (
  OIDS=FALSE
);


\COPY public.facteurs FROM '~/Documents/ECHANGES/MES_SCRIPTS/03_DONNEES_UTILISATEURS/facteurs.csv' WITH DELIMITER ';' NULL AS ''


WITH t AS (
			SELECT ua.npp, ua.a, ua.v0 * f.fexp * f.densite AS biom_ar, ua.v0 * f.fexp * f.densite * 0.475 AS carb_ar
			FROM inv_exp_nm.g3arbre ua
			INNER JOIN public.facteurs f ON ua.ess = f.ess
			WHERE ua.incref IN (18, 19)
			)
UPDATE inv_exp_nm.g3arbre a
SET biom_ar = t.biom_ar, carb_ar = t.carb_ar
FROM t
WHERE t.npp = a.npp AND t.a = a.a;


WITH t AS (
			SELECT pa.npp, pa.a, pa.v0 * f.fexp * f.densite AS biom_ar, pa.v0 * f.fexp * f.densite * 0.475 AS carb_ar
			FROM inv_exp_nm.p3arbre pa
			INNER JOIN public.facteurs f ON pa.ess = f.ess
			WHERE pa.incref IN (18, 19)
			)
UPDATE inv_exp_nm.p3arbre p
SET biom_ar = t.biom_ar, carb_ar = t.carb_ar
FROM t
WHERE t.npp = p.npp AND t.a = p.a;

DROP TABLE public.facteurs;


UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 19, validin = 0, validout = 19
WHERE famille = 'INV_EXP_NM' AND donnee IN ('BIOM_AR', 'CARB_AR');


COMMIT;

-- contrôles
SELECT g.incref, g.npp, g.biom_ar, g.carb_ar
FROM inv_exp_nm.g3arbre g
WHERE incref IN (18, 19)
AND g.biom_ar IS NULL 
AND g.carb_ar IS NULL;

SELECT p.incref, p.npp, p.biom_ar, p.carb_ar
FROM inv_exp_nm.p3arbre p
WHERE incref IN (18, 19)
AND p.biom_ar IS NULL 
AND p.carb_ar IS NULL;

/*-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_biom_ar;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_biom_ar;
*/
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--- MAJ incref 19

BEGIN;

DROP TABLE IF EXISTS public.facteurs;

CREATE TABLE public.facteurs (
    ess CHAR(2),
    essence VARCHAR(100),
    densite REAL,
    thf REAL,
    gp1 VARCHAR(20),
    gp VARCHAR(20),
    thh REAL,
    fexp REAL,
    CONSTRAINT facteurs_pkey PRIMARY KEY (ess)
)
WITH (
  OIDS=FALSE
);

\COPY facteurs FROM '~/Documents/ECHANGES/MES_SCRIPTS/03_DONNEES_UTILISATEURS/facteurs.csv' WITH DELIMITER ';' NULL AS ''

UPDATE inv_exp_nm.u_g3arbre ua
 SET u_biom_ar = u_v0 * f.fexp * f.densite
, u_carb_ar = u_v0 * f.fexp * f.densite * 0.475
 FROM facteurs f
 INNER JOIN inv_exp_nm.g3arbre a ON a.ess = f.ess
 WHERE a.npp = ua.npp AND a.a = ua.a
 AND ua.incref = 19;

UPDATE inv_exp_nm.u_p3arbre ua
 SET u_biom_ar = u_v0 * f.fexp * f.densite
, u_carb_ar = u_v0 * f.fexp * f.densite * 0.475
 FROM facteurs f
 INNER JOIN inv_exp_nm.p3arbre a ON a.ess = f.ess
 WHERE a.npp = ua.npp AND a.a = ua.a
 AND ua.incref = 19;

DROP TABLE public.facteurs;

UPDATE metaifn.afchamp
 SET calcout = 19, validout = 19
 WHERE famille = 'INV_EXP_NM' AND donnee IN ('U_BIOM_AR', 'U_CARB_AR');

UPDATE metaifn.afchamp
 SET calcout = 19, validout = 19
 WHERE famille = 'INV_EXP_NM' AND donnee IN ('U_V0');


COMMIT;




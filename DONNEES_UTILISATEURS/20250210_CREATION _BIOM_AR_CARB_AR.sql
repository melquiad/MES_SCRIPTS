
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_BIOM_AR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_BIOM_AR';

DELETE FROM metaifn.afchamp WHERE donnee = 'U_CARB_AR';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_CARB_AR';
--------------------------------------------------------------------------------------------

-- On crée les champs dans g3arbre et p3arbre pour BIOM_AR
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN biom_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN biom_ar float(8);

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('MMS', 'IFN', 'CONTINU', 'Masse de matière sèche', 'Masse de matière sèche');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('BIOM_AR', NULL, 'MMS', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Biomasse aerienne et racinaire', 'Biomasse aerienne et racinaire');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('BIOM_AR', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
---------------------------------------------------------------------------------------------------

-- On crée les champs dans g3arbre et p3arbre pour CARB_AR
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN carb_ar float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN carb_ar float(8);

-- Documentation metaifn
-- ajout unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('NTC', 'IFN', 'CONTINU', 'Tonne de carbone', 'Tonne de carbone');

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('CARB_AR', NULL, 'MMS', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Stock de carbone aerien et racinaire', 'Stock de carbone aerien et racinaire');

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


-- mise à jour de BIOM_AR et CARB_AR pour l'incref 18

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


\COPY public.facteurs FROM '~/Documents/ECHANGES/MES_SCRIPTS/DONNEES_UTILISATEURS/facteurs.csv' WITH DELIMITER ';' NULL AS ''


WITH t AS (
			SELECT ua.npp, ua.a, ua.v0 * f.fexp * f.densite AS biom_ar, ua.v0 * f.fexp * f.densite * 0.475 AS carb_ar
			FROM inv_exp_nm.g3arbre ua
			INNER JOIN public.facteurs f ON ua.ess = f.ess
			WHERE ua.incref = 18
			)
UPDATE inv_exp_nm.g3arbre a
SET biom_ar = t.biom_ar, carb_ar = t.carb_ar
FROM t
WHERE t.npp = a.npp AND t.a = a.a;


WITH t AS (
			SELECT pa.npp, pa.a, pa.v0 * f.fexp * f.densite AS biom_ar, pa.v0 * f.fexp * f.densite * 0.475 AS carb_ar
			FROM inv_exp_nm.p3arbre pa
			INNER JOIN public.facteurs f ON pa.ess = f.ess
			WHERE pa.incref = 18
			)
UPDATE inv_exp_nm.p3arbre p
SET biom_ar = t.biom_ar, carb_ar = t.carb_ar
FROM t
WHERE t.npp = a.npp AND t.a = a.a;

DROP TABLE public.facteurs;


UPDATE metaifn.afchamp
 SET calcout = 18, validout = 18
 WHERE famille = 'INV_EXP_NM' AND donnee IN ('BIOM_AR', 'CARB_AR');

UPDATE metaifn.afchamp
 SET calcout = 18, validout = 18
 WHERE famille = 'INV_EXP_NM' AND donnee IN ('V0');

COMMIT;



/*-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_biom_ar;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_biom_ar;
*/

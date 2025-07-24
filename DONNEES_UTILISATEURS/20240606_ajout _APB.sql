
-- partie unite
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('APB', 'AUTRE', 'NOMINAL', 'Arrêtés de protection de biotope', 'Point d inventaire dans un arrêté de protection de biotope');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('APB', '0', 1, 1, 1, 'HORS arrêté de protection de biotope', 'Point d inventaire situé HORS arrêté de protection de biotope')
, ('APB', '1', 2, 2, 1, 'Dans arrêté de protection de biotope', 'Point d inventaire situé dans un arrêté de protection de biotope')

DELETE FROM metaifn.afchamp WHERE donnee = 'U_APB';
DELETE FROM metaifn.addonnee WHERE unite = 'U_APB';
DELETE FROM metaifn.abmode WHERE unite = 'U_APB';
DELETE FROM metaifn.abunite WHERE unite = 'U_APB';

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('APB', NULL, 'APB', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Arrêtés de protection de biotope$$, $$Point d inventaire dans un arrêté de protection de biotope$$);

-- partie champ
SELECT * FROM metaifn.ajoutchamp('APB', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 18, 'bpchar', 1);
--              ou
SELECT * FROM metaifn.ajoutchamp('APB'::varchar, 'E2POINT'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 1, 18, 'bpchar'::varchar, 1::int4);

/*
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 13, validin = 0, validout = 13
WHERE famille = 'INV_EXP_NM'
AND donnee = 'APB';

--controle
select *
FROM metaifn.afchamp
where famille='INV_EXP_NM'
AND format='TE2POINT'
ORDER BY position desc;
*/

-- creation du champ dans la table
ALTER TABLE inv_exp_nm.e2point ADD COLUMN APB CHAR(1);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN APB CHAR(1);
		
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'APB');

-- Calcul de la donnée
BEGIN;

UPDATE inv_exp_nm.e2point p
SET apb = c.u_apb
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defin = 0, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'APB';

COMMIT;

-- nombre de points dans APB par incref
SELECT count(apb), incref
FROM inv_exp_nm.e2point
WHERE apb = '1'
GROUP BY incref, apb
ORDER BY incref DESC;


-- Mise à jour campagne 2023 (incref 18)
WITH croise AS (
SELECT c1.npp
,	CASE WHEN i.gid IS NOT NULL THEN '1'
	ELSE '0'
	END AS dedans
FROM inv_exp_nm.e1coord c1
LEFT JOIN sig_inpn.apb_2024 i
ON ST_Intersects(c1.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p
SET apb = c.dedans
FROM croise c
WHERE p.npp = c.npp AND p.incref = 18;


UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defin = 0, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'APB';

-- modification de l'unite de APB
UPDATE metaifn.addonnee SET unite = 'IN_ZONE' WHERE donnee = 'APB' AND unite = 'APB';




